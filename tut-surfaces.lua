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
            "SURFACE TYPES",
            -510,
            -235,
            globalFont,
            2,
            "#ffffff"
        },
	{
            "_______________________________________________________________________________________",
            0,
            -240,
            globalFont,
            1.3,
            "#ffffff"
    	},
	{
            "|",
            -345,
            -210,
            globalFont,
            2.5,
            "#ffffff"
    	},

	{
            "Active surfaces apply to the blocks you place. Type /surf none to reset the surface type.",
            125,
            -283,
            globalFont,
            1,
            "#ffffff"
    	},
	{
            "Lava",
            -640,
            -220,
            globalFont,
            0.9,
            "#ff0000"
    	},
	{
            "Deals 3 damage, bounces player on contact.",
            -459,
            -190,
            globalFont,
            0.9,
            "#ffffff"
    	},
	{
            "Quicksand",
            -621,
            -155,
            globalFont,
            0.9,
            "#c9ab79"
    	},
	{
            "Sinks the player, killing them.",
            -520,
            -125,
            globalFont,
            0.9,
            "#ffffff"
    	},
	{
            "Shallowsand",
            -613,
            -90,
            globalFont,
            0.9,
            "#bf7908"
    	},
	{
            "Sinks the player, restricting movement.",
            -478,
            -60,
            globalFont,
            0.9,
            "#ffffff"
    	},
	{
            "Slippery",
            -629,
            -25,
            globalFont,
            0.9,
            "#d9c9ff"
    	},
	{
            "Causes slipperiness. Can kick and framewalk.",
            -453,
            5,
            globalFont,
            0.9,
            "#ffffff"
    	},
	{
            "Not Slippery",
            -610,
            40,
            globalFont,
            0.9,
            "#6d77ab"
    	},
	{
            "Disables slipperiness.",
            -560,
            70,
            globalFont,
            0.9,
            "#ffffff"
    	},
	{
            "Very Slippery",
            -606,
            105,
            globalFont,
            0.9,
            "#bac6ff"
    	},
	{
            "Causes slipperiness. Cannot kick or framewalk.",
            -447,
            135,
            globalFont,
            0.9,
            "#ffffff"
    	},
	{
            "Hangable",
            -626,
            170,
            globalFont,
            0.9,
            "#709957"
    	},
	{
            "Allows ceiling hanging while holding A.",
            -482,
            200,
            globalFont,
            0.9,
            "#ffffff"
    	},
	{
            "Death",
            -640,
            235,
            globalFont,
            0.9,
            "#000000"
    	},
	{
            "Kills players 10.25 blocks above its surface.",
            -451,
            265,
            globalFont,
            0.9,
            "#ffffff"
    	},
	{
            "Vanish",
            -635,
            300,
            globalFont,
            0.9,
            "#1d16e0"
    	},
	{
            "Allows players to pass through with a vanish cap.",
            -431,
            330,
            globalFont,
            0.9,
            "#ffffff"
    	},
	{
            "NoCol",
            -637,
            365,
            globalFont,
            0.9,
            "#ffffff"
    	},
	{
            "Disables all collision on blocks.",
            -517,
            395,
            globalFont,
            0.9,
            "#ffffff"
    	},
	{
            "NoFall",
            -160,
            -220,
            globalFont,
            0.9,
            "#ffffff"
    	},
	{
            "Prevents all fall damage.",
            -68,
            -190,
            globalFont,
            0.9,
            "#ffffff"
    	},
	{
            "Checkpoint",
            -144,
            -155,
            globalFont,
            0.9,
            "#28d102"
    	},
    	{
            "Activates a checkpoint when idle.",
            -33,
            -125,
            globalFont,
            0.9,
            "#ffffff"
        },
	{
            "Heal",
            -171,
            -90,
            globalFont,
            0.9,
            "#ff78bb"
    	},
    	{
            "Quickly heals the player.",
            -73,
            -60,
            globalFont,
            0.9,
            "#ffffff"
        },
	{
            "Bounce",
            -161,
            -25,
            globalFont,
            0.9,
            "#00ffff"
    	},
    	{
            "Bounces the player back on all sides.",
            -18,
            5,
            globalFont,
            0.9,
            "#ffffff"
        },
	{
            "Boost",
            -165,
            40,
            globalFont,
            0.9,
            "#ff00ff"
    	},
    	{
            "NoCol block that increases speed.",
            -33,
            70,
            globalFont,
            0.9,
            "#ffffff"
        },
	{
            "Firsty",
            -161,
            105,
            globalFont,
            0.9,
            "#04c7ba"
    	},
    	{
            "Maintains speed with every wallkick.",
            -19,
            135,
            globalFont,
            0.9,
            "#ffffff"
        },
	{
            "Widekick",
            -151,
            170,
            globalFont,
            0.9,
            "#895dc2"
    	},
    	{
            "Allows wallkicks regardless of angle.",
            -17,
            200,
            globalFont,
            0.9,
            "#ffffff"
        },
	{
            "Anykick",
            -157,
            235,
            globalFont,
            0.9,
            "#fc7303"
    	},
    	{
            "Allows wallkicks after any bonk.",
            -38,
            265,
            globalFont,
            0.9,
            "#ffffff"
        },
	{
            "Jumpless",
            -153,
            300,
            globalFont,
            0.9,
            "#0357ff"
    	},
    	{
            "Prevents the usage of the A button.",
            -20,
            330,
            globalFont,
            0.9,
            "#ffffff"
        },
	{
            "Conveyor",
            -152,
            365,
            globalFont,
            0.9,
            "#919191"
    	},
	{
            "Moves players along the block. Hangable.",
            -3,
            395,
            globalFont,
            0.9,
            "#ffffff"
    	},
	{
            "Breakable",
            215,
            -220,
            globalFont,
            0.9,
            "#fcbd35"
    	},
	{
            "Enables block breaking. Respawns after 10 seconds.",
            413,
            -190,
            globalFont,
            0.9,
            "#ffffff"
    	},
	{
            "Shrinking",
            210,
            -155,
            globalFont,
            0.9,
            "#0e9104"
    	},
	{
            "Gradully shrinks on contact. Respawns after 5 seconds.",
            427,
            -125,
            globalFont,
            0.9,
            "#ffffff"
        },
	{
            "Capless",
            203,
            -90,
            globalFont,
            0.9,
            "#ffffff"
    	},
    	{
            "Disables all caps for players above its floor.",
            382,
            -60,
            globalFont,
            0.9,
            "#ffffff"
        },
	{
            "Wallkickless",
            222,
            -25,
            globalFont,
            0.9,
            "#d9d9d9"
    	},
    	{
            "Prevents wallkicks.",
            267,
            5,
            globalFont,
            0.9,
            "#ffffff"
        },
	{
            "Dash",
            191,
            40,
            globalFont,
            0.9,
            "#ff4a03"
    	},
    	{
            "Increases running speed significantly.",
            350,
            70,
            globalFont,
            0.9,
            "#ffffff"
        },
	{
            "Jump Pad",
            211,
            105,
            globalFont,
            0.9,
            "#fae20c"
    	},
    	{
            "Increases jump height to 6 blocks.",
            334,
            135,
            globalFont,
            0.9,
            "#ffffff"
        },
	{
            "Toxic",
            192,
            170,
            globalFont,
            0.9,
            "#688c0d"
    	},
	{
            "NoCol block that gradually decreases health.",
            378,
            200,
            globalFont,
            0.9,
            "#ffffff"
        },
	{
            "X to close",
            631,
            -311,
            globalFont,
            0.9,
            "#ffffff"
    	},

        {
            "OK",
            620,
            -288,
            FONT_MENU,
           0.9,
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
        renderRect(190, 120, FONT_MENU, 1368, 745, "#000000")

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

        if (m.controller.buttonPressed & X_BUTTON) ~= 0 then
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
hook_chat_command("surftypes", "| Displays the 'surfaces' tutorial message.", displayrules2)