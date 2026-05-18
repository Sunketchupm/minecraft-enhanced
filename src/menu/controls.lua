local Controls = {}

---@param screen { width: number, height: number } 
---@param x number
---@param y number
---@param tips table
local function render_controls_tips(screen, x, y, tips)
    local text_scale = (screen.width/screen.height) * 0.55
    local texture_scale = (screen.width/screen.height) * 1.1
    local initial_x = x

    djui_hud_set_color_with_table(WHITE)

    local tip_y = y
    for index, tip in ipairs(tips) do
        local tip_x = initial_x
        tip_y = screen.height * (1 - 0.05 * index)
        for _, part in ipairs(tip) do
            if type(part) == "string" then
                ---@cast part string
                tip_x = tip_x + 20
                djui_hud_set_font(FONT_SPECIAL)
                render_shadowed_text(part, tip_x, tip_y, text_scale)
            else
                ---@cast part TextureInfo
                djui_hud_render_texture(part, tip_x, tip_y, texture_scale, texture_scale)
                tip_x = tip_x + part.width * texture_scale + 5
            end
        end
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
        render_controls_tips(screen, x, y, { { L_TRIG_TEX, L_TRIG_TEX, "Fly (Enter Build Mode)" } })
    else
        if not gMenu.open then
            local l_held_modifier = gMarioStates[0].controller.buttonDown & L_TRIG ~= 0
            if not l_held_modifier then
                if not gCurrentItem then -- no hold L, no selected item
                    local group = {
                        { L_TRIG_TEX, L_TRIG_TEX, "Stop Flying" },
                        { X_BUTTON_TEX, "Open Menu" },
                        { A_BUTTON_TEX, "Fly Up" },
                        { Z_TRIG_TEX, "Fly Down" },
                        { B_BUTTON_TEX, "Sprint Fly" },
                        { LR_JPAD_TEX, "Cycle Hotbar" },
                        { L_TRIG_TEX, "Lock Face Angle/More" },
                    }
                    render_controls_tips(screen, x, y, group)
                else -- no hold L, item selected
                    local group = {
                        { L_TRIG_TEX, L_TRIG_TEX, "Stop Flying" },
                        { X_BUTTON_TEX, "Open Menu" },
                        { A_BUTTON_TEX, "Fly Up" },
                        { Z_TRIG_TEX, "Fly Down" },
                        { B_BUTTON_TEX, "Sprint Fly" },
                        { Y_BUTTON_TEX, "Place/Delete Item" },
                        { UD_JPAD_TEX, "Adjust Elevation" },
                        { LR_JPAD_TEX, "Cycle Hotbar" },
                        { L_TRIG_TEX, "Lock Face Angle/More" },
                    }
                    render_controls_tips(screen, x, y, group)
                end
            else
                if not gCurrentItem then -- L held, no selected item
                    local group = {
                        { B_BUTTON_TEX, "Slow Flying" },
                    }
                    render_controls_tips(screen, x, y, group)
                else -- L held, item selected
                    local group = {
                        { R_TRIG_TEX, "Disable Grid" },
                        { X_BUTTON_TEX, "Reset Grid" },
                        { A_BUTTON_TEX, "Fly Up" },
                        { Z_TRIG_TEX, "Fly Down" },
                        { B_BUTTON_TEX, "Slow Fly" },
                        { Y_BUTTON_TEX, "Place/Delete Item" },
                        { UD_JPAD_TEX, "Adjust Size" },
                        { LR_JPAD_TEX, "Adjust Roll" },
                        { L_CBUTTON_TEX, R_CBUTTON_TEX, "Adjust Yaw" },
                        { U_CBUTTON_TEX, D_CBUTTON_TEX, "Adjust Pitch" },
                    }
                    render_controls_tips(screen, x, y, group)
                end
            end
        else
            -- Menu open
            local group = {
                { X_BUTTON_TEX, "Close Menu" },
                { A_BUTTON_TEX, "Select Item" },
                { LR_JPAD_TEX, "Cycle Hotbar" },
                { L_CBUTTON_TEX, R_CBUTTON_TEX, "Next/Previous Page" },
                { L_TRIG_TEX, R_TRIG_TEX, "Next/Previous Tab" },
            }
            render_controls_tips(screen, x, y, group)
        end
    end
end

return Controls