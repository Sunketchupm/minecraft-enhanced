local CommonMenu = require("../common_menu")
local Mouse = require("../mouse")

local Settings = require("class") --[[@as SettingsMenu]]

local __select_option = function (change, scroll)
    if Settings.option_index ~= -1 then
        Settings.option_index = Settings.option_index + change
        if Settings.option_index < scroll.index then
            scroll.index = Settings.option_index
        elseif Settings.option_index > Settings.rendered_max_index then
            scroll.index = scroll.index + change
        end
    else
        Settings.option_index = scroll.index
    end
    Settings.option_index = math.clamp(Settings.option_index, scroll.index, Settings.rendered_max_index)
    audio_sample_play(SOUND_MCE_MOVE, gGlobalSoundSource, 1)
end

---@param m MarioState
---@param inputs Inputs
local function handle_inputs(m, inputs)
    CommonMenu.menu_inputs(m, inputs, Settings, Settings.tab, {
        tab = function (index)
            Settings.tab = index
            Settings.option_index = 1
            Settings.rendered_max_index = 1
        end,
        scroll = function (direction)
            if direction.up then
                Settings.option_index = Settings.option_index - 1
            elseif direction.down then
                Settings.option_index = Settings.option_index + 1
            end
            Settings.option_index = math.clamp(Settings.option_index, 1, Settings.rendered_max_index)
        end,
    })

    local current_options = Settings[Settings.tab]
    local current_option = current_options[Settings.option_index]

    if inputs.stick.up and Settings.option_index > 1 then
        __select_option(-1, current_options.scroll)
    elseif inputs.stick.down and Settings.option_index < #current_options then
        __select_option(1, current_options.scroll)
    end

    if current_option then
        if Mouse.moved and Mouse.down and Mouse.pressed.left then
            inputs.buttons.pressed = inputs.buttons.pressed | A_BUTTON
        end
        current_option.action(inputs)
    end

    Settings.doing_inputs = true
    if Settings.tab == SETTINGS_TAB_BLOCK_SURFACES or
    (not Mouse.moved and inputs.buttons.down & ~(C_BUTTONS | L_TRIG | R_TRIG) == 0) or
    (Mouse.moved and not (Mouse.down.left or Mouse.down.middle)) then
        Settings.doing_inputs = false
    end

    m.controller.buttonPressed = 0
end

return handle_inputs