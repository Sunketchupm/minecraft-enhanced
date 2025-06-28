-- name: \\#31db02\\Minecraft \\#1dcff2\\Enhanced \\[WIP]\\
-- description: An improved version of the Minecraft mod, originally by zKevin.\n\nModification by Sunk. Texture help by Sherbie. Minecraft+ made by Bene360 (which isn't used in this mod, but their effort shouldn't be wasted).

gLevelValues.fixCollisionBugs = true
gLevelValues.fixCollisionBugsFalseLedgeGrab = false
gLevelValues.fixCollisionBugsGroundPoundBonks = false

gServerSettings.stayInLevelAfterStar = 1
gLevelValues.fixInvalidShellRides = false

gCanBuild = true

E_MODEL_MCE_BLOCK = smlua_model_util_get_id("mce_block_geo")
E_MODEL_MCE_COLOR_BLOCK = smlua_model_util_get_id("mce_color_block_geo")
E_MODEL_OUTLINE = smlua_model_util_get_id("mce_outline")
E_MODEL_ARROW = smlua_model_util_get_id("arrow_geo")
E_MODEL_MCE_BLOCK_CUSTOM = smlua_model_util_get_id("custom_mce_block_geo")

---------------------------- MODEL TEST ----------------------------

--[[ local function model_test(m)
	if not CanBuild and m.controller.buttonPressed & X_BUTTON ~= 0 then
		spawn_sync_object(bhvMceBlock, E_MODEL_MCE_BLOCK_CUSTOM, m.pos.x, m.pos.y,m.pos.z, nil)
	end
end
hook_event(HOOK_MARIO_UPDATE, model_test) ]]

-------------------------------------------------------------------------------

local on_grid = true
gGridSize = {x = 200, y = 200, z = 200}

local function to_grid_x(n)
	if on_grid then
		return math.floor(n/gGridSize.x + .5) * gGridSize.x
	else
		return n
	end
end

local function to_grid_y(n)
	if on_grid then
		return math.floor(n/gGridSize.y + .5) * gGridSize.y
	else
		return n
	end
end

local function to_grid_z(n)
	if on_grid then
		return math.floor(n/gGridSize.z + .5) * gGridSize.z
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

	if not sizes[1] or not tonumber(sizes[1]) then
		djui_chat_message_create("Usage: [num] or [x|y|z]")
		return true
	end

	if sizes_count == 1 then
		local new_size = (tonumber(sizes[1]) or 1) * 200
		vec3f_set(gGridSize, new_size, new_size, new_size)
		djui_chat_message_create("Set grid size to " .. sizes[1])
	elseif sizes_count == 3 then
		local new_size_x = (tonumber(sizes[1]) or 1) * 200
		local new_size_y = (tonumber(sizes[2]) or 1) * 200
		local new_size_z = (tonumber(sizes[3]) or 1) * 200
		vec3f_set(gGridSize, new_size_x, new_size_y, new_size_z)
		djui_chat_message_create("Set grid size to (" .. sizes[1], sizes[2], sizes[3] .. ")")
	else
		djui_chat_message_create("Usage: [num] or [x y z] or [on|off]")
	end
	return true
end

hook_chat_command("grid", "[num] or [x|y|z] or [on|off] | Change the shape of the grid. Default is 1 in each dimension", on_grid_size_chat_command)

-------------------------------------------------------------------------------

---@type Object?
local s_outline = nil
g_outline_grid_y_offset = 0

--- Called from bhvOutline.bhv

---@param obj Object
function bhv_outline_init(obj)
	s_outline = obj
	obj.oOpacity = 255
	obj.oFaceAnglePitch = 0
	obj.oFaceAngleYaw = 0
	obj.oFaceAngleRoll = 0
	spawn_non_sync_object(bhvMockItem, E_MODEL_NONE, obj.oPosX, obj.oPosY, obj.oPosZ, nil)
	spawn_non_sync_object(bhvArrow, E_MODEL_ARROW, obj.oPosX, obj.oPosY, obj.oPosZ, nil)
end

