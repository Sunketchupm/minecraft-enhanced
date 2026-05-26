local Mouse = require("mouse")

------------------------------------------------------------------------------------------------

---@class Inputs
    ---@field stick Direction
    ---@field dpad Direction
    ---@field c_buttons Direction
    ---@field buttons { pressed: integer, down: integer, released: integer }

---@type Inputs
local sInputs = {
    stick = { up = false, left = false, down = false, right = false },
    dpad = { up = false, left = false, down = false, right = false },
    c_buttons = { up = false, left = false, down = false, right = false },
    buttons = { pressed = 0, down = 0, released = 0 }
}

local sPrevCSD = { up = false, left = false, down = false, right = false }
local sControlStickHoldTimer = 0
local sControlStickMovementTimer = 0
local sMovementIsHeld = false

---@param m MarioState
local function handle_control_stick_inputs(m)
    local controller = m.controller
    if not (controller.stickY <= 30 and controller.stickY >= -30 and controller.stickX >= -30 and controller.stickX <= 30) then
        sControlStickHoldTimer = sControlStickHoldTimer + 1
    else
        sControlStickHoldTimer = 0
        sMovementIsHeld = false
    end
    if sControlStickHoldTimer >= 10 then
        if sControlStickMovementTimer < 2 then
            sControlStickMovementTimer = sControlStickMovementTimer + 1
            sMovementIsHeld = false
        else
            sControlStickMovementTimer = 0
            sMovementIsHeld = true
        end
    end
    if not sInputs.stick.up and controller.stickY <= 30 then sPrevCSD.up = false end
    if not sInputs.stick.down and controller.stickY >= -30 then sPrevCSD.down = false end
    if not sInputs.stick.left and controller.stickX >= -30 then sPrevCSD.left = false end
    if not sInputs.stick.right and controller.stickX <= 30 then sPrevCSD.right = false end
    if (sMovementIsHeld or not sPrevCSD.up) and controller.stickY > 30 then sInputs.stick.up = true sPrevCSD.up = true Mouse.moved = false else sInputs.stick.up = false end
    if (sMovementIsHeld or not sPrevCSD.down) and controller.stickY < -30 then sInputs.stick.down = true sPrevCSD.down = true Mouse.moved = false else sInputs.stick.down = false end
    if (sMovementIsHeld or not sPrevCSD.left) and controller.stickX < -30 then sInputs.stick.left = true sPrevCSD.left = true Mouse.moved = false else sInputs.stick.left = false end
    if (sMovementIsHeld or not sPrevCSD.right) and controller.stickX > 30 then sInputs.stick.right = true sPrevCSD.right = true Mouse.moved = false else sInputs.stick.right = false end
end

local sDpadPrevCSD = { up = false, left = false, down = false, right = false }
local sDpadHoldTimer = 0
local sDpadMovementTimer = 0
local sDpadIsHeld = false

---@param m MarioState
local function handle_dpad_inputs(m)
    local down = m.controller.buttonDown
    if down & (U_JPAD | L_JPAD | D_JPAD | R_JPAD) ~= 0 then
        sDpadHoldTimer = sDpadHoldTimer + 1
    else
        sDpadHoldTimer = 0
        sDpadIsHeld = false
    end
    if sDpadHoldTimer >= 10 then
        if sDpadMovementTimer < 2 then
            sDpadMovementTimer = sDpadMovementTimer + 1
            sDpadIsHeld = false
        else
            sDpadMovementTimer = 0
            sDpadIsHeld = true
        end
    end
    if not sInputs.dpad.up and down & U_JPAD == 0 then sDpadPrevCSD.up = false end
    if not sInputs.dpad.down and down & D_JPAD == 0 then sDpadPrevCSD.down = false end
    if not sInputs.dpad.left and down & L_JPAD == 0 then sDpadPrevCSD.left = false end
    if not sInputs.dpad.right and down & R_JPAD == 0 then sDpadPrevCSD.right = false end
    if (sDpadIsHeld or not sDpadPrevCSD.up) and down & U_JPAD ~= 0 then sInputs.dpad.up = true sDpadPrevCSD.up = true Mouse.moved = false else sInputs.dpad.up = false end
    if (sDpadIsHeld or not sDpadPrevCSD.down) and down & D_JPAD ~= 0  then sInputs.dpad.down = true sDpadPrevCSD.down = true Mouse.moved = false else sInputs.dpad.down = false end
    if (sDpadIsHeld or not sDpadPrevCSD.left) and down & L_JPAD ~= 0  then sInputs.dpad.left = true sDpadPrevCSD.left = true Mouse.moved = false else sInputs.dpad.left = false end
    if (sDpadIsHeld or not sDpadPrevCSD.right) and down & R_JPAD ~= 0 then sInputs.dpad.right = true sDpadPrevCSD.right = true Mouse.moved = false else sInputs.dpad.right = false end
