local sInvertScroll = false

------------------------------------------------------------------------------------------------

gMouse = {
    moved = false,
    prev = { x = 0, y = 0 },
    pos = { x = 0, y = 0 },
    pressed = { left = false, right = false, middle = false },
    --held = { left = false, right = false, middle = false },
    released = { left = false, right = false, middle = false },
    scroll = 0,
    menu = {
        prevItemIndex = 1,
        clickedTabIndex = 0,
        hoveringSurfaceTip = false,
    }
}

local function handle_mouse_input()
    gMouse.pressed.left = djui_hud_get_mouse_buttons_pressed() == 1
    gMouse.pressed.right = djui_hud_get_mouse_buttons_pressed() == 4
    gMouse.scroll = djui_hud_get_mouse_scroll_y()
    --s_mouse_click_held = djui_hud_get_mouse_buttons_down() == 1
    gMouse.released.left = djui_hud_get_mouse_buttons_released() == 1
    --[[
    if mouse_click_held then
        mouse_hold_timer = mouse_hold_timer + 1
    else
        mouse_hold_timer = 0
    end
    ]]

    if gMouse.pressed.left or gMouse.pressed.right or gMouse.scroll ~= 0 or gMouse.released.left or
        djui_hud_get_raw_mouse_x() > 0 or djui_hud_get_raw_mouse_y() > 0 then

        gMouse.moved = true
    end
end

----------------------------------------------------

local function on_set_hotbar_item()
    local item = gMenu.hotbar.items[gMenu.hotbar.index].item
    local params = item.params
    local size = params.size
    if not item or not params or not size then return end
    vec3f_copy(gGridSize, size)
    vec3f_mul(gGridSize, GRID_SIZE_DEFAULT)
    gOutlineGridYOffset = 0
end

---@param m MarioState
local function handle_hotbar_inputs(m)
    if m.controller.buttonDown & L_TRIG ~= 0 then return end

    if m.controller.buttonPressed & L_JPAD ~= 0 then
        gMenu.hotbar.index = gMenu.hotbar.index - 1
        if gMenu.hotbar.index < 1 then
            gMenu.hotbar.index = HOTBAR_SIZE
        end
        if gMenu.hotbar.items[gMenu.hotbar.index] and gMenu.hotbar.items[gMenu.hotbar.index].item then
            on_set_hotbar_item()
        end
    elseif m.controller.buttonPressed & R_JPAD ~= 0 then
        gMenu.hotbar.index = gMenu.hotbar.index + 1
        if gMenu.hotbar.index > HOTBAR_SIZE then
            gMenu.hotbar.index = 1
        end
        if gMenu.hotbar.items[gMenu.hotbar.index] and gMenu.hotbar.items[gMenu.hotbar.index].item then
            on_set_hotbar_item()
        end
    end
    m.controller.buttonPressed = m.controller.buttonPressed & ~(L_JPAD | R_JPAD)
end

-- Control stick direction
local sCSD = { up = false, left = false, down = false, right = false }
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
    if not sCSD.up and controller.stickY <= 30 then sPrevCSD.up = false end
    if not sCSD.down and controller.stickY >= -30 then sPrevCSD.down = false end
    if not sCSD.left and controller.stickX >= -30 then sPrevCSD.left = false end
    if not sCSD.right and controller.stickX <= 30 then sPrevCSD.right = false end
    if (sMovementIsHeld or not sPrevCSD.up) and controller.stickY > 30 then sCSD.up = true sPrevCSD.up = true gMouse.moved = false else sCSD.up = false end
    if (sMovementIsHeld or not sPrevCSD.down) and controller.stickY < -30 then sCSD.down = true sPrevCSD.down = true gMouse.moved = false else sCSD.down = false end
    if (sMovementIsHeld or not sPrevCSD.left) and controller.stickX < -30 then sCSD.left = true sPrevCSD.left = true gMouse.moved = false else sCSD.left = false end
    if (sMovementIsHeld or not sPrevCSD.right) and controller.stickX > 30 then sCSD.right = true sPrevCSD.right = true gMouse.moved = false else sCSD.right = false end
end

----------------------------------------------------