---@param obj Object
function bhv_outline_loop(obj)
	local current_item = gCurrentItem
	if not current_item then
		obj_mark_for_deletion(obj)
		s_outline = nil
		return
	end
	s_outline = obj

	local m = gMarioStates[0]
	local facing_x = sins(m.intendedYaw)
	local facing_z = coss(m.intendedYaw)

	local posX = to_grid_x( m.pos.x + facing_x * math.max(gGridSize.x, 200) )
	local posY = to_grid_y( m.pos.y ) + (gGridSize.y * g_outline_grid_y_offset)
	local posZ = to_grid_z( m.pos.z + facing_z * math.max(gGridSize.z, 200) )

	s_outline.oPosX = posX
	s_outline.oPosY = posY
	s_outline.oPosZ = posZ
	obj_scale_xyz(obj, current_item.size.x, current_item.size.y, current_item.size.z)
	if current_item.rotation then
		s_outline.oFaceAnglePitch = current_item.rotation.x
		s_outline.oFaceAngleYaw = current_item.rotation.y
		s_outline.oFaceAngleRoll = current_item.rotation.z
		s_outline.oMoveAnglePitch = current_item.rotation.x
		s_outline.oMoveAngleYaw = current_item.rotation.y
		s_outline.oMoveAngleRoll = current_item.rotation.z
	end
end

--------------------------------------

--- Called from bhvMockItem.bhv

---@param obj Object
function bhv_mock_item_loop(obj)
	local current_item = gCurrentItem
	if s_outline and obj_get_first_with_behavior_id(bhvOutline) and current_item and current_item.model then
		obj.oPosX = s_outline.oPosX
		obj.oPosY = s_outline.oPosY - (current_item.spawnYOffset * current_item.size.y)
		obj.oPosZ = s_outline.oPosZ
		obj.header.gfx.node.flags = obj.header.gfx.node.flags & ~GRAPH_RENDER_BILLBOARD
		obj.oItemParams = current_item.params
		local outline_scale = s_outline.header.gfx.scale
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
			obj.oFaceAngleYaw = s_outline.oFaceAngleYaw
		end
		obj.oFaceAnglePitch = s_outline.oFaceAnglePitch
		obj.oFaceAngleRoll = s_outline.oFaceAngleRoll

		if current_item.behavior == bhvMceBlock then
			local transparent_start = mce_block_get_transparent_start_item(current_item)
			local anim_max = mce_block_get_anim_max_item(current_item)
			if obj.oAnimState >= transparent_start then
				obj.oOpacity = 100
			else
				obj.oAnimState = current_item.animState + transparent_start
				obj.oOpacity = 200
			end

			if obj.oAnimState > anim_max then
				obj.oAnimState = anim_max
			end
		end
	else
		obj_mark_for_deletion(obj)
	end
end

--------------------------------------

local s_show_arrow = true

--- Called from bhvArrow.bhv

---@param obj Object
function bhv_arrow_loop(obj)
	local current_item = gCurrentItem
	if s_outline and obj_get_first_with_behavior_id(bhvOutline) and current_item and current_item.model then
		outline_scale = s_outline.header.gfx.scale
		obj.oPosX = s_outline.oPosX + sins(s_outline.oFaceAngleYaw) * 200 * outline_scale.x
		obj.oPosY = s_outline.oPosY - (current_item.spawnYOffset * current_item.size.y)
		obj.oPosZ = s_outline.oPosZ + coss(s_outline.oFaceAngleYaw) * 200 * outline_scale.z
		obj_scale_xyz(obj, outline_scale.x, outline_scale.y, outline_scale.z)
		obj.oFaceAngleYaw = s_outline.oFaceAngleYaw - 16384
	else
		obj_mark_for_deletion(obj)
	end

	if gMarioStates[0].controller.buttonDown & L_TRIG ~= 0 and s_show_arrow then
		cur_obj_enable_rendering()
	else
		cur_obj_disable_rendering()
	end
end

hook_mod_menu_checkbox("Show Angle Arrow", true, function (_, value)
	s_show_arrow = value
end)

-------------------------------------------------------------------------------

