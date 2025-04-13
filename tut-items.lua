-- name: rules2
-- description: Displays rules/welcome message to anyone who connects to your server

-- false: Window won't close when mouse hovers over the OK button, only Buttons work
-- true: Window will close when mouse hovers over the OK button, alternatively buttons work too
local CLOSE_ON_MOUSE_HOVER = false

-- text-related options
-- sets font, scale (of text) and color for all texts;
local globalFont = FONT_NORMAL
local scale = 1.4
local color = "#000000"

local switched = false
local hasConfirmed = false
function displayrules()
    hostnum = network_local_index_from_global(0)
    host = gNetworkPlayers[hostnum]

    -- texts are written inside here.
    --[[ format:
    {
        string,
        x,
        y,
        font,
        scale,
        color (color in "#xxxxxx" format pls)
    }
--]]
    texts = { 
	{
            "ITEMS:",
            0,
            -170,
            globalFont,
            3,
            "#ffffff"
        },
	{
            "___________________________________________",
            0,
            -225,
            globalFont,
            1.0,
            "#ffffff"
    	},
	{
            "Items can be used in place for the standard",
            0,
            -185,
            globalFont,
            1.1,
            "#ffffff"
    	},
	{
            "blocks to allow for more diversity in level",
            0,
            -155,
            globalFont,
            1.1,
            "#ffffff"
    	},
	{
            "creation. Currently the list is small, but will",
            0,
            -125,
            globalFont,
            1.1,
            "#ffffff"
    	},
	{
            "gradually increase as the mod develops.",
            0,
            -95,
            globalFont,
            1.1,
            "#ffffff"
    	},
	{
            "___________________________________________",
            0,
            -80,
            globalFont,
            1.0,
            "#ffffff"
    	},
	{
            "Block",
            -230,
            -40,
            globalFont,
            1.1,
            "#ffffff"
    	},
	{
            "The default item used for building.",
            -66,
            -5,
            globalFont,
            1.1,
            "#ffffff"
    	},
	{
            "Exclamation",
            -193,
            40,
            globalFont,
            1.1,
            "#fff780"
    	},
	{
            "A ! box that can spawn certain items such as:",
            -3,
            75,
            globalFont,
            1.1,
            "#ffffff"
    	},
	{
            "Wing",
            -200,
            110,
            globalFont,
            1.1,
            "#ff0000"
    	},
	{
            "Vanish",
            -75,
            110,
            globalFont,
            1.1,
            "#1d16e0"
    	},
	{
            "Metal",
            75,
            110,
            globalFont,
            1.1,
            "#3c9e0b"
    	},

	{
            "Shell",
            200,
            110,
            globalFont,
            1.1,
            "#82ff80"
    	},
	{
            "Use the /surf command to change the box item.",
            -2,
            145,
            globalFont,
            1.1,
            "#ffffff"
    	},
	{
            "Star",
            -238,
            190,
            globalFont,
            1.1,
            "#ffff00"
    	},
	{	
            "A collectible star that isn't removed on contact.",
            2,
            225,
            globalFont,
            1.1,
            "#ffffff"
    	},
	{
            "___________________________________________",
            0,
            320,
            globalFont,
            1.0,
            "#ffffff"
    	},

    	{
            "Press A to close",
            80,
            385,
            globalFont,
            1.0,
            "#ffffff"
        },
        {
            "OK",
            210,
            360,
            FONT_MENU,
            1.1,
            "#ff0000"
        }
    }

    -----------------------------------------
    -- Main code:
    local m = gMarioStates[0]
    if (switched == true) then
        if (hasConfirmed == false) then
            set_mario_action(m, ACT_READING_AUTOMATIC_DIALOG, 0)
        end
        -- render the rectangle.
        renderRect(190, 120, FONT_MENU, 550, 720, "#000000")

        -- print all texts
        for _, v in ipairs(texts) do
            printColorText(v[1], v[2], v[3], v[4], v[5], v[6])
        end

        -- get relative coordinates of OK text
        local xd = returnX("OK", scale, globalFont)
        local yd = returnY("OK", scale, globalFont) + 360

        -- get mouse_x and mouse_y coordinates
        local mousex = djui_hud_get_mouse_x()
        local mousey = djui_hud_get_mouse_y()

        -- calculate distance between button and mouse
        -- if player presses D_PAD Down or (if mouse_hover is activated) hovers over the OK text,
        -- the window closes.
        local dist = math.sqrt(((xd - mousex) ^ 2) + (((yd + 40) - mousey) ^ 2))
        if (CLOSE_ON_MOUSE_HOVER) then
            if (dist < 40) then
                switched = false
                play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
                if (hasConfirmed == false) then
                    set_mario_action(m, ACT_IDLE, 0)
                    hasConfirmed = true
                end
            end
        end

        if (m.controller.buttonPressed & A_BUTTON) ~= 0 then
            switched = false
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
            if (hasConfirmed == false) then
                set_mario_action(m, ACT_IDLE, 0)
                hasConfirmed = true
            end
        end
    end
