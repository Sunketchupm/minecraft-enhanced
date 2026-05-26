---@class Hotbar
    ---@field index integer
    ---@field cooldown integer
    ---@field clear integer
    ---@field clear_leniency integer
    ---@field [integer] HotbarSlot

---@class HotbarSlot
    ---@field link CreativeMenuItemLink?
    ---@field rect Rectangle

---@type Hotbar
local Hotbar = {
    index = 1,
    cooldown = 0,
    clear = 0,
    clear_leniency = 0,
}

HOTBAR_SIZE = 10
for i = 1, HOTBAR_SIZE do
    Hotbar[i] = { link = nil, rect = { x = 0, y = 0, width = 0, height = 0 } }
end

return Hotbar