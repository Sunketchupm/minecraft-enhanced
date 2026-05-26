require("globals")
local Mouse = require("mouse")

local renders = {
    [MENU_TYPE_PAUSE] = require("pause/render"),
}

local behind_renders = {
    [MENU_TYPE_CREATIVE] = require("creative/render"),
    --[MENU_TYPE_WORLD] = require("world/render"),
}

-- Always rendered menus
local ControlsRender = require("controls")
local HotbarRender = require("hotbar/render")

local function on_hud_render()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    local screen_width, screen_height = djui_hud_get_screen_width(), djui_hud_get_screen_height()

    if renders[gCurrentMenu] then
        renders[gCurrentMenu](screen_width, screen_height)
    end

    if gCurrentMenu > MENU_TYPE_NONE then
        Mouse.render()
    end

    ControlsRender(screen_width, screen_height)
end

local function hud_render_behind()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    local screen_width, screen_height = djui_hud_get_screen_width(), djui_hud_get_screen_height()

    if gInBuildMode then
        HotbarRender(screen_width, screen_height)
        if behind_renders[gCurrentMenu] then
            behind_renders[gCurrentMenu](screen_width, screen_height)
        end
    end
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_event(HOOK_ON_HUD_RENDER_BEHIND, hud_render_behind)