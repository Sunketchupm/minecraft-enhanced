local Controls = {}

---@param screen { width: number, height: number } 
---@param x number
---@param y number
---@param buttons {prefix: string?, postfix: string?, texture: TextureInfo}[]
local function render_controls_tip(screen, x, y, buttons)
    local text_scale = (screen.width/screen.height) * 0.55
    local texture_scale = (screen.width/screen.height) * 1.1
    local initial_x = x
    local texture_y = y

    djui_hud_set_color_with_table(WHITE)
    for i, button in ipairs(buttons) do
        local texture = button.texture
        local texture_x = initial_x
        if button.prefix then
            ---@type string
            local prefix = button.prefix
            local text_size = djui_hud_measure_text(prefix) * text_scale
            local text_x = texture_x
            texture_x = text_x + text_size
            render_shadowed_text(prefix, text_x, texture_y, text_scale)
            initial_x = texture_x + texture.width * texture_scale
        end
        if button.postfix then
            ---@type string
            local postfix = button.postfix
            local text_size = djui_hud_measure_text(postfix) * text_scale
            local text_x = texture_x + texture.width * text_scale
            render_shadowed_text(postfix, text_x, texture_y, text_scale)
            initial_x = text_x + text_size
        end
        djui_hud_render_texture(texture, texture_x, texture_y, texture_scale, texture_scale)
    end
end

---@param screen_width number
---@param screen_height number
Controls.render = function(screen_width, screen_height)
    local x = screen_width * 0.02
    local y = screen_height * 0.955
    local screen = { width = screen_width, height = screen_height }
    if not gCanBuild then
        djui_hud_set_color(0, 0, 0, 60)
        render_controls_tip(screen, x * 0.98, y, {{prefix = "", texture = L_TRIG_TEX}, {postfix = "  Fly (Enter Build Mode)", texture = L_TRIG_TEX}})
    else
        if not gMenu.open then
            local l_held_modifier = gMarioStates[0].controller.buttonDown & L_TRIG ~= 0
            if not l_held_modifier then
                if not gCurrentItem then -- no hold L, no selected item
                    render_controls_tip(screen, x, y, {{prefix = "", texture = L_TRIG_TEX}, {postfix = "  Stop Flying", texture = L_TRIG_TEX}})
                    render_controls_tip(screen, x, y * 0.95, {{postfix = "  Open Menu", texture = X_BUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.90, {{postfix = "  Fly Up", texture = A_BUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.85, {{postfix = "  Fly Down", texture = Z_TRIG_TEX}})
                    render_controls_tip(screen, x, y * 0.80, {{postfix = "  Sprint Fly", texture = B_BUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.75, {{postfix = "  Cycle Hotbar", texture = LR_JPAD_TEX}})
                    render_controls_tip(screen, x, y * 0.70, {{postfix = "  Lock Face Angle/More", texture = L_TRIG_TEX}})
                else -- no hold L, item selected
                    render_controls_tip(screen, x, y, {{prefix = "", texture = L_TRIG_TEX}, {postfix = "  Stop Flying", texture = L_TRIG_TEX}})
                    render_controls_tip(screen, x, y * 0.95, {{postfix = "  Open Menu", texture = X_BUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.90, {{postfix = "  Place/Delete Item", texture = Y_BUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.85, {{postfix = "  Adjust Elevation", texture = UD_JPAD_TEX}})
                    render_controls_tip(screen, x, y * 0.80, {{postfix = "  Cycle Hotbar", texture = LR_JPAD_TEX}})
                    render_controls_tip(screen, x, y * 0.75, {{postfix = "  Lock Face Angle/More", texture = L_TRIG_TEX}})
                end
            else
                if not gCurrentItem then -- L held, no selected item
                    render_controls_tip(screen, x, y, {{postfix = "  Slow Fly", texture = B_BUTTON_TEX}})
                else -- L held, item selected
                    render_controls_tip(screen, x, y, {{postfix = "  Slow Fly", texture = B_BUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.95, {{postfix = "  Place/Delete Item", texture = Y_BUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.90, {{postfix = "  Adjust Size", texture = UD_JPAD_TEX}})
                    render_controls_tip(screen, x, y * 0.85, {{prefix = "", texture = U_CBUTTON_TEX}, {postfix = "  Adjust Pitch", texture = D_CBUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.80, {{prefix = "", texture = L_CBUTTON_TEX}, {postfix = "  Adjust Yaw", texture = R_CBUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.75, {{postfix = "  Adjust Roll", texture = LR_JPAD_TEX}})
                    render_controls_tip(screen, x, y * 0.70, {{postfix = "  Reset Angle", texture = X_BUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.65, {{postfix = "  Disable Grid", texture = R_TRIG_TEX}})
                end
            end
        else
            render_controls_tip(screen, x, y, {{postfix = "  Move Selection", texture = CONTROL_STICK_TEX}})
            render_controls_tip(screen, x, y * 0.95, {{postfix = "  Select Item", texture = A_BUTTON_TEX}})
            render_controls_tip(screen, x, y * 0.90, {{prefix = "", texture = L_CBUTTON_TEX}, {postfix = "  Next/Previous Page", texture = R_CBUTTON_TEX}})
            render_controls_tip(screen, x, y * 0.85, {{prefix = "", texture = L_TRIG_TEX}, {postfix = "  Next/Previous Tab", texture = R_TRIG_TEX}})
            render_controls_tip(screen, x, y * 0.80, {{postfix = "  Cycle Hotbar", texture = LR_JPAD_TEX}})
            render_controls_tip(screen, x, y * 0.75, {{postfix = "  Close Menu", texture = X_BUTTON_TEX}})
        end
    end
end

return Controls