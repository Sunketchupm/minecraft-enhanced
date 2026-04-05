local Mouse = require("mouse")

local Buttons = {}

---@class Button

---@param rect Rectangle
---@param text string
---@param texture TextureInfo
---@param input_func function
---@param override_darken boolean
---@return Rectangle
Buttons.render_menu_button = function(rect, text, texture, input_func, override_darken)
    local x, y, width, height = from_rect(rect)
    local text_scale = 0.7 * (width/height)
    local text_size = djui_hud_measure_text(text) * text_scale
    local texture_scale = 1.3 * (width/height)
    local texture_x = (x - texture.width * texture_scale) - 12
    -- Render text and texture later

    local overall_size = x + text_size - texture_x

    local button_rect = into_rect(texture_x - 6, y - 6, overall_size + 12, texture.height * texture_scale + 12)
    local colors = { MAIN_RECT_COLORS[1], MAIN_RECT_COLORS[2], MAIN_RECT_COLORS[3] }

    local darken = false
    if Mouse.is_within(button_rect) then
        darken = input_func()
    end
    darken = override_darken or darken

    if darken then
        colors = {
            { r = 180, g = 180, b = 180, a = 255 },
            { r = 235, g = 235, b = 235, a = 255 },
            { r = 68, g = 68, b = 68, a = 255 },
        }
    end

    render_bordered_rectangle(button_rect, colors, 0.008, 0.05, true)

    -- Render text and texture
    djui_hud_set_color_with_table(WHITE)
    djui_hud_render_texture(texture, texture_x, y, texture_scale, texture_scale)
    render_shadowed_text(text, x, y, text_scale)

    return button_rect
end

return Buttons