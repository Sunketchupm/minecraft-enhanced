-- localize functions to improve performance
local mario_set_forward_vel,perform_air_step,set_character_animation,queue_rumble_data_mario,check_fall_damage_or_get_stuck,set_mario_action,mario_bonk_reflection,lava_boost_on_wall,check_wall_kick,play_knockback_sound,common_air_knockback_step,update_air_without_turn = mario_set_forward_vel,perform_air_step,set_character_animation,queue_rumble_data_mario,check_fall_damage_or_get_stuck,set_mario_action,mario_bonk_reflection,lava_boost_on_wall,check_wall_kick,play_knockback_sound,common_air_knockback_step,update_air_without_turn

ACT_FREE_MOVE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE)

local savedMarioYaw = 0
---@param m MarioState
local function act_free_move(m)
    m.peakHeight = m.pos.y
    m.health = 0x880
    m.capTimer = 1
    if MenuOpen then return false end

    local lHeld = (m.controller.buttonDown & L_TRIG) ~= 0
    local bHeld = (m.controller.buttonDown & B_BUTTON) ~= 0
    if (m.input & INPUT_Z_DOWN) ~= 0 then
        local vel = 0
        if bHeld then
            vel = -60
            if lHeld then
                vel = -15
            end
        else
            vel = -30
        end
        m.vel.y = vel
    elseif (m.input & INPUT_A_DOWN) ~= 0 then
        local vel = 0
        if bHeld then
            vel = 60
            if lHeld then
                vel = 15
            end
        else
            vel = 30
        end
        m.vel.y = vel
    else
        m.vel.y = 0
    end

    if m.controller.buttonPressed & L_TRIG ~= 0 then
        savedMarioYaw = m.faceAngle.y
    end
    m.faceAngle.y = lHeld and savedMarioYaw or m.intendedYaw

    if m.controller.stickMag == 0 then
        mario_set_forward_vel(m, 0)
    end

    if m.forwardVel > 0 then
        if bHeld then
            m.vel.x = sins(m.intendedYaw) * (m.pos.y == m.floorHeight and 180 or 70)
            m.vel.z = coss(m.intendedYaw) * (m.pos.y == m.floorHeight and 180 or 70)
            if lHeld then
                m.vel.x = sins(m.intendedYaw) * (m.pos.y == m.floorHeight and 30 or 5)
                m.vel.z = coss(m.intendedYaw) * (m.pos.y == m.floorHeight and 30 or 5)
            end
        else
            m.vel.x = sins(m.intendedYaw) * (m.pos.y == m.floorHeight and 110 or 20)
            m.vel.z = coss(m.intendedYaw) * (m.pos.y == m.floorHeight and 110 or 20)
        end
    end

    set_character_animation(m, CHAR_ANIM_IDLE_HEAD_CENTER)

    perform_air_step(m, 0)
    update_air_without_turn(m)
end

---@param m MarioState
local function allow_interact(m)
    if m.action == ACT_FREE_MOVE then
        return false
    end
end

---@param m MarioState
local function on_death(m)
    if m.action == ACT_FREE_MOVE then return false end
    local spawn = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvSpinAirborneWarp)
    if spawn then
        vec3f_set(m.pos, spawn.oPosX, spawn.oPosY, spawn.oPosZ)
        m.health = 0x880
        m.capTimer = 1
    else
        warp_to_start_level()
    end
    return false
end

local override_action_change = false
---@param m MarioState
---@param incoming integer
local function before_set_mario_action(m, incoming)
    if m.playerIndex ~= 0 then return end

    if m.action == ACT_FREE_MOVE and incoming ~= ACT_FREE_MOVE and not override_action_change then
        override_action_change = false
        return 1
    end
end

local timer = 0
local start_timer = false
---@param m MarioState
local function mario_update(m)
    if m.playerIndex ~= 0 then return end
    if start_timer then
        timer = timer + 1
        if timer > 15 then
            start_timer = false
            timer = 0
        end
    end
    if m.controller.buttonPressed & L_TRIG ~= 0 then
        if start_timer then
            override_action_change = true
            set_mario_action(m, m.action == ACT_FREE_MOVE and ACT_FREEFALL or ACT_FREE_MOVE, 0)
            start_timer = false
            timer = 0
        end
        start_timer = true
    end
end

hook_mario_action(ACT_FREE_MOVE, act_free_move)
hook_event(HOOK_ALLOW_INTERACT, allow_interact)
hook_event(HOOK_ON_DEATH, on_death)
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, before_set_mario_action)
hook_event(HOOK_MARIO_UPDATE, mario_update)

-----------------------------------------------------------------------------------------------------------

-- Remove double bonks
---@param m MarioState
---@param landAction integer
---@param hardFallAction integer
---@param animation CharacterAnimID | integer
---@param speed number
---@return integer
local function common_air_knockback_step(m, landAction, hardFallAction, animation, speed)
    if not m then return 0 end
    local stepResult = 0

    if gServerSettings.playerInteractions ~= PLAYER_INTERACTIONS_NONE then
        if m.knockbackTimer == 0 then
            if not m.interactObj or m.interactObj.oInteractType & INTERACT_PLAYER == 0 then
                mario_set_forward_vel(m, speed)
            end
        else
            m.knockbackTimer = 10
        end
    else
        mario_set_forward_vel(m, speed)
    end

    stepResult = perform_air_step(m, 0)
    if stepResult == AIR_STEP_NONE then
        set_character_animation(m, animation)
    elseif stepResult == AIR_STEP_LANDED then
        if m.action == ACT_SOFT_BONK then
            queue_rumble_data_mario(m, 5, 40)
        end
        if check_fall_damage_or_get_stuck(m, hardFallAction) == 0 then
            if m.action == ACT_THROWN_FORWARD or m.action == ACT_THROWN_BACKWARD then
                set_mario_action(m, landAction, m.hurtCounter)
            else
                set_mario_action(m, landAction, m.actionArg)
            end
        end
    elseif stepResult == AIR_STEP_HIT_WALL then
        set_character_animation(m, CHAR_ANIM_BACKWARD_AIR_KB)
        mario_bonk_reflection(m, 0)

        if m.vel.y > 0.0 then
            m.vel.y = 0.0
        end

        mario_set_forward_vel(m, -speed)
    elseif stepResult == AIR_STEP_HIT_LAVA_WALL then
        lava_boost_on_wall(m)
    end
    return stepResult
end

---@param m MarioState
local function act_backward_air_kb(m)
    if check_wall_kick(m) ~= 0 then
        return true
    end

    play_knockback_sound(m)
    common_air_knockback_step(m, ACT_BACKWARD_GROUND_KB, ACT_HARD_BACKWARD_GROUND_KB, 0x0002, -16.0)
    return false
end

hook_mario_action(ACT_BACKWARD_AIR_KB, act_backward_air_kb)