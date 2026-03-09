--[[ 
    !!! REWRITE TO USE NEW MODFS !!!
]]

--[[
---@param msg string
local function on_save_chat_command(msg)
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
]]

local sStorage = mod_fs_get() or mod_fs_create()

---@param msg string
local function save_command(msg)
    local commands = msg:split(" ")
    local save_name = commands[1]

    if not save_name or save_name == "" then
        save_name = "default"
    end

    djui_chat_message_create("Will save to file: \"" .. save_name .. "\"")
    local file = sStorage:get_file(save_name) or sStorage:create_file(save_name, false)
    if not file then
        error("Could not get file: " .. save_name)
        return true
    end
    if not file:erase(file.size) then
        error("Could not erase file: " .. save_name)
        return true
    end
    if not file:rewind() then
        error("Could not rewind file: " .. save_name)
        return true
    end

    if file.isText then
        file:set_text_mode(false)
    end

    if commands[1] == "clear" then
        if mod_storage_clear() then
            djui_chat_message_create("All save slots have been cleared")
        else
            djui_chat_message_create("Failed to clear save slots")
        end
        return true
    end

    local save_all = false
    if commands[2] and commands[2] == "all" then
        djui_chat_message_create("All items placed in this area will be saved")
        save_all = true
    end

    for _, bhv_id in ipairs(gItemBhvIds) do
        local obj = obj_get_first_with_behavior_id(bhv_id)
        ---@type NetworkPlayer
        local np = gNetworkPlayers[0]
        while obj do
            if save_all or obj.oOwner == np.globalIndex + 1 then
                file:write_integer(bhv_id, INT_TYPE_U16)
                file:write_integer(obj_get_model_id_extended(obj), INT_TYPE_U16)
                file:write_number(obj.oPosX, FLOAT_TYPE_F32)
                file:write_number(obj.oPosY, FLOAT_TYPE_F32)
                file:write_number(obj.oPosZ, FLOAT_TYPE_F32)
                file:write_integer(obj.oAnimState, INT_TYPE_S32)
                file:write_integer(obj.oItemParams, INT_TYPE_U32)
                file:write_number(obj.header.gfx.scale.x, FLOAT_TYPE_F32)
                file:write_number(obj.header.gfx.scale.y, FLOAT_TYPE_F32)
                file:write_number(obj.header.gfx.scale.z, FLOAT_TYPE_F32)
                file:write_integer(obj.oFaceAnglePitch, INT_TYPE_S16)
                file:write_integer(obj.oFaceAngleYaw, INT_TYPE_S16)
                file:write_integer(obj.oFaceAngleRoll, INT_TYPE_S16)
                file:write_integer(obj.oBlockSurfaceProperties, INT_TYPE_U32)
            end
            obj = obj_get_next_with_same_behavior_id(obj)
        end
    end

    sStorage:save()
    djui_chat_message_create("Saved file: \"" .. save_name .. "\"")
    return true
end

local function load_command(msg)
    local save_name = msg
    if not save_name or save_name == "" then
        save_name = "default"
    end

    local file = sStorage:get_file(save_name)
    if not file then
        error("Could not get file: " .. save_name)
        return true
    end

    if not file:rewind() then
        error("Could not rewind file: " .. save_name)
        return true
    end

    djui_chat_message_create("Will attempt to load file: \"" .. save_name .. "\"")
    while not file:is_eof() do
        local item = {}
        item.id = file:read_integer(INT_TYPE_U16)
        item.model = file:read_integer(INT_TYPE_U16)
        item.x = file:read_number(FLOAT_TYPE_F32)
        item.y = file:read_number(FLOAT_TYPE_F32)
        item.z = file:read_number(FLOAT_TYPE_F32)
        item.animState = file:read_integer(INT_TYPE_S32)
        item.params = file:read_integer(INT_TYPE_U32)
        item.scaleX = file:read_number(FLOAT_TYPE_F32)
        item.scaleY = file:read_number(FLOAT_TYPE_F32)
        item.scaleZ = file:read_number(FLOAT_TYPE_F32)
        item.pitch = file:read_integer(INT_TYPE_S16)
        item.yaw = file:read_integer(INT_TYPE_S16)
        item.roll = file:read_integer(INT_TYPE_S16)
        item.properties = file:read_integer(INT_TYPE_U32)
        place_item_with_params(item)
    end

    djui_chat_message_create("Loaded file: \"" .. save_name .. "\"")
    return true
end

hook_chat_command("save", "[name] Save build", save_command)
hook_chat_command("load", "[name] Load build", load_command)