-- name: Minecraft Rewrite
-- description: A rewritten version of Minecraft, originally by zKevin

local outline = nil
local function bhv_outline_init(obj)
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
	obj.oFaceAnglePitch = 0
	obj.oFaceAngleYaw = 0
	obj.oFaceAngleRoll = 0
end

id_bhvOutlineBlock = hook_behavior(nil, OBJ_LIST_DEFAULT, true, bhv_outline_init, nil)

--- Called from bhvMinecraftBox.bhv

---@param obj Object
function bhv_minecraft_block_loop(obj)
	
end

local E_MODEL_COLOR_BOX = smlua_model_util_get_id("color_box_geo")

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

local function place_item()
	if not outline or not gCurrentItem or not gCurrentItem.behavior then return end
	spawn_sync_object(
		gCurrentItem.behavior,
		E_MODEL_COLOR_BOX,
		outline.oPosX, outline.oPosY, outline.oPosZ,
		---@param obj Object
		function (obj)
			obj.oOpacity = 255
			obj.oFaceAnglePitch = 0
			obj.oFaceAngleYaw = 0
			obj.oFaceAngleRoll = 0
			if gCurrentItem.behavior == bhvMinecraftBox then
				obj.oAnimState = gCurrentItem.params.color
			end
		end
	)

	play_sound(SOUND_GENERAL_BOX_LANDING, gMarioStates[0].marioObj.header.gfx.cameraToObject)
end

---@param m MarioState
local function outline_block_mario_update(m)
	local facing_x = sins(m.intendedYaw)
	local facing_z = coss(m.intendedYaw)

	local posX = to_grid( m.pos.x + facing_x*GRID_SIZE )
	local posY = to_grid( m.pos.y )
	local posZ = to_grid( m.pos.z + facing_z*GRID_SIZE )

	if not outline then
		outline = spawn_non_sync_object(
			id_bhvOutlineBlock,
			E_MODEL_COLOR_BOX,
			posX, posY, posZ,
			---@param obj Object
			function (obj)
				obj.oAnimState = 16
				obj.oOpacity = 255
			end
		)
	else
		outline.oPosX = posX
		outline.oPosY = posY
		outline.oPosZ = posZ
	end

	-- place block
	if (m.controller.buttonPressed & Y_BUTTON) ~= 0 then
		local nearest = obj_get_nearest_object_with_behavior_id(outline, bhvMinecraftBox)

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
end

-------------------------------------------------------------------------------

local function on_warp()
	if outline then
		obj_mark_for_deletion(outline)
	end
end

---@param m MarioState
local function mario_update(m)
	if m.playerIndex ~= 0 then return end
    outline_block_mario_update(m)
end


hook_event(HOOK_ON_WARP, on_warp)
hook_event(HOOK_MARIO_UPDATE, mario_update)