end

local sCButtonPrevCSD = { up = false, left = false, down = false, right = false }
local sCButtonHoldTimer = 0
local sCButtonMovementTimer = 0
local sCButtonMovementIsHeld = false

---@param m MarioState
local function handle_c_stick_inputs(m)
    local down = m.controller.buttonDown
    if down & C_BUTTONS ~= 0 then
        sCButtonHoldTimer = sCButtonHoldTimer + 1
    else
        sCButtonHoldTimer = 0
        sCButtonMovementIsHeld = false
    end
    if sCButtonHoldTimer >= 10 then
        if sCButtonMovementTimer < 2 then
            sCButtonMovementTimer = sCButtonMovementTimer + 1
            sCButtonMovementIsHeld = false
        else
            sCButtonMovementTimer = 0
            sCButtonMovementIsHeld = true
        end
    end
    if not sInputs.c_buttons.up and down & U_CBUTTONS == 0 then sCButtonPrevCSD.up = false end
    if not sInputs.c_buttons.down and down & D_CBUTTONS == 0 then sCButtonPrevCSD.down = false end
    if not sInputs.c_buttons.left and down & L_CBUTTONS == 0 then sCButtonPrevCSD.left = false end
    if not sInputs.c_buttons.right and down & R_CBUTTONS == 0 then sCButtonPrevCSD.right = false end
    if (sCButtonMovementIsHeld or not sCButtonPrevCSD.up) and down & U_CBUTTONS ~= 0 then sInputs.c_buttons.up = true sCButtonPrevCSD.up = true Mouse.moved = false else sInputs.c_buttons.up = false end
    if (sCButtonMovementIsHeld or not sCButtonPrevCSD.down) and down & D_CBUTTONS ~= 0  then sInputs.c_buttons.down = true sCButtonPrevCSD.down = true Mouse.moved = false else sInputs.c_buttons.down = false end
    if (sCButtonMovementIsHeld or not sCButtonPrevCSD.left) and down & L_CBUTTONS ~= 0  then sInputs.c_buttons.left = true sCButtonPrevCSD.left = true Mouse.moved = false else sInputs.c_buttons.left = false end
    if (sCButtonMovementIsHeld or not sCButtonPrevCSD.right) and down & R_CBUTTONS ~= 0 then sInputs.c_buttons.right = true sCButtonPrevCSD.right = true Mouse.moved = false else sInputs.c_buttons.right = false end
end

----------------------------------------------------

local Creative = require("creative/class")

local sMenuInputs = {
    [MENU_TYPE_CREATIVE] = require("creative/inputs"),
    [MENU_TYPE_PAUSE] = require("pause/inputs"),
}

local HotbarInputs = require("hotbar/inputs")

---@param m MarioState
local function handle_menuless_inputs(m)
    if gInBuildMode then
        if gCurrentMenu == MENU_TYPE_CLOSED and sInputs.buttons.pressed & X_BUTTON ~= 0 then
            gCurrentMenu = MENU_TYPE_CREATIVE
            if sInputs.buttons.down & L_TRIG ~= 0 then
                Creative.tab = CREATIVE_TAB_ITEM_SETTINGS
            end
            sInputs.buttons.pressed = sInputs.buttons.pressed & ~X_BUTTON
        end

        HotbarInputs(m, sInputs)
    end

    if gCurrentMenu ~= MENU_TYPE_PAUSE and sInputs.buttons.pressed & START_BUTTON ~= 0 then
        gCurrentMenu = MENU_TYPE_PAUSE
        sInputs.buttons.pressed = sInputs.buttons.pressed & ~START_BUTTON
    end
end

---@param m MarioState
local function before_mario_update(m)
    if m.playerIndex ~= 0 then return end

    Mouse.get_inputs()
    handle_control_stick_inputs(m)
    handle_dpad_inputs(m)
    handle_c_stick_inputs(m)
    sInputs.buttons.pressed = m.controller.buttonPressed
    sInputs.buttons.down = m.controller.buttonDown
    sInputs.buttons.released = m.controller.buttonReleased

    handle_menuless_inputs(m)

    if sMenuInputs[gCurrentMenu] then
        sMenuInputs[gCurrentMenu](m, sInputs)
    end
end

hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)