local Mouse = require("mouse")
local ItemGrid = require("item_grid")
local Scroll = require("scroll")
local Hotbar = require("hotbar")
local Buttons = require("buttons")
local PauseInputs = require("pause/inputs")

------------------------------------------------------------------------------------------------

-- Control stick direction
gCSD = { up = false, left = false, down = false, right = false }
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
    if not gCSD.up and controller.stickY <= 30 then sPrevCSD.up = false end
    if not gCSD.down and controller.stickY >= -30 then sPrevCSD.down = false end
    if not gCSD.left and controller.stickX >= -30 then sPrevCSD.left = false end
    if not gCSD.right and controller.stickX <= 30 then sPrevCSD.right = false end
    if (sMovementIsHeld or not sPrevCSD.up) and controller.stickY > 30 then gCSD.up = true sPrevCSD.up = true Mouse.moved = false else gCSD.up = false end
    if (sMovementIsHeld or not sPrevCSD.down) and controller.stickY < -30 then gCSD.down = true sPrevCSD.down = true Mouse.moved = false else gCSD.down = false end
    if (sMovementIsHeld or not sPrevCSD.left) and controller.stickX < -30 then gCSD.left = true sPrevCSD.left = true Mouse.moved = false else gCSD.left = false end
    if (sMovementIsHeld or not sPrevCSD.right) and controller.stickX > 30 then gCSD.right = true sPrevCSD.right = true Mouse.moved = false else gCSD.right = false end
end

gCButtonCSD = {up = false, left = false, down = false, right = false}
local sCButtonPrevCSD = {up = false, left = false, down = false, right = false}
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
    if not gCButtonCSD.up and down & U_CBUTTONS == 0 then sCButtonPrevCSD.up = false end
    if not gCButtonCSD.down and down & D_CBUTTONS == 0 then sCButtonPrevCSD.down = false end
    if not gCButtonCSD.left and down & L_CBUTTONS == 0 then sCButtonPrevCSD.left = false end
    if not gCButtonCSD.right and down & R_CBUTTONS == 0 then sCButtonPrevCSD.right = false end
    if (sCButtonMovementIsHeld or not sCButtonPrevCSD.up) and down & U_CBUTTONS ~= 0 then gCButtonCSD.up = true sCButtonPrevCSD.up = true Mouse.moved = false else gCButtonCSD.up = false end
    if (sCButtonMovementIsHeld or not sCButtonPrevCSD.down) and down & D_CBUTTONS ~= 0  then gCButtonCSD.down = true sCButtonPrevCSD.down = true Mouse.moved = false else gCButtonCSD.down = false end
    if (sCButtonMovementIsHeld or not sCButtonPrevCSD.left) and down & L_CBUTTONS ~= 0  then gCButtonCSD.left = true sCButtonPrevCSD.left = true Mouse.moved = false else gCButtonCSD.left = false end
    if (sCButtonMovementIsHeld or not sCButtonPrevCSD.right) and down & R_CBUTTONS ~= 0 then gCButtonCSD.right = true sCButtonPrevCSD.right = true Mouse.moved = false else gCButtonCSD.right = false end
end

----------------------------------------------------

---@param m MarioState
---@param scroll Scroll
---@param ret any
local function surface_tab_custom_handler(m, scroll, ret)
    if (Mouse.moved and Mouse.pressed.left and Mouse.menu.hoveringSurfaceTip) or (not Mouse.moved and m.controller.buttonPressed & A_BUTTON ~= 0) then
        local message = scroll.elements[scroll.index]
        on_set_surface_chat_command(message)
        audio_sample_play(SOUND_MCE_PRESS, gGlobalSoundSource, 1)
    end
end

----------------------------------------------------

local function on_change_tab_input()
    Mouse.menu.prevItemIndex = 0
    Hotbar.clear = 0
    Hotbar.cooldown = 0
    Mouse.menu.clickedTabIndex = 0
    audio_sample_play(SOUND_MCE_MOVE, gGlobalSoundSource, 1)
end

---@param m MarioState
local function handle_change_tab_inputs(m)
    local pressed = m.controller.buttonPressed
    if pressed & L_TRIG ~= 0 then
        gCurrentTab = gCurrentTab - 1
        if gCurrentTab < 1 then
            gCurrentTab = TAB_COUNT
        end
        on_change_tab_input()
    elseif pressed & R_TRIG ~= 0 then
        gCurrentTab = gCurrentTab + 1
        if gCurrentTab > TAB_COUNT then
            gCurrentTab = 1
        end
        on_change_tab_input()
    elseif Mouse.menu.clickedTabIndex > 0 then
        gCurrentTab = Mouse.menu.clickedTabIndex
        on_change_tab_input()
    end
end

---@param m MarioState
local function handle_close_menu_inputs(m)
    local pressed = m.controller.buttonPressed
    if pressed & START_BUTTON ~= 0 or not Mouse.moved and pressed & X_BUTTON ~= 0 or Mouse.moved and Mouse.pressed.right then
        gMenu.open = false
        Hotbar.clear = 0
        Hotbar.cooldown = 0
        Mouse.menu.prevItemIndex = 0
    end
end

local sTabInputHandlers = {
    [TAB_INPUT_TYPE_ITEM_GRID] = ItemGrid.inputs,
    [TAB_INPUT_TYPE_SCROLL] = Scroll.inputs,
    ---@param buttons Button
    [TAB_INPUT_TYPE_BUTTONS] = function (m, buttons, stick, c_stick) end,
}

local sTabCustomHandlers = {
    [TAB_SURFACE_TYPES] = surface_tab_custom_handler
}

---@param m MarioState
---@param tab MenuTab
local function handle_menu_inputs(m, tab)
    if Mouse.moved and (m.controller.buttonPressed ~= 0 or m.controller.stickMag > 0) and not Mouse.has_moved() then
        Mouse.moved = false
    end

    handle_close_menu_inputs(m)
    handle_change_tab_inputs(m)
    local ret = sTabInputHandlers[tab.input_type](m, tab.vars, gCSD, gCButtonCSD)
    if sTabCustomHandlers[tab.index] then
        sTabCustomHandlers[tab.index](m, tab.vars --[[@as any]], ret)
    end
    m.controller.buttonPressed = 0
end

----------------------------------------------------

---@param m MarioState
local function before_mario_update(m)
    if m.playerIndex ~= 0 then return end

    Mouse.get_inputs()
    handle_control_stick_inputs(m)
    handle_c_stick_inputs(m)

    if gPauseMenu.is_paused then
        PauseInputs(m)
        return
    end

    if not gMenu.open and m.controller.buttonPressed & START_BUTTON ~= 0 then
        gPauseMenu.is_paused = true
        m.controller.buttonPressed = m.controller.buttonPressed & ~START_BUTTON
        return
    end

    if not gCanBuild then
        camera_romhack_allow_dpad_usage(1)
        camera_config_enable_dpad(true)
        return
    end

    if not gMenu.open and m.controller.buttonPressed & X_BUTTON ~= 0 then
        gMenu.open = true
        return
    end

    local current_tab = gMenu[gCurrentTab]
    if not current_tab then return end

    Hotbar.inputs(m)
    if gMenu.open then
        m.freeze = 1
        handle_menu_inputs(m, current_tab)
    else
        if gCurrentItemLink then
            gCurrentItemLink.held = false
        end
    end

    camera_romhack_allow_dpad_usage(0)
    camera_config_enable_dpad(false)

    local hotbar_item = Hotbar.items[Hotbar.index]
    if hotbar_item then
        gCurrentItem = hotbar_item.item
    end
end

return before_mario_update
