-- name: Minecraft Enhanced Rewrite
-- description: An improved version of the Minecraft mod, originally by zKevin

CanBuild = true

-------------------------------------------------------------------------------

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

local E_MODEL_COLOR_BOX = smlua_model_util_get_id("mce_box")

function lua_asm_set_color(node, _misc)
    local graphNode = cast_graph_node(node.next)
    local dl = graphNode.displayList
	if gCurrentItem and gCurrentItem.behavior == bhvMinecraftBox then
		local color = gCurrentItem.params.color
		if color then
			gfx_parse(dl, function(cmd, op)
				if op == G_SETPRIMCOLOR then
					gfx_set_command(cmd, "gsDPSetPrimColor(0, 0, %i, %i, %i, %i)", color.r, color.g, color.b, color.a)
				end
			end)
		end
	end
end

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

---@param m MarioState
local function builder_mario_update(m)
	local facing_x = sins(m.intendedYaw)
	local facing_z = coss(m.intendedYaw)

	local posX = to_grid( m.pos.x + facing_x*GRID_SIZE )
	local posY = to_grid( m.pos.y )
	local posZ = to_grid( m.pos.z + facing_z*GRID_SIZE )

	outline = obj_get_first_with_behavior_id(id_bhvOutlineBlock)
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
		determine_place_or_delete()
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
	if CanBuild then
		builder_mario_update(m)
	else
		if outline then
			obj_mark_for_deletion(outline)
		end
	end

	CanBuild = m.action == ACT_FREE_MOVE
end


hook_event(HOOK_ON_WARP, on_warp)
hook_event(HOOK_MARIO_UPDATE, mario_update)