local sCButtonCSD = {up = false, left = false, down = false, right = false}
local sCButtonPrevCSD = {up = false, left = false, down = false, right = false}
local sCButtonHoldTimer = 0
local sCButtonMovementTimer = 0
local sCButtonMovementIsHeld = false

---@param m MarioState
local function handle_scrolling_inputs(m)
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
    if not sCButtonCSD.up and down & U_CBUTTONS == 0 then sCButtonPrevCSD.up = false end
    if not sCButtonCSD.down and down & D_CBUTTONS == 0 then sCButtonPrevCSD.down = false end
    if not sCButtonCSD.left and down & L_CBUTTONS == 0 then sCButtonPrevCSD.left = false end
    if not sCButtonCSD.right and down & R_CBUTTONS == 0 then sCButtonPrevCSD.right = false end
    if (sCButtonMovementIsHeld or not sCButtonPrevCSD.up) and down & U_CBUTTONS ~= 0 then sCButtonCSD.up = true sCButtonPrevCSD.up = true gMouse.moved = false else sCButtonCSD.up = false end
    if (sCButtonMovementIsHeld or not sCButtonPrevCSD.down) and down & D_CBUTTONS ~= 0  then sCButtonCSD.down = true sCButtonPrevCSD.down = true gMouse.moved = false else sCButtonCSD.down = false end
    if (sCButtonMovementIsHeld or not sCButtonPrevCSD.left) and down & L_CBUTTONS ~= 0  then sCButtonCSD.left = true sCButtonPrevCSD.left = true gMouse.moved = false else sCButtonCSD.left = false end
    if (sCButtonMovementIsHeld or not sCButtonPrevCSD.right) and down & R_CBUTTONS ~= 0 then sCButtonCSD.right = true sCButtonPrevCSD.right = true gMouse.moved = false else sCButtonCSD.right = false end
end

----------------------------------------------------

local function on_change_tab_input()
    gMouse.menu.clickedTabIndex = 0
    gMenu.current_item.index = 0
    gMenu.tabs[gMenu.tabs.current].pages.current = 1
    gMenu.tabs[TAB_SURFACE_TYPES].misc.index = 1
    gMenu.tabs[TAB_SURFACE_TYPES].misc.index_offset = 0
    gMouse.menu.prevItemIndex = 0
    play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
end

---@param pressed integer
local function handle_change_tab_inputs(pressed)
    if pressed & L_TRIG ~= 0 then
        gMenu.tabs.current = gMenu.tabs.current - 1
        if gMenu.tabs.current < 1 then
            gMenu.tabs.current = TAB_MAIN_END
        end
        on_change_tab_input()
    elseif pressed & R_TRIG ~= 0 then
        gMenu.tabs.current = gMenu.tabs.current + 1
        if gMenu.tabs.current > TAB_MAIN_END then
            gMenu.tabs.current = 1
        end
        on_change_tab_input()
    elseif gMouse.menu.clickedTabIndex > 0 then
        gMenu.tabs.current = gMouse.menu.clickedTabIndex
        on_change_tab_input()
    end
end

---@param m MarioState
local function handle_item_selection_inputs(m)
    local current_item_set_count = #gMenu.get_current_tab_items()
    if current_item_set_count == 0 then return end
    handle_control_stick_inputs(m)
    local items_per_page = gMenu.tabs.slots.rows * gMenu.tabs.slots.columns
    local selected_item_offset = items_per_page * (gMenu.get_current_page_index() - 1)
    local relative_item_index = gMenu.current_item.index - selected_item_offset

    if sCSD.up or sCSD.left or sCSD.down or sCSD.right then
        if gMenu.current_item.index == 0 then
            gMenu.current_item.index = selected_item_offset + 1
            relative_item_index = 1
            play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
            return
        end

        if sCSD.up and relative_item_index > 1 then
            local remaining = relative_item_index - (relative_item_index - gMenu.tabs.slots.columns)
            gMenu.current_item.index = math.max(gMenu.current_item.index - remaining, selected_item_offset + 1)
        elseif sCSD.down and relative_item_index < current_item_set_count then
            local remaining = math.min(current_item_set_count - relative_item_index, gMenu.tabs.slots.columns)
            gMenu.current_item.index = gMenu.current_item.index + remaining
        end
        if sCSD.left and relative_item_index > 1 then
            gMenu.current_item.index = gMenu.current_item.index - 1
        elseif sCSD.right and relative_item_index < current_item_set_count then
            gMenu.current_item.index = gMenu.current_item.index + 1
        end

        play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
    end
