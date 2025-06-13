-- name: Minecraft Enhanced Rewrite
-- description: An improved version of the Minecraft mod, originally by zKevin

gLevelValues.fixCollisionBugs = true
gLevelValues.fixCollisionBugsFalseLedgeGrab = false
gLevelValues.fixCollisionBugsGroundPoundBonks = false

gServerSettings.stayInLevelAfterStar = 1
gLevelValues.fixInvalidShellRides = false

CanBuild = true

E_MODEL_MCE_BLOCK = smlua_model_util_get_id("mce_block_geo")
E_MODEL_OUTLINE = smlua_model_util_get_id("mce_outline")

-------------------------------------------------------------------------------

local on_grid = true
local grid_size = {x = 200, y = 200, z = 200}

local function to_grid_x(n)
	if on_grid then
		return math.floor(n/grid_size.x + .5) * grid_size.x
	else
		return n
	end
end

local function to_grid_y(n)
	if on_grid then
		return math.floor(n/grid_size.y + .5) * grid_size.y
	else
		return n
	end
end

local function to_grid_z(n)
	if on_grid then
		return math.floor(n/grid_size.z + .5) * grid_size.z
	else
		return n
	end
end

---@param msg string
local function on_grid_size_chat_command(msg)
	if msg:lower() == "off" then
		on_grid = false
		djui_chat_message_create("Turned off the grid")
		return true
	elseif msg:lower() == "on" then
		on_grid = true
		djui_chat_message_create("Turned on the grid")
		return true
	elseif msg:lower() == "" then
		on_grid = not on_grid
		djui_chat_message_create("Turned " .. (on_grid and "on" or "off") .. " the grid")
		return true
	end

	local sizes = split_string(msg, " ")
	local sizes_count = #sizes

	if not sizes[1] then
		djui_chat_message_create("Usage: [num] or [x|y|z]")
		return true
	end

	if sizes_count == 1 then
		local size = tonumber(sizes[1]) or 200
		vec3f_set(grid_size, size, size, size)
		djui_chat_message_create("Set grid size to " .. size)
	elseif sizes_count == 3 then
		vec3f_set(grid_size, tonumber(sizes[1]) or 200, tonumber(sizes[2]) or 200, tonumber(sizes[3]) or 200)
		djui_chat_message_create("Set grid size to (" .. sizes[1], sizes[2], sizes[3] .. ")")
	else
		djui_chat_message_create("Usage: [num] or [x y z] or [on|off]")
	end
	return true
end

hook_chat_command("grid", "[num] or [x|y|z] or [on|off] | Change the shape of the grid. Default is 200 in each dimension", on_grid_size_chat_command)

hook_mod_menu_inputbox("Grid Size X", "200", 10, function (index, value) grid_size.x = tonumber(value) or 200 update_mod_menu_element_inputbox(index, tostring(grid_size.x)) end)
hook_mod_menu_inputbox("Grid Size Y", "200", 10, function (index, value) grid_size.y = tonumber(value) or 200 update_mod_menu_element_inputbox(index, tostring(grid_size.y)) end)
hook_mod_menu_inputbox("Grid Size Z", "200", 10, function (index, value) grid_size.z = tonumber(value) or 200 update_mod_menu_element_inputbox(index, tostring(grid_size.z)) end)

-------------------------------------------------------------------------------

---@type Object?
local outline = nil
local outline_stored_rotation = {pitch = 0, yaw = 0, roll = 0}

--- Called from bhvOutline.bhv

---@param obj Object
function bhv_outline_init(obj)
	outline = obj
	obj.oOpacity = 255
	obj.oFaceAnglePitch = outline_stored_rotation.pitch
	obj.oFaceAngleYaw = outline_stored_rotation.yaw
	obj.oFaceAngleRoll = outline_stored_rotation.roll
	spawn_non_sync_object(bhvMockItem, E_MODEL_NONE, obj.oPosX, obj.oPosY, obj.oPosZ, nil)
