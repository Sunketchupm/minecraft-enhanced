local Mouse = require("../mouse")

local Pause = require("class") --[[@as PauseMenu]]

---@param m MarioState
---@param inputs Inputs
local function handle_menu_inputs(m, inputs)
    if Pause.get_current_button().is_selected then
        Pause.get_current_button().selection(inputs)
        if inputs.buttons.pressed & (A_BUTTON | B_BUTTON | START_BUTTON) ~= 0 then
            Pause.get_current_button().is_selected = false
            Pause.selection_active = false
        end
        m.controller.buttonPressed = m.controller.buttonPressed &
            ~(U_JPAD | L_JPAD | D_JPAD | R_JPAD | U_CBUTTONS | L_CBUTTONS | D_CBUTTONS | R_CBUTTONS)
        return
    end

    if (inputs.stick.up or inputs.dpad.up or inputs.c_buttons.up or Mouse.scroll.y > 0) and Pause.index > 1 then
        Pause.index = Pause.index - 1
        audio_sample_play(SOUND_MCE_MOVE, gGlobalSoundSource, 1)
    elseif (inputs.stick.down or inputs.dpad.down or inputs.c_buttons.down or Mouse.scroll.y < 0) and Pause.index < #Pause[Pause.current_menu] then
        Pause.index = Pause.index + 1
        audio_sample_play(SOUND_MCE_MOVE, gGlobalSoundSource, 1)
    end

    if Mouse.pressed.left or (not Mouse.moved and inputs.buttons.pressed & A_BUTTON ~= 0 or inputs.buttons.pressed & START_BUTTON ~= 0) then
        Pause.get_current_button().action(m)
        audio_sample_play(SOUND_MCE_PRESS, gGlobalSoundSource, 1)
    elseif Mouse.pressed.right or (not Mouse.moved and inputs.buttons.pressed & B_BUTTON ~= 0) then
        if Pause.current_menu == PAUSE_MENU_MAIN then
            Pause.close_menu()
        else
            Pause.set_new_menu(PAUSE_MENU_MAIN)
        end
        audio_sample_play(SOUND_MCE_BACK, gGlobalSoundSource, 1)
    end
end

------------------------------------------------------------------

---@param m MarioState
---@param inputs Inputs
local function handle_inputs(m, inputs)
    m.freeze = 1

    if inputs.buttons.pressed & R_TRIG ~= 0 then
        djui_open_pause_menu()
        Pause.close_menu()
    end

    handle_menu_inputs(m, inputs)

    m.controller.buttonPressed = m.controller.buttonPressed & ~START_BUTTON
end

return handle_inputs