local CommonMenu = require("../common_menu")
local Utils = require("../utils")
local Mouse = require("../mouse")

local Settings = require("class") --[[@as SettingsMenu]]
local Surfaces = require("surfaces")

local function __mouse_input(rect, index)
    if Mouse.moved and Mouse.is_within(rect) then
        Settings.option_index = index
        audio_sample_play(SOUND_MCE_MOVE, gGlobalSoundSource, 1)
    end
end

---@param rect Rectangle
---@param button SettingsMenuOption
---@param last_height number
---@param index integer
local function render_option(rect, button, last_height, index)
    local x = rect.x + rect.width * 0.05
    local y = last_height
    local padding = 10
    if button.type == SETTINGS_OPTION_TYPE_BUTTON then
        local width = rect.width * 0.75
        local height = rect.height * 0.08
        local option_rect = Utils.into_rect(x, y, width, height)
        __mouse_input(option_rect, index)

        local color = table.deepcopy(MAIN_RECT_COLORS)
        if Settings.doing_inputs then
            color.normal = Utils.adjust_color(color.normal, { r = 0, g = 0, b = 0, a = -200 })
            color.shine = Utils.adjust_color(color.shine, { r = 0, g = 0, b = 0, a = -200 })
            color.shade = Utils.adjust_color(color.shade, { r = 0, g = 0, b = 0, a = -200 })
        end
        Utils.render_bordered_rectangle(option_rect, color, 0.008, false)

        color = index == Settings.option_index and YELLOW or BLACK
        if Settings.doing_inputs then
            color = Utils.adjust_color(color, { r = 0, g = 0, b = 0, a = -200 })
        end
        Utils.set_color_with_table(color)
        Utils.render_centered_text(button.name, x, width, y, 1)

        button.rect = rect
        y = y + height + padding
    elseif button.type == SETTINGS_OPTION_TYPE_CHECKBOX then
        local width = rect.width * 0.03
        local height = width
        local checkbox_rect = Utils.into_rect(x, y, width, height)
        __mouse_input(checkbox_rect, index)

        local color = RED
        local val = button.update()
        if val then
            color = GREEN
        end
        if Settings.doing_inputs then
            color = Utils.adjust_color(color, { r = 0, g = 0, b = 0, a = -200 })
        end
        Utils.set_color_with_table(color)
        Utils.render_rect_from_rect(checkbox_rect)

        color = index == Settings.option_index and YELLOW or BLACK
        if Settings.doing_inputs then
            color = Utils.adjust_color(color, { r = 0, g = 0, b = 0, a = -200 })
        end
        Utils.set_color_with_table(color)
        djui_hud_print_text(button.name, x + width + padding, y - 2.5, 1)

        button.rect = checkbox_rect
        y = y + 32 + padding
    elseif button.type == SETTINGS_OPTION_TYPE_SLIDER then
        local width = rect.width * 0.75
        local height = rect.height * 0.08
        local option_rect = Utils.into_rect(x, y, width, height)
        __mouse_input(option_rect, index)

        djui_hud_set_color(0, 0, 0, 127)
        djui_hud_render_rect(x, y, width, height)
        Utils.render_pixel_border(option_rect, BLACK, 1)

        local bar = {
            x = option_rect.x,
            y = y,
            width = option_rect.width * 0.03,
            height = option_rect.height
        }
        local val = button.update()
        if val then
            bar.x = option_rect.x
                + option_rect.width * (math.invlerp(val.min, val.max, val.val))
                - bar.width * 0.5
        end
        local color = BLUE
        if Settings.doing_inputs then
            color = Utils.adjust_color(color, { r = 0, g = 0, b = 0, a = -200 })
        end
        Utils.set_color_with_table(BLUE)
        Utils.render_rect_from_rect(bar)

        local text_y = option_rect.y + option_rect.height * 0.5 - 16
        local formatted_name = button.name:format(val.val or 0)

        color = index == Settings.option_index and YELLOW or WHITE
        if Settings.doing_inputs then
            color = Utils.adjust_color(color, { r = 0, g = 0, b = 0, a = -200 })
        end
        Utils.set_color_with_table(color)
        Utils.render_centered_text(formatted_name, option_rect.x, option_rect.width, text_y, 1)

        button.rect = option_rect
        y = y + height + padding
    elseif button.type == SETTINGS_OPTION_TYPE_ONLY_TEXT then
        local color = index == Settings.option_index and YELLOW or BLACK
        if Settings.doing_inputs then
            color = Utils.adjust_color(color, { r = 0, g = 0, b = 0, a = -200 })
        end
        Utils.set_color_with_table(color)
        djui_hud_print_text(button.name, x, y, 1)

        y = y + 32 + padding
    elseif button.type == SETTINGS_OPTION_TYPE_SURFACE_BUTTON then
        local width = rect.width * 0.3
        local height = rect.height * 0.08
        local surface_rect = Utils.into_rect(x, y, width, height)
        __mouse_input(surface_rect, index)

        Utils.render_bordered_rectangle(surface_rect, MAIN_RECT_COLORS, 0.015, false)

        color = index == Settings.option_index and YELLOW or BLACK
        Utils.set_color_with_table(color)
        Utils.render_centered_text(button.name, x, width, y, 1)

        Surfaces.render_description_box(rect, Settings.option_index)

        button.rect = surface_rect
        y = y + height + padding
    end
    return y
end

---@param buttons SettingsMenuTab
---@param options_count integer
local function __calibrate_scroll(rect, buttons, options_count)
    local heights = {}
    for i = 1, options_count, 1 do
        local button = buttons[i]
        if button then
            heights[i] = render_option(rect, button, 0, i)
        end
    end
    local highest_y = 0
    for _, height in ipairs(heights) do
        highest_y = highest_y + height
    end
    local cull_height = rect.height * 0.9
    if highest_y - (rect.y + cull_height) < 0 then
        return 0
    end

    local last_index = 1
    local sum = 0
    for i = #heights, 1, -1 do
        sum = sum + heights[i]
        if sum > cull_height then
            last_index = i
            break
        end
    end
    return last_index + 2
end

---@param screen_width number
---@param screen_height number
local function render(screen_width, screen_height)
    djui_hud_set_font(FONT_SPECIAL)

    local color = table.deepcopy(MAIN_RECT_COLORS)
    if Settings.doing_inputs then
        color.normal = Utils.adjust_color(color.normal, { r = 0, g = 0, b = 0, a = -200 })
        color.shine = Utils.adjust_color(color.shine, { r = 0, g = 0, b = 0, a = -200 })
        color.shade = Utils.adjust_color(color.shade, { r = 0, g = 0, b = 0, a = -200 })
    end
    local rect = CommonMenu.render_main_rectangle(screen_width, screen_height, Settings, Settings.tab, color)

    local last_height = rect.y + rect.height * 0.15
    local options_count = #Settings[Settings.tab]
    local buttons = Settings[Settings.tab]
    if buttons.scroll.max == -1 then
        buttons.scroll.max = __calibrate_scroll(rect, buttons, options_count)
    end

    if Mouse.moved then
        Settings.option_index = -1
    end

    for i = buttons.scroll.index, options_count, 1 do
        local button = buttons[i]
        if button then
            last_height = render_option(rect, button, last_height, i)
            if last_height > rect.y + rect.height * 0.9 then
                Settings.rendered_max_index = i
                break
            end
        end
        Settings.rendered_max_index = i
    end
end

return render