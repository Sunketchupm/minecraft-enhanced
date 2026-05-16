---@class PauseMenu
    ---@field [integer] PauseMenuButton[][]
    ---@field v_index integer
    ---@field h_index integer
    ---@field is_paused boolean
    ---@field current_menu integer
    ---@field get_current_button fun(): PauseMenuButton

---@class PauseMenuButton
    ---@field name string
    ---@field action fun(m: MarioState)
    ---@field is_selected boolean
    ---@field name_args (fun(): ...)?
    ---@field enabled (fun(): boolean)?
    ---@field selection (fun(input: {up: boolean, left: boolean, down: boolean, right: boolean}))?

PAUSE_MENU_MAIN = 1
PAUSE_MENU_OPTIONS = 2
PAUSE_MENU_HELP = 3

---@type PauseMenu
gPauseMenu = {
    menu = {},
    v_index = 1,
    h_index = 1,
    is_paused = false,
    current_menu = PAUSE_MENU_MAIN,
    get_current_button = function () return gPauseMenu[gPauseMenu.current_menu][gPauseMenu.h_index][gPauseMenu.v_index] end
}

function set_new_menu(menu)
    gPauseMenu.current_menu = menu
    gPauseMenu.h_index = 1
    gPauseMenu.v_index = 1
end

gPauseMenu[PAUSE_MENU_MAIN] = {
    {
        { name = "Resume Game", action = function () gPauseMenu.is_paused = false end },
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
                gPauseMenu.is_paused = false
            end},
        {
            name = "Exit to Castle",
            action = function ()
                initiate_warp(gLevelValues.exitCastleLevel, gLevelValues.exitCastleArea, gLevelValues.exitCastleWarpNode, WARP_ARG_EXIT_COURSE)
                fade_into_special_warp(0, 0)
                gPauseMenu.is_paused = false
            end
        },
        { name = "Options", action = function () set_new_menu(PAUSE_MENU_OPTIONS) end },
        { name = "Help", action = function () set_new_menu(PAUSE_MENU_HELP) end },
        {
            name = "Coop Settings",
            action = function (m)
                djui_open_pause_menu()
                gPauseMenu.is_paused = false
                m.controller.buttonPressed = m.controller.buttonPressed & ~A_BUTTON
            end
        },
    },
}

gPauseMenu[PAUSE_MENU_OPTIONS] = {
    {
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
                gPauseMenu.get_current_button().is_selected = true
            end,
            selection = function (input)
                if input.up then
                    gMiscSettings.angle_increment = gMiscSettings.angle_increment + 15
                elseif input.down then
                    gMiscSettings.angle_increment = gMiscSettings.angle_increment - 15
                end
                if input.left then
                    gMiscSettings.angle_increment = gMiscSettings.angle_increment - 5
                elseif input.right then
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
            name = "Invert Scrolling",
            action = function ()
                gMenu.settings.invert_scroll = not gMenu.settings.invert_scroll
            end,
            enabled = function ()
                return gMenu.settings.invert_scroll
            end
        },
        {
            name = "Show Controls",
            action = function ()
                gMenu.settings.show_controls = not gMenu.settings.show_controls
            end,
            enabled = function ()
                return gMenu.settings.show_controls
            end
        },
        { name = "Back", action = function () set_new_menu(PAUSE_MENU_MAIN) end },
    },
}

gPauseMenu[PAUSE_MENU_HELP] = {
    {
        { name = "Back", action = function () set_new_menu(PAUSE_MENU_MAIN) end },
    },
}