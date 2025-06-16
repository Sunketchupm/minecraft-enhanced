-- name: Minecraft Enhanced
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
GridSize = {x = 200, y = 200, z = 200}

local function to_grid_x(n)
	if on_grid then
		return math.floor(n/GridSize.x + .5) * GridSize.x
	else
		return n
	end
end

local function to_grid_y(n)
	if on_grid then
		return math.floor(n/GridSize.y + .5) * GridSize.y
	else
		return n
	end
end

local function to_grid_z(n)
	if on_grid then
		return math.floor(n/GridSize.z + .5) * GridSize.z
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
		local new_size = (tonumber(sizes[1]) or 1) * 200
		vec3f_set(GridSize, new_size, new_size, new_size)
		djui_chat_message_create("Set grid size to " .. sizes[1])
	elseif sizes_count == 3 then
		local new_size_x = (tonumber(sizes[1]) or 1) * 200
		local new_size_y = (tonumber(sizes[2]) or 1) * 200
		local new_size_z = (tonumber(sizes[3]) or 1) * 200
		vec3f_set(GridSize, new_size_x, new_size_y, new_size_z)
		djui_chat_message_create("Set grid size to (" .. sizes[1], sizes[2], sizes[3] .. ")")
	else
		djui_chat_message_create("Usage: [num] or [x y z] or [on|off]")
	end
	return true
end

hook_chat_command("grid", "[num] or [x|y|z] or [on|off] | Change the shape of the grid. Default is 1 in each dimension", on_grid_size_chat_command)

-------------------------------------------------------------------------------

---@type Object?
local outline = nil
local outline_grid_y_offset = 0

--- Called from bhvOutline.bhv

---@param obj Object
function bhv_outline_init(obj)
	outline = obj
	obj.oOpacity = 255
	obj.oFaceAnglePitch = 0
	obj.oFaceAngleYaw = 0
	obj.oFaceAngleRoll = 0
	spawn_non_sync_object(bhvMockItem, E_MODEL_NONE, obj.oPosX, obj.oPosY, obj.oPosZ, nil)
end

---@param obj Object
function bhv_outline_loop(obj)
	local current_item = gCurrentItem
	if not current_item then
		obj_mark_for_deletion(obj)
		outline = nil
		return
	end
	outline = obj

	local m = gMarioStates[0]
	local facing_x = sins(m.intendedYaw)
	local facing_z = coss(m.intendedYaw)

	local posX = to_grid_x( m.pos.x + facing_x * math.max(GridSize.x, 200) )
	local posY = to_grid_y( m.pos.y ) + (GridSize.y * outline_grid_y_offset)
	local posZ = to_grid_z( m.pos.z + facing_z * math.max(GridSize.z, 200) )

	outline.oPosX = posX
	outline.oPosY = posY
	outline.oPosZ = posZ
	obj_scale_xyz(obj, current_item.size.x, current_item.size.y, current_item.size.z)
	if current_item.rotation then
		outline.oFaceAnglePitch = current_item.rotation.x
		outline.oFaceAngleYaw = current_item.rotation.y
		outline.oFaceAngleRoll = current_item.rotation.z
		outline.oMoveAnglePitch = current_item.rotation.x
		outline.oMoveAngleYaw = current_item.rotation.y
		outline.oMoveAngleRoll = current_item.rotation.z
	end
end

--------------------------------------

--- Called from bhvMockItem.bhv

---@param obj Object
function bhv_mock_item_loop(obj)
	local current_item = gCurrentItem
	if outline and obj_get_first_with_behavior_id(bhvOutline) and current_item and current_item.model then
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

		if current_item.model == E_MODEL_MCE_BLOCK then
			if obj.oAnimState >= BLOCK_ANIM_STATE_TRANSPARENT_START then
				obj.oOpacity = 100
			else
				obj.oAnimState = current_item.animState + BLOCK_ANIM_STATE_TRANSPARENT_START
				obj.oOpacity = 200
			end
			if obj.oAnimState > BLOCK_BARRIER_ANIM then
				obj.oAnimState = BLOCK_BARRIER_ANIM
			end
		end
	else
		obj_mark_for_deletion(obj)
	end
