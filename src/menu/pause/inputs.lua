require("class")
local Mouse = require("../mouse")

---@param m MarioState
local function handle_menu_inputs(m)
    local pressed = m.controller.buttonPressed

    local input = {
        up = pressed & U_JPAD ~= 0 or gCSD.up or Mouse.scroll.y > 0,
        left = pressed & L_JPAD ~= 0 or gCSD.left or Mouse.scroll.x < 0,
        down = pressed & D_JPAD ~= 0 or gCSD.down or Mouse.scroll.y < 0,
        right = pressed & R_JPAD ~= 0 or gCSD.right or Mouse.scroll.x > 0,
    }
    if gPauseMenu.get_current_button().is_selected then
        gPauseMenu.get_current_button().selection(input)
        if pressed & (A_BUTTON | B_BUTTON | START_BUTTON) ~= 0 then
            gPauseMenu.get_current_button().is_selected = false
        end
        return
    end

    if input.up and gPauseMenu.v_index > 1 then
        gPauseMenu.v_index = gPauseMenu.v_index - 1
    elseif input.down and gPauseMenu.v_index < #gPauseMenu[gPauseMenu.current_menu][gPauseMenu.h_index] then
        gPauseMenu.v_index = gPauseMenu.v_index + 1
    end

    if input.left and gPauseMenu.h_index > 1 then
        gPauseMenu.h_index = gPauseMenu.h_index - 1
    elseif input.right and gPauseMenu.h_index < #gPauseMenu[gPauseMenu.current_menu] then
        gPauseMenu.h_index = gPauseMenu.h_index + 1
    end

    if Mouse.pressed.left or (not Mouse.moved and pressed & A_BUTTON ~= 0 or pressed & START_BUTTON ~= 0) then
        gPauseMenu.get_current_button().action(m)
    elseif Mouse.pressed.right or (not Mouse.moved and pressed & B_BUTTON ~= 0) then
        gPauseMenu.v_index = 1
        if gPauseMenu.current_menu == PAUSE_MENU_MAIN then
            gPauseMenu.is_paused = false
        else
            set_new_menu(PAUSE_MENU_MAIN)
        end
    end
end

------------------------------------------------------------------

---@param m MarioState
local function before_mario_update(m)
    m.freeze = 1

    local pressed = m.controller.buttonPressed
    if pressed & R_TRIG ~= 0 then
        djui_open_pause_menu()
    end

    handle_menu_inputs(m)

    m.controller.buttonPressed = m.controller.buttonPressed & ~START_BUTTON
end

return before_mario_update