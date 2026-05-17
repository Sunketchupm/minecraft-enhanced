local sActionsCanWallkick = {
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

local sLandingActions = {
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

local sPrevSpeed = 0
local sHitFirstyWall = false

local sPreservedFlightSpeed = 0
local sFlightHitBounceWall = false

---@type Object?
gHitBreakableBlock = nil

---@type Object?
local sInSpecialBlock = nil

---@type table<string, fun(m: MarioState): boolean?>
local sSpecialSurfaceHandlers = {
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
    end,
    toxicGas = function (m)
        if m.flags & MARIO_METAL_CAP == 0 then
            m.health = m.health - 3
        end
    end,
    booster = function (m)
        if m.action ~= ACT_DECELERATING then
            mario_set_forward_vel(m, m.forwardVel * 1.1)
        end
    end,
    water = function (m)
        if not sInSpecialBlock then return end

        local highest = gLevelValues.floorLowerLimit
        local lowest = gLevelValues.cellHeightLimit
        for i = 0, sInSpecialBlock.numSurfaces - 1, 1 do
            local surface = obj_get_surface_from_index(sInSpecialBlock, i)
            if surface.upperY > highest then
                highest = surface.upperY
            end
            if surface.lowerY < lowest then
                lowest = surface.lowerY
            end
        end
        m.waterLevel = find_water_level(m.pos.x, m.pos.z)

        local floor_raycast = collision_find_surface_on_ray(m.pos.x, highest + 20, m.pos.z, 0, -math.abs(highest - lowest), 0)
        if not (floor_raycast and floor_raycast.hitPos and floor_raycast.surface and floor_raycast.surface.object == sInSpecialBlock) then return end
        local floor_height = floor_raycast.hitPos.y
        local is_below_floor = m.pos.y < floor_height

        local ceil_raycast = collision_find_surface_on_ray(m.pos.x, lowest - 20, m.pos.z, 0, math.abs(highest - lowest), 0)
        if not (ceil_raycast and ceil_raycast.hitPos and ceil_raycast.surface and ceil_raycast.surface.object == sInSpecialBlock) then return end
        local ceil_height = floor_raycast.hitPos.y
        local is_above_ceil = m.pos.y > ceil_height

        if is_below_floor and is_above_ceil then
            m.waterLevel = floor_height
            return false
        end
    end
}

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
        local surface_properties = block.oItemFlags

        if surface_id == MCE_BLOCK_COL_ID_BOUNCE then
            local wall = m.wall
            local wallDYaw = math.s16(atan2s(wall.normal.z, wall.normal.x) - (m.faceAngle.y))
            local limit = degrees_to_sm64(90)
            local speed = m.forwardVel < 32 and 32 or m.forwardVel
            local negative = (wallDYaw >= limit or wallDYaw <= -limit) and -1 or 1
            if m.action == ACT_FLYING then
                m.faceAngle.y = m.faceAngle.y + 0x8000
            else
                mario_set_forward_vel(m, speed * negative)
            end
        end

        if surface_properties & MCE_BLOCK_PROPERTY_WIDE_WALLKICK ~= 0 then
            local wall = m.wall
            local wallDYaw = atan2s(wall.normal.z, wall.normal.x) - (m.faceAngle.y)
            local limit = degrees_to_sm64(180 - 89)
            wallDYaw = math.s16(wallDYaw)

            -- Standard air hit wall requirements
            if m.forwardVel >= 16 and sActionsCanWallkick[m.action] then
                if wallDYaw >= limit or wallDYaw <= -limit then
                    mario_bonk_reflection(m, 0)
                    m.faceAngle.y = m.faceAngle.y + 0x8000
                    m.wallKickTimer = 5
                    set_mario_action(m, ACT_AIR_HIT_WALL, 0)
                end
            end
        end
        if surface_properties & MCE_BLOCK_PROPERTY_DISAPPEARING ~= 0 then
            block.oAction = 1
        elseif surface_properties & MCE_BLOCK_PROPERTY_BREAKABLE ~= 0 and m.action & ACT_FLAG_ATTACKING ~= 0 then
            block.oAction = 2
        end
    end
    ------------------ FLOOR -------------------
    if block_floor then
        local block = block_floor
        local surface_id = block.oItemParams & 0xFF
        local surface_properties = block.oItemFlags

        if m.pos.y == m.floorHeight then
            if surface_id == MCE_BLOCK_COL_ID_DASH_PANEL then
                set_mario_action(m, ACT_DASH, 0)
            elseif surface_id == MCE_BLOCK_COL_ID_BOUNCE then
                if m.action == ACT_FLYING then
                    m.faceAngle.x = -m.faceAngle.x
                    m.angleVel.x = -m.angleVel.x
                elseif (m.action & ACT_FLAG_STATIONARY ~= 0 or m.action & ACT_FLAG_MOVING ~= 0) and not sLandingActions[m.action] then
                    m.vel.y = 50
                    set_mario_action(m, m.heldObj and ACT_HOLD_JUMP or ACT_DOUBLE_JUMP, 0)
                end
            elseif surface_id == MCE_BLOCK_COL_ID_SPRINGBOARD then
                set_mario_action(m, ACT_DOUBLE_JUMP, 0)
                m.vel.y = 80
            end

            if surface_properties & MCE_BLOCK_PROPERTY_CHECKPOINT ~= 0 then
                gRespawnLocation = {x = block.oPosX, y = block.oPosY + block.oScaleY * BLOCK_DEFAULT_SIZE, z = block.oPosZ}
                gRespawnAngle = block.oFaceAngleYaw
            end
            if surface_properties & MCE_BLOCK_PROPERTY_CONVEYOR ~= 0 then
                m.pos.x = m.pos.x + sins(block.oFaceAngleYaw) * 15
                m.pos.z = m.pos.z + coss(block.oFaceAngleYaw) * 15
            end
            if surface_properties & (MCE_BLOCK_PROPERTY_DISAPPEARING | MCE_BLOCK_PROPERTY_SHRINKING) ~= 0 then
                block.oAction = 1
            elseif surface_properties & MCE_BLOCK_PROPERTY_BREAKABLE ~= 0 and obj_is_mario_ground_pounding_platform(m, block) ~= 0 then
                block.oAction = 2
            end
        else
            if surface_id == MCE_BLOCK_COL_ID_BOUNCE and m.pos.y - m.floorHeight < 76 then
                m.peakHeight = m.pos.y
            end

            if surface_properties & MCE_BLOCK_PROPERTY_NO_FALL_DAMAGE ~= 0 and m.pos.y - m.floorHeight < 76 then
                m.peakHeight = m.pos.y
            end
            if surface_properties & MCE_BLOCK_PROPERTY_REMOVE_CAPS ~= 0 then
                m.capTimer = 1
            end
        end
    end
    ------------------ CEILING -------------------
    if block_ceiling then
        local block = block_ceiling
        local surface_id = block.oItemParams & 0xFF
        local surface_properties = block.oItemFlags
        local is_rising_into_block = m.pos.y + m.marioObj.hitboxHeight + m.vel.y >= m.ceilHeight and m.vel.y > 0

        if is_rising_into_block then
            if surface_id == MCE_BLOCK_COL_ID_BOUNCE then
                m.vel.y = -30
                if m.action == ACT_FLYING then
                    m.faceAngle.x = -m.faceAngle.x
                    m.angleVel.x = -m.angleVel.x
                end
            end
            if surface_properties & MCE_BLOCK_PROPERTY_BREAKABLE ~= 0 then
                block.oAction = 2
                m.vel.y = 0
            end
        end
        if surface_properties & MCE_BLOCK_PROPERTY_CONVEYOR ~= 0 and m.action & ACT_FLAG_HANGING ~= 0 then
            m.pos.x = m.pos.x + sins(block.oFaceAngleYaw) * 15
            m.pos.z = m.pos.z + coss(block.oFaceAngleYaw) * 15
        end
    end
    ------------------ MISC -------------------
    if sInSpecialBlock then
        local surface_id = sInSpecialBlock.oItemParams & 0xFF
        if surface_id == MCE_BLOCK_COL_ID_VERTICAL_WIND then
            sSpecialSurfaceHandlers.verticalWind(m)
        elseif surface_id == MCE_BLOCK_COL_ID_TOXIC_GAS then
            sSpecialSurfaceHandlers.toxicGas(m)
        end
    end

    if m.action == ACT_FLYING then
        if sFlightHitBounceWall then
            sFlightHitBounceWall = false
            mario_set_forward_vel(m, sPreservedFlightSpeed)
        elseif sPreservedFlightSpeed > 0 then
            sPreservedFlightSpeed = 0
        end
    else
        sFlightHitBounceWall = false
        sPreservedFlightSpeed = 0
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
        local surface_properties = block.oItemFlags

        if surface_id == MCE_BLOCK_COL_ID_JUMP_PAD and m.controller.buttonPressed & A_BUTTON ~= 0 then
            set_mario_action(m, ACT_DOUBLE_JUMP, 0)
            m.vel.y = 100
        end

        if surface_properties & MCE_BLOCK_PROPERTY_NO_A ~= 0 then
            m.controller.buttonPressed = m.controller.buttonPressed & ~A_BUTTON
        end
    end
    ------------------ CEILING -------------------
    ------------------ MISC -------------------
end

---@param m MarioState
local function custom_surface_before_phys_step(m)
    if m.playerIndex ~= 0 then return end

    if not sFlightHitBounceWall then
        sPreservedFlightSpeed = m.forwardVel
    end

    if sInSpecialBlock and sInSpecialBlock.oItemParams & 0xFF == MCE_BLOCK_COL_ID_BOOSTER then
        sSpecialSurfaceHandlers.booster(m)
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
        --local surface_id = block.oItemParams & 0xFF
        local surface_properties = block.oItemFlags

        if surface_properties & MCE_BLOCK_PROPERTY_FIRSTY ~= 0 and m.action == ACT_AIR_HIT_WALL then
            sPrevSpeed = m.forwardVel
            sHitFirstyWall = true
        end
        if surface_properties & MCE_BLOCK_PROPERTY_ANY_BONK_WALLKICK ~= 0 then
            if (m.action == ACT_BACKWARD_AIR_KB or m.action == ACT_SOFT_BONK) and m.prevAction ~= ACT_LEDGE_GRAB then
                m.prevAction = ACT_AIR_HIT_WALL
                m.wallKickTimer = 5
            end
        end
        if surface_properties & (MCE_BLOCK_PROPERTY_NO_A | MCE_BLOCK_PROPERTY_NO_WALLKICKS) ~= 0 then
            m.wallKickTimer = 0
            m.actionTimer = 3
        end
        if surface_properties & MCE_BLOCK_PROPERTY_BREAKABLE ~= 0 and m.action == ACT_AIR_HIT_WALL then
            gHitBreakableBlock = block
        end
    end
    ------------------ FLOOR -------------------
    ------------------ CEILING -------------------
    if block_ceiling then
        local block = block_ceiling
        --local surface_id = block.oItemParams & 0xFF
        local surface_properties = block.oItemFlags

        if surface_properties & MCE_BLOCK_PROPERTY_ANY_BONK_WALLKICK ~= 0 then
            local is_within_height = m.ceilHeight - m.pos.y < 200 and m.ceilHeight - m.pos.y > 0
            if is_within_height and (m.action == ACT_BACKWARD_AIR_KB or m.action == ACT_SOFT_BONK) and m.prevAction ~= ACT_LEDGE_GRAB then
                m.prevAction = ACT_AIR_HIT_WALL
                m.wallKickTimer = 5
            end
        end
    end
    ------------------ MISC -------------------
    if m.action & ACT_FLAG_AIR == 0 then
        sHitFirstyWall = false
    end

    if sHitFirstyWall and m.action == ACT_WALL_KICK_AIR then
        if sPrevSpeed < 20 then
            sPrevSpeed = 20
        end
        m.forwardVel = sPrevSpeed
        sHitFirstyWall = false
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
        --local surface_properties = block.oBlockSurfaceProperties

        if surface_id == MCE_BLOCK_COL_ID_BOUNCE then
            local bounce_actions = {
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

            sFlightHitBounceWall = true
            if bounce_actions[incoming] then
                mario_bonk_reflection(m, 1)
            end
            return 1
        end
    end
    ------------------ FLOOR -------------------
    if block_floor then
        local block = block_floor
        local surface_id = block.oItemParams & 0xFF
        --local surface_properties = block.oBlockSurfaceProperties

        if surface_id == MCE_BLOCK_COL_ID_BOUNCE and m.pos.y == m.floorHeight and sLandingActions[incoming] then
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
    if sInSpecialBlock and sInSpecialBlock.oItemParams & 0xFF == MCE_BLOCK_COL_ID_WATER then
        return sSpecialSurfaceHandlers.water(m)
    end
end

local function custom_surface_block_update()
    local block = obj_get_first_with_behavior_id(bhvMceBlock)
    ---@type MarioState
    local m = gMarioStates[0]
    sInSpecialBlock = nil
    while block do
        local surface_id = block.oItemParams & 0xFF
        local surface_properties = block.oItemFlags

        local special_surface_ids = {
            [MCE_BLOCK_COL_ID_VERTICAL_WIND] = true,
            [MCE_BLOCK_COL_ID_TOXIC_GAS] = true,
            [MCE_BLOCK_COL_ID_BOOSTER] = true,
            [MCE_BLOCK_COL_ID_WATER] = true,
        }
        if obj_is_intersecting_obj(m.marioObj, block) and special_surface_ids[surface_id] then
            sInSpecialBlock = block
        end

        if surface_properties & MCE_BLOCK_PROPERTY_DISAPPEARING ~= 0 then
            if block.oAction == 1 then
                block.oOpacity = math.max(block.oOpacity - 30, 0)
                if block.oOpacity == 0 then
                    block.oAction = 2
                    block.collisionData = nil
                end
            end
        elseif surface_properties & MCE_BLOCK_PROPERTY_SHRINKING ~= 0 then
            if block.oAction == 1 then
                block.header.gfx.scale.x = block.header.gfx.scale.x - (0.01 * block.oScaleX)
                block.header.gfx.scale.y = block.header.gfx.scale.y - (0.01 * block.oScaleY)
                block.header.gfx.scale.z = block.header.gfx.scale.z - (0.01 * block.oScaleZ)
                if block.oTimer >= 100 then
                    block.oAction = 2
                end
            end
        elseif surface_properties & MCE_BLOCK_PROPERTY_BREAKABLE ~= 0 then
            -- Behavior is handled in the block behavior itself to have good particles
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