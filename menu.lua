MenuOpen = false

local active_tab = 1
local selected_item_index = 1

local TAB_BUILDING_BLOCKS = 1
local TAB_ITEMS = 2
local TAB_ENEMIES = 3
local TAB_HELP = 4
local TAB_MAIN_END = 4

local selected_hotbar_index = 1
local HOTBAR_SIZE = 10
local hotbar_selection_active = false

local item_list_row_count = 10
local item_list_column_count = 10

---@class MenuItemLink
    ---@field item Item
    ---@field icon TextureInfo
    ---@field self MenuItemLink?

---@type table<integer, MenuItemLink[]>
local TabItemList = {
    [TAB_BUILDING_BLOCKS] = {},
    [TAB_ITEMS] = {},
    [TAB_ENEMIES] = {},
    [TAB_HELP] = {}
}

---@type MenuItemLink[]
local HotbarItemList = {}
for i = 1, HOTBAR_SIZE do
    HotbarItemList[i] = { item = nil, icon = nil } ---@diagnostic disable-line: assign-type-mismatch
end

---@param tab integer
---@param behavior BehaviorId
---@param model ModelExtendedId
---@param offset number
---@param mock_settings table
---@param behavior_param integer
---@param icon TextureInfo
local function add_item(tab, behavior, model, offset, mock_settings, behavior_param, icon)
    ---@type MenuItemLink
    local item = { item = { behavior = behavior, model = model, spawnYOffset = offset, mock = mock_settings, behaviorParams = behavior_param, misc = {} }, icon = icon }
    item.self = item
    table.insert(TabItemList[tab], item)
end

add_first_update(function ()
    for i = 1, 150, 1 do
        local color = 0
        local r = math.random(0, 256)
        local g = math.random(0, 256)
        local b = math.random(0, 256)
        color = (r << 16) | (g << 8) | (b << 0)
        ---@type MenuItemLink
        local menu_item = {
            item = {
                behavior = bhvMceBlock,
                model = E_MODEL_MCE_BLOCK,
                spawnYOffset = 0,
                mock = {},
                behaviorParams = color,
                misc = {}
            },
            icon = gTextures.star
        }
        menu_item.self = menu_item
        TabItemList[TAB_BUILDING_BLOCKS][i] = menu_item
    end

    local star_offset = 6
    add_item(TAB_ITEMS, bhvMceStar, E_MODEL_STAR, star_offset, {}, 0, gTextures.star)
    add_item(TAB_ITEMS, bhvMceStar, E_MODEL_TRANSPARENT_STAR, star_offset, {}, 0, gTextures.star)
    local coin_offset = 32
    add_item(TAB_ITEMS, bhvMceCoin, E_MODEL_YELLOW_COIN, coin_offset, { billboard = true }, 1, gTextures.coin)
    add_item(TAB_ITEMS, bhvMceCoin, E_MODEL_RED_COIN, coin_offset + 3, { billboard = true }, 2, gTextures.coin)
    add_item(TAB_ITEMS, bhvMceCoin, E_MODEL_BLUE_COIN, coin_offset + 26, { billboard = true, scale = 1.25 }, 5, gTextures.coin)
    local exclamation_box_offset = 50
    add_item(TAB_ITEMS, bhvMceExclamationBox, E_MODEL_EXCLAMATION_BOX, exclamation_box_offset, { animState = 0, scale = 2 }, 1, gTextures.apostrophe)
    add_item(TAB_ITEMS, bhvMceExclamationBox, E_MODEL_EXCLAMATION_BOX, exclamation_box_offset, { animState = 1, scale = 2 }, 2, gTextures.apostrophe)
    add_item(TAB_ITEMS, bhvMceExclamationBox, E_MODEL_EXCLAMATION_BOX, exclamation_box_offset, { animState = 2, scale = 2 }, 3, gTextures.apostrophe)
    add_item(TAB_ITEMS, bhvMceExclamationBox, E_MODEL_EXCLAMATION_BOX, exclamation_box_offset, { animState = 3, scale = 2 }, 4, gTextures.apostrophe)
    add_item(TAB_ITEMS, bhvMceExclamationBox, E_MODEL_EXCLAMATION_BOX, exclamation_box_offset, { animState = 3, scale = 2 }, 99, gTextures.apostrophe)

    local offset = 0
    add_item(TAB_ENEMIES, id_bhvGoomba, E_MODEL_GOOMBA, offset, {}, 0, gTextures.lakitu)
    add_item(TAB_ENEMIES, id_bhvBobomb, E_MODEL_BLACK_BOBOMB, offset, {}, 0, gTextures.lakitu)
    add_item(TAB_ENEMIES, id_bhvChuckya, E_MODEL_CHUCKYA, offset, {}, 0, gTextures.lakitu)
end)

