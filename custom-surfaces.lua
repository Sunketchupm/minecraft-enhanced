-- localize functions to improve performance
local collision_find_ceil,find_ceil_height,mario_bonk_reflection,set_mario_action,spawn_mist_particles = collision_find_ceil,find_ceil_height,mario_bonk_reflection,set_mario_action,spawn_mist_particles

--------------------------------------------------------------------------------------------------------------

local sBonkWallkickActions = {
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

local firstyPrevSpeed = 0
local hitFirsty = false

local hitBreakableBlockWall = false
local tempBrokenBlock = nil
local brokenBlock = nil
local breakTimer = 0
local BREAK_TIMER_MAX = 0

local hitWallkicklessBlock = false

--------------------------------------------------------------------------------------------------------------

---@param m MarioState
---@return Object?
local function collision_get_block_from_wall(m)
    --[[local detector = {
        x = 50.0 * sins(m.faceAngle.y),
        y = 0,
        z = 50.0 * coss(m.faceAngle.y)
    }
    local raycast = collision_find_surface_on_ray(m.pos.x, m.pos.y, m.pos.z, detector.x, detector.y, detector.z)
    local obj = (raycast and raycast.surface and raycast.surface.object) and raycast.surface.object or nil]]

    -- It's not perfectly ideal to used Mario's referenced wall since that can change mid-frame by another player
    -- However there isn't a problem with it here and it's much easier to let the game handle surface references
    local wall = m.wall
    local obj = nil
    if wall and wall.object then
        obj = m.wall.object
    end

    return obj
end

---@param m MarioState
---@return Object?
---@return number
local function collision_get_block_from_floor(m)
    local floor = collision_find_floor(m.pos.x, m.pos.y, m.pos.z)
    local height = find_floor_height(m.pos.x, m.pos.y, m.pos.z)
    --[[
    local floor = m.floor
    local height = m.floorHeight
    ]]

    local obj = (floor and floor.object) and floor.object or nil
    return obj, height
end

---@param m MarioState
---@return Object?
---@return number
local function collision_get_block_from_ceil(m)
    local ceil = collision_find_ceil(m.pos.x, m.pos.y, m.pos.z)
    local height = find_ceil_height(m.pos.x, m.pos.y, m.pos.z)
    --[[
    local ceil = m.ceil
    local height = m.ceilHeight
    ]]
    local obj = (ceil and ceil.object) and ceil.object or nil
    return obj, height
end

--------------------------------------------------------------------------------------------------------------

local function on_set_mario_action_wall_behaviors(m)
    ---@type Object?
    local blockWall = collision_get_block_from_wall(m)

    -----------------
    -- firsty wall --
    -----------------

    -- forces this flag to be reset if Mario bonks but not wallkick
    if (m.action & ACT_FLAG_AIR) == 0 then
        hitFirsty = false
    end

    if m.action == ACT_AIR_HIT_WALL then
        if blockWall and blockWall.oBehParams & 0xFF == BLOCK_SURFACE_ID_FIRSTY then
            firstyPrevSpeed = m.forwardVel
            hitFirsty = true
        else
            hitFirsty = false
        end
    end

    if hitFirsty and m.action == ACT_WALL_KICK_AIR then
        if firstyPrevSpeed < 20 then
            firstyPrevSpeed = 20
        end
        m.forwardVel = firstyPrevSpeed
        hitFirsty = false
    end

    -----------------------
    -- any bonk wallkick --
    -----------------------

    if (blockWall and blockWall.oBehParams & 0xFF == BLOCK_SURFACE_ID_ANY_BONK_WALLKICK) and
        (m.action == ACT_BACKWARD_AIR_KB or m.action == ACT_SOFT_BONK) and m.prevAction ~= ACT_LEDGE_GRAB then

        m.prevAction = ACT_AIR_HIT_WALL
        m.wallKickTimer = 5
    end

    ---------------
    -- Breakable --
    ---------------

    if blockWall and m.action ~= ACT_FREE_MOVE then
        local surface_id = blockWall.oBehParams & 0xFF
        if surface_id == BLOCK_SURFACE_ID_BREAKABLE then
            hitBreakableBlockWall = true
            tempBrokenBlock = blockWall
        end
    end

    if (m.action & ACT_FLAG_AIR) == 0 then
        hitBreakableBlockWall = false
        tempBrokenBlock = nil
    end

    if hitBreakableBlockWall and m.action == ACT_WALL_KICK_AIR then
        brokenBlock = tempBrokenBlock
        tempBrokenBlock = nil
    end

    if brokenBlock then
        if brokenBlock.oAction ~= 1 and breakTimer == 0 then
            brokenBlock.oAction = 1
        end
        brokenBlock = nil
        breakTimer = BREAK_TIMER_MAX
    end

    ----------
    -- Misc --
    ----------

    if blockWall then
        surface_id = blockWall.oBehParams & 0xFF
        if surface_id == BLOCK_SURFACE_ID_NO_A or surface_id == BLOCK_SURFACE_ID_NO_WALLKICKS then
            m.wallKickTimer = 0
            m.actionTimer = 3
        end
    end
end

local function on_set_mario_action_ceiling_behaviors(m)
    local blockCeiling, height = collision_get_block_from_ceil(m)
    if not blockCeiling then return end

    local surface_id = blockCeiling.oBehParams & 0xFF
    if surface_id == BLOCK_SURFACE_ID_ANY_BONK_WALLKICK and
        height - m.pos.y < 200 and height - m.pos.y > 0 and
        (m.action == ACT_BACKWARD_AIR_KB or m.action == ACT_SOFT_BONK) and m.prevAction ~= ACT_LEDGE_GRAB then

        m.prevAction = ACT_AIR_HIT_WALL
        m.wallKickTimer = 5
    end
end

--------------------------------------------------------

---@param m MarioState
local function mario_update_wall_behaviors(m)
    local wall = m.wall
    local blockWall = collision_get_block_from_wall(m)
    if not blockWall then return end
    local surface_id = blockWall.oBehParams & 0xFF

    if surface_id == BLOCK_SURFACE_ID_WIDE_WALLKICK then
        local wallDYaw = s16(atan2s(wall.normal.z, wall.normal.x) - (m.faceAngle.y))
        local limit = degrees(91)

        -- Standard air hit wall requirements
        if m.forwardVel >= 16 and sBonkWallkickActions[m.action] then
            if wallDYaw >= limit or wallDYaw <= -limit then
                mario_bonk_reflection(m, 0)
                m.faceAngle.y = m.faceAngle.y + 0x8000
                m.wallKickTimer = 5
                set_mario_action(m, ACT_AIR_HIT_WALL, 0)
            end
        end

    elseif surface_id == BLOCK_SURFACE_ID_BOUNCE then
        local wallDYaw = s16(atan2s(wall.normal.z, wall.normal.x) - (m.faceAngle.y))
        local limit = degrees(90)
        local speed = m.forwardVel < 32 and 32 or m.forwardVel
        local negative = (wallDYaw >= limit or wallDYaw <= -limit) and -1 or 1
        if m.action == ACT_FLYING then
            m.faceAngle.y = m.faceAngle.y + 0x8000
            negative = 1
        end
        mario_set_forward_vel(m, speed * negative)

    elseif surface_id == BLOCK_SURFACE_ID_BREAKABLE and m.flags & (MARIO_PUNCHING | MARIO_KICKING | MARIO_TRIPPING) ~= 0 then
        local detector = {
            x = m.pos.x + 50.0 * sins(m.faceAngle.y),
            y = m.pos.y,
            z = m.pos.z + 50.0 * coss(m.faceAngle.y)
        }
        local wcd = collision_get_temp_wall_collision_data()
        resolve_and_return_wall_collisions_data(detector, 80.0, 5.0, wcd)
        if wcd.numWalls > 0 and m.action ~= 1 and breakTimer == 0 then
            blockWall.oAction = 1
            breakTimer = BREAK_TIMER_MAX
        end
    end
end

---@param m MarioState
local function mario_update_floor_behaviors(m)
    local blockFloor, height = collision_get_block_from_floor(m)
    if not blockFloor then return end
    local surface_id = blockFloor.oBehParams & 0xFF

    if m.pos.y == height then

        if surface_id == BLOCK_SURFACE_ID_BOUNCE then
            local landing_actions = {
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
            }
            if (m.action & ACT_FLAG_STATIONARY ~= 0 or m.action & ACT_FLAG_MOVING ~= 0) and not landing_actions[m.action] then
                m.vel.y = 50
                set_mario_action(m, m.heldObj and ACT_HOLD_JUMP or ACT_DOUBLE_JUMP, 0)
            end

        elseif surface_id == BLOCK_SURFACE_ID_BOOSTER and m.action & ACT_FLAG_MOVING ~= 0 and m.action ~= ACT_DECELERATING then
            mario_set_forward_vel(m, m.forwardVel + 2.35)

        elseif surface_id == BLOCK_SURFACE_ID_HEAL then
            m.healCounter = 39

        elseif surface_id == BLOCK_SURFACE_ID_CONVEYOR then
            m.pos.x = m.pos.x + sins(blockFloor.oFaceAngleYaw) * 15
            m.pos.z = m.pos.z + coss(blockFloor.oFaceAngleYaw) * 15

        elseif surface_id == BLOCK_SURFACE_ID_BREAKABLE and m.action == ACT_GROUND_POUND_LAND and blockFloor.oAction ~= 1 and breakTimer == 0 then
            blockFloor.oAction = 1
            breakTimer = BREAK_TIMER_MAX
        elseif surface_id == BLOCK_SURFACE_ID_DISAPPEARING then
            blockFloor.oAction = 1
        elseif surface_id == BLOCK_SURFACE_ID_DASH_PANEL then
            set_mario_action(m, ACT_DASH, 0)
        end
    end

    if (surface_id == BLOCK_SURFACE_ID_NO_FALL_DAMAGE or surface_id == BLOCK_SURFACE_ID_BOUNCE) and m.pos.y - m.floorHeight < 76 then
        m.peakHeight = m.pos.y
    elseif surface_id == BLOCK_SURFACE_ID_REMOVE_CAPS then
        m.capTimer = 1
    end
end

local function mario_update_ceiling_behaviors(m)
    local blockCeil, height = collision_get_block_from_ceil(m)
    if not blockCeil then return end
    local surface_id = blockCeil.oBehParams & 0xFF
    local is_rising = (m.vel.y + m.pos.y + m.marioObj.hitboxHeight > height) and m.vel.y > 0

    if is_rising then

        if surface_id == BLOCK_SURFACE_ID_BOUNCE then
            m.vel.y = -30

        elseif surface_id == BLOCK_SURFACE_ID_BREAKABLE and blockCeil.oAction ~= 1 and breakTimer == 0 then
            blockCeil.oAction = 1
            breakTimer = BREAK_TIMER_MAX
            m.vel.y = 0 -- Simulate hitting the block ceiling
        end
    end

    if surface_id == BLOCK_SURFACE_ID_CONVEYOR and (m.action == ACT_START_HANGING or m.action == ACT_HANGING or m.action == ACT_HANG_MOVING) then
        m.pos.x = m.pos.x + sins(blockCeil.oFaceAngleYaw) * 15
        m.pos.z = m.pos.z + coss(blockCeil.oFaceAngleYaw) * 15
    end
end

--------------------------------------------------------

---@param m MarioState
local function before_mario_update_floor_behaviors(m)
    local blockFloor, height = collision_get_block_from_floor(m)
    if not blockFloor then return end
    local surface_id = blockFloor.oBehParams & 0xFF

    if m.pos.y == height then

        if surface_id == BLOCK_SURFACE_ID_NO_A then
            m.controller.buttonPressed = m.controller.buttonPressed & ~A_BUTTON
        elseif surface_id == BLOCK_SURFACE_ID_JUMP_PAD then
            if m.controller.buttonPressed & A_BUTTON ~= 0 then
                set_mario_action(m, ACT_DOUBLE_JUMP, 0)
                m.vel.y = 100
            end
        end
    end
end

--------------------------------------------------------

---@param m MarioState
---@param incomingAction any
---@param ret integer
---@return integer
local function before_set_mario_action_wall_behaviors(m, incomingAction, ret)
    local blockWall = collision_get_block_from_wall(m)
    if not blockWall then return ret end
    local surface_id = blockWall.oBehParams & 0xFF

    local bonk_actions = {
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

    if surface_id == BLOCK_SURFACE_ID_BOUNCE and bonk_actions[incomingAction] then
        mario_bonk_reflection(m, 1)
        return 1
    end

    return ret
end

---@param m any
---@param incomingAction any
---@param ret integer
---@return integer
local function before_set_mario_action_floor_behaviors(m, incomingAction, ret)
    local blockFloor, height = collision_get_block_from_floor(m)
    if not blockFloor then return ret end
    local surface_id = blockFloor.oBehParams & 0xFF

    if m.pos.y == height then

        if surface_id == BLOCK_SURFACE_ID_BOUNCE then
            local landing_actions = {
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
            }
            if landing_actions[incomingAction] then
                m.vel.y = 50
                return 1
            end
        end
    end

    return ret
end

-----------------------------------------------------------------------------------------------------------------

local function block_update()
    local block_behavior_id = gItemInfoLUT["block"].behaviorId
    for block in obj_get_all_with_behavior_id(block_behavior_id) do
        local surface = block.oBehParams & 0xFF
        if surface == BLOCK_SURFACE_ID_BREAKABLE then
            if block.oAction == 0 then
                -- This is actually bad and really laggy, however this forces broken blocks to behave when synced
                -- So limit the amount of breakable blocks in a level
                block.collisionData = gCollisionTypes[BLOCK_SURFACE_ID_DEFAULT]
                if obj_has_model_extended(block, E_MODEL_COLOR_BOX) == 0 then
                    obj_set_model_extended(block, E_MODEL_COLOR_BOX)
                end
            elseif block.oAction == 1 then
                block.collisionData = gCollisionTypes[BLOCK_SURFACE_ID_NO_COLLISION]

                spawn_mist_particles_variable(0, 0, 46)
                spawn_triangle_break_particles(30, 138, 3.0, 4)
                lua_create_sound_spawner(block)

                block.oAction = 2
                obj_set_model_extended(block, E_MODEL_OUTLINE)
            elseif block.oAction == 2 then
                if block.oTimer > 150 then
                    block.oAction = 0
                end
            end
        elseif surface == BLOCK_SURFACE_ID_DISAPPEARING then
            if block.oAction == 0 then
                -- Same as breakable
                block.header.gfx.scale.x = block.oScaleX
                block.header.gfx.scale.y = block.oScaleY
                block.header.gfx.scale.z = block.oScaleZ
                block.collisionData = gCollisionTypes[BLOCK_SURFACE_ID_DEFAULT]
                if obj_has_model_extended(block, E_MODEL_COLOR_BOX) == 0 then
                    obj_set_model_extended(block, E_MODEL_COLOR_BOX)
                end
            elseif block.oAction == 1 then
                block.header.gfx.scale.x = block.header.gfx.scale.x - (block.oScaleX * 0.01)
                block.header.gfx.scale.y = block.header.gfx.scale.y - (block.oScaleY * 0.01)
                block.header.gfx.scale.z = block.header.gfx.scale.z - (block.oScaleZ * 0.01)

                if block.header.gfx.scale.x <= 0 or block.header.gfx.scale.y <= 0 or block.header.gfx.scale.z <= 0 then
                    block.header.gfx.scale.x = block.oScaleX
                    block.header.gfx.scale.y = block.oScaleY
                    block.header.gfx.scale.z = block.oScaleZ
                    obj_set_model_extended(block, E_MODEL_OUTLINE)
                    block.oAction = 2
                end
            elseif block.oAction == 2 then
                block.collisionData = gCollisionTypes[BLOCK_SURFACE_ID_NO_COLLISION]
                if block.oTimer > 150 then
                    block.oAction = 0
                end
            end
        elseif surface == BLOCK_SURFACE_ID_BOOSTER then
            ---@type MarioState
            local m = gMarioStates[0]
            local is_in_range = m.pos.x >= block.oPosX - 100 * block.header.gfx.scale.x and m.pos.x <= block.oPosX + 100 * block.header.gfx.scale.x and
            m.pos.y >= block.oPosY - 100 * block.header.gfx.scale.y and m.pos.y <= block.oPosY + 100 * block.header.gfx.scale.y and
            m.pos.z >= block.oPosZ - 100 * block.header.gfx.scale.z and m.pos.z <= block.oPosZ + 100 * block.header.gfx.scale.z
            if is_in_range then
                if math.abs(m.forwardVel) < 250 then
                    mario_set_forward_vel(m, m.forwardVel * 1.1)
                end
            end
        elseif surface == BLOCK_SURFACE_ID_TOXIC_GAS then
            ---@type MarioState
            local m = gMarioStates[0]
            local is_in_range = m.pos.x >= block.oPosX - 100 * block.header.gfx.scale.x and m.pos.x <= block.oPosX + 100 * block.header.gfx.scale.x and
            m.pos.y >= block.oPosY - 100 * block.header.gfx.scale.y and m.pos.y <= block.oPosY + 100 * block.header.gfx.scale.y and
            m.pos.z >= block.oPosZ - 100 * block.header.gfx.scale.z and m.pos.z <= block.oPosZ + 100 * block.header.gfx.scale.z
            if is_in_range then
                if m.flags & MARIO_METAL_CAP == 0 then
                    m.health = m.health - 3
                end
            end
        end
    end
end

-----------------------------------------------------------------------------------------------------------------

---@param m MarioState
local function on_set_mario_action(m)
    if m.playerIndex ~= 0 then return end

    if m.action == ACT_FREE_MOVE then return end
    on_set_mario_action_wall_behaviors(m)
    -- There are no floor behaviors yet
    on_set_mario_action_ceiling_behaviors(m)
end

---@param m MarioState
local function mario_update(m)
    if m.playerIndex ~= 0 then return end

    if breakTimer > 0 then
        breakTimer = breakTimer - 1
    end

    if hitWallkicklessBlock then
        m.wallKickTimer = 0
        hitWallkicklessBlock = false
    end

    if m.action == ACT_FREE_MOVE then return end
    mario_update_wall_behaviors(m)
    mario_update_floor_behaviors(m)
    mario_update_ceiling_behaviors(m)
end

---@param m MarioState
local function before_mario_update(m)
    if m.playerIndex ~= 0 then return end

    if hitWallkicklessBlock then
        m.wallKickTimer = 0
        hitWallkicklessBlock = false
    end

    if m.action == ACT_FREE_MOVE then return end
    -- There are no wall behaviors yet
    before_mario_update_floor_behaviors(m)
    -- There are no ceiling behaviors yet
end

---@param m MarioState
---@param incomingAction integer
---@return integer?
local function before_set_mario_action(m, incomingAction)
    if m.playerIndex ~= 0 then return end

    if m.action == ACT_FREE_MOVE then return end
    local ret = 0
    ret = before_set_mario_action_wall_behaviors(m, incomingAction, ret)
    ret = before_set_mario_action_floor_behaviors(m, incomingAction, ret)
    -- There are no ceiling behaviors yet
    return ret == 0 and nil or ret
end

local function update()
    block_update()
end

hook_event(HOOK_ON_SET_MARIO_ACTION, on_set_mario_action)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, before_set_mario_action)
hook_event(HOOK_UPDATE, update)