require("src/menu/class")
local render = require("src/menu/render")
local inputs = require("src/menu/inputs")

hook_event(HOOK_ON_HUD_RENDER_BEHIND, render)
hook_event(HOOK_BEFORE_MARIO_UPDATE, inputs)