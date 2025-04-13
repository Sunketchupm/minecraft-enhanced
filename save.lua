-- localize functions to improve performance
local math_floor,string_rep,tonumber,djui_chat_message_create,obj_count_objects_with_behavior_id,obj_get_first_with_behavior_id,math_abs,tostring,obj_get_next_with_same_behavior_id,mod_storage_clear,min,math_min,table_insert,mod_storage_save,mod_storage_load,table_concat,spawn_sync_object = math.floor,string.rep,tonumber,djui_chat_message_create,obj_count_objects_with_behavior_id,obj_get_first_with_behavior_id,math.abs,tostring,obj_get_next_with_same_behavior_id,mod_storage_clear,min,math.min,table.insert,mod_storage_save,mod_storage_load,table.concat,spawn_sync_object

--[[
    There isn't very much space in mod storage and blocks take up a lot of space
    The base64 conversion code was created from ChatGPT :(
]]

gGlobalSyncTable.allowSameAreaSaveLoad = true

local BLOCK_CHAR_SIZE = 29

local base64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

---@param num number
--- Function to convert a decimal number to binary string
local function decimal_to_binary(num)
    local bin = ""
    while num > 0 do
        local rem = num % 2
        bin = rem .. bin
        num = math.floor(num / 2)
    end
    return bin
end

--- @param bin string
--- Function to pad binary string to a multiple of 6
local function pad_binary(bin)
    local padding = 6 - (#bin % 6)
    if padding == 6 then
        return bin
    else
        return string.rep("0", padding) .. bin
    end
end


--- @param bin string
--- Function to convert a binary string to a base64 character
local function binary_to_base64(bin)
    local index = tonumber(bin, 2) + 1
    return base64Chars:sub(index, index)
end

--- @param char string
--- Function to convert a base64 character to a binary string
local function base64_to_binary(char)
    local index = base64Chars:find(char) - 1
    local bin = decimal_to_binary(index)
    return string.rep("0", 6 - #bin) .. bin
end


--- @param num number?
--- Function to encode a decimal number to base64
local function encode_base64(num)
    if not num then return "B" end
    num = num + 1

    local bin = decimal_to_binary(num)
    bin = pad_binary(bin)

    local encoded = ""
    for i = 1, #bin, 6 do
        local chunk = bin:sub(i, i+5)
        encoded = encoded .. binary_to_base64(chunk)
    end

    return encoded
end

--- @param encoded string
--- @param reassign_blank boolean
--- @return integer
--- Function to decode a base64 string to a decimal number
local function decode_base64(encoded, reassign_blank)
    local bin = ""
    for i = 1, #encoded do
        local char = encoded:sub(i, i)
        if char ~= "." then
            bin = bin .. base64_to_binary(char)
        elseif reassign_blank then
            bin = "000001"
        end
    end

    return tonumber(bin, 2) - 1
end

---@param base64_string string
---@param desired_length number
local function add_padding(base64_string, desired_length)
    while base64_string:len() < desired_length do
        base64_string = "." .. base64_string
    end
    return base64_string
end

local function on_save_chat_command()
    if not allowBuild then
        djui_chat_message_create("Can't save. Forbidden from building.")
        return true
    end

    local encoded_string = ""
    for itemBhvId in pairs(gItems) do
        local item = obj_get_first_with_behavior_id(itemBhvId)
        ---@type NetworkPlayer
        local np = gNetworkPlayers[0]
        while item do
            if item.globalPlayerIndex == np.globalIndex then
                local scale_decimal_expansion = {
                    x = math.floor((item.header.gfx.scale.x - math.floor(item.header.gfx.scale.x)) * 100),
                    y = math.floor((item.header.gfx.scale.y - math.floor(item.header.gfx.scale.y)) * 100),
                    z = math.floor((item.header.gfx.scale.z - math.floor(item.header.gfx.scale.z)) * 100)
                }
                -- As no angles are going to be above 32767, this is fine to do
                local yaw = item.oFaceAngleYaw + 32768
                local pitch = item.oFaceAnglePitch + 32768
                local addon =
                    -- As no blocks are going to be at negative positions 65536, this is fine to do
                    add_padding(encode_base64((math.floor(item.oPosX) + 65536)), 3) .. -- 3
                    add_padding(encode_base64((math.floor(item.oPosY) + 65536)), 3) .. -- 6
                    add_padding(encode_base64((math.floor(item.oPosZ) + 65536)), 3) .. -- 9
                    add_padding(encode_base64(item.oAnimState), 2) .. -- 11
                    encode_base64(item.oItemId) .. -- 12
                    add_padding(encode_base64(item.oBehParams & 0x000000FF), 2) .. -- 14
                    encode_base64(math.floor(item.header.gfx.scale.x)) .. add_padding(encode_base64(scale_decimal_expansion.x), 2) .. -- 17
                    encode_base64(math.floor(item.header.gfx.scale.y)) .. add_padding(encode_base64(scale_decimal_expansion.y), 2) .. -- 20
                    encode_base64(math.floor(item.header.gfx.scale.z)) .. add_padding(encode_base64(scale_decimal_expansion.z), 2) .. -- 23
                    add_padding(encode_base64(yaw), 3) .. add_padding(encode_base64(pitch), 3) -- 29

                encoded_string = encoded_string .. addon
            end
            item = obj_get_next_with_same_behavior_id(item)
        end
    end

    if encoded_string == "" then
        djui_chat_message_create("Can't save items. You have not placed down any items")
        return true
    end

    mod_storage_clear()

    local lines = {}
    for i = 1, #encoded_string, MAX_KEY_VALUE_LENGTH - 1 do
        table.insert(lines, encoded_string:sub(i, math.min(i + MAX_KEY_VALUE_LENGTH - 1, #encoded_string)))
    end
    if encoded_string:len() > MAX_KEYS * MAX_KEY_VALUE_LENGTH then
        djui_chat_message_create("Too many items. Can't save.")
        return true
    end

    for index, value in ipairs(lines) do
        if value ~= "" then
            mod_storage_save(tostring(index), tostring(value))
        end
    end

    djui_chat_message_create("Saved items")
    return true
end

local function on_load_chat_command()
    if not allowBuild then
        djui_chat_message_create("Can't load. Forbidden from building.")
        return true
    end
    if not gGlobalSyncTable.allowSameAreaSaveLoad then
        ---@type NetworkPlayer
        local np = gNetworkPlayers[0]
        for i = 1, MAX_PLAYERS - 1, 1 do
            if (np and np.connected and gNetworkPlayers[i] and gNetworkPlayers[i].connected) and
                np.currLevelNum == gNetworkPlayers[i].currLevelNum and np.currAreaIndex == gNetworkPlayers[i].currAreaIndex and np.currActNum == gNetworkPlayers[i].currActNum then

                djui_chat_message_create("Can't load. Loading while anyone is in the same level is disabled.")
                return true
            end
        end
    end

    local lines = {}
    for i = 1, MAX_KEYS, 1 do
        if mod_storage_load(tostring(i)) then
            local encoded = mod_storage_load(tostring(i))
            table.insert(lines, encoded)
        end
    end

    local encoded_string = table.concat(lines)
    for i = 1, #encoded_string, BLOCK_CHAR_SIZE do
        local x_pos          = decode_base64(encoded_string:sub(i + 0, i + 2)  , false) - 65536
        local y_pos          = decode_base64(encoded_string:sub(i + 3, i + 5)  , false) - 65536
        local z_pos          = decode_base64(encoded_string:sub(i + 6, i + 8)  , false) - 65536
        local color          = decode_base64(encoded_string:sub(i + 9, i + 10) , false)
        local id             = decode_base64(encoded_string:sub(i + 11, i + 11), true )
        local surface        = decode_base64(encoded_string:sub(i + 12, i + 13), false)
        local scaleX         = decode_base64(encoded_string:sub(i + 14, i + 14), false)
        local scale_decimalX = decode_base64(encoded_string:sub(i + 15, i + 16), false)
        local scaleY         = decode_base64(encoded_string:sub(i + 17, i + 17), false)
        local scale_decimalY = decode_base64(encoded_string:sub(i + 18, i + 19), false)
        local scaleZ         = decode_base64(encoded_string:sub(i + 20, i + 20), false)
        local scale_decimalZ = decode_base64(encoded_string:sub(i + 21, i + 22), false)
        local yaw            = decode_base64(encoded_string:sub(i + 23, i + 25), false) - 32768
        local pitch          = decode_base64(encoded_string:sub(i + 26, i + 28), false) - 32768

        local item = spawn_sync_object(
            gIdToItem[id].behaviorId,
            gIdToItem[id].model, ---@diagnostic disable-line
            x_pos, y_pos, z_pos,
            ---@param obj Object
            function (obj)
                obj.oAnimState = color
                obj.oOpacity = 255
                obj.oFaceAngleYaw = yaw
                obj.oFaceAnglePitch = pitch
                obj.oFaceAngleRoll = 0
                obj.oItemId = id
                obj.oBehParams = surface
                obj.oScaleX = scaleX + (scale_decimalX * 0.01)
                obj.oScaleY = scaleY + (scale_decimalY * 0.01)
                obj.oScaleZ = scaleZ + (scale_decimalZ * 0.01)
                obj.globalPlayerIndex = gNetworkPlayers[0].globalIndex
            end
        )

        if not item then
            djui_chat_message_create("Failed to spawn item. The object limit may have been reached.")
        end
    end
    djui_chat_message_create("Loaded items")
    return true
end

hook_chat_command("save", "Stores the items you placed to be loaded again for later use. There is only 1 save slot! Only 768 blocks can be saved at a time!", on_save_chat_command)
hook_chat_command("load", "Loads the items that have been stored", on_load_chat_command)