local function place_item()
	local current_item = gCurrentItem
	if not s_outline or not current_item or not current_item.behavior or not current_item.model then return end
	local item = spawn_sync_object(
		current_item.behavior,
		current_item.model,
		s_outline.oPosX, s_outline.oPosY - (current_item.spawnYOffset * current_item.size.y), s_outline.oPosZ,
		---@param obj Object
		function (obj)
			obj.oOpacity = 255
			obj.oFaceAnglePitch = s_outline.oFaceAnglePitch
			obj.oFaceAngleYaw = s_outline.oFaceAngleYaw
			obj.oFaceAngleRoll = s_outline.oFaceAngleRoll
			obj.oMoveAnglePitch = s_outline.oMoveAnglePitch
			obj.oMoveAngleYaw = s_outline.oMoveAngleYaw
			obj.oMoveAngleRoll = s_outline.oMoveAngleRoll
			obj.oItemParams = current_item.params
			obj.oBlockSurfaceProperties = current_item.blockProperties
			obj.oScaleX = current_item.size.x
			obj.oScaleY = current_item.size.y
			obj.oScaleZ = current_item.size.z
			obj_scale_xyz(obj, current_item.size.x, current_item.size.y, current_item.size.z)
			obj.oAnimState = current_item.animState
			obj.globalPlayerIndex = network_global_index_from_local(0)
			obj.oOwner = network_global_index_from_local(0) + 1
		end
	)

	if item then
		play_sound(SOUND_GENERAL_BOX_LANDING, gMarioStates[0].marioObj.header.gfx.cameraToObject)
		if item.oPosX < -0x8000 or item.oPosX > 0x7FFF or item.oPosY < -0x8000 or item.oPosY > 0x7FFF or item.oPosZ < -0x8000 or item.oPosZ > 0x7FFF then
			djui_chat_message_create("Warning! Item placed in a PU! Some behaviors may not work as intended")
		end

		table.insert(g_load_block_datas, {
			item, current_item.behavior, current_item.model,
			s_outline.oPosX, s_outline.oPosY - (current_item.spawnYOffset * current_item.size.y), s_outline.oPosZ,
			s_outline.oFaceAnglePitch, s_outline.oFaceAngleYaw, s_outline.oFaceAngleRoll,
			current_item.params,
			current_item.size.x, current_item.size.y, current_item.size.z,
			current_item.animState, 0
		})
	else
		play_sound(SOUND_MENU_CAMERA_BUZZ, gMarioStates[0].marioObj.header.gfx.cameraToObject)
		djui_chat_message_create("Item failed to place. Perhaps the object limit was reached?")
	end
end

---@param allow_build_delete {build: boolean, delete: boolean}?
---@return boolean
local function determine_place_or_delete(allow_build_delete)
	if not s_outline then return false end
	if allow_build_delete == nil then allow_build_delete = {build = true, delete = true} end
	local nearest = obj_get_any_nearest_item(s_outline)

	if nearest then
		local dists = {
			x = math.abs(nearest.oPosX - s_outline.oPosX),
			y = math.abs(nearest.oPosY - s_outline.oPosY),
			z = math.abs(nearest.oPosZ - s_outline.oPosZ)
		}
		local is_out_range = (dists.x >= gGridSize.x or dists.y >= gGridSize.y or dists.z >= gGridSize.z)
		if allow_build_delete.build and is_out_range then
			place_item()
			return true
		elseif allow_build_delete.delete and not is_out_range then
			play_sound(SOUND_GENERAL_BOX_LANDING, gMarioStates[0].marioObj.header.gfx.cameraToObject)
			obj_mark_for_deletion(nearest)
			return false
		end
	elseif allow_build_delete.build then
		place_item()
		return true
	end
	return false
end

---@param m MarioState
local function set_item_size_control(m)
	if not s_outline or m.controller.buttonDown & L_TRIG == 0 then return end

	local current_selected = gHotbarItemList[gSelectedHotbarIndex].item
	if current_selected then
		local pressed = m.controller.buttonPressed
		local size = current_selected.size

		local largest_side = size.x
		if size.x < size.y then
			largest_side = size.y
			if size.y < size.z then
				largest_side = size.z
			end
		elseif size.x < size.z then
			largest_side = size.z
			if size.z < size.y then
				largest_side = size.y
			end
		end
		local smallest_side = size.x
		if size.x > size.y then
			smallest_side = size.y
			if size.y > size.z then
				smallest_side = size.z
			end
		elseif size.x > size.z then
			smallest_side = size.z
			if size.z > size.y then
				smallest_side = size.y
			end
		end

		if pressed & U_JPAD ~= 0 and largest_side < 10 then
			vec3f_set(size, size.x + 0.1, size.y + 0.1, size.z + 0.1)
		elseif pressed & D_JPAD ~= 0 and smallest_side > 0.1 then
			vec3f_set(size, size.x - 0.1, size.y - 0.1, size.z - 0.1)
		end
	end