end

---@param obj Object
function bhv_outline_loop(obj)
	outline = obj

	local m = gMarioStates[0]
	local facing_x = sins(m.intendedYaw)
	local facing_z = coss(m.intendedYaw)

	local posX = to_grid_x( m.pos.x + facing_x*grid_size.x )
	local posY = to_grid_y( m.pos.y )
	local posZ = to_grid_z( m.pos.z + facing_z*grid_size.z )

	outline.oPosX = posX
	outline.oPosY = posY
	outline.oPosZ = posZ
	outline.oOpacity = 127

	local current_item = gCurrentItem
	if current_item then
		obj_scale_xyz(obj, current_item.size.x, current_item.size.y, current_item.size.z)
	else
		obj_scale(obj, 1)
	end
end

--------------------------------------

--- Called from bhvMockItem.bhv

---@param obj Object
function bhv_mock_item_loop(obj)
	local current_item = gCurrentItem
	if outline and current_item and current_item.model then
		obj.oPosX = outline.oPosX
		obj.oPosY = outline.oPosY - (current_item.spawnYOffset * current_item.size.y)
		obj.oPosZ = outline.oPosZ
		obj.header.gfx.node.flags = obj.header.gfx.node.flags & ~GRAPH_RENDER_BILLBOARD
		obj.oItemParams = current_item.params
		local outline_scale = outline.header.gfx.scale
		obj_scale_xyz(obj, outline_scale.x, outline_scale.y, outline_scale.z)
		obj_set_model_extended(obj, current_item.model)

		local mock_settings = current_item.mock
		if mock_settings.billboard then
			obj_set_billboard(obj)
		end
		if mock_settings.scale then
			obj_scale_mult_to(obj, mock_settings.scale)
		end
		if mock_settings.animateAnimState then
			if mock_settings.animateFrame then
				obj.oAnimState = obj.oAnimState + (1 % mock_settings.animateFrame)
			else
				obj.oAnimState = obj.oAnimState + 1
			end
			if obj.oAnimState >= 255 then
				obj.oAnimState = 0
			end
		else
			obj.oAnimState = current_item.animState
		end
		if mock_settings.animateFaceAngleYaw then
			obj.oFaceAngleYaw = convert_s16(obj.oFaceAngleYaw + mock_settings.animateFaceAngleYaw)
		else
			obj.oFaceAngleYaw = outline.oFaceAngleYaw
		end
		obj.oFaceAnglePitch = outline.oFaceAnglePitch
		obj.oFaceAngleRoll = outline.oFaceAngleRoll
	else
		obj_set_model_extended(obj, E_MODEL_NONE)
	end
end

-------------------------------------------------------------------------------

local function place_item()
	local current_item = gCurrentItem
	if not outline or not current_item or not current_item.behavior or not current_item.model then return end
	spawn_sync_object(
		current_item.behavior,
		current_item.model,
		outline.oPosX, outline.oPosY - (current_item.spawnYOffset * current_item.size.y), outline.oPosZ,
		---@param obj Object
		function (obj)
			obj.oOpacity = 255
			obj.oFaceAnglePitch = outline.oFaceAnglePitch
			obj.oFaceAngleYaw = outline.oFaceAngleYaw
			obj.oFaceAngleRoll = outline.oFaceAngleRoll
			obj.oMoveAnglePitch = outline.oMoveAnglePitch
			obj.oMoveAngleYaw = outline.oMoveAngleYaw
			obj.oMoveAngleRoll = outline.oMoveAngleRoll
			obj.oItemParams = current_item.params
			obj.oScaleX = current_item.size.x
			obj.oScaleY = current_item.size.y
			obj.oScaleZ = current_item.size.z
			obj_scale_xyz(obj, current_item.size.x, current_item.size.y, current_item.size.z)
			obj.oAnimState = current_item.animState
		end
	)

	play_sound(SOUND_GENERAL_BOX_LANDING, gMarioStates[0].marioObj.header.gfx.cameraToObject)