end

local function on_confirm_item_input()
    ---@type MenuItemLink
    local hotbar_item = table.deepcopy(gMenu.get_current_item() --[[@as table]])
    gMenu.hotbar.items[gMenu.hotbar.index] = hotbar_item
    vec3f_set(gGridSize, GRID_SIZE_DEFAULT, GRID_SIZE_DEFAULT, GRID_SIZE_DEFAULT)
    play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
end

---@param m MarioState
local function handle_holding_item_inputs(m)
    if gMouse.moved then
        if gMouse.released.left then
            gMenu.current_item.is_held = false
            gMenu.current_item.index = gMouse.menu.prevItemIndex
            on_confirm_item_input()
        end
    else
        handle_control_stick_inputs(m)
        if sCSD.left and gMenu.hotbar.index > 1 then
            gMenu.hotbar.index = gMenu.hotbar.index - 1
            play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
        elseif sCSD.right and gMenu.hotbar.index < #gMenu.hotbar.items then
            gMenu.hotbar.index = gMenu.hotbar.index + 1
            play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
        end

        if m.controller.buttonReleased & A_BUTTON ~= 0 then
            gMenu.current_item.is_held = false
            on_confirm_item_input()
        end
    end
end

---@param pressed integer
local function handle_pick_item_inputs(pressed)
    if gMouse.moved then
        if gMouse.menu.prevItemIndex ~= gMenu.current_item.index then
            play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
        end
        gMouse.menu.prevItemIndex = gMenu.current_item.index
        if gMouse.pressed.left then
            gMenu.current_item.is_held = true
        end
    elseif pressed & A_BUTTON ~= 0 then
        gMenu.current_item.is_held = true
    end
end

---@param m MarioState
local function handle_paging_inputs(m)
    local invert_multiplier = sInvertScroll and -1 or 1
    local tab_pages = gMenu.get_current_tab_pages()
    if not tab_pages then return end

    if gMouse.moved then
        if gMouse.scroll * invert_multiplier > 0 and tab_pages.current > 1 then
            tab_pages.current = tab_pages.current - 1
            gMenu.current_item.index = 0
            play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
        elseif gMouse.scroll * invert_multiplier < 0 and tab_pages.current < tab_pages.count then
            tab_pages.current = tab_pages.current + 1
            gMenu.current_item.index = 0
            play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
        end
    else
        handle_scrolling_inputs(m)
        if sCButtonCSD.left and tab_pages.current > 1 then
            tab_pages.current = tab_pages.current - 1
            gMenu.current_item.index = 0
            play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
        elseif sCButtonCSD.right and tab_pages.current < tab_pages.count then
            tab_pages.current = tab_pages.current + 1
            gMenu.current_item.index = 0
            play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
        end
    end
end

---@param pressed integer
local function handle_extra_inputs(pressed)
    if pressed & Y_BUTTON ~= 0 then
        sClearHotbar = sClearHotbar + 1
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
         if sClearHotbar >= 5 then
             for i = 1, HOTBAR_SIZE, 1 do
                gMenu.hotbar.items[i] = { item = nil, icon = nil } ---@diagnostic disable-line: assign-type-mismatch
            end
            play_sound(SOUND_MENU_LET_GO_MARIO_FACE, gGlobalSoundSource)
            sClearHotbar = 0
        end
    end
end

local function handle_close_menu_inputs(pressed)
    if pressed & START_BUTTON ~= 0 or not gMouse.moved and pressed & X_BUTTON ~= 0 or gMouse.moved and gMouse.pressed.right then
        gMenu.open = false
        sClearHotbar = 0
        gMenu.tabs[TAB_SURFACE_TYPES].misc.index = 1
        gMenu.tabs[TAB_SURFACE_TYPES].misc.index_offset = 0
        gMouse.menu.prevItemIndex = 0
    end
end

----------------------------------------------------

