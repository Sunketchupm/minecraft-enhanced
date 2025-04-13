-- localize functions to improve performance
local string_find,string_len,string_gsub,tonumber,string_sub,error,djui_hud_set_resolution,djui_hud_set_font,djui_hud_get_screen_width,djui_hud_measure_text,djui_hud_get_screen_height,djui_hud_set_color,djui_hud_print_text,djui_hud_render_rect,set_mario_action,network_local_index_from_global,djui_hud_get_mouse_x,djui_hud_get_mouse_y,play_sound,djui_chat_message_create = string.find,string.len,string.gsub,tonumber,string.sub,error,djui_hud_set_resolution,djui_hud_set_font,djui_hud_get_screen_width,djui_hud_measure_text,djui_hud_get_screen_height,djui_hud_set_color,djui_hud_print_text,djui_hud_render_rect,set_mario_action,network_local_index_from_global,djui_hud_get_mouse_x,djui_hud_get_mouse_y,play_sound,djui_chat_message_create

--- @class WelcomeMsgText
--- @field public message string
--- @field public x number
--- @field public y number
--- @field public scale number
--- @field public font DjuiFontType
--- @field public hexColor string

-- false: Window won't close when mouse hovers over the OK button, only Buttons work
-- true: Window will close when mouse hovers over the OK button, alternatively buttons work too
local CLOSE_ON_MOUSE_HOVER = false

-- text-related options
-- sets font, scale (of text) and color for all texts
local globalFont = FONT_NORMAL
local globalScale = 1.4
local globalHexColor = "#000000"

welcomeMsgIsOpen = true
local hasConfirmed = false

--- @param message string
--- @param x number
--- @param y number
--- @param scale number
--- @param font DjuiFontType
--- @return WelcomeMsgText
local function make_text(message, x, y, scale, font, hexColor)
    return {
        message = message,
        x = x,
        y = y,
        scale = scale,
        font = font,
        hexColor = hexColor
    }
end

