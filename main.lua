-- name: \\#31db02\\Minecraft \\#1dcff2\\Enhanced \\#dcdcdc\\[WIP]
-- description: An improved version of the Minecraft mod, originally by zKevin.\n\nMod made by Teru. Texture help by Sherbie. Minecraft+ made by Bene360 (which isn't used in this mod, but their effort shouldn't be wasted).

local Hotbar = require("src/menu/hotbar") ---@diagnostic disable-line: different-requires

gLevelValues.fixCollisionBugs = true
gLevelValues.fixCollisionBugsFalseLedgeGrab = false
gLevelValues.fixCollisionBugsGroundPoundBonks = false

gServerSettings.stayInLevelAfterStar = 1
gLevelValues.fixInvalidShellRides = false

gCanBuild = true

E_MODEL_MCE_BLOCK = smlua_model_util_get_id("mce_block_geo")
E_MODEL_OUTLINE = smlua_model_util_get_id("mce_outline")
E_MODEL_ARROW = smlua_model_util_get_id("arrow_geo")

-------------------------------------------------------------------------------

local sEnableGrid = true
local sForceDisableGrid = false
GRID_SIZE_MULTIPLIER = 200

---@param num number
---@param grid number
local __to_grid = function (num, grid)
	if sEnableGrid then
		return math.floor(num / grid + .5) * grid
	else
		return num
	end
end

---@param item Item
---@param size string
---@param key string
---@return number
local __parse_size = function (item, size, key)
    if size == "_" then
        return item.dimensions.grid[key]
    end

    local new_size = 0
    local symbol = size:sub(1, 1)
    if symbol == "+" or symbol == "-" then
        local number = size:sub(2)
        if symbol == "-" then
            number = "-" .. number
        end
        if tonumber(number) then
            new_size = size + number
			return math.clamp(new_size, 0.01, 25)
        end
    end

    return math.clamp(tonumber(size) or item.dimensions.grid[key], 0.01, 25)
end

---@param msg string
local function on_grid_size_chat_command(msg)
	if not gCurrentItem then
		djui_chat_message_create("You need to hold an item to modify the grid")
		return true
	end
	local current_item = gCurrentItem

	if msg:lower() == "off" then
		sForceDisableGrid = true
		djui_chat_message_create("Turned off the grid")
		return true
	elseif msg:lower() == "on" then
		sForceDisableGrid = false
		djui_chat_message_create("Turned on the grid")
		return true
	elseif msg:lower() == "" then
		sForceDisableGrid = not sForceDisableGrid
		djui_chat_message_create("Turned " .. (sForceDisableGrid and "on" or "off") .. " the grid")
		return true
	end

	local sizes = string.split(msg, " ")
	local sizes_count = #sizes

	if not sizes[1] then
		djui_chat_message_create("Usage: [num] or [x|y|z]")
		return true
	end

	if sizes_count == 1 then
		local new_size = __parse_size(current_item, sizes[1], "x")
		vec3f_set(current_item.dimensions.grid, new_size, new_size, new_size)
		djui_chat_message_create("Set grid size to " .. new_size)
	elseif sizes_count == 3 then
		local new_size_x = __parse_size(current_item, sizes[1], "x")
		local new_size_y = __parse_size(current_item, sizes[2], "y")
		local new_size_z = __parse_size(current_item, sizes[3], "z")
		vec3f_set(gCurrentItem.dimensions.grid, new_size_x, new_size_y, new_size_z)
		djui_chat_message_create("Set grid size to (" .. new_size_x .. ", " .. new_size_y .. ", " .. new_size_z .. ")")
	else
		djui_chat_message_create("Usage: [num] or [x y z] or [on|off]")
	end
	return true
end

hook_chat_command("grid", "[num] or [x|y|z] or [on|off] | Change the shape of the grid. Default is 1 in each dimension", on_grid_size_chat_command)

-------------------------------------------------------------------------------

