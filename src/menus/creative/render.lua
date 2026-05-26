local Utils = require("../utils")
local Mouse = require("../mouse")
local CommonMenu = require("../common_menu")

local Hotbar = require("../hotbar/class")

local Menu = require("class")
local Grid = require("grid")
local List = require("list")

------------------------------------------------------------------------------------------------

local Y_BUTTON_TEX = get_texture_info("Ybutton")
local sPrevResetBarWidth = 0

---@param rect Rectangle
local function render_reset_button(rect)
    local reset_rect = {}
    reset_rect.height = rect.height * 0.1
    reset_rect.y = rect.y + rect.height * 0.925 - reset_rect.height * 0.5

    local reset_text_scale = 1
    local y_tex_scale = 2
    local reset_text = "Remove Item / Reset Hotbar"
    local total_size = (Y_BUTTON_TEX.width * y_tex_scale) + 16 + (djui_hud_measure_text(reset_text) * reset_text_scale)
    local reset_line_texture_x = rect.x + rect.width * 0.5 - total_size * 0.5
    local reset_line_text_x = reset_line_texture_x + (Y_BUTTON_TEX.width * y_tex_scale) + 16
    local reset_line_y = reset_rect.y + reset_rect.height * 0.5 - (Y_BUTTON_TEX.height * y_tex_scale) * 0.5

    reset_rect.width = total_size + 10
    reset_rect.x = rect.x + rect.width * 0.5 - reset_rect.width * 0.5

    local color = Menu.reset.active and SELECTED_BUTTON_COLORS or MAIN_RECT_COLORS
    Utils.render_bordered_rectangle(reset_rect, color, 0.01, false)

    Utils.set_color_with_table(WHITE)
    djui_hud_render_texture(Y_BUTTON_TEX, reset_line_texture_x, reset_line_y, y_tex_scale, y_tex_scale)
    local reset_text_color = Menu.reset.active and YELLOW or WHITE
    Utils.render_shadowed_text(reset_text, reset_line_text_x, reset_line_y, reset_text_scale, reset_text_color)

    local reset_bar_width = math.lerp(0, reset_rect.width, Menu.reset.progress / 90)

    Utils.set_color_with_table(GREEN)
    djui_hud_render_rect_interpolated(
        reset_rect.x, reset_rect.y + reset_rect.height, sPrevResetBarWidth, 10,
        reset_rect.x, reset_rect.y + reset_rect.height, reset_bar_width, 10)
    sPrevResetBarWidth = reset_bar_width

    if not Menu.item.link and Mouse.moved and Mouse.is_within(reset_rect) then
        if Mouse.pressed.left then
            Hotbar[Hotbar.index].link = nil
        elseif Mouse.down.left then
            Menu.reset.progress = Menu.reset.progress + 1
        end
    end
end

---@param rect Rectangle
---@param tab CreativeMenuTab
local function render_interior_rectangle(rect, tab)
    local interior_rect = {
        x = rect.x + rect.width * 0.05,
        y = rect.y + rect.height * 0.15,
        width = rect.width * 0.8,
        height = rect.height * 0.7
    }
    local new_color = Utils.adjust_color(MAIN_RECT_COLORS.normal, { r = -40, g = -40, b = -40, a = 0 })
    Utils.set_color_with_table(new_color)
    Utils.render_rect_from_rect(interior_rect)

    Grid.render(interior_rect, tab.grid, tab.scroll)
    render_reset_button(rect)
end

------------------------------------------------------------------------------------------------

local function render(screen_width, screen_height)
    djui_hud_set_font(FONT_SPECIAL)

    local rect = CommonMenu.render_main_rectangle(screen_width, screen_height, Menu, Menu.tab)

    local current_tab = Menu[Menu.tab]
    render_interior_rectangle(rect, current_tab)

    local link = Menu.item.link
    if link then
        if Mouse.moved then
            List.render_on_pos(Mouse.pos, link.icon)
        else
            List.render_on_rect(Hotbar[Hotbar.index].rect, link.icon)
        end
    end
end

return render