local sTexts = {
    make_text(
        "Welcome to Minecraft Enhanced!",
        -290,
        -245,
        2.0,
 	globalFont,
        "#ffffff"
    ),
    make_text(
            "|",
            100,
            -222,
            2.5,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "|",
            100,
            -160,
            2.5,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "|",
            100,
            -100,
            2.5,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "|",
            100,
            -40,
            2.5,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "|",
            100,
            20,
            2.5,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "|",
            100,
            80,
            2.5,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "|",
            100,
            140,
            2.5,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "|",
            100,
            200,
            2.5,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "|",
            100,
            260,
            2.5,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "|",
            100,
            320,
            2.5,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "|",
            100,
            380,
            2.5,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "|",
            100,
            440,
            2.5,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "|",
            100,
            460,
            2.5,
            globalFont,
            "#ffffff"
    ),
    make_text(
        "________________________________________________________________________________________________________",
        0,
        -270,
        1.1,
 	globalFont,
        "#ffffff"
    ),
    make_text(
        "Hosted by $HOSTNAME!",
        -530,
        400,
        1.0,
 	globalFont,
        "#ffffff"
    ),
    make_text(
        "This is a modified version of the Minecraft mod created by zKevin that",
        -315,
        -235,
        1.0,
 	globalFont,
        "#ffffff"
    ),
    make_text(
        "adds numerous colors and block customization.",
        -445,
        -205,
        1.0,
 	globalFont,
        "#ffffff"
    ),
    make_text(
        "This is not a mod of the game, Minecraft. Stop asking about that.",
        -340,
        -165,
        1,
 	globalFont,
        "#ff0000"
    ),
    make_text(
        "All the information of the mod can be found below:",
        -300,
        -127.5,
        1.0,
 	globalFont,
        "#ffffff"
    ),
    make_text(
        "/commandlist | Contains a list of commands related to the mod.",
        -354,
        -90,
        1,
 	globalFont,
        "#ffffff"
    ),
    make_text(
        "/surftypes | Contains a list of surface types for blocks.",
        -392,
        -50,
        1,
 	globalFont,
        "#ffffff"
    ),
    make_text(
        "/itemlist | Contains a list of different items.",
        -440,
        -10,
        1,
 	globalFont,
        "#ffffff"
    ),
    make_text(
        "/mcinfo | Brings you back to this screen.",
        -468,
        30,
        1,
 	globalFont,
        "#ffffff"
    ),
    make_text(
        "Minecraft Enhanced is still in development, so notify us of any bugs.",
        -328,
        80,
        1,
        globalFont,
        "#ffffff"
    ), 
       make_text(
        "Enjoy the mod, and build to your hearts content!",
        -430,
        125,
        1,
        globalFont,
        "#ffffff"
    ),
    make_text(
        "CREDITS:",
        -470,
        195,
        1.4,
        globalFont,
        "#ffffff"
    ),
       make_text(
        "-----------------------------------------------------------",
        -290,
        155,
        1.1,
        globalFont,
        "#ffffff"
    ),
    make_text(
        "Playtested by T h e S e r v e r",
        -520,
        305,
        1.0,
        globalFont,
        "#ffffff"
    ),
    make_text(
        "Color implementation by ER1CK and sherbie",
        -463,
        215,
        1.0,
        globalFont,
        "#ffffff"
    ),
    make_text(
        "Block customizations by Sunk",
        -535,
        245,
        1.0,
        globalFont,
        "#ffffff"
    ),
    make_text(
        "Optimizations by Sunk and Agent X",
        -502,
        275,
        1.0,
        globalFont,
        "#ffffff"
    ),
    make_text(
        "Original mod by zKevin",
        -565,
        335,
        1.0,
        globalFont,
        "#ffffff"
    ),
       make_text(
        "-----------------------------------------------------------",
        -290,
        370,
        1.1,
        globalFont,
        "#ffffff"
    ),
    make_text(
        "Press X to close",
        -90,
        400,
        1.0,
        globalFont,
        "#ffffff"
    ),
    make_text(
        "OK",
        50,
        374,
        0.65,
        FONT_MENU,
        "#ff0000"
    ),
    make_text(
            "CONTROLS:",
            400,
            -245,
            2,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "While flying:",
            195,
            -190,
            1.3,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "Press L twice to toggle flying",
            296.5,
            -160,
	    1.1,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "L",
            205.8,
            -160,
	    1.1,
            globalFont,
            "#919191"
    ),
    make_text(
            "Hold A to ascend",
            221.7,
            -130,
	    1.1,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "A",
            192.2,
            -130,
	    1.1,
            globalFont,
            "#1038eb"
    ),
    make_text(
            "Hold Z to descend",
            226,
            -100,
	    1.1,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "Z",
            191.01,
            -100,
	    1.1,
            globalFont,
            "#5b08c2"
    ),
    make_text(
            "Hold B to fly faster",
            239,
            -70,
	    1.1,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "B",
            191,
            -70,
	    1.1,
            globalFont,
            "#036e0c"
    ),
    make_text(
            "Hold L + B to fly slower",
            261,
            -40,
	    1.1,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "L",
            189.3,
            -40,
	    1.1,
            globalFont,
            "#919191"
    ),
    make_text(
            "B",
            237.9,
            -40,
	    1.1,
            globalFont,
            "#036e0c"
    ),
    make_text(
            "Hold L to lock your facing direction",
            323,
            -10,
	    1.1,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "L",
            188.6,
            -10,
	    1.1,
            globalFont,
            "#919191"
    ),
    make_text(
            "When placing blocks:",
            242,
            60,
	    1.3,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "Y to place/remove a block",
            267,
            90,
	    1.1,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "Y",
            136,
            90,
	    1.1,
            globalFont,
            "#b53007"
    ),
    make_text(
            "X to change block positioning",
            285,
            120,
	    1.1,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "X",
            134.1,
            120,
	    1.1,
            globalFont,
            "#b50775"
    ),
    make_text(
            "L + C-Buttons to rotate block",
            291,
            150,
	    1.1,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "L",
            133.6,
            150,
	    1.1,
            globalFont,
            "#919191"
    ),
    make_text(
            "C-Buttons",
            228.475,
            150,
	    1.1,
            globalFont,
            "#edd202"
    ),
    make_text(
            "L + X to reset block rotation",
            288.8,
            180,
	    1.1,
            globalFont,
            "#ffffff"
    ),
    make_text(
            "L",
            133.6,
            180,
	    1.1,
            globalFont,
            "#919191"
    ),
    make_text(
            "X",
            183.5,
            180,
	    1.1,
            globalFont,
            "#b50775"
    ),
    make_text(
            "Extra Notes:",
            198,
            250,
	    1.3,
            globalFont,
            "#ffffff"
    ),
    make_text(
           "Aglab cam is active when not flying.",
            325,
            280,
	    1.1,
            globalFont,
            "#ffffff"
    ),
    make_text(
           "The sparkle is used for specific surface direction.",
            378,
            310,
	    1.1,
            globalFont,
            "#ffffff"
    ),
    make_text(
           "Use /plot [#] to warp to an empty plot",
            338,
            340,
	    1.1,
            globalFont,
            "#ffffff"
    )
}

--- Converts an RGB hex code into a `Color`
--- @return Color|nil
local function get_color_format(hexColor)
    if string_find(globalHexColor, "#") == 1 and string_len(hexColor) == 7 then
        local colorHex = string.gsub(hexColor, "#", "")
        return {
            r = tonumber(string_sub(colorHex, 0, 2), 16),
            g = tonumber(string_sub(colorHex, 3, 4), 16),
            b = tonumber(string_sub(colorHex, 5, 6), 16)
        }
    end

    error("get_color_format: Color format is wrong.")
    return nil
