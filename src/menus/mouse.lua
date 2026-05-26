local Mouse = {
    moved = false,
    prev = { x = 0, y = 0 },
    pos = { x = 0, y = 0 },
    pressed = { left = false, right = false, middle = false },
    down = { left = false, right = false, middle = false },
    released = { left = false, right = false, middle = false },
    scroll = {
        x = 0,
        y = 0
    },
}

local MOUSE_TEX = get_texture_info("mousecursor")

Mouse.has_moved = function()
    return djui_hud_get_mouse_buttons_pressed() ~= 0 or
    djui_hud_get_mouse_buttons_down() ~= 0 or
    djui_hud_get_mouse_buttons_released() ~= 0 or
    djui_hud_get_mouse_scroll_x() ~= 0 or djui_hud_get_mouse_scroll_y() ~= 0 or
    djui_hud_get_raw_mouse_x() > 0 or djui_hud_get_raw_mouse_y() > 0
end

Mouse.get_inputs = function()
    if Mouse.has_moved() then
        Mouse.moved = true
    end

    Mouse.scroll.x = djui_hud_get_mouse_scroll_x() * (GlobalSettings.invert_mouse_scroll and -1 or 1)
    Mouse.scroll.y = djui_hud_get_mouse_scroll_y() * (GlobalSettings.invert_mouse_scroll and -1 or 1)
    Mouse.pressed.left = djui_hud_get_mouse_buttons_pressed() & 1 ~= 0
    Mouse.pressed.middle = djui_hud_get_mouse_buttons_pressed() & 2 ~= 0
    Mouse.pressed.right = djui_hud_get_mouse_buttons_pressed() & 4 ~= 0
    Mouse.down.left = djui_hud_get_mouse_buttons_down() & 1 ~= 0
    Mouse.down.middle = djui_hud_get_mouse_buttons_down() & 2 ~= 0
    Mouse.down.right = djui_hud_get_mouse_buttons_down() & 4 ~= 0
    Mouse.released.left = djui_hud_get_mouse_buttons_released() & 1 ~= 0
    Mouse.released.middle = djui_hud_get_mouse_buttons_released() & 2 ~= 0
    Mouse.released.right = djui_hud_get_mouse_buttons_released() & 4 ~= 0

    Mouse.prev.x = Mouse.pos.x
    Mouse.prev.y = Mouse.pos.y
    Mouse.pos.x = djui_hud_get_mouse_x()
    Mouse.pos.y = djui_hud_get_mouse_y()
end

Mouse.render = function()
    if not Mouse.moved then return end

    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_render_texture_interpolated(MOUSE_TEX,
        Mouse.prev.x - MOUSE_TEX.width * 0.5, Mouse.prev.y- MOUSE_TEX.height * 0.5, 1, 1,
        Mouse.pos.x - MOUSE_TEX.width * 0.5, Mouse.pos.y - MOUSE_TEX.height * 0.5, 1, 1)
end

---@param rect Rectangle
---@return boolean
Mouse.is_within = function(rect)
    local end_x = rect.x + rect.width
    local end_y = rect.y + rect.height
    return Mouse.pos.x > rect.x and Mouse.pos.y > rect.y and Mouse.pos.x < end_x and Mouse.pos.y < end_y
end

------------------------------------------------------

--[[
-- Used by render.lua
Mouse.handle_open_settings_inputs = function()
    --gCurrentTab = TAB_TO_SETTINGS[gCurrentTab] or gCurrentTab
    --on_change_tab_input()

    -- TEMPORARY
    if not Mouse.pressed.left then return false end
    gMenu.settings.transparent = not gMenu.settings.transparent
    if gMenu.settings.transparent then
        djui_chat_message_create("Transparency active. ONLY WORKS FOR BLOCKS.")
    else
        djui_chat_message_create("Transparency disabled.")
    end
    return true
end
]]

return Mouse