---@type Object?
local sOutlineObject = nil
gOutlineGridYOffset = 0

--- Called from bhvOutline.bhv

---@param obj Object
function bhv_outline_init(obj)
	sOutlineObject = obj
	obj.oOpacity = 255
	obj.oFaceAnglePitch = 0
	obj.oFaceAngleYaw = 0
	obj.oFaceAngleRoll = 0
	spawn_non_sync_object(bhvPreviewItem, E_MODEL_NONE, obj.oPosX, obj.oPosY, obj.oPosZ, function () end)
	spawn_non_sync_object(bhvArrow, E_MODEL_ARROW, obj.oPosX, obj.oPosY, obj.oPosZ, function () end)
end

---@param obj Object
function bhv_outline_loop(obj)
	local current_item = gCurrentItem
	if not current_item then
		obj_mark_for_deletion(obj)
		sOutlineObject = nil
		return
	end
	obj.parentObj = obj

	sOutlineObject = obj

	---@type MarioState
	local m = gMarioStates[0]
	local facing_x = sins(m.intendedYaw)
	local facing_z = coss(m.intendedYaw)
	if m.controller.buttonDown & L_TRIG ~= 0 then
		facing_x = sins(m.faceAngle.y)
		facing_z = coss(m.faceAngle.y)
	end

	local gridX = current_item.dimensions.grid.x * GRID_SIZE_MULTIPLIER
	local gridY = current_item.dimensions.grid.y * GRID_SIZE_MULTIPLIER
	local gridZ = current_item.dimensions.grid.z * GRID_SIZE_MULTIPLIER
	local posX = __to_grid(m.pos.x + facing_x * math.max(gridX, GRID_SIZE_MULTIPLIER), gridX)
	local posY = __to_grid(m.pos.y, gridY) + (gridY * gOutlineGridYOffset)
	local posZ = __to_grid(m.pos.z + facing_z * math.max(gridZ, GRID_SIZE_MULTIPLIER), gridZ)

	sOutlineObject.oPosX = posX
	sOutlineObject.oPosY = posY
	sOutlineObject.oPosZ = posZ

	local item_dimensions = current_item.dimensions

	local item_size = item_dimensions.size
	obj_scale_xyz(obj, item_size.x, item_size.y, item_size.z)

	local rotation = item_dimensions.rotation
	sOutlineObject.oFaceAnglePitch = rotation.x
	sOutlineObject.oFaceAngleYaw = rotation.y
	sOutlineObject.oFaceAngleRoll = rotation.z
	sOutlineObject.oMoveAnglePitch = rotation.x
	sOutlineObject.oMoveAngleYaw = rotation.y
	sOutlineObject.oMoveAngleRoll = rotation.z
end

--------------------------------------

---@param animate_settings PreviewAnimations
---@param obj Object
local function preview_animate(animate_settings, obj)
	if animate_settings.animation then
		obj.oAnimations = animate_settings.animation
		cur_obj_init_animation(animate_settings.animIndex or 0)
	end

	if animate_settings.animState then
		if obj.oTimer >= animate_settings.animState then
			obj.oAnimState = obj.oAnimState + 1
			obj.oTimer = 0
		end
	end

	if animate_settings.faceAngleYaw then
		obj.oFaceAngleYaw = math.s16(obj.oFaceAngleYaw + animate_settings.faceAngleYaw)
	else
		---@cast sOutlineObject Object
		obj.oFaceAngleYaw = sOutlineObject.oFaceAngleYaw
	end
end

---@param obj Object
local function preview_handle_transparency(obj)
	local current_item = gCurrentItem --[[@as Item]]
	if current_item.behavior == bhvMceBlock then
		obj.oOpacity = 127
	else
		obj.oOpacity = 255
	end
end

--- Called from bhvPreviewItem.bhv

