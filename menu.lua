require("src/menu/class")
local render = require("src/menu/render")
local inputs = require("src/menu/inputs")

local sHideHud = false

local function on_hud_render_behind()
    if sHideHud then
        hud_hide()
        return
    end
    render()
end

local function before_mario_update(m)
    if sHideHud then return end
    inputs(m)
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, on_hud_render_behind)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)

hook_mod_menu_checkbox("Hide Hud", false, function (_, on)
    sHideHud = on
    if not on then
        hud_show()
    end
end)