end

local function determine_place_or_delete()
	if not outline then return end
	local nearest = obj_get_any_nearest_item(outline)

	if nearest then
		local dists = {
			x = math.abs(nearest.oPosX - outline.oPosX),
			y = math.abs(nearest.oPosY - outline.oPosY),
			z = math.abs(nearest.oPosZ - outline.oPosZ)
		}
		if dists.x >= grid_size.x or dists.y >= grid_size.y or dists.z >= grid_size.z then
			place_item()
		else
			obj_mark_for_deletion(nearest)
		end
	else
		place_item()
	end
end

---@param down integer
---@param pressed integer
local function set_outline_rotation(down, pressed)
	if not outline then return end
	local l_held_modifier = down & L_TRIG ~= 0
	if pressed & U_JPAD ~= 0 then
		if l_held_modifier then
			outline.oFaceAngleRoll = outline.oFaceAngleRoll + 0x400
			outline.oMoveAngleRoll = outline.oMoveAngleRoll + 0x400
		else
			outline.oFaceAnglePitch = outline.oFaceAnglePitch + 0x400
			outline.oMoveAnglePitch = outline.oMoveAnglePitch + 0x400
		end
	elseif pressed & D_JPAD ~= 0 then
		if l_held_modifier then
			outline.oFaceAngleRoll = outline.oFaceAngleRoll - 0x400
			outline.oMoveAngleRoll = outline.oMoveAngleRoll - 0x400
		else
			outline.oFaceAnglePitch = outline.oFaceAnglePitch - 0x400
			outline.oMoveAnglePitch = outline.oMoveAnglePitch - 0x400
		end
	end
	if l_held_modifier then
		if pressed & L_JPAD ~= 0 then
			outline.oFaceAngleYaw = outline.oFaceAngleYaw - 0x400
			outline.oMoveAngleYaw = outline.oMoveAngleYaw - 0x400
		elseif pressed & R_JPAD ~= 0 then
			outline.oFaceAngleYaw = outline.oFaceAngleYaw + 0x400
			outline.oMoveAngleYaw = outline.oMoveAngleYaw + 0x400
		end
		if pressed & X_BUTTON ~= 0 then
			outline.oFaceAnglePitch = 0
			outline.oFaceAngleYaw = 0
			outline.oFaceAngleRoll = 0
		end
	end

	outline_stored_rotation.pitch = outline.oFaceAnglePitch
	outline_stored_rotation.yaw = outline.oFaceAngleYaw
	outline_stored_rotation.roll = outline.oFaceAngleRoll
end

local function delete_outline()
	if outline then
		obj_mark_for_deletion(outline)
	end
	local mock = obj_get_first_with_behavior_id(bhvMockItem)
	if mock then
		obj_mark_for_deletion(mock)
	end
end

---------------------------------------

---@param m MarioState
local function builder_mario_update(m)
	local down = m.controller.buttonDown
	local pressed = m.controller.buttonPressed

	if not obj_get_first_with_behavior_id(bhvOutline) then
		spawn_non_sync_object(
			bhvOutline,
			E_MODEL_OUTLINE,
			m.pos.x, m.pos.y, m.pos.z,
			nil
		)
		return
	end

	set_outline_rotation(down, pressed)
	if pressed & Y_BUTTON ~= 0 then
		determine_place_or_delete()
    end
end

-------------------------------------------------------------------------------

local function on_warp()
	delete_outline()
end

---@param m MarioState
local function mario_update(m)
	if m.playerIndex ~= 0 then return end
	if CanBuild then
		if not MenuOpen then
			builder_mario_update(m)
		end
	else
		delete_outline()
	end

	CanBuild = m.action == ACT_FREE_MOVE
end


hook_event(HOOK_ON_WARP, on_warp)
hook_event(HOOK_MARIO_UPDATE, mario_update)