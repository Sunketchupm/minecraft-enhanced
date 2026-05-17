require("class")
local Mouse = require("../mouse")

local PAUSE_MENU_COLORS = {
    { r = 160, g = 160, b = 160, a = 255 }, -- Normal
    { r = 215, g = 215, b = 215, a = 255 }, -- Shine
    { r = 50, g = 48, b = 48, a = 255 } -- Shade
}

---@param color DjuiColor
---@param key string
---@param amount integer
local function adjust_color(color, key, amount)
    color[1][key] = color[1][key] + amount
    color[2][key] = color[2][key] + amount
    color[3][key] = color[3][key] + amount
end

---@param screen_width number
---@param screen_height number
---@param h_index integer
---@param v_index integer
---@param columns integer
local function get_pause_button_dimensions(screen_width, screen_height, h_index, v_index, columns)
    local unchanged_width = screen_width * 0.3
    local width = unchanged_width / columns
    local height = screen_height * 0.05
    local x_padding = 6
    local y_padding = 10
    local x = screen_width * 0.5 - unchanged_width * 0.5 + (width * (h_index - 1) + (x_padding * 2))
    local y = screen_height * 0.3 + ((height + y_padding) * (v_index - 1))
    if columns > 1 then
        width = width - x_padding
    end
    return into_rect(x, y, width, height)
end

---@param rect Rectangle
---@param name string
---@param h_index integer
---@param v_index integer
local function render_pause_menu_button(rect, name, h_index, v_index)
    local color = table.deepcopy(PAUSE_MENU_COLORS)
    if gPauseMenu.h_index == h_index and gPauseMenu.v_index == v_index then
        adjust_color(color, "b", 40)
    end
    local button = gPauseMenu[gPauseMenu.current_menu][h_index][v_index]
    if button then
        if button.enabled and button.enabled() then
            adjust_color(color, "g", 40)
        elseif button.is_selected then
            adjust_color(color, "r", 40)
            adjust_color(color, "g", 40)
            adjust_color(color, "b", -40)
        end
    end

    render_bordered_rectangle(rect, color, 0.01, false)
    djui_hud_set_font(FONT_NORMAL)

    local text_scale = 1
    local text_size = djui_hud_measure_text(name) * text_scale
    local text_x = rect.x + rect.width * 0.5 - text_size * 0.5
    local text_y = rect.y + rect.height * 0.5 - 16 * text_scale
    render_shadowed_text(name, text_x, text_y, text_scale)
end

------------------------------------------------------------------------

---@param screen_width number
---@param screen_height number
local function hud_render(screen_width, screen_height)
    djui_hud_set_color(0, 0, 0, 100)
    djui_hud_render_rect(0, 0, screen_width, screen_height)

    render_centered_colored_text("\\#31db02\\Minecraft \\#1dcff2\\Enhanced", 0, screen_width, screen_height * 0.1, 3)

    local buttons = gPauseMenu[gPauseMenu.current_menu]
    if buttons then
        for h_index, group in ipairs(buttons) do
            ---@param button PauseMenuButton
            for v_index, button in ipairs(group) do
                local name = button.name
                if button.name_args then
                    name = name:format(button.name_args())
                end

                local columns = #buttons
                local dimensions = get_pause_button_dimensions(screen_width, screen_height, h_index, v_index, columns)
                if Mouse.moved and Mouse.is_within(dimensions) then
                    gPauseMenu.h_index = h_index
                    gPauseMenu.v_index = v_index
                end
                render_pause_menu_button(dimensions, name, h_index, v_index)

                if gPauseMenu.current_menu == PAUSE_MENU_HELP then
                    local x, y = from_rect(dimensions)
                    y = y + 100
                    djui_hud_set_color(255, 255, 255, 255)
                    djui_hud_set_font(FONT_NORMAL)
                    djui_hud_print_text("There is nothing here yet", x, y, 1)
                end
            end
        end
    end

    Mouse.render()
end

return hud_render