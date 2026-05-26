local Utils = {}

---@class Rectangle
    ---@field x number
    ---@field y number
    ---@field width number
    ---@field height number

---@class Direction
    ---@field up boolean
    ---@field left boolean
    ---@field down boolean
    ---@field right boolean

---@param color DjuiColor
function Utils.set_color_with_table(color)
    djui_hud_set_color(color.r, color.g, color.b, color.a)
end

---@param color DjuiColor
---@param offset DjuiColor
---@return DjuiColor
function Utils.adjust_color(color, offset)
    return { r = color.r + offset.r, g = color.g + offset.g, b = color.b + offset.b, a = color.a + offset.a }
end

---@param text string
---@param x number
---@param y number
---@param scale number
---@param color DjuiColor
function Utils.render_shadowed_text(text, x, y, scale, color)
    local shadow_x = x
    local shadow_y = y
    djui_hud_set_color(0, 0, 0, 255)
    djui_hud_print_text(text, shadow_x, shadow_y, scale)

    local text_x = shadow_x - 2
    local text_y = shadow_y - 2
    djui_hud_set_color(color.r, color.g, color.b, color.a)
    djui_hud_print_text(text, text_x, text_y, scale)
end

---@param rect Rectangle
---@param color DjuiColor
---@param pixel_size number
function Utils.render_pixel_border(rect, color, pixel_size)
    djui_hud_set_color(color.r, color.g, color.b, color.a)
    local x, y, width, height = Utils.from_rect(rect)
    djui_hud_render_rect(x, y, width, pixel_size)
    djui_hud_render_rect(x, y, pixel_size, height)
    djui_hud_render_rect(x, y + height - pixel_size, width, pixel_size)
    djui_hud_render_rect(x + width - pixel_size, y, pixel_size, height)
end

---@param rect Rectangle
---@param colors BorderedColors
---@param margin_percent number
function Utils.render_rectangle_borders(rect, colors, margin_percent)
    local x, y, width, height = Utils.from_rect(rect)
    local margin_width = width * margin_percent
    local margin_height = margin_width
    djui_hud_set_color(colors.shine.r, colors.shine.g, colors.shine.b, colors.shine.a)
    djui_hud_render_rect(x, y, width, margin_height)
    djui_hud_render_rect(x, y, margin_width, height)
    djui_hud_set_color(colors.shade.r, colors.shade.g, colors.shade.b, colors.shade.a)
    djui_hud_render_rect(x, y + height - margin_height, width, margin_height)
    djui_hud_render_rect(x + width - margin_width, y, margin_width, height)
end

---@param rect Rectangle
---@param colors BorderedColors
---@param margin_percent number
---@param remove_pixel_border boolean
function Utils.render_bordered_rectangle(rect, colors, margin_percent, remove_pixel_border)
    Utils.render_rectangle_borders(rect, colors, margin_percent)
    if not remove_pixel_border then
        Utils.render_pixel_border(rect, BLACK, 2)
    end
    djui_hud_set_color(colors.normal.r, colors.normal.g, colors.normal.b, colors.normal.a)

    local x, y, width, height = Utils.from_rect(rect)
    local margin_width = width * margin_percent
    local margin_height = margin_width
    djui_hud_render_rect(
        x + margin_width,
        y + margin_height,
        width - margin_width * 2,
        height - margin_height * 2
    )
end

---@param text string
---@param rect_x number
---@param rect_width number
---@param y number
---@param scale number
function Utils.render_centered_colored_text(text, rect_x, rect_width, y, scale)
    local components = {}
    local total_size = 0

    local in_backslash = false
    local recorded_color = ""
    local recorded_message = ""

    local message_length = #text
    for i = 1, message_length, 1 do
        local char = text:sub(i, i)
        local is_at_end = i == message_length
        if char == "\\" or i == message_length then
            in_backslash = not in_backslash
            if in_backslash or is_at_end then
                if recorded_color == "" then recorded_color = "000000" end
                local r = tonumber(recorded_color:sub(1, 2), 16) --[[@as number]]
                local g = tonumber(recorded_color:sub(3, 4), 16) --[[@as number]]
                local b = tonumber(recorded_color:sub(5, 6), 16) --[[@as number]]
                local color_table = { r = r, g = g, b = b, a = 255 }

                local sub_message = nil
                if recorded_message ~= "" then
                    sub_message = recorded_message
                    if is_at_end then
                        sub_message = sub_message .. char
                    end
                end

                if sub_message then
                    table.insert(components, {
                        color = { r = color_table.r, g = color_table.g, b = color_table.b, a = color_table.a },
                        message = sub_message
                    })
                    total_size = total_size + djui_hud_measure_text(sub_message) * scale
                end

                recorded_color = ""
                recorded_message = ""
            end
        elseif in_backslash and char ~= "#" then
            recorded_color = recorded_color .. char
        elseif not in_backslash then
            recorded_message = recorded_message .. char
        end
    end

    local initial_text_x = rect_x + rect_width * 0.5 - total_size * 0.5
    local size_accumulator = 0
    for _, part in ipairs(components) do
        local color = part.color
        local sub_message = part.message

        local text_x = initial_text_x + size_accumulator
        size_accumulator = size_accumulator + djui_hud_measure_text(sub_message) * scale

        djui_hud_set_color(color.r, color.g, color.b, color.a)
        djui_hud_print_text(sub_message, text_x, y, scale)
    end
end

---@param text string
---@param x number
---@param x_end number
---@param y number
---@param scale number
function Utils.render_centered_text(text, x, x_end, y, scale)
    local text_size = djui_hud_measure_text(text) * scale
    local text_x = x + x_end * 0.5 - text_size * 0.5
    djui_hud_print_text(text, text_x, y, scale)
end

---@param rect Rectangle
function Utils.render_rect_from_rect(rect)
    djui_hud_render_rect(rect.x, rect.y, rect.width, rect.height)
end

---@param rect Rectangle
---@return number, number, number, number
function Utils.from_rect(rect)
    return rect.x, rect.y, rect.width, rect.height
end

---@param x number
---@param y number
---@param width number
---@param height number
---@return Rectangle
function Utils.into_rect(x, y, width, height)
    return { x = x, y = y, width = width, height = height }
end

return Utils