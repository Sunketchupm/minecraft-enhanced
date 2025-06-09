local __djui_chat_message_create = djui_chat_message_create
function djui_chat_message_create(message)
    __djui_chat_message_create(tostring(message))
end

MinecraftDebug = {}
function MinecraftDebug.segments(x, y, width, height)
    djui_hud_set_color(0, 255, 0, 255)
    local rect_x = x
    while rect_x <= x + width do
        local rect_y = y
        while rect_y <= y + height do
            djui_hud_render_rect(rect_x, rect_y, 10 ,10)
            rect_y = rect_y + height * 0.05
        end
        rect_x = rect_x + width * 0.05
    end
end