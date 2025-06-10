MenuOpen = false

local active_tab = 1
local selected_item_index = 1
local active_item_index = 0

local TAB_BUILDING_BLOCKS = 1
local TAB_ITEMS = 2
local TAB_ENEMIES = 3
local TAB_HELP = 4
local TAB_MAIN_END = 4

---@class MenuItemLink
    ---@field item Item
    ---@field icon TextureInfo

---@type table<integer, MenuItemLink[]>
local TabItemList = {
    [TAB_BUILDING_BLOCKS] = {},
    [TAB_ITEMS] = {},
    [TAB_ENEMIES] = {},
    [TAB_HELP] = {}
}

add_first_update(function ()
    TabItemList[TAB_BUILDING_BLOCKS][1] = { item = { behavior = bhvMinecraftBox, params = { color = {r = 255, g = 255, b = 255, a = 255} } }, icon = gTextures.star}
    TabItemList[TAB_BUILDING_BLOCKS][2] = { item = { behavior = bhvMinecraftBox, params = { color = {r = 255, g = 0, b = 0, a = 255} } }, icon = gTextures.star}
    TabItemList[TAB_BUILDING_BLOCKS][3] = { item = { behavior = bhvMinecraftBox, params = { color = {r = 0, g = 0, b = 255, a = 255} } }, icon = gTextures.star}
    TabItemList[TAB_BUILDING_BLOCKS][4] = { item = { behavior = bhvMinecraftBox, params = { color = {r = 255, g = 255, b = 0, a = 255} } }, icon = gTextures.star}
    TabItemList[TAB_BUILDING_BLOCKS][5] = { item = { behavior = bhvMinecraftBox, params = { color = {r = 255, g = 0, b = 255, a = 255} } }, icon = gTextures.star}
    TabItemList[TAB_BUILDING_BLOCKS][6] = { item = { behavior = bhvMinecraftBox, params = { color = {r = 255, g = 255, b = 0, a = 255} } }, icon = gTextures.star}
    TabItemList[TAB_BUILDING_BLOCKS][6] = { item = { behavior = bhvMinecraftBox, params = { color = {r = 0, g = 0, b = 0, a = 255} } }, icon = gTextures.star}
    for i = 1, 17, 1 do
        TabItemList[TAB_ITEMS][i] = { item = {behavior = nil, params = {} }, icon = gTextures.coin }
    end
    for i = 1, 22, 1 do
        TabItemList[TAB_ENEMIES][i] = { item = {behavior = nil, params = {} }, icon = gTextures.lakitu }
    end
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
---@param colors DjuiColor[]
---@param margin_width number
---@param margin_height number
local function render_bordered_rectangle(x, y, width, height, colors, margin_width, margin_height)
    djui_hud_set_color_with_table(colors[2])
    djui_hud_render_rect(x, y, width, height)
    djui_hud_set_color_with_table(colors[3])
    djui_hud_render_rect(x + (width * margin_width), y + height * margin_width, width - width * margin_height, height - height * margin_height)
    djui_hud_set_color_with_table(colors[1])
    djui_hud_render_rect(x + (width * margin_width), y + height * margin_width, width - width * margin_height * 2, height - height * margin_height * 2)
end

----------------------------------------------------

local moved_mouse = false
local prev_mouse_x = 0
local prev_mouse_y = 0
local mouse_x = 0
local mouse_y = 0
local mouse_has_clicked = false
local mouse_has_right_clicked = false
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
    for index, item in ipairs(items) do
        local slot_width = width * 0.1
        local slot_height = height * 0.1
        local slot_x = x + (slot_width * ((index - 1) % 10))
        local slot_y = y + (slot_height * ((index - 1) // 10))
        local item_x = (slot_x + slot_width * 0.5) - (item.icon.width * 0.5)
        local item_y = (slot_y + slot_height * 0.5) - (item.icon.height * 0.5)
        if moved_mouse and mouse_is_within(slot_x, slot_y, slot_x + slot_width, slot_y + slot_height) then
            selected_item_index = index
            hovering_over_item = true
        end

        if index == active_item_index then
            djui_hud_set_color(125, 125, 125, 255)
            djui_hud_render_rect(slot_x, slot_y, slot_width, slot_height)
        elseif index == selected_item_index then
            djui_hud_set_color(150, 150, 150, 255)
            djui_hud_render_rect(slot_x, slot_y, slot_width, slot_height)
        end
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_render_texture(item.icon, item_x, item_y, 1, 1)
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
    djui_hud_set_color(175, 175, 175, 255)
    djui_hud_render_rect(interior_rect_x, interior_rect_y, interior_rect_width, interior_rect_height)
    render_item_list(interior_rect_x, interior_rect_y, interior_rect_width, interior_rect_height, TabItemList[active_tab])
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
    render_bordered_rectangle(tab_x, tab_y, tab_width, tab_height, colors, 0.1, 0.1)
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
    render_bordered_rectangle(x, y, width, height, colors, 0.01, 0.01)
    return x, y, width, height
end

----------------------------------------------------

---@param screen_width number
---@param screen_height number
local function render_menu(screen_width, screen_height)
    if not MenuOpen then return end
    local x, y, width, height = render_main_rectangle(screen_width, screen_height)
    MenuTabs[active_tab](x, y, width, height)
    render_mouse()
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

---@param pressed integer
local function handle_standard_inputs(pressed)
    if moved_mouse and pressed ~= 0 and not mouse_has_clicked and not mouse_has_right_clicked then
        moved_mouse = false
    end
    if (pressed & START_BUTTON ~= 0) or (not moved_mouse and pressed & X_BUTTON ~= 0) or (moved_mouse and mouse_has_right_clicked) then
        MenuOpen = false
        return
    end

    if pressed & L_TRIG ~= 0 and active_tab > 1 then
        active_tab = active_tab - 1
        selected_item_index = 0
        active_item_index = 0
        play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    elseif pressed & R_TRIG ~= 0 and active_tab < TAB_MAIN_END then
        active_tab = active_tab + 1
        selected_item_index = 0
        active_item_index = 0
        play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    elseif mouse_tab_was_clicked_on > 0 then
        active_tab = mouse_tab_was_clicked_on
        mouse_tab_was_clicked_on = 0
        selected_item_index = 0
        active_item_index = 0
        play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    end

    local current_item_set_count = #TabItemList[active_tab]
    if current_item_set_count == 0 then return end

    if pressed & (U_JPAD | L_JPAD | D_JPAD | R_JPAD) ~= 0 then
        play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
        if selected_item_index == 0 then
            selected_item_index = active_item_index > 0 and active_item_index or 1
        end

        if pressed & U_JPAD ~= 0 and selected_item_index > 10 then
            selected_item_index = selected_item_index - 10
        elseif pressed & D_JPAD ~= 0 and selected_item_index < current_item_set_count then
            local remaining = math.min(current_item_set_count - selected_item_index, 10)
            selected_item_index = selected_item_index + remaining
        end
        if pressed & L_JPAD ~= 0 and selected_item_index > 1 and selected_item_index % 10 ~= 1 then
            selected_item_index = selected_item_index - 1
        elseif pressed & R_JPAD ~= 0 and selected_item_index < current_item_set_count and selected_item_index % 10 ~= 0 then
            selected_item_index = selected_item_index + 1
        end
    end

    if selected_item_index > 0 then
        if moved_mouse then
            if mouse_prev_item_index ~= selected_item_index then
                play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
            end
            mouse_prev_item_index = selected_item_index
            if mouse_has_clicked and TabItemList[active_tab] and TabItemList[active_tab][selected_item_index] then
                active_item_index = selected_item_index
                gCurrentItem = TabItemList[active_tab][active_item_index].item
                play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
            end
        elseif not moved_mouse and pressed & A_BUTTON ~= 0 and TabItemList[active_tab] and TabItemList[active_tab][selected_item_index] then
            active_item_index = selected_item_index
            gCurrentItem = TabItemList[active_tab][active_item_index].item
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        end
    end
end

---@param m MarioState
local function handle_menu_inputs(m)
    local pressed = m.controller.buttonPressed

    if MenuOpen then
        handle_mouse_input()
        if active_tab <= TAB_MAIN_END then
            handle_standard_inputs(pressed)
            m.controller.buttonPressed = 0
        end
    end
end

----------------------------------------------------

---@param m MarioState
local function before_mario_update(m)
    if m.playerIndex ~= 0 then return end
    if not CanBuild then return end

    if not MenuOpen and m.controller.buttonPressed & X_BUTTON ~= 0 then
        MenuOpen = true
        return
    end

    if MenuOpen then
        m.freeze = 1

        handle_menu_inputs(m)
    end
end

------------------------------------------------------------------------------------------------

hook_event(HOOK_ON_HUD_RENDER_BEHIND, hud_render)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)