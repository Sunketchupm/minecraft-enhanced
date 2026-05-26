local CommonMenu = require("../common_menu")
local Utils = require("../utils")

local Menu = require("class")
local Grid = require("grid")
local Settings = require("settings")

------------------------------------------------------------------------------------------------

---@param screen_width number
---@param screen_height number
local function render(screen_width, screen_height)
    djui_hud_set_font(FONT_SPECIAL)

    local color = table.deepcopy(MAIN_RECT_COLORS)
    if Menu.settings.doing_inputs then
        color.normal = Utils.adjust_color(color.normal, { r = 0, g = 0, b = 0, a = -200 })
        color.shine = Utils.adjust_color(color.shine, { r = 0, g = 0, b = 0, a = -200 })
        color.shade = Utils.adjust_color(color.shade, { r = 0, g = 0, b = 0, a = -200 })
    end
    local rect = CommonMenu.render_main_rectangle(screen_width, screen_height, Menu, Menu.tab, color)

    local current_tab = Menu[Menu.tab]
    if current_tab.type == TAB_TYPE_GRID then
        Menu.settings.doing_inputs = false
        Grid.render(rect, current_tab)
    elseif current_tab.type == TAB_TYPE_SETTINGS then
        Settings.render(rect, current_tab)
    end
end

return render