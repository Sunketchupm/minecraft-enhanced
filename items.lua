---@class Item
    ---@field behavior BehaviorId
    ---@field params table

gCurrentItem = {}
local first_update = true
hook_event(HOOK_UPDATE, function ()
    if not first_update then return end
    first_update = false
    gCurrentItem = {behavior = bhvMinecraftBox, params = {color = {r = 255, g = 0, b = 0, a = 255}}}
end)