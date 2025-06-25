
---@param m MarioState
---@param block Object
local function mario_is_within_block(m, block)
    -- ! Use a better checking system as this does not at all account for angles
    return m.pos.x > block.oPosX - (100 * block.oScaleX) and m.pos.x < block.oPosX + (100 * block.oScaleX) and
            m.pos.y > block.oPosY - (100 * block.oScaleY) and m.pos.y < block.oPosY + (100 * block.oScaleY) and
            m.pos.z > block.oPosZ - (100 * block.oScaleZ) and m.pos.z < block.oPosZ + (100 * block.oScaleZ)
end

local actions_can_bonk_can_wallkick = {
    [ACT_JUMP] = true,
    [ACT_HOLD_JUMP] = true,
    [ACT_DOUBLE_JUMP] = true,
    [ACT_TRIPLE_JUMP] = true,
    [ACT_SIDE_FLIP] = true,
    [ACT_BACKFLIP] = true,
    [ACT_LONG_JUMP] = true,
    [ACT_WALL_KICK_AIR] = true,
    [ACT_TOP_OF_POLE_JUMP] = true,
    [ACT_FREEFALL] = true,
}

local bounce_landing_actions = {
    [ACT_JUMP_LAND] = true,
    [ACT_FREEFALL_LAND] = true,
    [ACT_DOUBLE_JUMP_LAND] = true,
    [ACT_SIDE_FLIP_LAND] = true,
    [ACT_HOLD_JUMP_LAND] = true,
    [ACT_HOLD_FREEFALL_LAND] = true,
    [ACT_QUICKSAND_JUMP_LAND] = true,
    [ACT_HOLD_QUICKSAND_JUMP_LAND] = true,
    [ACT_TRIPLE_JUMP_LAND] = true,
    [ACT_LONG_JUMP_LAND] = true,
    [ACT_BACKFLIP_LAND] = true,
    [ACT_DIVE_SLIDE] = true,
    [ACT_SLIDE_KICK_SLIDE] = true,
    [ACT_STOMACH_SLIDE] = true,
    [ACT_BUTT_SLIDE] = true,
    [ACT_FLYING] = true
}

local bounce_bonk_actions = {
    [ACT_AIR_HIT_WALL] = true,
    [ACT_SOFT_BONK] = true,
    [ACT_BACKWARD_AIR_KB] = true,
    [ACT_HARD_BACKWARD_AIR_KB] = true,
    [ACT_FORWARD_AIR_KB] = true,
    [ACT_HARD_FORWARD_AIR_KB] = true,
    [ACT_BACKWARD_GROUND_KB] = true,
    [ACT_HARD_BACKWARD_GROUND_KB] = true,
    [ACT_SOFT_BACKWARD_GROUND_KB] = true,
    [ACT_FORWARD_GROUND_KB] = true,
    [ACT_HARD_FORWARD_GROUND_KB] = true,
    [ACT_SOFT_FORWARD_GROUND_KB] = true,
    [ACT_FLYING] = true
}

local prev_speed = 0
local hit_firsty_wall = false

local preserved_flight_speed = 0
local flight_hit_bounce_wall = false

---@type Object?
hit_breakable_block = nil

---@param m MarioState
local function vanilla_mario_update_geometry_inputs(m)
    resolve_and_return_wall_collisions(m.pos, 60, 50)
    resolve_and_return_wall_collisions(m.pos, 30, 24)

    m.floor = collision_find_floor(m.pos.x, m.pos.y, m.pos.z)
    m.floorHeight = find_floor_height(m.pos.x, m.pos.y, m.pos.z)

    -- If Mario is OOB, move his position to his graphical position (which was not updated)
    -- and check for the floor there.
    -- This can cause errant behavior when combined with astral projection,
    -- since the graphical position was not Mario's previous location.
    if not m.floor then
        vec3f_copy(m.pos, m.marioObj.header.gfx.pos)
        m.floorHeight = find_floor_height(m.pos.x, m.pos.y, m.pos.z)
    end

    m.ceil = collision_find_ceil(m.pos.x, m.floorHeight, m.pos.z)
    m.ceilHeight = find_ceil_height(m.pos.x, m.floorHeight, m.pos.z)
    gasLevel = find_poison_gas_level(m.pos.x, m.pos.z)
    m.waterLevel = find_water_level(m.pos.x, m.pos.z)

    if m.floor then
        m.floorAngle = atan2s(m.floor.normal.z, m.floor.normal.x)
        m.terrainSoundAddend = mario_get_terrain_sound_addend(m)

        if m.pos.y > m.waterLevel - 40 and mario_floor_is_slippery(m) ~= 0 then
            m.input = m.input | INPUT_ABOVE_SLIDE
        end

        if (m.floor.flags & SURFACE_FLAG_DYNAMIC ~= 0)
            or (m.ceil and m.ceil.flags & SURFACE_FLAG_DYNAMIC ~= 0) then
            ceilToFloorDist = m.ceilHeight - m.floorHeight

            if 0.0 <= ceilToFloorDist and ceilToFloorDist <= 150.0 then
                m.input = m.input | INPUT_SQUISHED
            end
        end

        if m.pos.y > m.floorHeight + 100.0 then
            m.input = m.input | INPUT_OFF_FLOOR
        end

        if m.pos.y < m.waterLevel - 10 then
            m.input = m.input | INPUT_IN_WATER
        end

        if m.pos.y < gasLevel - 100.0 then
            m.input = m.input | INPUT_IN_POISON_GAS
        end
    end
