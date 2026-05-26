MENU_TYPE_NONE = 0 -- Not in flying mode
MENU_TYPE_CLOSED = 1 -- In flying mode
MENU_TYPE_CREATIVE = 2
MENU_TYPE_PAUSE = 3
MENU_TYPE_WORLD = 4
gCurrentMenu = MENU_TYPE_NONE

WHITE = { r = 255, g = 255, b = 255, a = 255 }
BLACK = { r = 0, g = 0, b = 0, a = 255 }
RED = { r = 255, g = 0, b = 0, a = 255 }
YELLOW = { r = 255, g = 255, b = 0, a = 255 }
GREEN = { r = 0, g = 255, b = 0, a = 255 }
CYAN = { r = 0, g = 255, b = 255, a = 255 }
BLUE = { r = 0, g = 0, b = 255, a = 255 }
PURPLE = { r = 255, g = 0, b = 255, a = 255 }

---@class BorderedColors
    ---@field normal DjuiColor
    ---@field shine DjuiColor
    ---@field shade DjuiColor


---@type BorderedColors
MAIN_RECT_COLORS = {
    normal = { r = 200, g = 200, b = 200, a = 255 },
    shine = { r = 255, g = 255, b = 255, a = 255 },
    shade = { r = 90, g = 88, b = 88, a = 255 },
}

---@type BorderedColors
BUTTON_RECT_COLORS = {
    normal = { r = 154, g = 154, b = 154, a = 255 },
    shine = { r = 194, g = 194, b = 194, a = 255 },
    shade = { r = 114, g = 114, b = 114, a = 255 },
}

---@type BorderedColors
SELECTED_BUTTON_COLORS = {
    normal = { r = 167, g = 175, b = 214, a = 255 },
    shine = { r = 205, g = 215, b = 254, a = 255 },
    shade = { r = 127, g = 135, b = 174, a = 255 },
}

GlobalSettings = {
    invert_mouse_scroll = false,
    show_controls = true,
}