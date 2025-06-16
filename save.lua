-- localize functions to improve performance
local math_floor,string_rep,tonumber,djui_chat_message_create,obj_count_objects_with_behavior_id,obj_get_first_with_behavior_id,math_abs,tostring,obj_get_next_with_same_behavior_id,mod_storage_clear,min,math_min,table_insert,mod_storage_save,mod_storage_load,table_concat,spawn_sync_object = math.floor,string.rep,tonumber,djui_chat_message_create,obj_count_objects_with_behavior_id,obj_get_first_with_behavior_id,math.abs,tostring,obj_get_next_with_same_behavior_id,mod_storage_clear,min,math.min,table.insert,mod_storage_save,mod_storage_load,table.concat,spawn_sync_object

--[[
    There isn't very much space in mod storage and blocks take up a lot of space
    The base64 conversion code was created from ChatGPT :(
]]

--gGlobalSyncTable.allowSameAreaSaveLoad = true

local BLOCK_CHAR_SIZE = 47

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
--- @return integer
--- Function to decode a base64 string to a decimal number
local function decode_base64(encoded)
    local bin = ""
    for i = 1, #encoded do
        local char = encoded:sub(i, i)
        if char ~= "." then
            bin = bin .. base64_to_binary(char)
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

---@param msg string
local function on_save_chat_command(msg)
    --[[if not CanBuild then
        djui_chat_message_create("Can't save. Forbidden from building.")
        return true
    end]]

    if msg:lower() == "clear" then
        mod_storage_clear()
        djui_chat_message_create("All save slots have been cleared")
        return true
    end

    local encoded_string = ""
    local pad = add_padding
    local encode = encode_base64
    for _, item_behavior_ids in ipairs(all_item_behaviors) do
        local obj = obj_get_first_with_behavior_id(item_behavior_ids)
        ---@type NetworkPlayer
        local np = gNetworkPlayers[0]
        while obj do
            if obj.oOwner == np.globalIndex + 1 then
                local scale_decimal_expansion = {
                    x = math.floor((obj.header.gfx.scale.x - math.floor(obj.header.gfx.scale.x)) * 100),
                    y = math.floor((obj.header.gfx.scale.y - math.floor(obj.header.gfx.scale.y)) * 100),
                    z = math.floor((obj.header.gfx.scale.z - math.floor(obj.header.gfx.scale.z)) * 100)
                }
                local pos_decimal_expansion = {
                    x = math.floor((obj.oPosX - math.floor(obj.oPosX)) * 100),
                    y = math.floor((obj.oPosY - math.floor(obj.oPosY)) * 100),
                    z = math.floor((obj.oPosZ - math.floor(obj.oPosZ)) * 100)
                }
                -- Todo: Force all items to be in range of s16 in a loop rather than just saving
                local yaw = convert_s16(obj.oFaceAngleYaw) + 32768
                local pitch = convert_s16(obj.oFaceAnglePitch) + 32768
                local roll = convert_s16(obj.oFaceAngleRoll) + 32768
                local addon =
                    pad(encode(item_behavior_ids), 3) .. -- 3
                    pad(encode(obj.oModelId), 3) .. -- 6
                    pad(encode((math.floor(obj.oPosX) + 65536)), 3) .. pad(encode(pos_decimal_expansion.x), 2) .. -- 11
                    pad(encode((math.floor(obj.oPosY) + 65536)), 3) .. pad(encode(pos_decimal_expansion.y), 2) .. -- 16
                    pad(encode((math.floor(obj.oPosZ) + 65536)), 3) .. pad(encode(pos_decimal_expansion.z), 2) .. -- 21
                    pad(encode(obj.oAnimState), 2) .. -- 23
                    pad(encode(obj.oItemParams), 6) .. -- 29
                    pad(encode(math.floor(obj.header.gfx.scale.x)), 1) .. pad(encode(scale_decimal_expansion.x), 2) .. -- 32
                    pad(encode(math.floor(obj.header.gfx.scale.y)), 1) .. pad(encode(scale_decimal_expansion.y), 2) .. -- 35
                    pad(encode(math.floor(obj.header.gfx.scale.z)), 1) .. pad(encode(scale_decimal_expansion.z), 2) .. -- 38
                    pad(encode(yaw), 3) .. pad(encode(pitch), 3) .. pad(encode(roll), 3) -- 47

                encoded_string = encoded_string .. addon
            end
            obj = obj_get_next_with_same_behavior_id(obj)
        end
    end

    if encoded_string == "" then
        djui_chat_message_create("Can't save items. You have not placed down any items")
        return true
    end

    local lines = {}
    for i = 1, #encoded_string, MAX_KEY_VALUE_LENGTH - 1 do
        table.insert(lines, encoded_string:sub(i, math.min(i + MAX_KEY_VALUE_LENGTH - 1, #encoded_string)))
    end
    if encoded_string:len() > MAX_KEYS * MAX_KEY_VALUE_LENGTH then
        djui_chat_message_create("Too many items. Can't save.")
        return true
    end

    if mod_storage_exists(msg .. "_1") then
        djui_chat_message_create("Save slot \"" .. msg .."\" found. It has been overwritten")
    end
    for index, value in ipairs(lines) do
        if value ~= "" then
            mod_storage_save(msg .. "_" .. tostring(index), tostring(value))
        end
    end

    djui_chat_message_create("Saved items to slot \"" .. msg .. "\"")
    return true
end

---@param msg string
local function on_load_chat_command(msg)
    --[[if not allowBuild then
        djui_chat_message_create("Can't load. Forbidden from building.")
        return true
    end]]
    --[[if not gGlobalSyncTable.allowSameAreaSaveLoad then
        ---@type NetworkPlayer
        local np = gNetworkPlayers[0]
        for i = 1, MAX_PLAYERS - 1, 1 do
            if (np and np.connected and gNetworkPlayers[i] and gNetworkPlayers[i].connected) and
                np.currLevelNum == gNetworkPlayers[i].currLevelNum and np.currAreaIndex == gNetworkPlayers[i].currAreaIndex and np.currActNum == gNetworkPlayers[i].currActNum then

                djui_chat_message_create("Can't load. Loading while anyone is in the same level is disabled.")
                return true
            end
        end
    end]]

    local lines = {}
    local exists = false
    for i = 1, MAX_KEYS, 1 do
        if mod_storage_exists(msg .. "_" .. tostring(i)) then
            local encoded = mod_storage_load(msg .. "_" .. tostring(i))
            table.insert(lines, encoded)
            exists = true
        elseif exists then
            break
        else
            djui_chat_message_create("Save slot \"" .. msg .. "\" doesn't exist")
            return true
        end
    end

    local decode = decode_base64
    local encoded_string = table.concat(lines)
    --local count = 0
    for i = 1, #encoded_string, BLOCK_CHAR_SIZE do
        --count = count + 1
        --djui_chat_message_create(count, encoded_string:sub(i + 0, i + 2))
        local behavior_id    = decode(encoded_string:sub(i + 0, i + 2)  )
        --djui_chat_message_create(count, "ID: " .. encoded_string:sub(i + 0, i + 2))
        local model          = decode(encoded_string:sub(i + 3, i + 5)  )
        --djui_chat_message_create(count, "Model: " .. encoded_string:sub(i + 3, i + 5))
        local x_pos          = decode(encoded_string:sub(i + 6, i + 8)  ) - 65536
        --djui_chat_message_create(count, "X: " .. encoded_string:sub(i + 6, i + 8))
        local x_pos_decimal  = decode(encoded_string:sub(i + 9, i + 10) )
        --djui_chat_message_create(count, "X decimal: " .. encoded_string:sub(i + 9, i + 10))
        local y_pos          = decode(encoded_string:sub(i + 11, i + 13)) - 65536
        --djui_chat_message_create(count, "Y: " .. encoded_string:sub(i + 11, i + 13))
        local y_pos_decimal  = decode(encoded_string:sub(i + 14, i + 15))
        --djui_chat_message_create(count, "Y Decimal: " .. encoded_string:sub(i + 14, i + 15))
        local z_pos          = decode(encoded_string:sub(i + 16, i + 18)) - 65536
        --djui_chat_message_create(count, "Z: " .. encoded_string:sub(i + 16, i + 18))
        local z_pos_decimal  = decode(encoded_string:sub(i + 19, i + 20))
        --djui_chat_message_create(count, "Z Decimal: " .. encoded_string:sub(i + 19, i + 20))
        local anim_state     = decode(encoded_string:sub(i + 21, i + 22))
        --djui_chat_message_create(count, "Anim: " .. encoded_string:sub(i + 21, i + 22))
        local params         = decode(encoded_string:sub(i + 23, i + 28))
        --djui_chat_message_create(count, "Params: " .. encoded_string:sub(i + 23, i + 28))
        local scaleX         = decode(encoded_string:sub(i + 29, i + 29))
        --djui_chat_message_create(count, "Scale X: " .. encoded_string:sub(i + 29, i + 29))
        local scale_decimalX = decode(encoded_string:sub(i + 30, i + 31))
        --djui_chat_message_create(count, "Scale X Decimal: " .. encoded_string:sub(i + 30, i + 31))
        local scaleY         = decode(encoded_string:sub(i + 32, i + 32))
        --djui_chat_message_create(count, "Scale Y: " .. encoded_string:sub(i + 32, i + 32))
        local scale_decimalY = decode(encoded_string:sub(i + 33, i + 34))
        --djui_chat_message_create(count, "Scale Y Decimal: " .. encoded_string:sub(i + 33, i + 34))
        local scaleZ         = decode(encoded_string:sub(i + 35, i + 35))
        --djui_chat_message_create(count, "Scale Z: " .. encoded_string:sub(i + 35, i + 35))
        local scale_decimalZ = decode(encoded_string:sub(i + 36, i + 37))
        --djui_chat_message_create(count, "Scale Z Decimal: " .. encoded_string:sub(i + 36, i + 37))
        local yaw            = decode(encoded_string:sub(i + 38, i + 40)) - 32768
        --djui_chat_message_create(count, "Yaw: " .. encoded_string:sub(i + 38, i + 40))
        local pitch          = decode(encoded_string:sub(i + 41, i + 43)) - 32768
        --djui_chat_message_create(count, "Pitch: " .. encoded_string:sub(i + 41, i + 43))
        local roll           = decode(encoded_string:sub(i + 44, i + 46)) - 32768
        --djui_chat_message_create(count, "Roll: " .. encoded_string:sub(i + 44, i + 46))

        local item = spawn_sync_object(
            behavior_id,
            model,
            x_pos + x_pos_decimal * 0.01, y_pos + y_pos_decimal * 0.01, z_pos + z_pos_decimal * 0.01,
            ---@param obj Object
            function (obj)
                obj.oAnimState = anim_state
                obj.oOpacity = 255
                obj.oFaceAngleYaw = yaw
                obj.oFaceAnglePitch = pitch
                obj.oFaceAngleRoll = roll
                obj.oMoveAngleYaw = yaw
                obj.oMoveAnglePitch = pitch
                obj.oMoveAngleRoll = roll
                obj.oItemParams = params
                obj.oScaleX = scaleX + (scale_decimalX * 0.01)
                obj.oScaleY = scaleY + (scale_decimalY * 0.01)
                obj.oScaleZ = scaleZ + (scale_decimalZ * 0.01)
                obj_scale_xyz(obj, scaleX + (scale_decimalX * 0.01), scaleY + (scale_decimalY * 0.01), scaleZ + (scale_decimalZ * 0.01))
                obj.globalPlayerIndex = gNetworkPlayers[0].globalIndex
                obj.oOwner = gNetworkPlayers[0].globalIndex + 1
                obj.oModelId = model
            end
        )

        if not item then
            djui_chat_message_create("Item failed to place. Perhaps the object limit was reached?")
        end
    end
    djui_chat_message_create("Loaded items from slot \"" .. msg .. "\"")
    return true
end

hook_chat_command("save", "[<slot name>|clear] | Stores the items you placed to be loaded again for later use", on_save_chat_command)
hook_chat_command("load", "[<slot name>] | Loads the items that have been stored", on_load_chat_command)