---@param obj Object
function bhv_preview_item_loop(obj)
	if not sOutlineObject or not gCurrentItem then
		obj_mark_for_deletion(obj)
		return
	end
	local current_item = gCurrentItem
	obj.parentObj = obj

	local item_params = current_item.params
	obj.oPosX = sOutlineObject.oPosX
	obj.oPosY = sOutlineObject.oPosY - (item_params.yOffset * current_item.dimensions.size.y)
	obj.oPosZ = sOutlineObject.oPosZ
	obj.header.gfx.node.flags = obj.header.gfx.node.flags & ~GRAPH_RENDER_BILLBOARD
	obj.oItemParams = item_params.params
	obj.oColor = color_table_to_integer(item_params.color)
	local outline_scale = sOutlineObject.header.gfx.scale
	obj_scale_xyz(obj, outline_scale.x, outline_scale.y, outline_scale.z)
	obj_set_model_extended(obj, current_item.model)

	preview_handle_transparency(obj)

	local preview_settings = current_item.preview
	if current_item.behavior ~= bhvMceBlock and preview_settings then
		if preview_settings.billboard then
			obj_set_billboard(obj)
		end

		if preview_settings.scale then
			obj_scale_mult_to(obj, preview_settings.scale)
		end

		local animate_settings = preview_settings.animate
		if animate_settings then
			preview_animate(animate_settings, obj)
		else
			obj.oAnimState = current_item.animState
			obj.oFaceAngleYaw = sOutlineObject.oFaceAngleYaw
		end
	elseif current_item.behavior == bhvMceBlock then
		obj.oAnimState = current_item.animState
	end

	obj.oFaceAnglePitch = sOutlineObject.oFaceAnglePitch
	obj.oFaceAngleYaw = sOutlineObject.oFaceAngleYaw
	obj.oFaceAngleRoll = sOutlineObject.oFaceAngleRoll
end

--------------------------------------

local sShowArrow = true

--- Called from bhvArrow.bhv

---@param obj Object
function bhv_arrow_loop(obj)
	local current_item = gCurrentItem
	if sOutlineObject and obj_get_first_with_behavior_id(bhvOutline) and current_item and current_item.model then
		local item_params = current_item.params
		outline_scale = sOutlineObject.header.gfx.scale
		obj.oPosX = sOutlineObject.oPosX + sins(sOutlineObject.oFaceAngleYaw) * GRID_SIZE_MULTIPLIER * outline_scale.x
		obj.oPosY = sOutlineObject.oPosY - (item_params.yOffset * current_item.dimensions.size.y)
		obj.oPosZ = sOutlineObject.oPosZ + coss(sOutlineObject.oFaceAngleYaw) * GRID_SIZE_MULTIPLIER * outline_scale.z
		obj_scale_xyz(obj, outline_scale.x, outline_scale.y, outline_scale.z)
		obj.oFaceAngleYaw = sOutlineObject.oFaceAngleYaw - 16384
	else
		obj_mark_for_deletion(obj)
	end

	if gMarioStates[0].controller.buttonDown & L_TRIG ~= 0 and sShowArrow then
		cur_obj_enable_rendering()
	else
		cur_obj_disable_rendering()
	end
end

hook_mod_menu_checkbox("Show Angle Arrow", true, function (_, value)
	sShowArrow = value
end)

-------------------------------------------------------------------------------