---@param m MarioState
local function handle_standard_inputs(m)
    local pressed = m.controller.buttonPressed

    handle_paging_inputs(m)
    handle_extra_inputs(pressed)
    if gMenu.current_item.is_held then
        handle_holding_item_inputs(m)
    else
        handle_item_selection_inputs(m)
        if gMenu.current_item.index > 0 then
            handle_pick_item_inputs(pressed)
        end
    end
end

---@param m MarioState
local function handle_surface_inputs(m)
    handle_control_stick_inputs(m)

    local surface_tab = gMenu.get_current_tab().misc
    if gMouse.moved then
        if gMouse.menu.prevItemIndex ~= surface_tab.index then
            play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
        end
        gMouse.menu.prevItemIndex = surface_tab.index

        local invert_multiplier = sInvertScroll and -1 or 1
        if (gMouse.scroll * invert_multiplier) > 0 and surface_tab.index_offset > 0 then
            surface_tab.index_offset = surface_tab.index_offset - 1
        elseif (gMouse.scroll * invert_multiplier) < 0 and #surface_tab.buttons - surface_tab.index_offset > surface_tab.buttons_rendered then
            surface_tab.index_offset = surface_tab.index_offset + 1
        end
    else
        local relative_button_index = surface_tab.index - surface_tab.index_offset
        if sCButtonCSD.up then
            surface_tab.index = surface_tab.index - 1
            if surface_tab.index <= 0 then
                surface_tab.index = #surface_tab.buttons
                surface_tab.index_offset = #surface_tab.buttons - surface_tab.buttons_rendered
            elseif relative_button_index < 4 and surface_tab.index_offset > 0 then
                surface_tab.index_offset = surface_tab.index_offset - 1
            end
            play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
        elseif sCButtonCSD.down then
            surface_tab.index = surface_tab.index + 1
            if surface_tab.index > #surface_tab.buttons then
                surface_tab.index = 1
                surface_tab.index_offset = 0
            elseif relative_button_index > surface_tab.buttons_rendered - 3 and surface_tab.index + 1 < #surface_tab.buttons then
                surface_tab.index_offset = surface_tab.index_offset + 1
            end
            play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
        end
    end

    if (gMouse.moved and gMouse.pressed.left and gMouse.menu.hoveringSurfaceTip) or (not gMouse.moved and m.controller.buttonPressed & A_BUTTON ~= 0) then
        on_set_surface_chat_command(surface_tab.buttons[surface_tab.index])
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
    end
end

----------------------------------------------------

local sTabsWithSpecialInputs = {
    [TAB_SURFACE_TYPES] = handle_surface_inputs
}

---@param m MarioState
local function handle_menu_inputs(m)
    local pressed = m.controller.buttonPressed
    if gMouse.moved and pressed ~= 0 and not gMouse.pressed.left and not gMouse.pressed.right then
        gMouse.moved = false
    end

    handle_close_menu_inputs(pressed)
    handle_change_tab_inputs(pressed)
    if not sTabsWithSpecialInputs[gMenu.tabs.current] then
        handle_standard_inputs(m)
    else
        sTabsWithSpecialInputs[gMenu.tabs.current](m)
    end
    m.controller.buttonPressed = 0
end

----------------------------------------------------

---@param m MarioState
local function before_mario_update(m)
    if m.playerIndex ~= 0 then return end

    if not gCanBuild then
        camera_romhack_allow_dpad_usage(1)
        camera_config_enable_dpad(true)
        return
    end

    if not gMenu.open and m.controller.buttonPressed & X_BUTTON ~= 0 then
        gMenu.open = true
        return
    end

    if is_game_paused() then
        return
    end

    if not gMenu.get_current_tab() then
        return
    end

    handle_hotbar_inputs(m)
    if gMenu.open then
        m.freeze = 1
        handle_mouse_input()
        handle_menu_inputs(m)
    else
        gMenu.current_item.is_held = false
    end

    camera_romhack_allow_dpad_usage(0)
    camera_config_enable_dpad(false)
    if gMenu.hotbar.items[gMenu.hotbar.index] then
        gCurrentItem = gMenu.hotbar.items[gMenu.hotbar.index].item
    end
end

------------------------------------------------------------------------------------------------

hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)