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