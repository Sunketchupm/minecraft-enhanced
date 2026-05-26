local Utils = require("../utils")
local Mouse = require("../mouse")

local Items = require("../creative/list")
local CreativeMenu = require("../creative/class")

local Hotbar = require("class") --[[@as Hotbar]]

---@param screen_width number
---@param screen_height number
local function render(screen_width, screen_height)
    local hotbar_width = screen_width * 0.5
    local slot_width = hotbar_width * 0.1
    local slot_height = slot_width
    local hotbar_height = slot_height
    local hotbar_x = screen_width * 0.25
    local hotbar_y = screen_height - hotbar_height * 1.4
    local hotbar_rect = Utils.into_rect(hotbar_x, hotbar_y, hotbar_width, hotbar_height)
    djui_hud_set_color(64, 64, 32, 192)
    Utils.render_rect_from_rect(hotbar_rect)

    local slot_x = hotbar_x
    local slot_y = hotbar_y
    local slot_rect = Utils.into_rect(slot_x, slot_y, slot_width, slot_height)
    for index, slot in ipairs(Hotbar) do
        slot_rect.x = hotbar_x + slot_width * (index - 1)
        Hotbar[index].rect = table.copy(slot_rect)

        if gCurrentMenu == MENU_TYPE_CREATIVE and Mouse.moved and Mouse.is_within(slot_rect) then
            Hotbar.index = index
        end

        if index == Hotbar.index then
            djui_hud_set_color(255, 255, 255, 150)
            if CreativeMenu.grid.item.link and CreativeMenu.grid.item.link.held then
                djui_hud_set_color(255, 255, 127, 150)
            end
            djui_hud_render_rect(slot_rect.x, slot_y, slot_width, slot_height)
        end

        if slot.link and slot.link.icon then
            Items.render_on_rect(slot_rect, slot.link.icon )
        end

        if index == Hotbar.index and not Mouse.moved then
            if CreativeMenu.grid.item.link and CreativeMenu.grid.item.link.held then
                Items.render_on_rect(slot_rect, CreativeMenu.grid.item.link.icon)
            end
        end
        djui_hud_set_color(128, 128, 128, 255)
        djui_hud_render_rect(slot_rect.x, hotbar_y, 3, slot_height)
    end
    local border_colors = {
        normal = WHITE,
        shine = { r = 128, g = 128, b = 128, a = 255 },
        shade = { r = 128, g = 128, b = 128, a = 255 }
    }
    Utils.render_rectangle_borders(hotbar_rect, border_colors, 0.005)
    Utils.render_pixel_border(hotbar_rect, {r = 0, g = 0, b = 0, a = 255}, 2)
end

return render