local Mouse = require("mouse")

local Scroll = {}

---@class Scroll
    ---@field index integer
    ---@field offset integer
    ---@field elements string[]
    ---@field elements_rendered integer

---@param button Rectangle
---@param rect Rectangle
---@param offset_y number
---@param scroll Scroll
---@param elements string[]
Scroll.render = function(button, rect, offset_y, scroll, elements)
    local button_list_size = rect.height - (button.y - rect.y)
    local button_spacing = 8
    local button_total_height = button.height + button_spacing
    local button_div = button_list_size / button_total_height
    local button_count = math.floor(button_div)
    local extra_increm = (button_div - button_count) / button_count
    button_total_height = button_total_height + extra_increm

    local arrow_scale = 2
    local page_arrow_x = button.x + button.width * 0.5 - PAGE_UP_TEX.width * 0.5 * arrow_scale
    local arrow_offset = 10
    local page_up_arrow_y = button.y - PAGE_UP_TEX.height * arrow_scale - arrow_offset
    local page_down_arrow_y = (button.y + button_total_height * (button_count - 1)) + PAGE_DOWN_TEX.height * arrow_scale + arrow_offset * 2
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_render_texture(PAGE_UP_TEX, page_arrow_x, page_up_arrow_y + offset_y, arrow_scale, arrow_scale)
    djui_hud_render_texture(PAGE_DOWN_TEX, page_arrow_x, page_down_arrow_y + offset_y, arrow_scale, arrow_scale)

    scroll.elements = elements
    scroll.elements_rendered = button_count

    local hovered_index = -1
    for i = 1, button_count, 1 do
        local absolute_index = i + scroll.offset
        local rendered_button = {
            x = button.x,
            y = button.y + button_total_height * (i - 1) + offset_y,
            width = button.width,
            height = button.height,
        }
        if Mouse.moved and Mouse.is_within(rendered_button) then
            hovered_index = absolute_index
        end

        local button_colors = {{r = 125, g = 125, b = 125, a = 255}, {r = 175, g = 175, b = 175, a = 255}, {r = 75, g = 75, b = 75, a = 255}}
        if scroll.index == absolute_index then
            button_colors = {{r = 65, g = 65, b = 65, a = 255}, {r = 175, g = 175, b = 175, a = 255}, {r = 75, g = 75, b = 75, a = 255}}
        end

        if elements[absolute_index] then
            local rendered_button_rect = into_rect(button.x, button.y + button_total_height * (i - 1) + offset_y, button.width, button.height)
            render_bordered_rectangle(rendered_button_rect, button_colors, 0.01, 0.06, false)
            render_shadowed_text(elements[absolute_index], button.x + 12, button.y + 4.5 + button_total_height * (i - 1) + offset_y, 0.8)
        end
    end
    scroll.index = hovered_index
    return hovered_index
end

---@param scroll Scroll
---@param stick Directions
Scroll.inputs = function(_, scroll, stick, _)
    local element_count = #scroll.elements
    if Mouse.moved then
        if Mouse.menu.prevItemIndex ~= scroll.index then
            play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
        end
        Mouse.menu.prevItemIndex = scroll.index

        local invert_multiplier = gMenu.settings.invert_scroll and -1 or 1
        if (Mouse.scroll * invert_multiplier) > 0 and scroll.offset > 0 then
            scroll.offset = scroll.offset - 1
        elseif (Mouse.scroll * invert_multiplier) < 0 and element_count - scroll.offset > scroll.elements_rendered then
            scroll.offset = scroll.offset + 1
        end
    else
        local relative_button_index = scroll.index - scroll.offset
        if stick.up then
            scroll.index = scroll.index - 1
            if scroll.index <= 0 then
                scroll.index = element_count
                scroll.offset = element_count - scroll.elements_rendered
            elseif relative_button_index < 4 and scroll.offset > 0 then
                scroll.offset = scroll.offset - 1
            end
            play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
        elseif stick.down then
            scroll.index = scroll.index + 1
            if scroll.index > element_count then
                scroll.index = 1
                scroll.offset = 0
            elseif relative_button_index > scroll.elements_rendered - 3 and scroll.index + 1 < element_count then
                scroll.offset = scroll.offset + 1
            end
            play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
        end
    end
end

return Scroll