------------------------------------------------------------------------------------------------

---@param color_table DjuiColor
local function djui_hud_set_color_with_table(color_table)
    djui_hud_set_color(color_table.r, color_table.g, color_table.b, color_table.a)
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param color DjuiColor?
---@param pixel_size number?
local function render_pixel_border(x, y, width, height, color, pixel_size)
    local border_color = {r = 0, g = 0, b = 0, a = 255}
    local size = 1
    if color then
        border_color = color
    end
    if pixel_size then
        size = pixel_size
    end
    djui_hud_set_color_with_table(border_color)
    djui_hud_render_rect(x, y, width, size)
    djui_hud_render_rect(x, y, size, height)
    djui_hud_render_rect(x, y + height, width, size)
    djui_hud_render_rect(x + width, y, size, height + size)
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param shine DjuiColor
---@param shade DjuiColor
---@param margin_width number
---@param margin_height number
local function render_rectangle_borders(x, y, width, height, shine, shade, margin_width, margin_height)
    djui_hud_set_color_with_table(shine)
    djui_hud_render_rect(x, y, width, height * margin_height)
    djui_hud_render_rect(x, y, width * margin_width, height)
    djui_hud_set_color_with_table(shade)
    djui_hud_render_rect(x, y + (height - height * margin_height), width, height * margin_height)
    djui_hud_render_rect(x + (width - width * margin_width), y, width * margin_width, height)
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param colors DjuiColor?
---@param margin_width number
---@param margin_height number
local function render_colored_rectangle(x, y, width, height, colors, margin_width, margin_height)
    if colors then
        djui_hud_set_color_with_table(colors)
    end
    djui_hud_render_rect(x + width * margin_width, y + height * margin_height, width - width * margin_width * 2, height - height * margin_height * 2)
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param colors DjuiColor[] {base, shine, shade}
---@param margin_width number
---@param margin_height number
---@param remove_pixel_border boolean?
local function render_bordered_rectangle(x, y, width, height, colors, margin_width, margin_height, remove_pixel_border)
    render_rectangle_borders(x, y, width, height, colors[2], colors[3], margin_width, margin_height)
    if not remove_pixel_border then
        render_pixel_border(x, y, width, height)
    end
    render_colored_rectangle(x, y, width, height, colors[1], margin_width, margin_height)
end

----------------------------------------------------

local moved_mouse = false
local prev_mouse_x = 0
local prev_mouse_y = 0
local mouse_x = 0
local mouse_y = 0
local mouse_has_clicked = false
local mouse_has_right_clicked = false
--local mouse_click_held = false
--local mouse_hold_released = false
--local mouse_hold_timer = 0
local mouse_prev_item_index = 1
local mouse_tab_was_clicked_on = 0