end

---@param m MarioState
local function set_outline_offset(m)
	if not s_outline or m.controller.buttonDown & L_TRIG ~= 0 then return end
	local pressed = m.controller.buttonPressed

	if pressed & U_JPAD ~= 0 and g_outline_grid_y_offset < 3 then
		g_outline_grid_y_offset = g_outline_grid_y_offset + 1
	elseif pressed & D_JPAD ~= 0 and g_outline_grid_y_offset > -3 then
		g_outline_grid_y_offset = g_outline_grid_y_offset - 1
	end
end

local s_rotation_increment = degrees_to_sm64(15)
---@param m MarioState
local function set_item_rotation(m)
	if not s_outline or m.controller.buttonDown & L_TRIG == 0 then return end
	local current_item = gCurrentItem
	if not current_item then return end
	local pressed = m.controller.buttonPressed
	local item_rotation = current_item.rotation

	if pressed & U_CBUTTONS ~= 0 then
		item_rotation.x = item_rotation.x + s_rotation_increment
	elseif pressed & D_CBUTTONS ~= 0 then
		item_rotation.x = item_rotation.x - s_rotation_increment
	end
	if pressed & L_CBUTTONS ~= 0 then
		item_rotation.y = item_rotation.y + s_rotation_increment
	elseif pressed & R_CBUTTONS ~= 0 then
		item_rotation.y = item_rotation.y - s_rotation_increment
	end
	if pressed & L_JPAD ~= 0 then
		item_rotation.z = item_rotation.z + s_rotation_increment
	elseif pressed & R_JPAD ~= 0 then
		item_rotation.z = item_rotation.z - s_rotation_increment
	end
	if pressed & X_BUTTON ~= 0 then
		gCurrentItem.rotation = gVec3sZero()
	end

	m.controller.buttonPressed = m.controller.buttonPressed & ~(U_CBUTTONS | L_CBUTTONS | D_CBUTTONS | R_CBUTTONS | X_BUTTON)
end

hook_mod_menu_inputbox("Angle Increment", "15", 4, function (index, value)
	s_rotation_increment = degrees_to_sm64(tonumber(value) or 15)
	update_mod_menu_element_inputbox(index, tostring(math.round(sm64_to_degrees(s_rotation_increment))))
end)

local function delete_outline()
	if s_outline then
		obj_mark_for_deletion(s_outline)
	end
	local mock = obj_get_first_with_behavior_id(bhvMockItem)
	if mock then
		obj_mark_for_deletion(mock)
	end
end

---------------------------------------

local s_auto_build = true
local s_initial_block_placed = false

---@param m MarioState
local function builder_mario_update(m)
	if not obj_get_first_with_behavior_id(bhvOutline) then
		s_outline = nil
		if gCurrentItem then
			spawn_non_sync_object(
				bhvOutline,
				E_MODEL_OUTLINE,
				m.pos.x, m.pos.y, m.pos.z,
				nil
			)
		end
		return
	end

	set_item_size_control(m)
	set_outline_offset(m)
	set_item_rotation(m)
	if m.controller.buttonPressed & Y_BUTTON ~= 0 then
		s_initial_block_placed = determine_place_or_delete()
    end
	if s_auto_build and m.controller.buttonDown & Y_BUTTON ~= 0 then
		determine_place_or_delete({build = s_initial_block_placed, delete = not s_initial_block_placed})
	end
end

hook_mod_menu_checkbox("Autobuild", true, function (_, value)
	s_auto_build = value
end)

-------------------------------------------------------------------------------

local function on_warp()
	delete_outline()
end

---@param m MarioState
local function mario_update(m)
	if m.playerIndex ~= 0 then return end
	if gCanBuild then
		if not gMenuOpen then
			builder_mario_update(m)
		end
	else
		delete_outline()
	end

	gCanBuild = m.action == ACT_FREE_MOVE
end


hook_event(HOOK_ON_WARP, on_warp)
hook_event(HOOK_BEFORE_MARIO_UPDATE, mario_update)