end

--- @param text string
--- @param x number
--- @param y number
--- @param font DjuiFontType
--- @param scale number
--- @param hexColor string
--- Prints text in the center of the screen
local function print_color_text(text, x, y, scale, font, hexColor)
    local rgbTable = get_color_format(hexColor)
    if rgbTable == nil then return end

    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(font)

    local screenWidth = djui_hud_get_screen_width()
    local width = (djui_hud_measure_text(text) * 0.5) * scale

    local screenHeight = djui_hud_get_screen_height()
    local height = 64 * scale

    -- get centre of screen
    local halfWidth = screenWidth * 0.5
    local halfHeight = screenHeight * 0.5

    local xc = halfWidth - width
    local yc = halfHeight - height

    djui_hud_set_color(rgbTable.r, rgbTable.g, rgbTable.b, 255)
    djui_hud_print_text(text, xc + x, yc + y, scale)
end

--- Returns X coordinate relative to text
local function return_x(text, scale, font)
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(font)

    local screenWidth = djui_hud_get_screen_width()
    local width = (djui_hud_measure_text(text) * 0.5) * scale

    -- get center of screen
    local halfWidth = screenWidth * 0.5

    return halfWidth - width
end

--- @param scale number
--- @param font DjuiFontType
--- Returns Y coordinate relative to text
local function return_y(scale, font)
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(font)

    local screenHeight = djui_hud_get_screen_height()
    local height = 64 * scale

    -- get center of screen
    local halfHeight = screenHeight * 0.5

    return halfHeight - height
end

--- @param x number
--- @param y number
--- @param w number
--- @param h number
--- @param hexColor string
--- Renders a rectangle in the center of the screen
local function render_rect(x, y, w, h, hexColor)
    local rgbTable = get_color_format(hexColor)
    if rgbTable == nil then return end

    djui_hud_set_resolution(RESOLUTION_DJUI)

    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    local xd = x + (screenWidth * 0.5)
    local yd = y + (screenHeight * 0.5)

    local xe = x + (w * 0.5)
    local ye = y + (h * 0.5)

    local fx = xd - xe
    local fy = yd - ye

    djui_hud_set_color(rgbTable.r, rgbTable.g, rgbTable.b, 170)
    djui_hud_render_rect(fx, fy, w, h)
end

local function display_rules()
    --- @type MarioState
    local m = gMarioStates[0]
    if not welcomeMsgIsOpen then return end

    if not hasConfirmed then
        set_mario_action(m, ACT_READING_AUTOMATIC_DIALOG, 0)
    end

    render_rect(190, 120, 1368, 745, "#000000")

    -- print all texts
    for _, text in ipairs(sTexts) do
        local message = text.message:gsub("$HOSTNAME", gNetworkPlayers[network_local_index_from_global(0)].name)
        print_color_text(message, text.x, text.y, text.scale, text.font or globalFont, text.hexColor or globalHexColor)
    end

    -- get relative coordinates of OK text
    local xd = return_x("OK", globalScale, globalFont)
    local yd = return_y(globalScale, globalFont) + 360

    -- get mouse_x and mouse_y coordinates
    local mousex = djui_hud_get_mouse_x()
    local mousey = djui_hud_get_mouse_y()

    -- calculate distance between button and mouse
    -- if player presses D_PAD Down or (if mouse_hover is activated) hovers over the OK text,
    -- the window closes.
    local dist = math.sqrt(((xd - mousex) ^ 2) + (((yd + 40) - mousey) ^ 2))
    if CLOSE_ON_MOUSE_HOVER then
        if dist < 40 then
            welcomeMsgIsOpen = false
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
            if not hasConfirmed then
                set_mario_action(m, ACT_IDLE, 0)
                hasConfirmed = true
            end
        end
    end

    if (gControllers[0].buttonPressed & X_BUTTON) ~= 0 then
        welcomeMsgIsOpen = false
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
        if not hasConfirmed then
            set_mario_action(m, ACT_IDLE, 0)
            hasConfirmed = true
        end
    end
    if (gControllers[0].buttonDown & X_BUTTON) ~= 0 and (gControllers[0].buttonDown & Y_BUTTON) ~= 0 then
        disable_inputs(m, (X_BUTTON | Y_BUTTON))
    end
end

local function display_rules2()
    if welcomeMsgIsOpen then
        djui_chat_message_create("The window has already been opened. Please close it first.")
        return true
    end
    welcomeMsgIsOpen = true
    return true
end

hook_event(HOOK_ON_HUD_RENDER, display_rules)

hook_chat_command("mcinfo", "| Displays the 'info' pop-up message.", display_rules2)