local CommonMenu = require("../common_menu")
local Utils = require("../utils")
local Mouse = require("../mouse")

local Menu = require("class")
local Surfaces = require("surfaces")

local Settings = {}

local function __mouse_input(rect, index)
    if Mouse.moved and Mouse.is_within(rect) then
        Menu.settings.index = index
        audio_sample_play(SOUND_MCE_MOVE, gGlobalSoundSource, 1)
    end
end

---@param rect Rectangle
---@param button CreativeMenuOption
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
        if Menu.settings.doing_inputs then
            color.normal = Utils.adjust_color(color.normal, { r = 0, g = 0, b = 0, a = -200 })
            color.shine = Utils.adjust_color(color.shine, { r = 0, g = 0, b = 0, a = -200 })
            color.shade = Utils.adjust_color(color.shade, { r = 0, g = 0, b = 0, a = -200 })
        end
        Utils.render_bordered_rectangle(option_rect, color, 0.008, false)

        color = index == Menu.settings.index and YELLOW or BLACK
        if Menu.settings.doing_inputs then
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
        if Menu.settings.doing_inputs then
            color = Utils.adjust_color(color, { r = 0, g = 0, b = 0, a = -200 })
        end
        Utils.set_color_with_table(color)
        Utils.render_rect_from_rect(checkbox_rect)

        color = index == Menu.settings.index and YELLOW or BLACK
        if Menu.settings.doing_inputs then
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
        if Menu.settings.doing_inputs then
            color = Utils.adjust_color(color, { r = 0, g = 0, b = 0, a = -200 })
        end
        Utils.set_color_with_table(BLUE)
        Utils.render_rect_from_rect(bar)

        local text_y = option_rect.y + option_rect.height * 0.5 - 16
        local formatted_name = button.name:format(val and val.val or 0)

        color = index == Menu.settings.index and YELLOW or WHITE
        if Menu.settings.doing_inputs then
            color = Utils.adjust_color(color, { r = 0, g = 0, b = 0, a = -200 })
        end
        Utils.set_color_with_table(color)
        Utils.render_centered_text(formatted_name, option_rect.x, option_rect.width, text_y, 1)

        button.rect = option_rect
        y = y + height + padding
    elseif button.type == SETTINGS_OPTION_TYPE_ONLY_TEXT then
        local color = index == Menu.settings.index and YELLOW or BLACK
        if Menu.settings.doing_inputs then
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

        color = index == Menu.settings.index and YELLOW or BLACK
        Utils.set_color_with_table(color)
        Utils.render_centered_text(button.name, x, width, y, 1)

        Surfaces.render_description_box(rect, Menu.settings.index)

        button.rect = surface_rect
        y = y + height + padding
    end
    return y
end

---@param buttons CreativeMenuTab
---@param options_count integer
local function __calibrate_scroll(rect, buttons, options_count)
    local heights = {}
    for i = 1, options_count, 1 do
        local button = buttons[i] --[[@as CreativeMenuOption]]
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

---@param rect Rectangle
---@param tab CreativeMenuTab
function Settings.render(rect, tab)
    if Menu[Menu.tab].type ~= TAB_TYPE_SETTINGS then
        return
    end

    djui_hud_set_color(63, 63, 63, 255)
    local header_scale = 0.75
    local text_y = rect.y + rect.height * 0.12
    Utils.render_centered_text("This tab only affects the currently held item", rect.x, rect.width, text_y, header_scale)

    local last_height = rect.y + rect.height * 0.18
    if tab.scroll.max == -1 then
        tab.scroll.max = __calibrate_scroll(rect, tab, #tab)
    end

    if Mouse.moved then
        Menu.settings.index = -1
    end

    for i = tab.scroll.index, #tab, 1 do
        local button = tab[i] --[[@as CreativeMenuOption]]
        if button then
            last_height = render_option(rect, button, last_height, i)
            if last_height > rect.y + rect.height * 0.9 then
                Menu.settings.rendered_max_index = i
                break
            end
        end
        Menu.settings.rendered_max_index = i
    end
end

------------------------------------------------

local __select_option = function (change, scroll)
    if Menu.settings.index ~= -1 then
        Menu.settings.index = Menu.settings.index + change
        if Menu.settings.index < scroll.index then
            scroll.index = Menu.settings.index
        elseif Menu.settings.index > Menu.settings.rendered_max_index then
            scroll.index = scroll.index + change
        end
    else
        Menu.settings.index = scroll.index
    end
    Menu.settings.index = math.clamp(Menu.settings.index, scroll.index, Menu.settings.rendered_max_index)
    audio_sample_play(SOUND_MCE_MOVE, gGlobalSoundSource, 1)
end

---@param m MarioState
---@param inputs Inputs
function Settings.inputs(m, inputs)
    CommonMenu.menu_inputs(m, inputs, Menu, Menu.tab, {
        tab = function (index)
            Menu.tab = index
            Menu.settings.index = 1
            Menu.settings.rendered_max_index = 1
        end,
        scroll = function (direction)
            if direction.up then
                Menu.settings.index = Menu.settings.index - 1
            elseif direction.down then
                Menu.settings.index = Menu.settings.index + 1
            end
            Menu.settings.index = math.clamp(Menu.settings.index, 1, Menu.settings.rendered_max_index)
        end,
    })
    if Menu[Menu.tab].type ~= TAB_TYPE_SETTINGS then
        return
    end

    local current_options = Menu[Menu.tab]
    local current_option = current_options[Menu.settings.index]

    if inputs.stick.up and Menu.settings.index > 1 then
        __select_option(-1, current_options.scroll)
    elseif inputs.stick.down and Menu.settings.index < #current_options then
        __select_option(1, current_options.scroll)
    end

    if current_option then
        if Mouse.moved and Mouse.down and Mouse.pressed.left then
            inputs.buttons.pressed = inputs.buttons.pressed | A_BUTTON
        end
        current_option.action(inputs)
    end

    Menu.settings.doing_inputs = true
    if Menu.tab == CREATIVE_TAB_BLOCK_SURFACES or
    (not Mouse.moved and inputs.buttons.down & ~(C_BUTTONS | L_TRIG | R_TRIG) == 0) or
    (Mouse.moved and not (Mouse.down.left or Mouse.down.middle)) then
        Menu.settings.doing_inputs = false
    end
end

return Settings