end

local special_surface_types = {
    verticalWind = {},
    toxicGas = {},
    booster = {},
    water = {}
}

---@type table<string, fun(m: MarioState):boolean?>
local special_surface_handlers = {
    verticalWind = function (m)
        if m.action ~= ACT_CUSTOM_VERTICAL_WIND and m.action & ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION ~= 0 then
            drop_and_set_mario_action(m, ACT_CUSTOM_VERTICAL_WIND, 0)
        end
        m.vel.y = m.vel.y + 15
        if m.vel.y > 50 then
            m.vel.y = 50
        end
        spawn_wind_particles(1, 0)
        play_sound(SOUND_ENV_WIND2, m.marioObj.header.gfx.cameraToObject)
        special_surface_types.verticalWind = {}
    end,
    toxicGas = function (m)
        if m.flags & MARIO_METAL_CAP == 0 then
            m.health = m.health - 3
        end
        special_surface_types.toxicGas = {}
    end,
    booster = function (m)
        if m.action & ACT_FLAG_MOVING ~= 0 and m.action ~= ACT_DECELERATING then
            mario_set_forward_vel(m, m.forwardVel + 2.35)
        end
        special_surface_types.booster = {}
    end,
    water = function (m)
        local blocks = special_surface_types.water
        local highest_water_y = gLevelValues.floorLowerLimit
        local first_check = true
        local in_water_block = false
        for _, block in ipairs(blocks) do
            if first_check then
                vanilla_mario_update_geometry_inputs(m)
                first_check = false
                highest_water_y = m.waterLevel
            end
            local new_water_level = block.oPosY + block.oScaleY * 100
            if new_water_level > highest_water_y then
                m.waterLevel = new_water_level
                highest_water_y = new_water_level
            else
                m.waterLevel = highest_water_y
            end
            in_water_block = true
        end

        special_surface_types.water = {}
        if in_water_block then
            return false
        end
    end
}

--[[ Boilerplate:
    if m.playerIndex ~= 0 then return end

    local block_wall = m.wall and m.wall.object
    local block_floor = m.floor and m.floor.object
    local block_ceiling = m.ceil and m.ceil.object

    ------------------ WALL -------------------
    if block_wall then
        local block = block_wall
        local surface_id = block.oItemParams & 0xFF

        if surface_id == MCE_BLOCK_COL_ID_ then
            --
        end
    end
    ------------------ FLOOR -------------------
    if block_floor then
        local block = block_floor
        local surface_id = block.oItemParams & 0xFF

        if surface_id == MCE_BLOCK_COL_ID_ then
            --
        end
    end
    ------------------ CEILING -------------------
    if block_ceiling then
        local block = block_ceiling
        local surface_id = block.oItemParams & 0xFF

        if surface_id == MCE_BLOCK_COL_ID_ then
            --
        end
    end
    ------------------ MISC -------------------
]]

------------------------------------------------------------------------------------------------