local function place_item()
	local current_item = gCurrentItem
	if not sOutlineObject or not current_item or not current_item.behavior or not current_item.model then return end

	local current_item_params = current_item.params
	local item = spawn_sync_object(
		current_item.behavior,
		current_item.model,
		sOutlineObject.oPosX, sOutlineObject.oPosY - (current_item_params.yOffset * current_item.dimensions.size.y), sOutlineObject.oPosZ,
		---@param obj Object
		function (obj)
			obj.oOpacity = 255
			obj.oFaceAnglePitch = sOutlineObject.oFaceAnglePitch
			obj.oFaceAngleYaw = sOutlineObject.oFaceAngleYaw
			obj.oFaceAngleRoll = sOutlineObject.oFaceAngleRoll
			obj.oMoveAnglePitch = sOutlineObject.oMoveAnglePitch
			obj.oMoveAngleYaw = sOutlineObject.oMoveAngleYaw
			obj.oMoveAngleRoll = sOutlineObject.oMoveAngleRoll
			obj.oItemParams = current_item_params.params
			obj.oItemFlags = current_item_params.flags
			obj.oScaleX = current_item.dimensions.size.x
			obj.oScaleY = current_item.dimensions.size.y
			obj.oScaleZ = current_item.dimensions.size.z
			obj_scale_xyz(obj, current_item.dimensions.size.x, current_item.dimensions.size.y, current_item.dimensions.size.z)
			obj.globalPlayerIndex = network_global_index_from_local(0)
			obj.oOwner = network_global_index_from_local(0) + 1
			obj.oColor = color_table_to_integer(current_item.params.color)
			obj.oAnimState = current_item.animState

			if current_item.behavior == bhvMceBlock then
				obj.oAnimState = current_item.animState
				obj.oOpacity = current_item.params.color.a
			end
		end
	)
	-- Just to make sure
	network_send_object(item, true)

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

local sCanDelete = true
---@param allow_build_delete { build: boolean, delete: boolean }
---@return boolean
local function determine_place_or_delete(allow_build_delete)
	if not sOutlineObject then return false end
	local nearest = obj_get_any_nearest_item(sOutlineObject)

	if nearest then
		if gCurrentItem then
			local dists = {
				x = math.abs(nearest.oPosX - sOutlineObject.oPosX),
				y = math.abs(nearest.oPosY - sOutlineObject.oPosY),
				z = math.abs(nearest.oPosZ - sOutlineObject.oPosZ)
			}
			local is_outside_range = dists.x >= gCurrentItem.dimensions.grid.x or
									 dists.y >= gCurrentItem.dimensions.grid.y or
									 dists.z >= gCurrentItem.dimensions.grid.z
			if not sCanDelete then
				is_outside_range = true
			end

			if allow_build_delete.build and is_outside_range then
				place_item()
				return true
			elseif allow_build_delete.delete and not is_outside_range then
				play_sound(SOUND_GENERAL_BOX_LANDING, gMarioStates[0].marioObj.header.gfx.cameraToObject)
				obj_mark_for_deletion(nearest)
				return false
			end
		end
	elseif allow_build_delete.build then
		if gCurrentItem then
			place_item()
		end
		return true
	end
	return false
end

---@param m MarioState
local function set_item_size_control(m)
	if not sOutlineObject or not gCurrentItem or m.controller.buttonDown & L_TRIG == 0 then return end

	local pressed = m.controller.buttonPressed
	local size = gCurrentItem.dimensions.size

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

---@param m MarioState
local function set_outline_offset(m)
	if not sOutlineObject or m.controller.buttonDown & L_TRIG ~= 0 then return end
	local pressed = m.controller.buttonPressed

	if pressed & U_JPAD ~= 0 and gOutlineGridYOffset < 3 then
		gOutlineGridYOffset = gOutlineGridYOffset + 1
	elseif pressed & D_JPAD ~= 0 and gOutlineGridYOffset > -3 then
		gOutlineGridYOffset = gOutlineGridYOffset - 1
	end
end

