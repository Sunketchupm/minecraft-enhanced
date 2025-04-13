-- localize functions to improve performance
local mario_set_forward_vel,perform_air_step,set_character_animation,queue_rumble_data_mario,check_fall_damage_or_get_stuck,set_mario_action,mario_bonk_reflection,lava_boost_on_wall,check_wall_kick,play_knockback_sound,common_air_knockback_step,update_air_without_turn = mario_set_forward_vel,perform_air_step,set_character_animation,queue_rumble_data_mario,check_fall_damage_or_get_stuck,set_mario_action,mario_bonk_reflection,lava_boost_on_wall,check_wall_kick,play_knockback_sound,common_air_knockback_step,update_air_without_turn

ACT_FREE_MOVE = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE)
ACT_DASH = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING)

savedMarioYaw = 0
---@param m MarioState
local function act_free_move(m)
    m.peakHeight = m.pos.y
    m.health = 0x880
    if menuOpen then return false end

    m.capTimer = 1
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
local function act_dash(m)
    mario_set_forward_vel(m, 90)
    mario_drop_held_object(m)

    if m.input & INPUT_A_PRESSED ~= 0 then
        return set_jump_from_landing(m)
    end

    if check_ground_dive_or_punch(m) ~= 0 then
        return true
    end

    m.actionState = 0

    local startPos = {x = 0, y = 0, z = 0}
    vec3f_copy(startPos, m.pos)
    ----- update_walking_speed() ----- (Inlined)

    m.faceAngle.y =
        m.intendedYaw - approach_s32(s16(m.intendedYaw - m.faceAngle.y), 0, 0x800, 0x800)
    apply_slope_accel(m)

    ----------------------------------

    local step = perform_ground_step(m)
    if step == GROUND_STEP_LEFT_GROUND then
        set_character_animation(m, CHAR_ANIM_GENERAL_FALL)
        return set_mario_action(m, ACT_FREEFALL, 0)
    elseif step == GROUND_STEP_NONE then
        anim_and_audio_for_walk(m)
        if m.intendedMag - m.forwardVel > 16.0 then
            m.particleFlags = m.particleFlags | PARTICLE_DUST
        end
    elseif step == GROUND_STEP_HIT_WALL then
        push_or_sidle_wall(m, startPos)
        m.actionTimer = 0
    end

    check_ledge_climb_down(m)
    tilt_body_walking(m, m.faceAngle.y)

    if not (m.floor and m.floor.object and obj_has_behavior_id(m.floor.object, gItemInfoLUT["block"].behaviorId) ~= 0) then
        return set_mario_action(m, ACT_WALKING, 0)
    end

    return false
end

---@param m MarioState
---@param obj Object
---@param intType integer
local function allow_interact(m, obj, intType)
    if m.playerIndex ~= 0 then return end

    if m.action == ACT_FREE_MOVE then
        return false
    end
end

hook_mario_action(ACT_FREE_MOVE, act_free_move)
hook_mario_action(ACT_DASH, act_dash)
hook_event(HOOK_ALLOW_INTERACT, allow_interact)

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