end

-------------------------------------------------------------------------------

local function place_item()
	local current_item = gCurrentItem
	if not outline or not current_item or not current_item.behavior or not current_item.model then return end
	local item = spawn_sync_object(
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
			obj.globalPlayerIndex = network_global_index_from_local(0)
			obj.oOwner = network_global_index_from_local(0) + 1
		end
	)

	if item then
		play_sound(SOUND_GENERAL_BOX_LANDING, gMarioStates[0].marioObj.header.gfx.cameraToObject)
		if item.oPosX < -0x8000 or item.oPosX > 0x7FFF or item.oPosY < -0x8000 or item.oPosY > 0x7FFF or item.oPosZ < -0x8000 or item.oPosZ > 0x7FFF then
			djui_chat_message_create("Warning! Item placed in a PU! Some behaviors may not work as intended")
		end
	else
		play_sound(SOUND_MENU_CAMERA_BUZZ, gMarioStates[0].marioObj.header.gfx.cameraToObject)
		djui_chat_message_create("Item failed to place. Perhaps the object limit was reached?")
	end
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
		if dists.x >= GridSize.x * 0.5 or dists.y >= GridSize.y * 0.5 or dists.z >= GridSize.z * 0.5 then
			place_item()
		else
			play_sound(SOUND_GENERAL_BOX_LANDING, gMarioStates[0].marioObj.header.gfx.cameraToObject)
			obj_mark_for_deletion(nearest)
		end
	else
		place_item()
	end
end

---@param m MarioState
local function set_item_size_control(m)
	if not outline or m.controller.buttonDown & L_TRIG == 0 then return end

	local current_selected = HotbarItemList[SelectedHotbarIndex].item
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
	if not outline or m.controller.buttonDown & L_TRIG ~= 0 then return end
	local pressed = m.controller.buttonPressed

	if pressed & U_JPAD ~= 0 and outline_grid_y_offset < 3 then
		outline_grid_y_offset = outline_grid_y_offset + 1
	elseif pressed & D_JPAD ~= 0 and outline_grid_y_offset > -3 then
		outline_grid_y_offset = outline_grid_y_offset - 1
	end
end

local rotation_increment = 0xAAA
---@param m MarioState
local function set_item_rotation(m)
	if not outline or m.controller.buttonDown & L_TRIG == 0 then return end
	local current_item = gCurrentItem
	if not current_item then return end
	local pressed = m.controller.buttonPressed
	local item_rotation = current_item.rotation

	if pressed & U_CBUTTONS ~= 0 then
		item_rotation.x = item_rotation.x + rotation_increment
	elseif pressed & D_CBUTTONS ~= 0 then
		item_rotation.x = item_rotation.x - rotation_increment
	end
	if pressed & L_CBUTTONS ~= 0 then
		item_rotation.y = item_rotation.y + rotation_increment
	elseif pressed & R_CBUTTONS ~= 0 then
		item_rotation.y = item_rotation.y - rotation_increment
	end
	if pressed & L_JPAD ~= 0 then
		item_rotation.z = item_rotation.z + rotation_increment
	elseif pressed & R_JPAD ~= 0 then
		item_rotation.z = item_rotation.z - rotation_increment
	end
	if pressed & X_BUTTON ~= 0 then
		gCurrentItem.rotation = gVec3sZero()
	end

	m.controller.buttonPressed = m.controller.buttonPressed & ~(U_CBUTTONS | L_CBUTTONS | D_CBUTTONS | R_CBUTTONS | X_BUTTON)
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
	if not obj_get_first_with_behavior_id(bhvOutline) then
		outline = nil
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
hook_event(HOOK_BEFORE_MARIO_UPDATE, mario_update)