local sRotationIncrement = degrees_to_sm64(15)
---@param m MarioState
local function set_item_rotation(m)
	if not sOutlineObject or not gCurrentItem or m.controller.buttonDown & L_TRIG == 0 then return end

	local item_rotation = gCurrentItem.dimensions.rotation
	local pressed = m.controller.buttonPressed

	if pressed & U_CBUTTONS ~= 0 then
		item_rotation.x = item_rotation.x + sRotationIncrement
	elseif pressed & D_CBUTTONS ~= 0 then
		item_rotation.x = item_rotation.x - sRotationIncrement
	end
	if pressed & L_CBUTTONS ~= 0 then
		item_rotation.y = item_rotation.y + sRotationIncrement
	elseif pressed & R_CBUTTONS ~= 0 then
		item_rotation.y = item_rotation.y - sRotationIncrement
	end
	if pressed & L_JPAD ~= 0 then
		item_rotation.z = item_rotation.z + sRotationIncrement
	elseif pressed & R_JPAD ~= 0 then
		item_rotation.z = item_rotation.z - sRotationIncrement
	end
	if pressed & X_BUTTON ~= 0 then
		gCurrentItem.dimensions.rotation = gVec3sZero()
	end

	m.controller.buttonPressed = m.controller.buttonPressed & ~(U_CBUTTONS | L_CBUTTONS | D_CBUTTONS | R_CBUTTONS | X_BUTTON)
end

hook_mod_menu_inputbox("Angle Increment", "15", 4, function (index, value)
	sRotationIncrement = degrees_to_sm64(tonumber(value) or 15)
	update_mod_menu_element_inputbox(index, tostring(math.round(sm64_to_degrees(sRotationIncrement))))
end)

local function delete_outline()
	if sOutlineObject then
		obj_mark_for_deletion(sOutlineObject)
	end
	local preview = obj_get_first_with_behavior_id(bhvPreviewItem)
	if preview then
		obj_mark_for_deletion(preview)
	end
end

---------------------------------------

local sAutoBuild = true
local sAutoBuildTimer = 0 -- TEMPORARY
local sBuiltOrDeleted = false

---@param m MarioState
local function builder_mario_update(m)
	if not obj_get_first_with_behavior_id(bhvOutline) then
		sOutlineObject = nil
		if gCurrentItem then
			spawn_non_sync_object(
				bhvOutline,
				E_MODEL_OUTLINE,
				m.pos.x, m.pos.y, m.pos.z,
				function () end
			)
		end
		return
	end

	sEnableGrid = not sForceDisableGrid and (m.controller.buttonDown & L_TRIG == 0 or m.controller.buttonDown & R_TRIG == 0)

	set_item_size_control(m)
	set_outline_offset(m)
	set_item_rotation(m)
	if m.controller.buttonPressed & Y_BUTTON ~= 0 then
		sBuiltOrDeleted = determine_place_or_delete({ build = true, delete = true })
    end
	if sAutoBuild and m.controller.buttonDown & Y_BUTTON ~= 0 then
		local do_build = sBuiltOrDeleted
		if sAutoBuildTimer < 5 then
			sAutoBuildTimer = sAutoBuildTimer + 1
			return
		else
			sAutoBuildTimer = 0
		end
		determine_place_or_delete({build = do_build, delete = not do_build})
	else
		sAutoBuildTimer = 0
	end

	if m.controller.buttonDown & L_TRIG ~= 0 and m.controller.buttonPressed & R_TRIG ~= 0 then
		m.controller.buttonPressed = m.controller.buttonPressed & ~R_TRIG
	end
end

hook_mod_menu_checkbox("Autobuild", true, function (_, value)
	sAutoBuild = value
end)

-------------------------------------------------------------------------------

local function on_warp()
	delete_outline()
end

---@param m MarioState
local function before_mario_update(m)
	if m.playerIndex ~= 0 then return end
	if gCanBuild then
		if not gMenu.open then
			builder_mario_update(m)
		end
	else
		delete_outline()
	end

	gCanBuild = m.action == ACT_FREE_MOVE
end


hook_event(HOOK_ON_WARP, on_warp)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)

local function on_delete_chat_command()
	sCanDelete = not sCanDelete
	djui_chat_message_create("You are " .. (sCanDelete and "now" or "no longer") .. " able to delete objects")
	return true
end

hook_chat_command("delete", "| Toggle whether or not you can delete blocks", on_delete_chat_command)