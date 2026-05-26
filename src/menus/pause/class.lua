---@class PauseMenu
    ---@field index integer
    ---@field current_menu integer
    ---@field selection_active boolean
    ---@field [integer] PauseMenuButton[]
    ---@field get_current_button fun(): PauseMenuButton
    ---@field set_new_menu fun(menu: integer)
    ---@field close_menu fun()
    ---@field set_selection fun()

---@class PauseMenuButton
    ---@field name string
    ---@field action fun(m: MarioState)
    ---@field is_selected boolean
    ---@field name_args (fun(): ...)?
    ---@field enabled (fun(): boolean)?
    ---@field selection (fun(inputs: Inputs))?

PAUSE_MENU_MAIN = 1
PAUSE_MENU_OPTIONS = 2
PAUSE_MENU_HELP = 3

---@type PauseMenu
local Pause = {
    index = 1,
    current_menu = PAUSE_MENU_MAIN,
    selection_active = false,
    get_current_button = function () return {} end,
    set_new_menu = function () end,
    close_menu = function () end,
    set_selection = function () end,
}
Pause.get_current_button = function ()
    return Pause[Pause.current_menu][Pause.index]
end
Pause.set_new_menu = function (menu)
    Pause.current_menu = menu
    Pause.index = 1
    Pause.selection_active = false
end
Pause.close_menu = function ()
    gCurrentMenu = gInBuildMode and MENU_TYPE_CLOSED or MENU_TYPE_NONE
    Pause.index = 1
    Pause.selection_active = false
end
Pause.set_selection = function ()
    Pause.get_current_button().is_selected = true
    Pause.selection_active = true
end

Pause[PAUSE_MENU_MAIN] = {
    { name = "Resume Game", action = function () Pause.close_menu() end },
    {
        name = "%s Course",
        name_args = function ()
            return gNetworkPlayers[0].currLevelNum == LEVEL_PLOT and "Restart" or "Exit"
        end,
        action = function (m)
            if gNetworkPlayers[0].currLevelNum == LEVEL_PLOT then
                trigger_on_death()
            else
                level_trigger_warp(m, WARP_OP_EXIT)
            end
            Pause.close_menu()
        end},
    {
        name = "Exit to Castle",
        action = function ()
            initiate_warp(gLevelValues.exitCastleLevel, gLevelValues.exitCastleArea, gLevelValues.exitCastleWarpNode, WARP_ARG_EXIT_COURSE)
            fade_into_special_warp(0, 0)
            Pause.close_menu()
        end
    },
    { name = "Options", action = function () Pause.set_new_menu(PAUSE_MENU_OPTIONS) end },
    { name = "Help", action = function () Pause.set_new_menu(PAUSE_MENU_HELP) end },
    {
        name = "Coop Settings",
        action = function (m)
            djui_open_pause_menu()
            Pause.close_menu()
            m.controller.buttonPressed = m.controller.buttonPressed & ~A_BUTTON
        end
    },
}

Pause[PAUSE_MENU_OPTIONS] = {
    { name = "Hide Hud", action = function () _ = hud_is_hidden() and hud_show() or hud_hide() end, enabled = function () return hud_is_hidden() end },
    {
        name = "Show Angle Arrow",
        action = function ()
            gMiscSettings.show_arrow = not gMiscSettings.show_arrow
        end,
        enabled = function ()
            return gMiscSettings.show_arrow
        end
    },
    {
        name = "Angle Increment: %d",
        name_args = function () return gMiscSettings.angle_increment end,
        action = function ()
            Pause.set_selection()
        end,
        selection = function (inputs)
            if inputs.stick.up or inputs.dpad.up or inputs.c_buttons.up then
                gMiscSettings.angle_increment = gMiscSettings.angle_increment + 15
            elseif inputs.stick.down or inputs.dpad.down or inputs.c_buttons.down then
                gMiscSettings.angle_increment = gMiscSettings.angle_increment - 15
            end
            if inputs.stick.left or inputs.dpad.left or inputs.c_buttons.left then
                gMiscSettings.angle_increment = gMiscSettings.angle_increment - 5
            elseif inputs.stick.right or inputs.dpad.right or inputs.c_buttons.right then
                gMiscSettings.angle_increment = gMiscSettings.angle_increment + 5
            end
        end
    },
    {
        name = "Auto Build",
        action = function ()
            gMiscSettings.auto_build = not gMiscSettings.auto_build
        end,
        enabled = function ()
            return gMiscSettings.auto_build
        end
    },
    {
        name = "Invert Mouse Scrolling",
        action = function ()
            GlobalSettings.invert_mouse_scroll = not GlobalSettings.invert_mouse_scroll
        end,
        enabled = function ()
            return GlobalSettings.invert_mouse_scroll
        end
    },
    {
        name = "Show Controls",
        action = function ()
            GlobalSettings.show_controls = not GlobalSettings.show_controls
        end,
        enabled = function ()
            return GlobalSettings.show_controls
        end
    },
    { name = "Back", action = function () Pause.set_new_menu(PAUSE_MENU_MAIN) end },
}

Pause[PAUSE_MENU_HELP] = {
    { name = "Back", action = function () Pause.set_new_menu(PAUSE_MENU_MAIN) end },
}

return Pause