---@param m MarioState
local function custom_surface_mario_update(m)
    if m.playerIndex ~= 0 then return end

    local block_wall = m.wall and m.wall.object
    local block_floor = m.floor and m.floor.object
    local block_ceiling = m.ceil and m.ceil.object

    ------------------ WALL -------------------
    if block_wall then
        local block = block_wall
        local surface_id = block.oItemParams & 0xFF

        if surface_id == MCE_BLOCK_COL_ID_WIDE_WALLKICK then
            local wall = m.wall
            local wallDYaw = atan2s(wall.normal.z, wall.normal.x) - (m.faceAngle.y)
            local limit = degrees_to_sm64(180 - 89)
            wallDYaw = convert_s16(wallDYaw)

            -- Standard air hit wall requirements
            if m.forwardVel >= 16 and actions_can_bonk_can_wallkick[m.action] then
                if wallDYaw >= limit or wallDYaw <= -limit then
                    mario_bonk_reflection(m, 0)
                    m.faceAngle.y = m.faceAngle.y + 0x8000
                    m.wallKickTimer = 5
                    set_mario_action(m, ACT_AIR_HIT_WALL, 0)
                end
            end
        elseif surface_id == MCE_BLOCK_COL_ID_BOUNCE then
            local wall = m.wall
            local wallDYaw = convert_s16(atan2s(wall.normal.z, wall.normal.x) - (m.faceAngle.y))
            local limit = degrees_to_sm64(90)
            local speed = m.forwardVel < 32 and 32 or m.forwardVel
            local negative = (wallDYaw >= limit or wallDYaw <= -limit) and -1 or 1
            if m.action == ACT_FLYING then
                m.faceAngle.y = m.faceAngle.y + 0x8000
            else
                mario_set_forward_vel(m, speed * negative)
            end
        elseif surface_id == MCE_BLOCK_COL_ID_DISAPPEARING then
            block.oAction = 1
        elseif surface_id == MCE_BLOCK_COL_ID_BREAKABLE then
            if m.action & ACT_FLAG_ATTACKING ~= 0 then
                block.oAction = 2
            end
        end
    end
    ------------------ FLOOR -------------------
    if block_floor then
        local block = block_floor
        local surface_id = block.oItemParams & 0xFF

        if m.pos.y == m.floorHeight then
            if surface_id == MCE_BLOCK_COL_ID_CHECKPOINT then
                respawn_location = {x = block.oPosX, y = block.oPosY + block.oScaleY * 200, z = block.oPosZ}
            elseif surface_id == MCE_BLOCK_COL_ID_HEAL then
                m.healCounter = 39
            elseif surface_id == MCE_BLOCK_COL_ID_CONVEYOR then
                m.pos.x = m.pos.x + sins(block.oFaceAngleYaw) * 15
                m.pos.z = m.pos.z + coss(block.oFaceAngleYaw) * 15
            elseif surface_id == MCE_BLOCK_COL_ID_DASH_PANEL then
                set_mario_action(m, ACT_DASH, 0)
            elseif surface_id == MCE_BLOCK_COL_ID_BOUNCE then
                if m.action == ACT_FLYING then
                    m.faceAngle.x = -m.faceAngle.x
                    m.angleVel.x = -m.angleVel.x
                elseif (m.action & ACT_FLAG_STATIONARY ~= 0 or m.action & ACT_FLAG_MOVING ~= 0) and not bounce_landing_actions[m.action] then
                    m.vel.y = 50
                    set_mario_action(m, m.heldObj and ACT_HOLD_JUMP or ACT_DOUBLE_JUMP, 0)
                end
            elseif surface_id == MCE_BLOCK_COL_ID_DISAPPEARING or surface_id == MCE_BLOCK_COL_ID_SHRINKING then
                block.oAction = 1
            elseif surface_id == MCE_BLOCK_COL_ID_BREAKABLE then
                if obj_is_mario_ground_pounding_platform(m, block) ~= 0 then
                    block.oAction = 2
                end
            elseif surface_id == MCE_BLOCK_COL_ID_SPRINGBOARD then
                set_mario_action(m, ACT_DOUBLE_JUMP, 0)
                m.vel.y = 80
            end
        else
            if surface_id == MCE_BLOCK_COL_ID_NO_FALL_DAMAGE or surface_id == MCE_BLOCK_COL_ID_BOUNCE then
                if m.pos.y - m.floorHeight < 76 then
                    m.peakHeight = m.pos.y
                end
            elseif surface_id == MCE_BLOCK_COL_ID_REMOVE_CAPS then
                m.capTimer = 1
            end
        end
    end
    ------------------ CEILING -------------------
    if block_ceiling then
        local block = block_ceiling
        local surface_id = block.oItemParams & 0xFF
        local is_rising_into_block = m.pos.y + m.marioObj.hitboxHeight + m.vel.y >= m.ceilHeight and m.vel.y > 0

        if is_rising_into_block then
            if surface_id == MCE_BLOCK_COL_ID_BOUNCE then
                m.vel.y = -30
                if m.action == ACT_FLYING then
                    m.faceAngle.x = -m.faceAngle.x
                    m.angleVel.x = -m.angleVel.x
                end
            elseif surface_id == MCE_BLOCK_COL_ID_BREAKABLE then
                block.oAction = 2
                m.vel.y = 0
            end
        end
        if surface_id == MCE_BLOCK_COL_ID_CONVEYOR and m.action & ACT_FLAG_HANGING ~= 0 then
            m.pos.x = m.pos.x + sins(block.oFaceAngleYaw) * 15
            m.pos.z = m.pos.z + coss(block.oFaceAngleYaw) * 15
        end
    end
    ------------------ MISC -------------------
    if #special_surface_types.verticalWind > 0 then
        special_surface_handlers.verticalWind(m)
    end
    if #special_surface_types.toxicGas > 0 then
        special_surface_handlers.toxicGas(m)
    end
    if #special_surface_types.booster > 0 then
        special_surface_handlers.booster(m)
    end

    if m.action == ACT_FLYING then
        if flight_hit_bounce_wall then
            flight_hit_bounce_wall = false
            mario_set_forward_vel(m, preserved_flight_speed)
        elseif preserved_flight_speed > 0 then
            preserved_flight_speed = 0
        end
    else
        flight_hit_bounce_wall = false
        preserved_flight_speed = 0
    end
