local Utils = require("utils")

local Pause = require("pause/class")

local A_BUTTON_TEX = get_texture_info("Abutton")
local B_BUTTON_TEX = get_texture_info("Bbutton")
local X_BUTTON_TEX = get_texture_info("Xbutton")
local Y_BUTTON_TEX = get_texture_info("Ybutton")
local START_BUTTON_TEX = get_texture_info("Startbutton")
local U_JPAD_TEX = get_texture_info("UJpad")
local L_JPAD_TEX = get_texture_info("LJpad")
local D_JPAD_TEX = get_texture_info("DJpad")
local R_JPAD_TEX = get_texture_info("RJpad")
local UD_JPAD_TEX = get_texture_info("U-Djpad")
local LR_JPAD_TEX = get_texture_info("L-Rjpad")
local U_CBUTTON_TEX = get_texture_info("Ucbutton")
local L_CBUTTON_TEX = get_texture_info("Lcbutton")
local D_CBUTTON_TEX = get_texture_info("Dcbutton")
local R_CBUTTON_TEX = get_texture_info("Rcbutton")
local L_TRIG_TEX = get_texture_info("Ltrig")
local R_TRIG_TEX = get_texture_info("Rtrig")
local Z_TRIG_TEX = get_texture_info("Ztrig")
local CONTROL_STICK_TEX = get_texture_info("Ctrlstick")
local PAGE_UP_TEX = get_texture_info("page_up")
local PAGE_DOWN_TEX = get_texture_info("page_down")

-----------------------------------------------------------------------

local function creative_menu_tips()
    return {
        { X_BUTTON_TEX, "Close Menu" },
        { CONTROL_STICK_TEX, "Select Item" },
        { A_BUTTON_TEX, "Pick Item" },
        { LR_JPAD_TEX, "Cycle Hotbar" },
        { U_CBUTTON_TEX, D_CBUTTON_TEX, L_CBUTTON_TEX, R_CBUTTON_TEX, "Scroll" },
        { L_TRIG_TEX, R_TRIG_TEX, "Next/Previous Tab" },
    }
end

local function pause_menu_tips()
    local button = Pause.get_current_button()
    if button then
        if button.is_selected then
            return {
                { CONTROL_STICK_TEX, "/", LR_JPAD_TEX, UD_JPAD_TEX, "/", L_CBUTTON_TEX, R_CBUTTON_TEX, D_CBUTTON_TEX, U_CBUTTON_TEX, "Scroll" },
                { A_BUTTON_TEX, "/", B_BUTTON_TEX, "/", START_BUTTON_TEX, "Close" },
            }
        else
            return {
                { CONTROL_STICK_TEX, "/", UD_JPAD_TEX, "/", U_CBUTTON_TEX, D_CBUTTON_TEX, "Scroll" },
                { A_BUTTON_TEX, "/", START_BUTTON_TEX, "Select" },
            }
        end
    end
end

local function item_settings_tips()
    return {
        { X_BUTTON_TEX, "Close Menu" },
        { CONTROL_STICK_TEX, "Select Option / Move Slider" },
        { A_BUTTON_TEX, "Toggle Option" },
        { LR_JPAD_TEX, "Cycle Hotbar" },
        { U_CBUTTON_TEX, D_CBUTTON_TEX, L_CBUTTON_TEX, R_CBUTTON_TEX, "Scroll" },
        { L_TRIG_TEX, R_TRIG_TEX, "Next/Previous Tab" },
    }
end

-----------------------------------------------------------------------

local sMenuSpecificTips = {
    [MENU_TYPE_CREATIVE] = creative_menu_tips,
    [MENU_TYPE_PAUSE] = pause_menu_tips,
    [MENU_TYPE_SETTINGS] = item_settings_tips,
}

---@param screen { width: number, height: number } 
---@param x number
---@param y number
---@param tips table
local function render_controls_tips(screen, x, y, tips)
    local text_scale = (screen.width/screen.height) * 0.55
    local texture_scale = (screen.width/screen.height) * 1.1
    local initial_x = x

    Utils.set_color_with_table(WHITE)

    local tip_y = y
    for index, tip in ipairs(tips) do
        local tip_x = initial_x
        tip_y = screen.height * (1 - 0.05 * index)
        for part_index, part in ipairs(tip) do
            if type(part) == "string" then
                ---@cast part string
                if part_index == #tip then
                    tip_x = tip_x + 20
                end
                djui_hud_set_font(FONT_SPECIAL)
                Utils.render_shadowed_text(part, tip_x, tip_y, text_scale, WHITE)
                tip_x = tip_x + djui_hud_measure_text(part) * text_scale + 5
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
local function render(screen_width, screen_height)
    local x = screen_width * 0.02
    local y = screen_height * 0.955
    local screen = { width = screen_width, height = screen_height }
    local group = {}
    if not gInBuildMode then
        group = {
            { L_TRIG_TEX, L_TRIG_TEX, "Fly (Enter Build Mode)" }
        }
    else
        local l_held_modifier = gMarioStates[0].controller.buttonDown & L_TRIG ~= 0
        if not l_held_modifier then
            if not gCurrentItem then
                group = {
                    { L_TRIG_TEX, L_TRIG_TEX, "Stop Flying" },
                    { X_BUTTON_TEX, "Open Menu" },
                    { A_BUTTON_TEX, "Fly Up" },
                    { Z_TRIG_TEX, "Fly Down" },
                    { B_BUTTON_TEX, "Sprint Fly" },
                    { LR_JPAD_TEX, "Cycle Hotbar" },
                    { L_TRIG_TEX, "Lock Face Angle/More" },
                }
            else
                group = {
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
            end
        else
            if not gCurrentItem then
                group = {
                    { B_BUTTON_TEX, "Slow Flying" },
                }
            else
                group = {
                    { R_TRIG_TEX, "Disable Grid" },
                    { X_BUTTON_TEX, "Open Item Settings" },
                    { A_BUTTON_TEX, "Fly Up" },
                    { Z_TRIG_TEX, "Fly Down" },
                    { B_BUTTON_TEX, "Slow Fly" },
                    { Y_BUTTON_TEX, "Place/Delete Item" },
                    { UD_JPAD_TEX, "Adjust Size" },
                    { LR_JPAD_TEX, "Adjust Roll" },
                    { L_CBUTTON_TEX, R_CBUTTON_TEX, "Adjust Yaw" },
                    { U_CBUTTON_TEX, D_CBUTTON_TEX, "Adjust Pitch" },
                }
            end
        end
    end

    if sMenuSpecificTips[gCurrentMenu] then
        group = sMenuSpecificTips[gCurrentMenu]() or group
    end
    render_controls_tips(screen, x, y, group)
end

return render