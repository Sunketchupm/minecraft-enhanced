-- localize functions to improve performance (soon)

--[[
    There isn't very much space in mod storage and blocks take up a lot of space
    The base64 conversion code was created from ChatGPT :(
]]

local BLOCK_CHAR_SIZE = 53

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

    local num = tonumber(bin, 2)
    if num == nil then
        djui_chat_message_create("Failed to load save file. It may be incompatible")
        return 0
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
    local save_all = false
    if msg:lower() == "clear" then
        if mod_storage_clear() then
            djui_chat_message_create("All save slots have been cleared")
        else
            djui_chat_message_create("Failed to clear save slots")
        end
        return true
    elseif msg:lower() == "all" then
        djui_chat_message_create("All items placed in this area will be saved")
        save_all = true
    end

    if msg == "" then
        msg = "default"
    end

    local encoded_string = ""
    local pad = add_padding
    local encode = encode_base64
    for _, item_behavior_ids in ipairs(g_all_item_behaviors) do
        local obj = obj_get_first_with_behavior_id(item_behavior_ids)
        ---@type NetworkPlayer
        local np = gNetworkPlayers[0]
        while obj do
            if save_all or obj.oOwner == np.globalIndex + 1 then
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
                    pad(encode(obj_get_model_id_extended(obj)), 3) .. -- 6
                    pad(encode((math.floor(obj.oPosX) + 65536)), 3) .. pad(encode(pos_decimal_expansion.x), 2) .. -- 11
                    pad(encode((math.floor(obj.oPosY) + 65536)), 3) .. pad(encode(pos_decimal_expansion.y), 2) .. -- 16
                    pad(encode((math.floor(obj.oPosZ) + 65536)), 3) .. pad(encode(pos_decimal_expansion.z), 2) .. -- 21
                    pad(encode(obj.oAnimState), 2) .. -- 23
                    pad(encode(obj.oItemParams), 6) .. -- 29
                    pad(encode(math.floor(obj.header.gfx.scale.x)), 1) .. pad(encode(scale_decimal_expansion.x), 2) .. -- 32
                    pad(encode(math.floor(obj.header.gfx.scale.y)), 1) .. pad(encode(scale_decimal_expansion.y), 2) .. -- 35
                    pad(encode(math.floor(obj.header.gfx.scale.z)), 1) .. pad(encode(scale_decimal_expansion.z), 2) .. -- 38
                    pad(encode(yaw), 3) .. pad(encode(pitch), 3) .. pad(encode(roll), 3) .. -- 47
                    pad(encode(obj.oBlockSurfaceProperties), 6) -- 53

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
        for i = 1, 500 do
            if mod_storage_exists(msg .. "_" .. i) then
                mod_storage_remove(msg .. "_" .. i)
            else
                break
            end
        end
    end
    for index, value in ipairs(lines) do
        if value ~= "" then
            mod_storage_save(msg .. "_" .. tostring(index), tostring(value))
        end
    end

    djui_chat_message_create("Saved items to slot \"" .. msg .. "\"")
    return true
end

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

local s_load_name = "default"
local s_load_lines = {}
g_load_block_datas = {}
local s_load_state = 0
local s_reload_items = false

local function on_load_part_2()
    if s_load_state == 1 then
        for _, texture in ipairs(gMenuBlockTextureIcons) do
            djui_hud_render_texture(texture, 0, 0, 1, 1)
        end
        s_load_state = 2
    elseif s_load_state == 2 then
        if s_reload_items then
            on_clear_chat_command("")
        end

        local decode = decode_base64
        local encoded_string = table.concat(s_load_lines)
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
            local properties     = decode(encoded_string:sub(i + 47, i + 52))

            local item = spawn_sync_object(
                behavior_id,
                model,
                x_pos + x_pos_decimal * 0.01, y_pos + y_pos_decimal * 0.01, z_pos + z_pos_decimal * 0.01,
                ---@param obj Object
                function (obj)
                    obj.oOpacity = 255
                    obj.oFaceAngleYaw = yaw
                    obj.oFaceAnglePitch = pitch
                    obj.oFaceAngleRoll = roll
                    obj.oMoveAngleYaw = yaw
                    obj.oMoveAnglePitch = pitch
                    obj.oMoveAngleRoll = roll
                    obj.oItemParams = params
                    obj.oBlockSurfaceProperties = properties
                    obj.oScaleX = scaleX + (scale_decimalX * 0.01)
                    obj.oScaleY = scaleY + (scale_decimalY * 0.01)
                    obj.oScaleZ = scaleZ + (scale_decimalZ * 0.01)
                    obj_scale_xyz(obj, scaleX + (scale_decimalX * 0.01), scaleY + (scale_decimalY * 0.01), scaleZ + (scale_decimalZ * 0.01))
                    obj.oAnimState = anim_state
                    obj.globalPlayerIndex = gNetworkPlayers[0].globalIndex
                    obj.oOwner = gNetworkPlayers[0].globalIndex + 1
                end
            )

            if not item then
                djui_chat_message_create("Item failed to place. Perhaps the object limit was reached?")
            else
                table.insert(g_load_block_datas, {
                    item, behavior_id, model,
                    x_pos + x_pos_decimal * 0.01, y_pos + y_pos_decimal * 0.01, z_pos + z_pos_decimal * 0.01,
                    pitch, yaw, roll,
                    params, properties,
                    scaleX + scale_decimalX, scaleY + scale_decimalY, scaleZ + scale_decimalZ,
                    anim_state, 0
                })
            end
        end
        djui_chat_message_create("Loaded items from slot \"" .. s_load_name .. "\"")
        s_load_state = 0
        s_load_name = "default"
        s_load_lines = {}
        s_reload_items = false
    end
end

---@param m MarioState
local function retry_place_block(m)
    if m.playerIndex ~= 0 then return end

    for index, respawn_item in ipairs(g_load_block_datas) do
        ---@type Object
        local item_obj = respawn_item[1]
        if not item_obj or item_obj.activeFlags == 0 then
            local behavior_id = respawn_item[2]
            local model = respawn_item[3]
            local x = respawn_item[4]
            local y = respawn_item[5]
            local z = respawn_item[6]
            local pitch = respawn_item[7]
            local yaw = respawn_item[8]
            local roll = respawn_item[9]
            local params = respawn_item[10]
            local properties = respawn_item[11]
            local scaleX = respawn_item[12]
            local scaleY = respawn_item[13]
            local scaleZ = respawn_item[14]
            local anim_state = respawn_item[15]
            local respawned_item = spawn_sync_object(
                behavior_id,
                model,
                x, y, z,
                ---@param obj Object
                function (obj)
                    obj.oOpacity = 255
                    obj.oFaceAngleYaw = yaw
                    obj.oFaceAnglePitch = pitch
                    obj.oFaceAngleRoll = roll
                    obj.oMoveAngleYaw = yaw
                    obj.oMoveAnglePitch = pitch
                    obj.oMoveAngleRoll = roll
                    obj.oItemParams = params
                    obj.oBlockSurfaceProperties = properties
                    obj.oScaleX = scaleX
                    obj.oScaleY = scaleY
                    obj.oScaleZ = scaleZ
                    obj_scale_xyz(obj, scaleX, scaleY, scaleZ)
                    obj.oAnimState = anim_state
                    obj.globalPlayerIndex = gNetworkPlayers[0].globalIndex
                    obj.oOwner = gNetworkPlayers[0].globalIndex + 1
                end
            )

            if not respawned_item then
                djui_chat_message_create("Item failed to place. Perhaps the object limit was reached?")
                g_load_block_datas = {}
                break
            else
                g_load_block_datas[index][1] = respawned_item
                g_load_block_datas[index][15] = 0
            end
        else
            g_load_block_datas[index][15] = respawn_item[15] + 1
        end

        if respawn_item[15] > 1 then
            table.remove(g_load_block_datas, index)
        end
    end
end

---@param msg string
local function on_load_chat_command(msg)
    local exists = false
    local has_reload_param = (msg:sub(-6, #msg)):lower() == "reload"
    if has_reload_param then
        msg = msg:sub(1, -8)
        s_reload_items = true
    end

    if msg == "" then
        msg = "default"
    end

    for i = 1, MAX_KEYS, 1 do
        if mod_storage_exists(msg .. "_" .. tostring(i)) then
            local encoded = mod_storage_load(msg .. "_" .. tostring(i))
            table.insert(s_load_lines, encoded)
            exists = true
        elseif exists then
            break
        else
            djui_chat_message_create("Save slot \"" .. msg .. "\" doesn't exist")
            return true
        end
    end

    if s_load_state == 0 then
        s_load_state = 1
        s_load_name = msg
        g_load_block_datas = {}
    end
    return true
end

hook_chat_command("save", "[<slot name>|clear|all] | Stores the items you placed to be loaded again for later use", on_save_chat_command)
hook_chat_command("load", "[<slot name>] [reload] | Loads the items that have been stored", on_load_chat_command)

hook_event(HOOK_ON_HUD_RENDER, on_load_part_2)
hook_event(HOOK_MARIO_UPDATE, retry_place_block)

local save_slot_name = ""

hook_mod_menu_inputbox("Save Slot Name", "default", 20, function (_, val)
    save_slot_name = val
end)
hook_mod_menu_button("Save", function (_)
    on_save_chat_command(save_slot_name)
end)
hook_mod_menu_button("Load", function (_)
    on_load_chat_command(save_slot_name)
end)
hook_mod_menu_button("Save Slot Clear", function (_)
    on_save_chat_command("clear")
end)