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

local sEnableGrid = true
local sForceDisableGrid = false
GRID_SIZE_DEFAULT = 200
gGridSize = { x = GRID_SIZE_DEFAULT, y = GRID_SIZE_DEFAULT, z = GRID_SIZE_DEFAULT }

local function to_grid_x(n)
	if sEnableGrid then
		return math.floor(n/gGridSize.x + .5) * gGridSize.x
	else
		return n
	end
end

local function to_grid_y(n)
	if sEnableGrid then
		return math.floor(n/gGridSize.y + .5) * gGridSize.y
	else
		return n
	end
end

local function to_grid_z(n)
	if sEnableGrid then
		return math.floor(n/gGridSize.z + .5) * gGridSize.z
	else
		return n
	end
end

---@param msg string
local function on_grid_size_chat_command(msg)
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

	if not sizes[1] or not tonumber(sizes[1]) then
		djui_chat_message_create("Usage: [num] or [x|y|z]")
		return true
	end

	if sizes_count == 1 then
		local new_size = (tonumber(sizes[1]) or 1) * GRID_SIZE_DEFAULT
		vec3f_set(gGridSize, new_size, new_size, new_size)
		djui_chat_message_create("Set grid size to " .. sizes[1])
	elseif sizes_count == 3 then
		local new_size_x = (tonumber(sizes[1]) or 1) * GRID_SIZE_DEFAULT
		local new_size_y = (tonumber(sizes[2]) or 1) * GRID_SIZE_DEFAULT
		local new_size_z = (tonumber(sizes[3]) or 1) * GRID_SIZE_DEFAULT
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
	spawn_non_sync_object(bhvPreviewItem, E_MODEL_NONE, obj.oPosX, obj.oPosY, obj.oPosZ, nil)
	spawn_non_sync_object(bhvArrow, E_MODEL_ARROW, obj.oPosX, obj.oPosY, obj.oPosZ, nil)
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

	local posX = to_grid_x( m.pos.x + facing_x * math.max(gGridSize.x, GRID_SIZE_DEFAULT) )
	local posY = to_grid_y( m.pos.y ) + (gGridSize.y * gOutlineGridYOffset)
	local posZ = to_grid_z( m.pos.z + facing_z * math.max(gGridSize.z, GRID_SIZE_DEFAULT) )

	sOutlineObject.oPosX = posX
	sOutlineObject.oPosY = posY
	sOutlineObject.oPosZ = posZ
	local item_params = current_item.params
	if not item_params then return end

	local item_size = item_params.size
	if item_size then
		obj_scale_xyz(obj, item_size.x, item_size.y, item_size.z)
	end

	if item_params.rotation then
		local item_rotation = current_item.params.rotation
		if not item_rotation then return end

		sOutlineObject.oFaceAnglePitch = item_rotation.x
		sOutlineObject.oFaceAngleYaw = item_rotation.y
		sOutlineObject.oFaceAngleRoll = item_rotation.z
		sOutlineObject.oMoveAnglePitch = item_rotation.x
		sOutlineObject.oMoveAngleYaw = item_rotation.y
		sOutlineObject.oMoveAngleRoll = item_rotation.z
	end
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
	local current_item = gCurrentItem
	if current_item.behavior == bhvMceBlock then
		local transparent_start = mce_block_get_transparent_start_item(current_item)
		obj.oAnimState = current_item.animState + transparent_start
		obj.oOpacity = 100

		local anim_max = mce_block_get_anim_max_item(current_item)
		if obj.oAnimState > anim_max then
			obj.oAnimState = anim_max
		end
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
	obj.oPosY = sOutlineObject.oPosY - (item_params.spawnYOffset * item_params.size.y)
	obj.oPosZ = sOutlineObject.oPosZ
	obj.header.gfx.node.flags = obj.header.gfx.node.flags & ~GRAPH_RENDER_BILLBOARD
	obj.oItemParams = item_params.params
	local outline_scale = sOutlineObject.header.gfx.scale
	obj_scale_xyz(obj, outline_scale.x, outline_scale.y, outline_scale.z)
	obj_set_model_extended(obj, current_item.model)

	preview_handle_transparency(obj)

	local preview_settings = item_params.preview
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
		obj.oPosX = sOutlineObject.oPosX + sins(sOutlineObject.oFaceAngleYaw) * GRID_SIZE_DEFAULT * outline_scale.x
		obj.oPosY = sOutlineObject.oPosY - (item_params.spawnYOffset * item_params.size.y)
		obj.oPosZ = sOutlineObject.oPosZ + coss(sOutlineObject.oFaceAngleYaw) * GRID_SIZE_DEFAULT * outline_scale.z
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
		sOutlineObject.oPosX, sOutlineObject.oPosY - (current_item_params.spawnYOffset * current_item_params.size.y), sOutlineObject.oPosZ,
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
			obj.oBlockSurfaceProperties = current_item_params.blockProperties
			obj.oScaleX = current_item_params.size.x
			obj.oScaleY = current_item_params.size.y
			obj.oScaleZ = current_item_params.size.z
			obj_scale_xyz(obj, current_item_params.size.x, current_item_params.size.y, current_item_params.size.z)
			obj.oAnimState = current_item.animState
			obj.globalPlayerIndex = network_global_index_from_local(0)
			obj.oOwner = network_global_index_from_local(0) + 1
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

