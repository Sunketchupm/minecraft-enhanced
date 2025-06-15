-- localize functions to improve performance
local mario_set_forward_vel,perform_air_step,set_character_animation,queue_rumble_data_mario,check_fall_damage_or_get_stuck,set_mario_action,mario_bonk_reflection,lava_boost_on_wall,check_wall_kick,play_knockback_sound,common_air_knockback_step,update_air_without_turn = mario_set_forward_vel,perform_air_step,set_character_animation,queue_rumble_data_mario,check_fall_damage_or_get_stuck,set_mario_action,mario_bonk_reflection,lava_boost_on_wall,check_wall_kick,play_knockback_sound,common_air_knockback_step,update_air_without_turn

ACT_FREE_MOVE = allocate_mario_action(ACT_GROUP_AUTOMATIC | ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE)

local savedMarioYaw = 0
local prev_romhack_cam_state = camera_get_romhack_override()
---@param m MarioState
local function act_free_move(m)
    if MenuOpen then return false end

    m.peakHeight = m.pos.y
    m.health = 0x880
    m.capTimer = 1
    m.squishTimer = 0
    if m.area.camera.cutscene ~= 0 then
        reset_camera(m.area.camera)
    end

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

    if m.controller.stickMag > 0 then
        if bHeld then
            m.vel.x = sins(m.intendedYaw) * 70
            m.vel.z = coss(m.intendedYaw) * 70
            if lHeld then
                m.vel.x = sins(m.intendedYaw) * 5
                m.vel.z = coss(m.intendedYaw) * 5
            end
        else
            m.vel.x = sins(m.intendedYaw) * 20
            m.vel.z = coss(m.intendedYaw) * 20
        end
    end

    set_character_animation(m, CHAR_ANIM_IDLE_HEAD_CENTER)

    local next_pos = vec3f_add(m.vel, vec3f_copy(gVec3fZero(), m.pos))
    local floor_height = find_floor_height(next_pos.x, next_pos.y, next_pos.z)
    if floor_height == gLevelValues.floorLowerLimit then
        floor_height = find_floor_height(next_pos.x, next_pos.y + m.marioObj.hitboxHeight, next_pos.z)
        next_pos.y = floor_height
    end
    if floor_height ~= gLevelValues.floorLowerLimit then
        vec3f_copy(m.pos, next_pos)
    end

    if m.pos.y < m.floorHeight then
        m.pos.y = m.floorHeight
    end
    vec3f_zero(m.vel)

    vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
    vec3s_set(m.marioObj.header.gfx.angle, 0, m.faceAngle.y, 0)
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
    else
        warp_to_start_level()
    end
    mario_pop_bubble(m)
    set_mario_action(m, ACT_FREEFALL, 0)
    m.invincTimer = 1
    m.capTimer = 1
    m.squishTimer = 1
    return false
end

---@param m MarioState
local function allow_force_water_action(m)
    if m.action == ACT_FREE_MOVE then return false end
end

---@param m MarioState
local function allow_hazard_surface(m)
    if m.action == ACT_FREE_MOVE then return false end
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
            start_timer = false
            timer = 0

            if m.action == ACT_SQUISHED then
                m.pos.y = m.pos.y + m.marioObj.hitboxHeight
                m.squishTimer = 1
            end

            if m.action ~= ACT_FREE_MOVE then
                prev_romhack_cam_state = camera_get_romhack_override()
            end
            local next_action = m.action == ACT_FREE_MOVE and ACT_FREEFALL or ACT_FREE_MOVE
            if next_action == ACT_FREE_MOVE then
                camera_set_romhack_override(RCO_ALL_INCLUDING_VANILLA)
            else
                if prev_romhack_cam_state == RCO_NONE or
                    (level_is_vanilla_level(gNetworkPlayers[0].currLevelNum) and prev_romhack_cam_state == RCO_ALL or prev_romhack_cam_state == RCO_ALL_EXCEPT_BOWSER) then
                    camera_set_romhack_override(RCO_DISABLE)
                else
                    camera_set_romhack_override(prev_romhack_cam_state)
                end
            end
            drop_and_set_mario_action(m, next_action, 0)
            mario_set_forward_vel(m, 0)
        else
            start_timer = true
        end
    end
end

hook_mario_action(ACT_FREE_MOVE, act_free_move)
hook_event(HOOK_ALLOW_INTERACT, allow_interact)
hook_event(HOOK_ON_DEATH, on_death)
hook_event(HOOK_ALLOW_FORCE_WATER_ACTION, allow_force_water_action)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ALLOW_HAZARD_SURFACE, allow_hazard_surface)

-----------------------------------------------------------------------------------------------------------

ACT_CUSTOM_VERTICAL_WIND = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_DIVING | ACT_FLAG_SWIMMING_OR_FLYING)

---@param m MarioState
local function act_custom_vertical_wind(m)
    local intendedDYaw = -convert_s16(m.intendedYaw - m.faceAngle.y)
    local intendedMag = m.intendedMag / 32.0

    play_character_sound_if_no_flag(m, CHAR_SOUND_HERE_WE_GO, MARIO_MARIO_SOUND_PLAYED)
    if m.actionState == 0 then
        set_character_animation(m, CHAR_ANIM_FORWARD_SPINNING_FLIP)
        if m.marioObj.header.gfx.animInfo.animFrame == 1 then
            play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)
            queue_rumble_data_mario(m, 8, 80)
        end

        if is_anim_past_end(m) ~= 0 then
            m.actionState = 1
        end
    else
        set_character_animation(m, CHAR_ANIM_AIRBORNE_ON_STOMACH)
    end

    update_air_without_turn(m)
    local step = perform_air_step(m, 0)
    if step == AIR_STEP_LANDED then
        set_mario_action(m, ACT_DIVE_SLIDE, 0)
    elseif step == AIR_STEP_HIT_WALL then
        mario_set_forward_vel(m, -16)
    end

    m.marioObj.header.gfx.angle.x = convert_s16(6144 * intendedMag * convert_s16(coss(intendedDYaw)))
    --m.marioObj.header.gfx.angle.y = convert_s16(-4096 * intendedMag * convert_s16(sins(intendedDYaw)))
    return false
end

hook_mario_action(ACT_CUSTOM_VERTICAL_WIND, { every_frame = act_custom_vertical_wind })

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