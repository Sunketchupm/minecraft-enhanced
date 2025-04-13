gGlobalSyncTable.canTeleport = true
gGlobalSyncTable.bubbleTeleport = false
gGlobalSyncTable.teleAll = false

local function strip_colors(name)
    local string = ''
    local inSlash = false
    for i = 1, #name do
        local character = name:sub(i,i)
        if character == '\\' then
            inSlash = not inSlash
        elseif not inSlash then
            string = string .. character
        end
    end
    return string
end

---@param player_name string
---@return integer | nil
local function get_global_index_from_name(player_name)
    for i = 0, MAX_PLAYERS - 1, 1 do
        if gNetworkPlayers[i].connected then
            if (strip_colors(gNetworkPlayers[i].name)):lower() == (player_name):lower() then
                i = network_global_index_from_local(i)
                return i
            end
        end
    end
    return nil
end

---@return boolean
local function is_current_area_sync_valid()
    local np
    for i = 0, MAX_PLAYERS - 1, 1 do
        np = gNetworkPlayers[i]
        if np and np.connected and (not np.currLevelSyncValid or not np.currAreaSyncValid) then
            return false
        end
    end
    return true
end

local teleport_due = false

---@param target_player MarioState
local function initiate_teleport_to(target_player)
    local target_player_global_index = network_global_index_from_local(target_player.playerIndex)

    ---@type NetworkPlayer
    local np_target = network_player_from_global_index(target_player_global_index)

    if target_player and np_target.connected then
        if is_player_in_local_area(target_player) == 0 then
            warp_to_level(np_target.currLevelNum, np_target.currAreaIndex, np_target.currActNum)
            teleport_due = true
        end
        vec3f_copy(gMarioStates[0].pos, target_player.pos)
        return
    end

    djui_chat_message_create("Teleport failed: Couldn't find target")
end

---@type MarioState | nil
local targetMarioState = nil

local function sync_valid()
    if not gGlobalSyncTable.canTeleport then return end
    if not targetMarioState then return end

    if teleport_due and is_current_area_sync_valid() and (not gGlobalSyncTable.bubbleTeleport and targetMarioState.action ~= ACT_BUBBLED) then
        vec3f_copy(gMarioStates[0].pos, targetMarioState.pos)
    elseif teleport_due then
        local text = "Teleport failed"
        if targetMarioState.action == ACT_BUBBLED then
            text = text .. ": Targeted player is in bubble"
        end
        djui_chat_message_create(text)
    end

    teleport_due = false
end

function on_teleport_chat_command(msg)
    if not gGlobalSyncTable.canTeleport then
        djui_chat_message_create("Teleportation is disabled")
        return true
    end

    if network_is_server() and msg:lower() == 'all' then
        gGlobalSyncTable.teleAll = not gGlobalSyncTable.teleAll
        return true
    end

    ---@type integer | nil
    local index = nil
    --Branches if a name or index is entered
    msg = tonumber(msg)
    if not msg then
        -- If a name is entered
        index = get_global_index_from_name(msg)
    else
        -- If a number is entered
        index = network_global_index_from_local(tonumber(msg))
    end

    if not index then
        djui_chat_message_create("Player not found (Invalid index)")
        return true
    end

    local mario_state = gMarioStates[network_local_index_from_global(index)]
    local does_player_exist = mario_state and gNetworkPlayers[mario_state.playerIndex].connected
    if not does_player_exist then
        djui_chat_message_create("Enter a valid player " .. "(Player not connected)")
        return true
    end

    initiate_teleport_to(mario_state)

    return true
end

hook_event(HOOK_ON_SYNC_VALID, sync_valid)

local description = "Teleport to another player, even through levels. Type in the player's name or player index."
if network_is_server() then
    description = description .. "\nUse 'all' to teleport everyone to you."
end
hook_chat_command('tp', description, on_teleport_chat_command)

function on_sync_table_change(tag, oldVal, newVal)
    initiate_teleport_to(gMarioStates[network_local_index_from_global(0)])
end
hook_on_sync_table_change(gGlobalSyncTable, "teleAll", "tag", on_sync_table_change)

function on_allow_teleport_command()
    gGlobalSyncTable.canTeleport = not gGlobalSyncTable.canTeleport
    djui_chat_message_create("Teleportation has been " .. (gGlobalSyncTable.canTeleport and "enabled" or "disabled"))
    return true
end
function on_allow_bubble_teleport_command()
    gGlobalSyncTable.bubbleTeleport = not gGlobalSyncTable.bubbleTeleport
    djui_chat_message_create("Bubble teleportation has been " .. (gGlobalSyncTable.bubbleTeleport and "enabled" or "disabled"))
    return true
end

if network_is_server() then
    hook_chat_command('allow-teleport', "Toggles the teleportation command.", on_allow_teleport_command)
    hook_chat_command('allow-tele-to-bubble', "Toggles whether or not players can teleport to players in bubbles.", on_allow_bubble_teleport_command)
end
