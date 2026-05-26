local Utils = require("../utils")
local Mouse = require("../mouse")

local Pause = require("class") --[[@as PauseMenu]]

local PAUSE_MENU_COLORS = {
    normal = { r = 160, g = 160, b = 160, a = 255 },
    shine = { r = 215, g = 215, b = 215, a = 255 },
    shade = { r = 50, g = 48, b = 48, a = 255 }
}

---@param color BorderedColors
---@param key string
---@param amount integer
local function adjust_color(color, key, amount)
    color.normal[key] = color.normal[key] + amount
    color.shine[key] = color.shine[key] + amount
    color.shade[key] = color.shade[key] + amount
end

---@param screen_width number
---@param screen_height number
---@param index integer
local function get_pause_button_dimensions(screen_width, screen_height, index)
    local width = screen_width * 0.3
    local height = screen_height * 0.05
    local x = screen_width * 0.5 - width * 0.5
    local y_padding = 10
    local y = screen_height * 0.3 + ((height + y_padding) * (index - 1))
    return Utils.into_rect(x, y, width, height)
end

---@param rect Rectangle
---@param name string
---@param index integer
local function render_pause_menu_button(rect, name, index)
    local color = table.deepcopy(PAUSE_MENU_COLORS)
    local text_color = WHITE
    if Pause.index == index then
        color = table.deepcopy(SELECTED_BUTTON_COLORS)
        text_color = YELLOW
    end
    local button = Pause[Pause.current_menu][index]
    if button.enabled and button.enabled() then
        adjust_color(color, "g", 40)
    elseif button.is_selected then
        adjust_color(color, "r", 40)
        adjust_color(color, "g", 40)
        adjust_color(color, "b", -40)
    end

    Utils.render_bordered_rectangle(rect, color, 0.01, false)
    djui_hud_set_font(FONT_NORMAL)

    local text_scale = 1
    local text_size = djui_hud_measure_text(name) * text_scale
    local text_x = rect.x + rect.width * 0.5 - text_size * 0.5
    local text_y = rect.y + rect.height * 0.5 - 16 * text_scale
    Utils.render_shadowed_text(name, text_x, text_y, text_scale, text_color)
end

------------------------------------------------------------------------

---@param screen_width number
---@param screen_height number
local function render(screen_width, screen_height)
    djui_hud_set_color(0, 0, 0, 100)
    djui_hud_render_rect(0, 0, screen_width, screen_height)

    Utils.render_centered_colored_text("\\#31db02\\Minecraft \\#1dcff2\\Enhanced", 0, screen_width, screen_height * 0.1, 3)

    local buttons = Pause[Pause.current_menu]
    ---@param button PauseMenuButton
    for index, button in ipairs(buttons) do
        local name = button.name
        if button.name_args then
            name = name:format(button.name_args())
        end

        local dimensions = get_pause_button_dimensions(screen_width, screen_height, index)
        if Mouse.moved and Mouse.is_within(dimensions) and not Pause.selection_active then
            Pause.index = index
        end
        render_pause_menu_button(dimensions, name, index)

        if Pause.current_menu == PAUSE_MENU_HELP then
            local x, y = Utils.from_rect(dimensions)
            y = y + 100
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_set_font(FONT_NORMAL)
            djui_hud_print_text("There is nothing here yet", x, y, 1)
        end
    end
end

return render