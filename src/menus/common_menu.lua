local Utils = require("utils")
local Mouse = require("mouse")

---@class Icon
    ---@field texture TextureInfo?
    ---@field color DjuiColor

---@class MenuTab
    ---@field icon Icon
    ---@field name string
    ---@field scroll MenuScroll

---@class MenuScroll
    ---@field index integer
    ---@field max integer

---@class MenuSideEffect
    ---@field tab fun(tab_index: integer)
    ---@field scroll fun(direction: { up: boolean?, left: boolean?, down: boolean?, right: boolean?, clicked: boolean? }, scroll_index: integer)

local CommonMenu = {}

local sMouseClickedTabIndex = -1
local sMouseClickedScroll = -1

---@param rect Rectangle
---@param name string
local function render_tab_header(rect, name)
    djui_hud_set_color(63, 63, 63, 255)
    local header_scale = 1.5
    local text_y = rect.y + rect.height * 0.04
    Utils.render_centered_text(name, rect.x, rect.width, text_y, header_scale)
end

---@param rect Rectangle
---@param index integer
---@param icon Icon
---@param current_tab integer
local function render_menu_tab(rect, index, icon, current_tab)
    local colors = {
        normal = { r = 125, g = 125, b = 125, a = 255 },
        shine = { r = 175, g = 175, b = 175, a = 255 },
        shade = { r = 75, g = 75, b = 75, a = 255 }
    }
    if index == current_tab then
        colors = MAIN_RECT_COLORS
    end

    local tab_width = rect.width * 0.1
    local tab_height = rect.height * 0.1
    local tab_x = rect.x + (tab_width * (index - 1))
    local tab_y = rect.y - (tab_height - (tab_height * 0.1))
    local tab_rect = Utils.into_rect(tab_x, tab_y, tab_width, tab_height)
    Utils.render_bordered_rectangle(tab_rect, colors, 0.1, false)

    if icon then
        Utils.set_color_with_table(icon.color)
        local texture_scale = 1
        local texture_x = tab_x + tab_width * 0.5 - icon.texture.width * 0.5 * texture_scale
        local texture_y = tab_y + tab_height * 0.5 - icon.texture.height * 0.5 * texture_scale
        djui_hud_render_texture(icon.texture, texture_x, texture_y, texture_scale, texture_scale)
    end

    if Mouse.moved and Mouse.is_within(tab_rect) and Mouse.pressed.left then
        sMouseClickedTabIndex = index
    end
end

