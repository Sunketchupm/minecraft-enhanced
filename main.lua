-- name: Minecraft Enhanced Rewrite
-- description: An improved version of the Minecraft mod, originally by zKevin

gLevelValues.fixCollisionBugs = true
gLevelValues.fixCollisionBugsFalseLedgeGrab = false
gLevelValues.fixCollisionBugsGroundPoundBonks = false

gServerSettings.stayInLevelAfterStar = 1

CanBuild = true

-------------------------------------------------------------------------------

local ON_GRID = true
local GRID_SIZE = 200

local function to_grid(n)
	if ON_GRID then
		return math.floor(n/GRID_SIZE + .5) * GRID_SIZE
	else
		return n
	end
end

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

	local posX = to_grid( m.pos.x + facing_x*GRID_SIZE )
	local posY = to_grid( m.pos.y )
	local posZ = to_grid( m.pos.z + facing_z*GRID_SIZE )

	outline.oPosX = posX
	outline.oPosY = posY
	outline.oPosZ = posZ
end

--------------------------------------

--- Called from bhvMockItem.bhv

---@param obj Object
function bhv_mock_item_loop(obj)
	local current_item = gCurrentItem
	if outline and current_item and current_item.model then
		obj.oPosX = outline.oPosX
		obj.oPosY = outline.oPosY - current_item.spawnYOffset
		obj.oPosZ = outline.oPosZ
		obj.oFaceAnglePitch = outline.oFaceAnglePitch
		obj.oFaceAngleYaw = outline.oFaceAngleYaw
		obj.oFaceAngleRoll = outline.oFaceAngleRoll
		obj.header.gfx.node.flags = obj.header.gfx.node.flags & ~GRAPH_RENDER_BILLBOARD
		obj.oAnimState = 0
		obj.oBehParams = current_item.behaviorParams
		obj_scale(obj, 1)
		obj_set_model_extended(obj, current_item.model)
		if current_item.mock then
			local mock_settings = current_item.mock
			if mock_settings.billboard then
				obj_set_billboard(obj)
			end

			if mock_settings.animState then
				obj.oAnimState = mock_settings.animState
			end
			if mock_settings.scale then
				obj_scale(obj, mock_settings.scale)
			end
		end
	else
		obj_set_model_extended(obj, E_MODEL_NONE)
	end
end

-------------------------------------------------------------------------------

local function place_item()
	if not outline or not gCurrentItem or not gCurrentItem.behavior or not gCurrentItem.model then return end
	spawn_sync_object(
		gCurrentItem.behavior,
		gCurrentItem.model,
		outline.oPosX, outline.oPosY  - gCurrentItem.spawnYOffset, outline.oPosZ,
		---@param obj Object
		function (obj)
			obj.oOpacity = 255
			obj.oFaceAnglePitch = outline.oFaceAnglePitch
			obj.oFaceAngleYaw = outline.oFaceAngleYaw
			obj.oFaceAngleRoll = outline.oFaceAngleRoll
			if gCurrentItem.behaviorParams then
				obj.oBehParams = gCurrentItem.behaviorParams
			end
			--[[if gCurrentItem.misc then
				
			end]]
		end
	)

	play_sound(SOUND_GENERAL_BOX_LANDING, gMarioStates[0].marioObj.header.gfx.cameraToObject)
end

local function determine_place_or_delete()
	if not outline then return end
	local nearest = obj_get_any_nearest_item(outline)

	if nearest then
		local dist = dist_between_objects(outline, nearest)
		if dist >= GRID_SIZE then
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
		else
			outline.oFaceAnglePitch = outline.oFaceAnglePitch + 0x400
		end
	elseif pressed & D_JPAD ~= 0 then
		if l_held_modifier then
			outline.oFaceAngleRoll = outline.oFaceAngleRoll - 0x400
		else
			outline.oFaceAnglePitch = outline.oFaceAnglePitch - 0x400
		end
	end
	if l_held_modifier then
		if pressed & L_JPAD ~= 0 then
			outline.oFaceAngleYaw = outline.oFaceAngleYaw - 0x400
		elseif pressed & R_JPAD ~= 0 then
			outline.oFaceAngleYaw = outline.oFaceAngleYaw + 0x400
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
		builder_mario_update(m)
	else
		delete_outline()
	end

	CanBuild = m.action == ACT_FREE_MOVE
end


hook_event(HOOK_ON_WARP, on_warp)
hook_event(HOOK_MARIO_UPDATE, mario_update)