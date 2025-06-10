---@class Item
    ---@field behavior BehaviorId
    ---@field model ModelExtendedId
    ---@field params table

gCurrentItem = {behavior = nil, model = E_MODEL_NONE, params = {}}
gItemBehaviors = {}
add_first_update(function ()
    ---@type Item
    gCurrentItem = {behavior = bhvMinecraftBox, model = E_MODEL_COLOR_BOX, params = {color = {r = 255, g = 0, b = 0, a = 255}}}
    ---@type BehaviorId[]
    gItemBehaviors = {
        bhvMinecraftBox
    }
end)

------------------------------------------------------------------------------------------

--- Called from bhvMinecraftBox.bhv

---@param obj Object
function bhv_minecraft_block_loop(obj)
	
end

--- Called from mce_box.geo

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


------------------------------------------------------------------------------------------

---@param obj Object
---@return Object? item
function obj_get_any_nearest_item(obj)
    local nearest_item = nil
    local nearest_dist = 0xFFFF
    for _, item_behavior in ipairs(gItemBehaviors) do
        local item = obj_get_nearest_object_with_behavior_id(obj, item_behavior)
        local dist = dist_between_objects(item, obj)
        if dist < nearest_dist then
            nearest_item = item
            nearest_dist = dist
        end
    end
    return nearest_item
end

local function on_object_count_chat_commmand()
    local count = 0
    for i = OBJ_LIST_PLAYER, NUM_OBJ_LISTS - 1, 1 do
        local obj = obj_get_first(i)
        while obj do
            count = count + 1
            obj = obj_get_next(obj)
        end
    end
    djui_chat_message_create("Total objects: " .. count .. "/" .. OBJECT_POOL_CAPACITY)
    return true
end

hook_chat_command("objects", "Counts the amount of objects in the current area", on_object_count_chat_commmand)