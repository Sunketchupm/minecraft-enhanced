-- localize functions to improve performance
local mario_set_forward_vel,perform_air_step,set_character_animation,queue_rumble_data_mario,check_fall_damage_or_get_stuck,set_mario_action,mario_bonk_reflection,lava_boost_on_wall,check_wall_kick,play_knockback_sound,common_air_knockback_step,update_air_without_turn = mario_set_forward_vel,perform_air_step,set_character_animation,queue_rumble_data_mario,check_fall_damage_or_get_stuck,set_mario_action,mario_bonk_reflection,lava_boost_on_wall,check_wall_kick,play_knockback_sound,common_air_knockback_step,update_air_without_turn

ACT_FREE_MOVE = allocate_mario_action(ACT_GROUP_AUTOMATIC | ACT_FLAG_INTANGIBLE | ACT_FLAG_INVULNERABLE)

local savedMarioYaw = 0
local marioYaw_timer = 0
local prev_romhack_cam_state = camera_get_romhack_override()
---@param m MarioState
local function act_free_move(m)
    if MenuOpen then return false end

    m.peakHeight = m.pos.y
    m.health = 0x880
    m.capTimer = 1
    m.squishTimer = 0
    local camera = m.area.camera
    if camera.cutscene == CUTSCENE_QUICKSAND_DEATH then
        soft_reset_camera(camera)
    end
    if camera.mode == CAMERA_MODE_WATER_SURFACE or camera.mode == CAMERA_MODE_BEHIND_MARIO then
        set_camera_mode(camera, CAMERA_MODE_NONE, 0)
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
        marioYaw_timer = marioYaw_timer + 1
        if marioYaw_timer == 1 then
            savedMarioYaw = m.faceAngle.y
        end
    else
        marioYaw_timer = 0
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
        m.forwardVel = 20
    else
        m.forwardVel = 0
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

    --if m.pos.y < m.floorHeight then
    --    m.pos.y = m.floorHeight
    --end
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

local default_respawn_location = gVec3fZero()
respawn_location = gVec3fZero()

---@param m MarioState
local function on_death(m)
    if m.action == ACT_FREE_MOVE then return false end
    vec3f_copy(m.pos, respawn_location)
    mario_pop_bubble(m)
    set_mario_action(m, ACT_FREEFALL, 0)
    m.invincTimer = 1
    m.capTimer = 1
    m.squishTimer = 1
    m.faceAngle.y = 0
    return false
end

local function on_warp()
    local m = gMarioStates[0]
    vec3f_copy(default_respawn_location, m.pos)
    vec3f_copy(respawn_location, m.pos)
end

---@param m MarioState
local function allow_force_water_action(m)
    if m.action == ACT_FREE_MOVE then return false end
end

---@param m MarioState
local function allow_hazard_surface(m)
    if m.action == ACT_FREE_MOVE then return false end
end

---@param m MarioState
local function override_geometry_inputs(m)
    if m.action == ACT_FREE_MOVE then
        m.floor = collision_find_floor(m.pos.x, m.pos.y, m.pos.z)
        m.floorHeight = find_floor_height(m.pos.x, m.pos.y, m.pos.z)
        if not m.floor then
            vec3f_copy(m.pos, m.marioObj.header.gfx.pos)
            m.floorHeight = find_floor_height(m.pos.x, m.pos.y, m.pos.z)
        end

        m.ceil = collision_find_ceil(m.pos.x, m.floorHeight, m.pos.z)
        m.ceilHeight = find_ceil_height(m.pos.x, m.floorHeight, m.pos.z)
        return false
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
        else
            start_timer = true
        end
    end
end

hook_mario_action(ACT_FREE_MOVE, act_free_move)
hook_event(HOOK_ALLOW_INTERACT, allow_interact)
hook_event(HOOK_ON_DEATH, on_death)
hook_event(HOOK_ON_WARP, on_warp)
hook_event(HOOK_ALLOW_FORCE_WATER_ACTION, allow_force_water_action)
hook_event(HOOK_ALLOW_HAZARD_SURFACE, allow_hazard_surface)
hook_event(HOOK_MARIO_OVERRIDE_GEOMETRY_INPUTS, override_geometry_inputs)
hook_event(HOOK_MARIO_UPDATE, mario_update)

hook_chat_command("restart", "[<nothing>|reset] Restarts you to your current checkpoint, or use \"reset\" to respawn at spawn", function (msg)
    if msg:lower() == "reset" then
        vec3f_copy(respawn_location, default_respawn_location)
    end
    on_death(gMarioStates[0])
    return true
end)

-----------------------------------------------------------------------------------------------------------

ACT_CUSTOM_VERTICAL_WIND = allocate_mario_action(ACT_GROUP_AIRBORNE | ACT_FLAG_AIR | ACT_FLAG_DIVING | ACT_FLAG_SWIMMING_OR_FLYING)
ACT_DASH = allocate_mario_action(ACT_GROUP_MOVING | ACT_FLAG_MOVING)

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

    m.marioObj.header.gfx.angle.x = convert_s16(6144 * intendedMag * coss(intendedDYaw))
    --m.marioObj.header.gfx.angle.y = convert_s16(-4096 * intendedMag * convert_s16(sins(intendedDYaw)))
    return false
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
        m.intendedYaw - approach_s32(convert_s16(m.intendedYaw - m.faceAngle.y), 0, 0x800, 0x800)
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

    if not (m.floor and m.floor.object and obj_has_behavior_id(m.floor.object, bhvMceBlock) ~= 0) then
        return set_mario_action(m, ACT_WALKING, 0)
    end

    return false
end

hook_mario_action(ACT_CUSTOM_VERTICAL_WIND, { every_frame = act_custom_vertical_wind })
hook_mario_action(ACT_DASH, { every_frame = act_dash })

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