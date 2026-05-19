local Mouse = require("mouse")
local Items = require("item_list")
local Buttons = require("buttons")

---@class Hotbar
    ---@field index integer
    ---@field items MenuItemLink[]
    ---@field cooldown integer
    ---@field clear integer
    ---@field clear_leniency integer

local Hotbar = {
    index = 1,
    items = {},
    cooldown = 0,
    clear = 0,
    clear_leniency = 0
}

HOTBAR_SIZE = 10
for i = 1, HOTBAR_SIZE do
    Hotbar.items[i] = {} ---@diagnostic disable-line: missing-fields
end

---@param screen_width number
---@param screen_height number
local function render_hotbar(screen_width, screen_height)
    local hotbar_width = screen_width * 0.5
    local slot_width = hotbar_width * 0.1
    local slot_height = slot_width
    local hotbar_height = slot_height
    local hotbar_x = screen_width * 0.25
    local hotbar_y = screen_height - hotbar_height * 1.4
    local hotbar_rect = into_rect(hotbar_x, hotbar_y, hotbar_width, hotbar_height)
    djui_hud_set_color(64, 64, 32, 192)
    djui_hud_render_rect(hotbar_x, hotbar_y, hotbar_width, hotbar_height)

    local slot_x = hotbar_x
    local slot_y = hotbar_y
    local slot_rect = into_rect(slot_x, slot_y, slot_width, slot_height)
    for index, item in ipairs(Hotbar.items) do
        slot_rect.x = hotbar_x + slot_width * (index - 1)

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
        djui_hud_render_rect(slot_rect.x, hotbar_y, 3, slot_height)
    end
    render_rectangle_borders(hotbar_rect, {r = 128, g = 128, b = 128, a = 255}, {r = 128, g = 128, b = 128, a = 255}, 0.005)
    render_pixel_border(hotbar_rect, {r = 0, g = 0, b = 0, a = 255}, 2)
end

-------------------------------------------------------------------------

local sPrevResetBarWidth = 0
---@param rect Rectangle
local function render_reset_hotbar(rect)
    local x, y, width, height = from_rect(rect)
    local text_x = x + width * 0.5
    local text_y = y + height * 0.9
    local button_rect = into_rect(text_x, text_y, width, height)
    local button_x, button_y, button_width, button_height =
        from_rect(Buttons.render_menu_button(button_rect, "Remove Item / Reset Hotbar", Y_BUTTON_TEX, Hotbar.handle_reset_mouse_input, false))

    local reset_bar_width = button_width * math.remap(0, 60, 0, 1, Hotbar.clear)
    local reset_bar_height = 10
    local reset_bar_x = button_x
    local reset_bar_y = button_y + button_height
    djui_hud_set_color_with_table(GREEN)
    djui_hud_render_rect_interpolated(reset_bar_x, reset_bar_y, sPrevResetBarWidth, reset_bar_height, reset_bar_x, reset_bar_y, reset_bar_width, reset_bar_height)
    sPrevResetBarWidth = reset_bar_width
end

---@param m MarioState
---@param is_mouse boolean
local function handle_reset_inputs(m, is_mouse)
    if gCurrentItemLink and gCurrentItemLink.held then return end

    if m.controller.buttonPressed & Y_BUTTON ~= 0 or is_mouse then
        Hotbar.items[Hotbar.index] = {}
    end

    if (m.controller.buttonDown & Y_BUTTON ~= 0 or is_mouse) and Hotbar.cooldown <= 0 then
        Hotbar.clear = Hotbar.clear + 1
        Hotbar.clear_leniency = 0
        play_sound(SOUND_MENU_COLLECT_SECRET + ((Hotbar.clear // 12) << 16), gGlobalSoundSource)
    else
        Hotbar.clear_leniency = Hotbar.clear_leniency + 1
        if Hotbar.clear_leniency > 10 then
            Hotbar.clear = 0
            Hotbar.clear_leniency = 0
        end
    end

    if Hotbar.clear >= 60 then
        for i = 1, HOTBAR_SIZE, 1 do
            Hotbar.items[i] = {}
        end
        play_sound(SOUND_MENU_LET_GO_MARIO_FACE, gGlobalSoundSource)
        Hotbar.clear = 0
        Hotbar.cooldown = 39
        Hotbar.clear_leniency = 0
    end
    if Hotbar.cooldown > 0 then
        Hotbar.cooldown = Hotbar.cooldown - 1
    end
end

-- Used by render.lua
Hotbar.handle_reset_mouse_input = function()
    if not Mouse.moved then return false end
    return handle_reset_inputs(gMarioStates[0], Mouse.held.left)
end

-------------------------------------------------------------------------

---@param screen_width number
---@param screen_height number
Hotbar.render = function (screen_width, screen_height)
    render_hotbar(screen_width, screen_height)
end

---@param rect Rectangle
Hotbar.render_reset = function (rect)
    render_reset_hotbar(rect)
end

---@param m MarioState
Hotbar.inputs = function(m)
    if m.controller.buttonDown & L_TRIG ~= 0 then return end

    if m.controller.buttonPressed & L_JPAD ~= 0 then
        Hotbar.index = Hotbar.index - 1
        if Hotbar.index < 1 then
            Hotbar.index = HOTBAR_SIZE
        end
    elseif m.controller.buttonPressed & R_JPAD ~= 0 then
        Hotbar.index = Hotbar.index + 1
        if Hotbar.index > HOTBAR_SIZE then
            Hotbar.index = 1
        end
    end
    m.controller.buttonPressed = m.controller.buttonPressed & ~(L_JPAD | R_JPAD)

    if gMenu.open then
        handle_reset_inputs(m, false)
    end
end

return Hotbar