local CreativeMenu = require("../creative/class")

local Hotbar = require("class") --[[@as Hotbar]]

---@param m MarioState
---@param inputs Inputs
local function handle_inputs(m, inputs)
    if inputs.buttons.down & L_TRIG == 0 then
        if inputs.dpad.left then
            Hotbar.index = Hotbar.index - 1
            if Hotbar.index < 1 then
                Hotbar.index = HOTBAR_SIZE
            end
        elseif inputs.dpad.right then
            Hotbar.index = Hotbar.index + 1
            if Hotbar.index > HOTBAR_SIZE then
                Hotbar.index = 1
            end
        end
    end

    if gCurrentMenu == MENU_TYPE_CREATIVE and CreativeMenu.item.link then
        if inputs.stick.left then
            Hotbar.index = Hotbar.index - 1
            if Hotbar.index < 1 then
                Hotbar.index = HOTBAR_SIZE
            end
        elseif inputs.stick.right then
            Hotbar.index = Hotbar.index + 1
            if Hotbar.index > HOTBAR_SIZE then
                Hotbar.index = 1
            end
        end
    end

    if Hotbar[Hotbar.index].link then
        gCurrentItem = Hotbar[Hotbar.index].link.item
    else
        gCurrentItem = nil
    end

    m.controller.buttonPressed = m.controller.buttonPressed & ~(L_JPAD | R_JPAD)
end

return handle_inputs