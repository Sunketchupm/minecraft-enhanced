local Mouse = require("mouse")
local Items = require("item_list")

---@class Hotbar
    ---@field index integer
    ---@field items MenuItemLink[]
    ---@field cooldown integer
    ---@field clear integer

local Hotbar = {
    index = 1,
    items = {},
    cooldown = 0,
    clear = 0,
}

HOTBAR_SIZE = 10
for i = 1, HOTBAR_SIZE do
    Hotbar.items[i] = {} ---@diagnostic disable-line: missing-fields
end

---@param screen_width number
---@param screen_height number
Hotbar.render = function(screen_width, screen_height)
    local width = screen_width * 0.5
    local height = screen_height * 0.08
    local x = screen_width * 0.25
    local y = screen_height - height * 1.8
    local hotbar_rect = into_rect(x, y, width, height)
    djui_hud_set_color(64, 64, 32, 192)
    djui_hud_render_rect(x, y, width, height)
    local slot_width = width * 0.1
    local slot_height = height * 0.95
    local slot_x = x
    local slot_y = y
    local slot_rect = into_rect(slot_x, slot_y, slot_width, slot_height)
    for index, item in ipairs(Hotbar.items) do
        slot_rect.x = x + slot_width * (index - 1)

        if gMenu.open and Mouse.moved and Mouse.is_within(slot_rect) then
            Hotbar.index = index
        end

        if index == Hotbar.index then
            djui_hud_set_color(255, 255, 255, 150)
            if gCurrentItemLink and gCurrentItemLink.held then
                djui_hud_set_color(255, 255, 127, 150)
            end
            djui_hud_render_rect(slot_rect.x, slot_y, slot_width, slot_height)
        end

        if item.icon then
            Items.render(slot_rect, item.icon)
        end

        if index == Hotbar.index and not Mouse.moved then
            if gCurrentItemLink and gCurrentItemLink.held then
                Items.render(slot_rect, gCurrentItemLink.icon)
            end
        end
        djui_hud_set_color(128, 128, 128, 255)
        djui_hud_render_rect(slot_rect.x, y, 3, slot_height)
    end
    render_rectangle_borders(hotbar_rect, {r = 128, g = 128, b = 128, a = 255}, {r = 128, g = 128, b = 128, a = 255}, 0.01, 0.08)
    render_pixel_border(hotbar_rect, {r = 0, g = 0, b = 0, a = 255}, 2)
end

local function on_set_hotbar_item()
    local item = Hotbar.items[Hotbar.index].item
    local params = item.params
    local size = params.size
    if not item or not params or not size then return end
    vec3f_copy(gGridSize, size)
    vec3f_mul(gGridSize, GRID_SIZE_DEFAULT)
    gOutlineGridYOffset = 0
end

---@param m MarioState
Hotbar.inputs = function(m)
    if m.controller.buttonDown & L_TRIG ~= 0 then return end

    if m.controller.buttonPressed & L_JPAD ~= 0 then
        Hotbar.index = Hotbar.index - 1
        if Hotbar.index < 1 then
            Hotbar.index = HOTBAR_SIZE
        end
        local item = Hotbar.items[Hotbar.index]
        if item and item.item then
            on_set_hotbar_item()
        end
    elseif m.controller.buttonPressed & R_JPAD ~= 0 then
        Hotbar.index = Hotbar.index + 1
        if Hotbar.index > HOTBAR_SIZE then
            Hotbar.index = 1
        end
        local item = Hotbar.items[Hotbar.index]
        if item and item.item then
            on_set_hotbar_item()
        end
    end
    m.controller.buttonPressed = m.controller.buttonPressed & ~(L_JPAD | R_JPAD)
end

-- Used by render.lua
Hotbar.handle_reset_inputs = function()
    if not Mouse.moved then return false end

    if Mouse.held.left and Hotbar.cooldown <= 0 then
        Hotbar.clear = Hotbar.clear + 1
        play_sound(SOUND_MENU_COLLECT_SECRET + ((Hotbar.clear // 12) << 16), gGlobalSoundSource)
        return true
    else
        Hotbar.clear = 0
    end
    return false
end

return Hotbar