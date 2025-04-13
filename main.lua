-- name: Minecraft
-- description: Y to place block

local ON_GRID = true
local GRID_SIZE = 200

local function to_grid(n)
	if ON_GRID then
		return math.floor(n/GRID_SIZE + .5) * GRID_SIZE
	else
		return n
	end
end

--outline place
function bhv_outlineblock_init(obj)
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
	cur_obj_scale(4.01)
	obj.oOpacity = 255
	obj.oFaceAnglePitch = 0
	obj.oFaceAngleYaw = 0
	obj.oFaceAngleRoll = 0
end

id_bhvOutlineblock = hook_behavior(nil, OBJ_LIST_DEFAULT, true, bhv_outlineblock_init, nil)

function find_place()
    local obj = obj_get_first(OBJ_LIST_DEFAULT)
    while obj ~= nil do
        if get_id_from_behavior(obj.behavior) == id_bhvOutlineblock then
            return obj
        end
        obj = obj_get_next(obj)
    end
    return nil
end

local place

function place_block(x,y,z)
	local box = spawn_sync_object(
		id_bhvBreakableBox,
		E_MODEL_BREAKABLE_BOX,
		x,y,z,
		function (obj)
			obj.oOpacity = 255
			obj.oFaceAnglePitch = 0
			obj.oFaceAngleYaw = 0
			obj.oFaceAngleRoll = 0
		end
	)
	
	play_sound(SOUND_GENERAL_BOX_LANDING, {x=x,y=y,z=z} )
end

function mario_update_local(m)
	local rgt = math.sin(m.intendedYaw/32688 * math.pi)--idk the max angle value so i just went with this
	local fwd = math.cos(m.intendedYaw/32688 * math.pi)
	
	local in_air = m.pos.y - m.floorHeight > 5
	local crouching = (m.controller.buttonDown & Z_TRIG) ~= 0
	local posX = to_grid( m.pos.x + (in_air and 0 or rgt*GRID_SIZE) )
	local posY = to_grid( m.pos.y + ((in_air or crouching) and -GRID_SIZE or 0) )
	local posZ = to_grid( m.pos.z + (in_air and 0 or fwd*GRID_SIZE) )
	
	--update outline box pos
	place = find_place()--prob not best to run this every update
	if not place then
		place = spawn_non_sync_object(
			id_bhvOutlineblock,
			E_MODEL_EXCLAMATION_BOX_OUTLINE,
			posX,posY,posZ,
			nil
		)
	else
		place.oPosX = posX
		place.oPosY = posY - 8
		place.oPosZ = posZ
	end
	
	
	--place block
	if (m.controller.buttonPressed & Y_BUTTON) ~= 0 then
		local nearest = obj_get_nearest_object_with_behavior_id(place, id_bhvBreakableBox)
		
		if nearest then
			local dist = dist_between_objects(place, nearest)
			if dist >= GRID_SIZE-10 then
				place_block(posX,posY,posZ)
			else
				play_sound(SOUND_MENU_CAMERA_BUZZ, m.marioObj.header.gfx.cameraToObject)
			end
		else
			place_block(posX,posY,posZ)
		end
    end
end

function on_warp()
	if place then
		obj_mark_for_deletion(place)
	end
end

function mario_update(m)
    if m.playerIndex == 0 then
        mario_update_local(m)
    end
end


hook_event(HOOK_ON_WARP, on_warp)
hook_event(HOOK_MARIO_UPDATE, mario_update)