---@param rect Rectangle
---@param scroll MenuScroll
local function render_scroll_bar(rect, scroll)
    local scroll_shadow = {
        x = rect.x + rect.width * 0.9,
        y = rect.y + rect.height * 0.15,
        width = rect.width * 0.04,
        height = rect.height * 0.7
    }

    djui_hud_set_color(0, 0, 0, 80)
    Utils.render_rect_from_rect(scroll_shadow)

    local scroll_slider = {
        x = scroll_shadow.x - scroll_shadow.width * 0.15,
        y = scroll_shadow.y - scroll_shadow.height * 0.02,
        width = scroll_shadow.width * 1.3,
        height = scroll_shadow.height * 0.1
    }

    local min_y = scroll_slider.y
    local max_y = min_y + scroll_shadow.height - scroll_slider.height * 0.6
    if scroll.max - 1 > 0 then
        scroll_slider.y = math.lerp(min_y, max_y, (scroll.index - 1) / (scroll.max - 1))
    end

    djui_hud_set_color(255, 255, 255, 255)
    Utils.render_rect_from_rect(scroll_slider)

    if Mouse.moved and Mouse.is_within(scroll_shadow) and Mouse.down.left then
        local segments = scroll_shadow.height / scroll.max
        local mouse_y = scroll_shadow.y + scroll_shadow.height - Mouse.pos.y
        local scroll_to_index = (mouse_y // segments)
        sMouseClickedScroll = scroll_to_index
    end
end

---@param screen_width number
---@param screen_height number
---@param tabs MenuTab[]
---@param current_tab integer
---@param color BorderedColors?
---@return Rectangle
function CommonMenu.render_main_rectangle(screen_width, screen_height, tabs, current_tab, color)
    local main_rect = {
        x = screen_width * 0.25,
        y = screen_height * 0.2,
        width = screen_width * 0.5,
        height = screen_height * 0.6,
    }
    for i, tab in ipairs(tabs) do
        render_menu_tab(main_rect, i, tab.icon, current_tab)
    end
    Utils.render_bordered_rectangle(main_rect, color or MAIN_RECT_COLORS, 0.01, false)
    render_tab_header(main_rect, tabs[current_tab].name)
    render_scroll_bar(main_rect, tabs[current_tab].scroll)
    return main_rect
end

---@param m MarioState
---@param inputs Inputs
---@param tabs MenuTab[]
---@param current_tab integer
---@param side_effect MenuSideEffect
function CommonMenu.menu_inputs(m, inputs, tabs, current_tab, side_effect)
    if inputs.buttons.pressed & (X_BUTTON | START_BUTTON) ~= 0 or (Mouse.moved and Mouse.pressed.right) then
        gCurrentMenu = MENU_TYPE_CLOSED
        m.controller.buttonPressed = m.controller.buttonPressed & ~(X_BUTTON | START_BUTTON)
        return
    end

    local scroll = tabs[current_tab].scroll

    if sMouseClickedTabIndex ~= -1 then
        side_effect.tab(sMouseClickedTabIndex)
        sMouseClickedTabIndex = -1
    elseif inputs.buttons.pressed & L_TRIG ~= 0 and current_tab > 1 then
        side_effect.tab(current_tab - 1)
    elseif inputs.buttons.pressed & R_TRIG ~= 0 and current_tab < #tabs then
        side_effect.tab(current_tab + 1)
    end

    if scroll.max > 1 then
        if sMouseClickedScroll ~= -1 then
            scroll.index = scroll.max - sMouseClickedScroll
            side_effect.scroll({ clicked = true }, scroll.index)
            sMouseClickedScroll = -1
        elseif inputs.c_buttons.up or Mouse.scroll.y > 0 then
            scroll.index = scroll.index - 1
            side_effect.scroll({ up = true }, scroll.index)
        elseif inputs.c_buttons.down or Mouse.scroll.y < 0 then
            scroll.index = scroll.index + 1
            side_effect.scroll({ down = true }, scroll.index)
        elseif inputs.c_buttons.left then
            side_effect.scroll({ left = true }, scroll.index)
        elseif inputs.c_buttons.right then
            side_effect.scroll({ right = true }, scroll.index)
        end
        scroll.index = math.clamp(scroll.index, 1, scroll.max)
    end
end

----------------------------------------------------------------

--[[
---@class MenuButton
    ---@field rect Rectangle
    ---@field colors { unselected: BorderedColors, selected: BorderedColors }
    ---@field flags integer
    ---@field links { up: integer?, left: integer?, down: integer?, right: integer? }
    ---@field action fun(m: MarioState, inputs: Inputs)
    ---@field update fun(rect: Rectangle)

BUTTON_FLAG_NOT_BORDERED = 1

local sMouseHoveredButton = nil

---@param rect Rectangle
---@param colors { unselected: BorderedColors, selected: BorderedColors }
---@param flags integer
---@param action fun(m: MarioState, inputs: Inputs)
---@param update fun(rect: Rectangle)
---@param link_up integer
---@param link_left integer
---@param link_down integer
---@param link_right integer
---@return MenuButton
function CommonMenu.make_button(rect, colors, flags, action, update, link_up, link_left, link_down, link_right)
    ---@type MenuButton
    return {
        rect = rect,
        colors = colors,
        flags = flags,
        action = action,
        update = update,
        links = {
            up = link_up,
            left = link_left,
            down = link_down,
            right = link_right
        },
    }
end

---@param rect Rectangle
---@param buttons MenuButton[]
---@param current MenuButton
function CommonMenu.render_buttons(rect, buttons, current)
    sMouseHoveredButton = nil
    for _, button in ipairs(buttons) do
        local absolute_button_rect = {
            x = rect.x + rect.width * button.rect.x,
            y = rect.y + rect.height * button.rect.y,
            width = rect.width * button.rect.width,
            height = rect.height * button.rect.height
        }
        if not sMouseHoveredButton and Mouse.moved and Mouse.is_within(absolute_button_rect) then
            sMouseHoveredButton = button
        end
        local colors = button.colors.unselected
        if current == button then
            colors = button.colors.selected
        end
        if button.flags & BUTTON_FLAG_NOT_BORDERED == 0 then
            Utils.render_bordered_rectangle(absolute_button_rect, colors, 0.03, false)
        else
            Utils.set_color_with_table(colors.normal)
            Utils.render_rect_from_rect(absolute_button_rect)
        end
        button.update(absolute_button_rect)
    end
    return sMouseHoveredButton
end

---@param m MarioState
---@param inputs Inputs
---@param current MenuButton
---@param group MenuButton[]
function CommonMenu.button_inputs(m, inputs, current, group)
    if (not Mouse.moved and inputs.buttons.pressed & A_BUTTON ~= 0) or
    (Mouse.pressed.left and sMouseHoveredButton and sMouseHoveredButton == current) then
        current.action(m, inputs)
        m.controller.buttonPressed = m.controller.buttonPressed & ~A_BUTTON
    end

    local new_button = current
    if inputs.stick.up then
        new_button = group[current.links.up] or current
    elseif inputs.stick.down then
        new_button = group[current.links.down] or current
    end

    if inputs.stick.left then
        new_button = group[current.links.left] or current
    elseif inputs.stick.right then
        new_button = group[current.links.right] or current
    end
    return new_button
end
]]

----------------------------------------------------------------

return CommonMenu