end

---@param m MarioState
local function custom_surface_before_mario_update(m)
    if m.playerIndex ~= 0 then return end

    --local block_wall = m.wall and m.wall.object
    local block_floor = m.floor and m.floor.object
    --local block_ceiling = m.ceil and m.ceil.object

    ------------------ WALL -------------------
    ------------------ FLOOR -------------------
    if block_floor then
        local block = block_floor
        local surface_id = block.oItemParams & 0xFF

        if surface_id == MCE_BLOCK_COL_ID_NO_A then
            m.controller.buttonPressed = m.controller.buttonPressed & ~A_BUTTON
        elseif surface_id == MCE_BLOCK_COL_ID_JUMP_PAD then
            if m.controller.buttonPressed & A_BUTTON ~= 0 then
                set_mario_action(m, ACT_DOUBLE_JUMP, 0)
                m.vel.y = 100
            end
        end
    end
    ------------------ CEILING -------------------
    ------------------ MISC -------------------
end

---@param m MarioState
local function custom_surface_before_phys_step(m)
    if m.playerIndex ~= 0 then return end

    if not flight_hit_bounce_wall then
        preserved_flight_speed = m.forwardVel
    end
end

---@param m MarioState
local function custom_surface_set_mario_action(m)
    if m.playerIndex ~= 0 then return end

    local block_wall = m.wall and m.wall.object
    --local block_floor = m.floor and m.floor.object
    local block_ceiling = m.ceil and m.ceil.object

    ------------------ WALL -------------------
    if block_wall then
        local block = block_wall
        local surface_id = block.oItemParams & 0xFF

        if surface_id == MCE_BLOCK_COL_ID_FIRSTY and m.action == ACT_AIR_HIT_WALL then
            prev_speed = m.forwardVel
            hit_firsty_wall = true
        elseif surface_id == MCE_BLOCK_COL_ID_ANY_BONK_WALLKICK then
            if (m.action == ACT_BACKWARD_AIR_KB or m.action == ACT_SOFT_BONK) and m.prevAction ~= ACT_LEDGE_GRAB then
                m.prevAction = ACT_AIR_HIT_WALL
                m.wallKickTimer = 5
            end
        elseif surface_id == MCE_BLOCK_COL_ID_NO_A or surface_id == MCE_BLOCK_COL_ID_NO_WALLKICKS then
            m.wallKickTimer = 0
            m.actionTimer = 3
        elseif surface_id == MCE_BLOCK_COL_ID_BREAKABLE then
            if m.action == ACT_AIR_HIT_WALL then
                hit_breakable_block = block
            end
        end
    end
    ------------------ FLOOR -------------------
    ------------------ CEILING -------------------
    if block_ceiling then
        local block = block_ceiling
        local surface_id = block.oItemParams & 0xFF

        if surface_id == MCE_BLOCK_COL_ID_ANY_BONK_WALLKICK then
            local is_within_height = m.ceilHeight - m.pos.y < 200 and m.ceilHeight - m.pos.y > 0
            if is_within_height and (m.action == ACT_BACKWARD_AIR_KB or m.action == ACT_SOFT_BONK) and m.prevAction ~= ACT_LEDGE_GRAB then
                m.prevAction = ACT_AIR_HIT_WALL
                m.wallKickTimer = 5
            end
        end
    end
    ------------------ MISC -------------------
    if m.action & ACT_FLAG_AIR == 0 then
        hit_firsty_wall = false
    end

    if hit_firsty_wall and m.action == ACT_WALL_KICK_AIR then
        if prev_speed < 20 then
            prev_speed = 20
        end
        m.forwardVel = prev_speed
        hit_firsty_wall = false
    end
end