-- Used by load_command in save.lua
function place_item_with_params(item)
	local spawned_item = spawn_sync_object(
		item.id,
		item.model,
		item.x, item.y, item.z,
		---@param obj Object
		function (obj)
			obj.oOpacity = 255
			obj.oFaceAnglePitch = item.pitch
			obj.oFaceAngleYaw = item.yaw
			obj.oFaceAngleRoll = item.roll
			obj.oMoveAnglePitch = item.pitch
			obj.oMoveAngleYaw = item.yaw
			obj.oMoveAngleRoll = item.roll
			obj.oItemParams = item.params
			obj.oBlockSurfaceProperties = item.properties
			obj.oScaleX = item.scaleX
			obj.oScaleY = item.scaleY
			obj.oScaleZ = item.scaleZ
			obj_scale_xyz(obj, item.scaleX, item.scaleY, item.scaleZ)
			obj.oAnimState = item.animState
			obj.globalPlayerIndex = network_global_index_from_local(0)
			obj.oOwner = network_global_index_from_local(0) + 1
		end
	)

	if not spawned_item then
		djui_chat_message_create("Item failed to place. Perhaps the object limit was reached?")
	end
end

---@param allow_build_delete {build: boolean, delete: boolean}
---@return boolean
local function determine_place_or_delete(allow_build_delete)
	if not sOutlineObject then return false end
	local nearest = obj_get_any_nearest_item(sOutlineObject)

	if nearest then
		local dists = {
			x = math.abs(nearest.oPosX - sOutlineObject.oPosX),
			y = math.abs(nearest.oPosY - sOutlineObject.oPosY),
			z = math.abs(nearest.oPosZ - sOutlineObject.oPosZ)
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
	if not sOutlineObject or m.controller.buttonDown & L_TRIG == 0 then return end

	local current_selected = Hotbar.items[Hotbar.index]
	if current_selected then
		local current_item = current_selected.item
		local pressed = m.controller.buttonPressed
		local params = current_item.params
		if not params then return end
		local size = params.size
		if not size then return end

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
	if not sOutlineObject or m.controller.buttonDown & L_TRIG == 0 then return end

	local current_item = gCurrentItem
	if not current_item then return end
	local pressed = m.controller.buttonPressed
	local params = current_item.params
	if not params then return end
	local item_rotation = params.rotation
	if not item_rotation then return end

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
		gCurrentItem.params.rotation = gVec3sZero()
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
				nil
			)
		end
		return
	end

	sEnableGrid = not sForceDisableGrid and (m.controller.buttonDown & L_TRIG == 0 or m.controller.buttonDown & R_TRIG == 0)

	set_item_size_control(m)
	set_outline_offset(m)
	set_item_rotation(m)
	if m.controller.buttonPressed & Y_BUTTON ~= 0 then
		sBuiltOrDeleted = determine_place_or_delete({build = true, delete = true})
    end
	if sAutoBuild and m.controller.buttonDown & Y_BUTTON ~= 0 then
		-- TEMPORARY
		local do_build = sBuiltOrDeleted
		local restrict_auto_build = true
		for _, id in ipairs(gItemBhvIds) do
			if gCurrentItem.behavior == id then
				restrict_auto_build = false
			end
		end
		if restrict_auto_build then
			if sAutoBuildTimer < 15 then
				sAutoBuildTimer = sAutoBuildTimer + 1
				return
			else
				sAutoBuildTimer = 0
			end
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