local function render_mouse()
    if moved_mouse then
        prev_mouse_x = mouse_x
        prev_mouse_y = mouse_y
        mouse_x = djui_hud_get_mouse_x()
        mouse_y = djui_hud_get_mouse_y()
        djui_hud_render_texture_interpolated(gTextures.camera, prev_mouse_x, prev_mouse_y, 1, 1, mouse_x, mouse_y, 1, 1)
        --djui_hud_render_texture(gTextures.camera, mouse_x, mouse_y, 1, 1)
    end
end

local function mouse_is_within(start_x, start_y, end_x, end_y)
    return mouse_x > start_x and mouse_y > start_y and mouse_x < end_x and mouse_y < end_y
end

local function handle_mouse_input()
    if djui_hud_get_raw_mouse_x() > 0 or djui_hud_get_raw_mouse_y() > 0 then
        moved_mouse = true
    end
    mouse_has_clicked = djui_hud_get_mouse_buttons_pressed() == 1
    mouse_has_right_clicked = djui_hud_get_mouse_buttons_pressed() == 4
    --[[
    mouse_click_held = djui_hud_get_mouse_buttons_down() == 1
    mouse_hold_released = djui_hud_get_mouse_buttons_released() == 1
    if mouse_click_held then
        mouse_hold_timer = mouse_hold_timer + 1
    else
        mouse_hold_timer = 0
    end
    ]]
end

------------------------------------------------------------------------------------------------

