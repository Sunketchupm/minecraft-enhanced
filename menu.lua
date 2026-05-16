require("src/menu/class")
local render = require("src/menu/render")
local inputs = require("src/menu/inputs")

local function hud_render_behind()
    render.hud_render_behind()
end

local function hud_render()
    render.hud_render()
end

local function before_mario_update(m)
    inputs(m)
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, hud_render_behind)
hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)