---@class Item
    ---@field behavior BehaviorId
    ---@field params table

---@type Item
gCurrentItem = {behavior = nil, params = {}}
---@type BehaviorId[]
gItemBehaviors = {}
add_first_update(function ()
    gCurrentItem = {behavior = bhvMinecraftBox, params = {color = {r = 255, g = 0, b = 0, a = 255}}}
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