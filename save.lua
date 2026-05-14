local MCE_MAGIC = 0x4E81A0CE
local MCE_SAVE_VERSION = 2
local sStorage = mod_fs_get() or mod_fs_create()

local function place_item_with_params(load)
	local spawned_item = spawn_sync_object(
		load.id,
		load.model,
		load.x, load.y, load.z,
		---@param obj Object
		function (obj)
			obj.oFaceAnglePitch = load.pitch
			obj.oFaceAngleYaw = load.yaw
			obj.oFaceAngleRoll = load.roll
			obj.oMoveAnglePitch = load.pitch
			obj.oMoveAngleYaw = load.yaw
			obj.oMoveAngleRoll = load.roll
			obj.oItemParams = load.params
			obj.oItemFlags = load.flags
			obj.oScaleX = load.scaleX
			obj.oScaleY = load.scaleY
			obj.oScaleZ = load.scaleZ
			obj_scale_xyz(obj, load.scaleX, load.scaleY, load.scaleZ)
			obj.oAnimState = load.animState
			obj.globalPlayerIndex = network_global_index_from_local(0)
			obj.oOwner = network_global_index_from_local(0) + 1
            obj.oOpacity = load.opacity
            obj.oColor = load.color
		end
	)

	if not spawned_item then
		djui_chat_message_create("Item failed to place. Perhaps the object limit was reached?")
	end
end

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

    file:write_integer(MCE_MAGIC, INT_TYPE_U32)
    file:write_integer(MCE_SAVE_VERSION, INT_TYPE_U8)
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
                file:write_integer(obj.oItemFlags, INT_TYPE_U32)
                file:write_integer(obj.oColor, INT_TYPE_U32)
                file:write_integer(obj.oOpacity, INT_TYPE_S32)
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
    local magic = file:read_integer(INT_TYPE_U32)
    local version = file:read_integer(INT_TYPE_U8)
    if magic ~= MCE_MAGIC then
        djui_chat_message_create("Could not validate MCE save")
        return true
    end
    if version ~= MCE_SAVE_VERSION then
        djui_chat_message_create("Incompatible MCE save version")
        return true
    end

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
        item.flags = file:read_integer(INT_TYPE_U32)
        item.color = file:read_integer(INT_TYPE_U32)
        item.opacity = file:read_integer(INT_TYPE_S32)
        place_item_with_params(item)
    end

    djui_chat_message_create("Loaded file: \"" .. save_name .. "\"")
    return true
end

hook_chat_command("save", "[name] Save build", save_command)
hook_chat_command("load", "[name] Load build", load_command)