end

-- prints text in the center of the screen
function printColorText(text, x, y, font, scale, color)
    local r, g, b, a = 0, 0, 0, 0

    local rgbtable = checkColorFormat(color)
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(font)

    local screenWidth = djui_hud_get_screen_width()
    local width = (djui_hud_measure_text(text) / 2) * scale

    local screenHeight = djui_hud_get_screen_height()
    local height = 64 * scale

    -- get centre of screen
    local halfwidth = screenWidth / 2
    local halfheight = screenHeight / 2

    local xc = halfwidth - width
    local yc = halfheight - height

    djui_hud_set_color(rgbtable.r, rgbtable.g, rgbtable.b, 255)
    djui_hud_print_text(text, xc + x, yc + y, scale)
end

-- returns X coordinate relative to text
function returnX(text, scale, font)
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(font)

    local screenWidth = djui_hud_get_screen_width()
    local width = (djui_hud_measure_text(text) / 2) * scale

    local screenHeight = djui_hud_get_screen_height()
    local height = 64 * scale

    -- get centre of screen
    local halfwidth = screenWidth / 2
    local halfheight = screenHeight / 2

    local xc = halfwidth - width
    local yc = halfheight - height

    return xc
end

-- returns Y coordinate relative to text
function returnY(text, scale, font)
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(font)

    local screenWidth = djui_hud_get_screen_width()
    local width = (djui_hud_measure_text(text) / 2) * scale

    local screenHeight = djui_hud_get_screen_height()
    local height = 64 * scale

    -- get centre of screen
    local halfwidth = screenWidth / 2
    local halfheight = screenHeight / 2

    local xc = halfwidth - width
    local yc = halfheight - height

    return yc
end

-- renders a rectangle in the center of the screen
function renderRect(x, y, font, w, h, color)
    local rgbtable = checkColorFormat(color)
    djui_hud_set_resolution(RESOLUTION_DJUI)
    --djui_hud_set_font(font);

    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()

    -- get center
    local halfwidth = screenWidth / 2
    local halfheight = screenHeight / 2

    local xc = x + halfwidth
    local yc = y + halfheight

    local xx = xc - halfwidth
    local yy = yc - halfheight

    local xd = x + (screenWidth / 2)
    local yd = y + (screenHeight / 2)

    local xe = x + (w / 2)
    local ye = y + (h / 2)

    local fx = xd - xe
    local fy = yd - ye

    djui_hud_set_color(rgbtable.r, rgbtable.g, rgbtable.b, 170)
    djui_hud_render_rect(fx, fy, w, h)
end

function displayrules2()
    if (switched) then
        djui_chat_message_create("The window has already been opened. Please close it first.")
        return true
    end
    switched = true
    return true
end

function checkColorFormat(rgbhex)
    local r, g, b, a = 0, 0, 0, 0

    local d = string.find(color, "#")
    if ((d == 1) and (string.len(rgbhex) == 7)) then
        local colorhex = string.gsub(rgbhex, "#", "")
        r = string.sub(colorhex, 0, 2)
        g = string.sub(colorhex, 3, 4)
        b = string.sub(colorhex, 5, 6)

        r = tonumber(r, 16)
        g = tonumber(g, 16)
        b = tonumber(b, 16)
        return {r = r, g = g, b = b}
    else
        print("Color format is wrong.")
        return
    end
end

hook_event(HOOK_ON_HUD_RENDER, displayrules)
hook_chat_command("titem", "| Displays the 'items' tutorial message.", displayrules2)