---@param x number
---@param y number
---@param width number
---@param height number
---@param text string
local function render_tab_header(x, y, width, height, text)
    djui_hud_set_color(0, 0, 0, 255)
    djui_hud_set_font(FONT_NORMAL)
    local scale = 1.5
    local size = djui_hud_measure_text(text) * scale
    local text_x = x + width * 0.5 - size * 0.5
    local text_y = y + height * 0.04
    djui_hud_print_text(text, text_x, text_y, scale)
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param items MenuItemLink[]
local function render_item_list(x, y, width, height, items)
    local hovering_over_item = false
    local slot_width = 50
    local slot_height = 50
    local div = width / slot_width
    local div_floor = math.floor(div)
    item_list_column_count = div_floor
    if div ~= div_floor then
        local div_decimal = div - div_floor
        slot_width = slot_width + (slot_width * (div_decimal / item_list_column_count))
    end
    djui_chat_message_create(div)
    item_list_row_count = height // slot_height

    for index, item in ipairs(items) do
        local slot_x = x + ((slot_width * ((index - 1) % item_list_column_count)))
        local slot_y = y + ((slot_height * ((index - 1) // item_list_column_count)))
        if moved_mouse and mouse_is_within(slot_x, slot_y, slot_x + slot_width, slot_y + slot_height) then
            selected_item_index = index
            hovering_over_item = true
        end

        if index == selected_item_index then
            djui_hud_set_color(255, 255, 255, 150)
            render_colored_rectangle(slot_x, slot_y, slot_width, slot_height, nil, 0.05, 0.05)
            djui_hud_render_rect(slot_x, slot_y, slot_width, slot_height)
        end
        if item.icon then
            local item_x = (slot_x + slot_width * 0.5) - (item.icon.width * 0.5)
            local item_y = (slot_y + slot_height * 0.5) - (item.icon.height * 0.5)
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_render_texture(item.icon, item_x, item_y, 1, 1)
        end
    end

    for i = 1, item_list_column_count + 1, 1 do
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_render_rect(x + (slot_width * (i - 1) - 1), y, 2, height)
        djui_hud_set_color(96, 96, 96, 255)
        djui_hud_render_rect(x + (slot_width * (i - 1) + 1), y, 2, height)
    end
    for i = 1, item_list_row_count + 1, 1 do
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_render_rect(x, y + (slot_height * (i - 1) - 1), width, 2)
        djui_hud_set_color(96, 96, 96, 255)
        djui_hud_render_rect(x, y + (slot_height * (i - 1) + 1), width, 2)
    end

    if moved_mouse and not hovering_over_item then
        selected_item_index = 0
    end
end

---@param x number
---@param y number
---@param width number
---@param height number
local function render_interior_rectangle(x, y, width, height)
    local interior_rect_x = x + width * 0.05
    local interior_rect_y = y + height * 0.15
    local interior_rect_width = width * 0.9
    local interior_rect_height = height * 0.8
    --local interior_colors = {{r = 175, g = 175, b = 175, a = 255}, {r = 96, g = 96, b = 96, a = 255}, {r = 255, g = 255, b = 255, a = 255}}
    local color = {r = 175, g = 175, b = 175, a = 255}
    djui_hud_set_color_with_table(color)
    djui_hud_render_rect(interior_rect_x, interior_rect_y, interior_rect_width, interior_rect_height)
    --render_colored_rectangle(interior_rect_x, interior_rect_y, interior_rect_width, interior_rect_height, interior_colors[1], 0.007, 0.007)
    render_item_list(interior_rect_x, interior_rect_y, interior_rect_width, interior_rect_height, TabItemList[active_tab])
    --render_rectangle_borders(interior_rect_x, interior_rect_y, interior_rect_width, interior_rect_height, interior_colors[2], interior_colors[3], 0.007, 0.007)
end

local function render_standard_tab(x, y, width, height, name)
    render_tab_header(x, y, width, height, name)
    render_interior_rectangle(x, y, width, height)
end

---@param x number
---@param y number
---@param width number
---@param height number
local function render_building_blocks_tab(x, y, width, height)
    render_standard_tab(x, y, width, height, "Building Blocks")
end

---@param x number
---@param y number
---@param width number
---@param height number
local function render_items_tab(x, y, width, height)
    render_standard_tab(x, y, width, height, "Items")
end

---@param x number
---@param y number
---@param width number
---@param height number
local function render_enemies_tab(x, y, width, height)
    render_standard_tab(x, y, width, height, "Enemies")
end

---@param x number
---@param y number
---@param width number
---@param height number
local function render_help_tab(x, y, width, height)
    render_tab_header(x, y, width, height, "How to use")
end

local MenuTabs = {
    render_building_blocks_tab,
    render_items_tab,
    render_enemies_tab,
    render_help_tab
}

----------------------------------------------------

---@param x number
---@param y number
---@param width number
---@param height number
---@param index integer
local function render_menu_tab(x, y, width, height, index)
    local colors = {{r = 125, g = 125, b = 125, a = 255}, {r = 175, g = 175, b = 175, a = 255}, {r = 75, g = 75, b = 75, a = 255}}
    if index == active_tab then
        colors = {{r = 200, g = 200, b = 200, a = 255}, {r = 255, g = 255, b = 255, a = 255}, {r = 150, g = 150, b = 150, a = 255}}
    end
    local tab_width = width * 0.1
    local tab_height = height * 0.1
    local tab_x = x + (tab_width * (index - 1))
    local tab_y = y - (tab_height - (tab_height * 0.1))
    render_bordered_rectangle(tab_x, tab_y, tab_width, tab_height, colors, 0.05, 0.07)
    if mouse_is_within(tab_x, tab_y, tab_x + tab_width, tab_y + tab_height) and mouse_has_clicked then
        mouse_tab_was_clicked_on = index
    end
end

---@param screen_width number
---@param screen_height number
---@return number x
---@return number y
---@return number width
---@return number height
local function render_main_rectangle(screen_width, screen_height)
    local x = screen_width * 0.25
    local y = screen_height * 0.2
    local width = screen_width * 0.5
    local height = screen_height * 0.6
    local colors = {{r = 200, g = 200, b = 200, a = 255}, {r = 255, g = 255, b = 255, a = 255}, {r = 150, g = 150, b = 150, a = 255}}
    for i = 1, TAB_MAIN_END do
        render_menu_tab(x, y, width, height, i)
    end
    render_bordered_rectangle(x, y, width, height, colors, 0.008, 0.01)
    return x, y, width, height
end

----------------------------------------------------

---@param screen_width number
---@param screen_height number
local function render_hotbar(screen_width, screen_height)
    local width = screen_width * 0.5
    local height = screen_height * 0.08
    local x = screen_width * 0.25
    local y = screen_height - (height * 1.4)
    local colors = {{r = 64, g = 64, b = 32, a = 192}, {r = 128, g = 128, b = 128, a = 255}, {r = 128, g = 128, b = 128, a = 255}}
    render_bordered_rectangle(x, y, width, height, colors, 0.007, 0.06)
    for index, item in ipairs(HotbarItemList) do
        local slot_width = width * 0.1
        local slot_height = height * 0.95
        local slot_x = x + slot_width * (index - 1)
        local slot_y = y
        if MenuOpen and moved_mouse and mouse_is_within(slot_x, slot_y, slot_x + slot_width, slot_y + slot_height) then
            selected_hotbar_index = index
        end

        if index == selected_hotbar_index then
            djui_hud_set_color(150, 150, 150, 255)
            if hotbar_selection_active then
                djui_hud_set_color(255, 255, 0, 255)
            end
            local slot_colors = {{r = 32, g = 32, b = 0, a = 0}, {r = 192, g = 192, b = 192, a = 255}, {r = 192, g = 192, b = 192, a = 255}}
            render_bordered_rectangle(slot_x * 0.995, slot_y * 0.995, slot_width + 10, slot_height + 13, slot_colors, 0.1, 0.1)

        end
        if item.icon then
            local item_x = (slot_x + slot_width * 0.5) - (item.icon.width * 0.5)
            local item_y = (slot_y + slot_height * 0.5) - (item.icon.height * 0.5)
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_render_texture(item.icon, item_x, item_y, 1, 1)
        end
    end
end

---@param screen_width number
---@param screen_height number
local function render_menu(screen_width, screen_height)
    render_hotbar(screen_width, screen_height)
    if MenuOpen then
        local x, y, width, height = render_main_rectangle(screen_width, screen_height)
        MenuTabs[active_tab](x, y, width, height)
        render_mouse()
    end
end

----------------------------------------------------

local function hud_render()
    if not CanBuild then return end
    djui_hud_set_resolution(RESOLUTION_DJUI)

    local screen_width = djui_hud_get_screen_width()
    local screen_height = djui_hud_get_screen_height()
    render_menu(screen_width, screen_height)
end

------------------------------------------------------------------------------------------------

---@param m MarioState
local function handle_hotbar_inputs(m)
    if m.controller.buttonDown & L_TRIG ~= 0 then return end

    if m.controller.buttonPressed & L_JPAD ~= 0 and selected_hotbar_index > 1 then
        selected_hotbar_index = selected_hotbar_index - 1
    elseif m.controller.buttonPressed & R_JPAD ~= 0 and selected_hotbar_index < HOTBAR_SIZE then
        selected_hotbar_index = selected_hotbar_index + 1
    end
    m.controller.buttonPressed = m.controller.buttonPressed & ~(L_JPAD | R_JPAD)
end

---@param m MarioState
local function handle_hotbar_menu_inputs(m)
    local pressed = m.controller.buttonPressed
    if pressed & L_JPAD ~= 0 and selected_hotbar_index > 1 then
        selected_hotbar_index = selected_hotbar_index - 1
    elseif pressed & R_JPAD ~= 0 and selected_hotbar_index < HOTBAR_SIZE then
        selected_hotbar_index = selected_hotbar_index + 1
    end

    if m.controller.buttonReleased & A_BUTTON ~= 0 then
        HotbarItemList[selected_hotbar_index] = TabItemList[active_tab][selected_item_index]
        hotbar_selection_active = false
    end
end

----------------------------------------------------

local function handle_change_tab_inputs(pressed)
    if pressed & L_TRIG ~= 0 and active_tab > 1 then
        active_tab = active_tab - 1
        selected_item_index = 0
        play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    elseif pressed & R_TRIG ~= 0 and active_tab < TAB_MAIN_END then
        active_tab = active_tab + 1
        selected_item_index = 0
        play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    elseif mouse_tab_was_clicked_on > 0 then
        active_tab = mouse_tab_was_clicked_on
        mouse_tab_was_clicked_on = 0
        selected_item_index = 0
        play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    end
end

local function handle_item_selection_inputs(pressed)
    local current_item_set_count = #TabItemList[active_tab]
    if current_item_set_count == 0 then return end
    if pressed & (U_JPAD | L_JPAD | D_JPAD | R_JPAD) ~= 0 then
        play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
        if selected_item_index == 0 then
            selected_item_index = 1
        end

        if pressed & U_JPAD ~= 0 and selected_item_index > item_list_column_count then
            selected_item_index = selected_item_index - item_list_column_count
        elseif pressed & D_JPAD ~= 0 and selected_item_index < current_item_set_count then
            local remaining = math.min(current_item_set_count - selected_item_index, item_list_column_count)
            selected_item_index = selected_item_index + remaining
        end
        if pressed & L_JPAD ~= 0 and selected_item_index > 1 then
            selected_item_index = selected_item_index - 1
        elseif pressed & R_JPAD ~= 0 and selected_item_index < current_item_set_count then
            selected_item_index = selected_item_index + 1
        end
    end
end

local function handle_pick_item_inputs(pressed)
    if moved_mouse then
        if mouse_prev_item_index ~= selected_item_index then
            play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
        end
        mouse_prev_item_index = selected_item_index
        if mouse_has_clicked and TabItemList[active_tab] and TabItemList[active_tab][selected_item_index] then
            HotbarItemList[selected_hotbar_index] = TabItemList[active_tab][selected_item_index]
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        end
    elseif not moved_mouse and pressed & A_BUTTON ~= 0 and TabItemList[active_tab] and TabItemList[active_tab][selected_item_index] then
        --HotbarItemList[selected_hotbar_index] = TabItemList[active_tab][selected_item_index]
        hotbar_selection_active = true
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
    end
end

---@param pressed integer
local function handle_standard_inputs(pressed)
    if moved_mouse and pressed ~= 0 and not mouse_has_clicked and not mouse_has_right_clicked then
        moved_mouse = false
    end
    if (pressed & START_BUTTON ~= 0) or (not moved_mouse and pressed & X_BUTTON ~= 0) or (moved_mouse and mouse_has_right_clicked) then
        MenuOpen = false
        return
    end

    handle_change_tab_inputs(pressed)
    handle_item_selection_inputs(pressed)
    if selected_item_index > 0 then
        handle_pick_item_inputs(pressed)
    end
end

----------------------------------------------------

---@param m MarioState
local function handle_menu_inputs(m)
    local pressed = m.controller.buttonPressed

    if active_tab <= TAB_MAIN_END then
        if not hotbar_selection_active then
            handle_standard_inputs(pressed)
        else
            handle_hotbar_menu_inputs(m)
        end
        m.controller.buttonPressed = 0
    end
end

----------------------------------------------------

---@param m MarioState
local function before_mario_update(m)
    if m.playerIndex ~= 0 then return end
    if not CanBuild then return end

    if not MenuOpen and m.controller.buttonDown & L_TRIG == 0 and m.controller.buttonPressed & X_BUTTON ~= 0 then
        MenuOpen = true
        return
    end

    if MenuOpen then
        m.freeze = 1
        handle_mouse_input()
        handle_menu_inputs(m)
    else
        handle_hotbar_inputs(m)
    end

    gCurrentItem = HotbarItemList[selected_hotbar_index].item
end

------------------------------------------------------------------------------------------------

hook_event(HOOK_ON_HUD_RENDER_BEHIND, hud_render)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)