---@param m MarioState
---@param incoming integer
---@return integer?
local function custom_surface_before_set_mario_action(m, incoming)
    if m.playerIndex ~= 0 then return end

    local block_wall = m.wall and m.wall.object
    local block_floor = m.floor and m.floor.object
    --local block_ceiling = m.ceil and m.ceil.object

    ------------------ WALL -------------------
    if block_wall then
        local block = block_wall
        local surface_id = block.oItemParams & 0xFF

        if surface_id == MCE_BLOCK_COL_ID_BOUNCE then
            flight_hit_bounce_wall = true
            if bounce_bonk_actions[incoming] then
                mario_bonk_reflection(m, 1)
            end
            return 1
        end
    end
    ------------------ FLOOR -------------------
    if block_floor then
        local block = block_floor
        local surface_id = block.oItemParams & 0xFF

        if surface_id == MCE_BLOCK_COL_ID_BOUNCE and m.pos.y == m.floorHeight and bounce_landing_actions[incoming] then
            m.vel.y = 50
            return 1
        end
    end
    ------------------ CEILING -------------------
    ------------------ MISC -------------------
end

---@param m MarioState
local function custom_surface_override_geometry_inputs(m)
    if m.playerIndex ~= 0 then return end
    ------------------ WATER -------------------
    return special_surface_handlers.water(m)
end

local function reset_block(m, block)
    if m.action == ACT_FREE_MOVE and block.oAction ~= MCE_BLOCK_ACT_RESET then
        block.oAction = MCE_BLOCK_ACT_RESET
    end
end

local function custom_surface_block_update()
    local block = obj_get_first_with_behavior_id(bhvMceBlock)
    ---@type MarioState
    local m = gMarioStates[0]
    local already_exists = {verticalWind = false, toxicGas = false, booster = false}
    while block do
        local surface_id = block.oItemParams & 0xFF

        if not already_exists.verticalWind and surface_id == MCE_BLOCK_COL_ID_VERTICAL_WIND and mario_is_within_block(m, block) then
            table.insert(special_surface_types.verticalWind, block)
            already_exists.verticalWind = true
        elseif not already_exists.toxicGas and surface_id == MCE_BLOCK_COL_ID_TOXIC_GAS and mario_is_within_block(m, block) then
            table.insert(special_surface_types.toxicGas, block)
            already_exists.toxicGas = true
        elseif not already_exists.booster and surface_id == MCE_BLOCK_COL_ID_BOOSTER and mario_is_within_block(m, block) then
            table.insert(special_surface_types.booster, block)
            already_exists.booster = true
        elseif surface_id == MCE_BLOCK_COL_ID_WATER and mario_is_within_block(m, block) then
            table.insert(special_surface_types.water, block)
        elseif surface_id == MCE_BLOCK_COL_ID_DISAPPEARING then
            if block.oAction == 1 then
                local transparent_start = mce_block_get_transparent_start_obj(block)
                if block.oAnimState < transparent_start then
                    block.oAnimState = block.oAnimState + transparent_start
                end
                block.oOpacity = math.max(block.oOpacity - 30, 0)
                if block.oOpacity == 0 then
                    block.oAction = 2
                    block.collisionData = nil
                end
            end
            reset_block(m, block)
        elseif surface_id == MCE_BLOCK_COL_ID_SHRINKING then
            if block.oAction == 1 then
                block.header.gfx.scale.x = block.header.gfx.scale.x - (0.01 * block.oScaleX)
                block.header.gfx.scale.y = block.header.gfx.scale.y - (0.01 * block.oScaleY)
                block.header.gfx.scale.z = block.header.gfx.scale.z - (0.01 * block.oScaleZ)
                if block.oTimer >= 100 then
                    block.oAction = 2
                end
            end
            reset_block(m, block)
        elseif surface_id == MCE_BLOCK_COL_ID_BREAKABLE then
            -- Behavior is handled in the block behavior itself to have good particles
            reset_block(m, block)
        end
        block = obj_get_next_with_same_behavior_id(block)
    end
end

hook_event(HOOK_MARIO_UPDATE, custom_surface_mario_update)
hook_event(HOOK_BEFORE_MARIO_UPDATE, custom_surface_before_mario_update)
hook_event(HOOK_BEFORE_PHYS_STEP, custom_surface_before_phys_step)
hook_event(HOOK_ON_SET_MARIO_ACTION, custom_surface_set_mario_action)
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, custom_surface_before_set_mario_action)
hook_event(HOOK_MARIO_OVERRIDE_GEOMETRY_INPUTS, custom_surface_override_geometry_inputs)
hook_event(HOOK_UPDATE, custom_surface_block_update)