-- localize functions to improve performance
local mario_set_forward_vel,set_mario_action,reset_camera,soft_reset_camera,dist_between_object_and_point,obj_mark_for_deletion = mario_set_forward_vel,set_mario_action,reset_camera,soft_reset_camera,dist_between_object_and_point,obj_mark_for_deletion

local activateCheckpointTimer = false
local checkpointCheckTimer = 2
local savedSAngleY = 0
local savedCheckpointX = 0
local savedCheckpointY = 0
local savedCheckpointZ = 0
local savedWarpX = 0
local savedWarpY = 0
local savedWarpZ = 0
local reachedCheckpoint = false
local hasDied = false

local function on_warp()
    local m = gMarioStates[0]
    if m.playerIndex ~= 0 then return end

    if m.action ~= ACT_TELEPORT_FADE_IN then
        savedWarpX = m.pos.x
        savedWarpY = m.pos.y
        savedWarpZ = m.pos.z
        savedCheckpointX = m.pos.x
        savedCheckpointY = m.pos.y
        savedCheckpointZ = m.pos.z
        savedSAngleY = m.faceAngle.y
    end
end

---@param m MarioState
local function on_death(m)
    if m.playerIndex ~= 0 then return end
    if m.action == ACT_FREE_MOVE then return false end

    m.health = 0x880
    m.healCounter = 8
    m.hurtCounter = 0
    m.faceAngle.y = savedSAngleY
    mario_set_forward_vel(m, 0)
    m.vel.y = 0
    drop_and_set_mario_action(m, ACT_FREEFALL, 0)
    soft_reset_camera(m.area.camera)
    m.marioObj.header.gfx.animInfo.animFrame = 0
    m.capTimer = 1

    if reachedCheckpoint then
        m.pos.x = savedCheckpointX
        m.pos.y = savedCheckpointY
        m.pos.z = savedCheckpointZ
    else
        m.pos.x = savedWarpX
        m.pos.y = savedWarpY
        m.pos.z = savedWarpZ
    end

    hasDied = true
    return false
end

---@param m MarioState
local function mario_update(m)
    if m.playerIndex ~= 0 then return end

    if m.floor and m.floor.object then
        local obj = m.floor.object
        if obj.oBehParams & 0xFF == BLOCK_SURFACE_ID_CHECKPOINT and m.pos.y == m.floorHeight then
            savedCheckpointX = obj.oPosX
            savedCheckpointY = obj.oPosY + 100 * obj.header.gfx.scale.y
            savedCheckpointZ = obj.oPosZ
            savedSAngleY = obj.oFaceAngleYaw
            reachedCheckpoint = true
        end
    end

    if reachedCheckpoint and hasDied then
        activateCheckpointTimer = true
    end

    if activateCheckpointTimer then
        if checkpointCheckTimer > 0 then
            checkpointCheckTimer = checkpointCheckTimer - 1
        else
            activateCheckpointTimer = false
        end
    else
        checkpointCheckTimer = 2
    end

    if checkpointCheckTimer == 0 then
        if m.floor and m.floor.object then
            local obj = m.floor.object
            if obj.oBehParams & 0xFF ~= BLOCK_SURFACE_ID_CHECKPOINT then
                m.pos.x = savedWarpX
                m.pos.y = savedWarpY
                m.pos.z = savedWarpZ
                reachedCheckpoint = false
            end
        else
            m.pos.x = savedWarpX
            m.pos.y = savedWarpY
            m.pos.z = savedWarpZ
            reachedCheckpoint = false
        end
    end

    hasDied = false
end

local function joined_game()
    local m = gMarioStates[0]
    savedWarpX = m.pos.x
    savedWarpY = m.pos.y
    savedWarpZ = m.pos.z
end

hook_event(HOOK_ON_WARP, on_warp)
hook_event(HOOK_ON_DEATH, on_death)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_JOINED_GAME, joined_game)

local function on_kill_chat_command()
    on_death(gMarioStates[0])
    return true
end

hook_chat_command('kill', "| Respawns yourself", on_kill_chat_command)