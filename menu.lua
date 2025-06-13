MenuOpen = false

local active_tab = 1
local selected_item_index = 1
local current_item_page = 1
local item_page_max = 1

local TAB_BUILDING_BLOCKS = 1
local TAB_ITEMS = 2
local TAB_ENEMIES = 3
local TAB_HELP = 4
local TAB_MAIN_END = 4

selected_hotbar_index = 1
local HOTBAR_SIZE = 10
local item_list_row_count = 10
local item_list_column_count = 10

-------------- TEXTURES --------------
local A_BUTTON_TEX = get_texture_info("Abutton")
local B_BUTTON_TEX = get_texture_info("Bbutton")
local X_BUTTON_TEX = gTextures.star --get_texture_info("Xbutton")
local Y_BUTTON_TEX = gTextures.star --get_texture_info("Ybutton")
local U_JPAD_TEX = gTextures.star --get_texture_info("Ujpad")
local L_JPAD_TEX = gTextures.star --get_texture_info("Ljpad")
local D_JPAD_TEX = gTextures.star --get_texture_info("Djpad")
local R_JPAD_TEX = gTextures.star --get_texture_info("Rjpad")
local U_CBUTTON_TEX = gTextures.star --get_texture_info("Ucbutton")
local L_CBUTTON_TEX = gTextures.star --get_texture_info("Lcbutton")
local D_CBUTTON_TEX = gTextures.star --get_texture_info("Dcbutton")
local R_CBUTTON_TEX = gTextures.star --get_texture_info("Rcbutton")
local L_TRIG_TEX = get_texture_info("Ltrig")
local R_TRIG_TEX =  get_texture_info("Rtrig")
local Z_TRIG_TEX =  get_texture_info("Ztrig")
local CONTROL_STICK_TEX = gTextures.star --get_texture_info("controlstick")
--------------------------------------

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
HotbarItemList = {}
for i = 1, HOTBAR_SIZE do
    HotbarItemList[i] = { item = nil, icon = nil } ---@diagnostic disable-line: assign-type-mismatch
end

---@param tab integer
---@param behavior BehaviorId
---@param model ModelExtendedId
---@param offset number
---@param mock_settings table
---@param anim_state integer
---@param behavior_param integer
---@param icon TextureInfo
local function add_item(tab, behavior, model, offset, anim_state, mock_settings, behavior_param, icon)
    ---@type MenuItemLink
    local item = { item = {
        behavior = behavior,
        model = model,
        spawnYOffset = offset,
        params = behavior_param,
        size = gVec3fOne(),
        animState = anim_state,
        mock = mock_settings
    }, icon = icon }

    item.self = item
    table.insert(TabItemList[tab], item)
end

add_first_update(function ()
    for i = 1, 100, 1 do
        ---@type MenuItemLink
        local menu_item = {
            item = {
                behavior = bhvMceBlock,
                model = E_MODEL_MCE_BLOCK,
                spawnYOffset = 0,
                params = 0,
                size = gVec3fOne(),
                animState = i,
                mock = {}
            },
            icon = gTextures.star
        }
        menu_item.self = menu_item
        TabItemList[TAB_BUILDING_BLOCKS][i] = menu_item
    end

    local star_offset = 6
    add_item(TAB_ITEMS, bhvMceStar, E_MODEL_STAR, star_offset, 0, { animateFaceAngleYaw = 0x800 }, 0, gTextures.star)
    add_item(TAB_ITEMS, bhvMceStar, E_MODEL_TRANSPARENT_STAR, star_offset, 0, { animateFaceAngleYaw = 0x800 }, 0, gTextures.star)
    local coin_offset = 32
    add_item(TAB_ITEMS, bhvMceCoin, E_MODEL_YELLOW_COIN, coin_offset, 0, { animateAnimState = true, animateFrame = 2, billboard = true }, 1, gTextures.coin)
    add_item(TAB_ITEMS, bhvMceCoin, E_MODEL_RED_COIN, coin_offset + 3, 0, { animateAnimState = true, animateFrame = 2, billboard = true }, 2, gTextures.coin)
    add_item(TAB_ITEMS, bhvMceCoin, E_MODEL_BLUE_COIN, coin_offset + 26, 0, { animateAnimState = true, animateFrame = 2, billboard = true, scale = 1.25 }, 5, gTextures.coin)
    local exclamation_box_offset = 50
    add_item(TAB_ITEMS, bhvMceExclamationBox, E_MODEL_EXCLAMATION_BOX, exclamation_box_offset, 0, { scale = 2 }, 1, gTextures.apostrophe)
    add_item(TAB_ITEMS, bhvMceExclamationBox, E_MODEL_EXCLAMATION_BOX, exclamation_box_offset, 1, { scale = 2 }, 2, gTextures.apostrophe)
    add_item(TAB_ITEMS, bhvMceExclamationBox, E_MODEL_EXCLAMATION_BOX, exclamation_box_offset, 2, { scale = 2 }, 3, gTextures.apostrophe)
    add_item(TAB_ITEMS, bhvMceExclamationBox, E_MODEL_EXCLAMATION_BOX, exclamation_box_offset, 3, { scale = 2 }, 4, gTextures.apostrophe)
    add_item(TAB_ITEMS, bhvMceExclamationBox, E_MODEL_EXCLAMATION_BOX, exclamation_box_offset, 3, { scale = 2 }, 99, gTextures.apostrophe)

    local offset = 0
    add_item(TAB_ENEMIES, id_bhvGoomba, E_MODEL_GOOMBA, offset, 0, {}, 0, gTextures.lakitu)
    add_item(TAB_ENEMIES, id_bhvBobomb, E_MODEL_BLACK_BOBOMB, offset, 0, {}, 0, gTextures.lakitu)
    add_item(TAB_ENEMIES, id_bhvChuckya, E_MODEL_CHUCKYA, offset, 0, {}, 0, gTextures.lakitu)
end)

------------------------------------------------------------------------------------------------

---@param color_table DjuiColor
local function djui_hud_set_color_with_table(color_table)
    djui_hud_set_color(color_table.r, color_table.g, color_table.b, color_table.a)
end

---@param text string
---@param x number
---@param y number
---@param scale number
local function render_shadowed_text(text, x, y, scale)
    local shadow_x = x
    local shadow_y = y
    djui_hud_set_color(0, 0, 0, 255)
    djui_hud_print_text(text, shadow_x, shadow_y, scale)

    local text_x = shadow_x - 2
    local text_y = shadow_y - 2
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_print_text(text, text_x, text_y, scale)
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param color DjuiColor?
---@param pixel_size number?
local function render_pixel_border(x, y, width, height, color, pixel_size)
    local border_color = {r = 0, g = 0, b = 0, a = 255}
    local size = 2
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

---@param base_slot_width number
---@param width number
---@return number
---@return integer
local function determine_slot_width(base_slot_width, width)
    local column_count = width / base_slot_width
    local whole_column_count = math.floor(column_count)
    item_list_column_count = whole_column_count
    if column_count ~= whole_column_count then
        local div_decimal = column_count - whole_column_count
        base_slot_width = base_slot_width + (base_slot_width * (div_decimal / item_list_column_count))
    end
    return base_slot_width, whole_column_count
end

---@param base_slot_height number
---@param height number
---@return number
---@return integer
local function determine_slot_height(base_slot_height, height)
    local row_count = height / base_slot_height
    local whole_row_count = math.floor(row_count)
    item_list_row_count = whole_row_count
    if row_count ~= whole_row_count then
        local div_decimal = row_count - whole_row_count
        base_slot_height = base_slot_height + (base_slot_height * (div_decimal / item_list_row_count))
    end
    return base_slot_height, whole_row_count
end

---@param column_count integer
---@param row_count integer
---@param items MenuItemLink[]
---@return MenuItemLink[][]
local function determine_pages(column_count, row_count, items)
    local max_items_per_page = column_count * row_count
    ---@type MenuItemLink[][]
    local item_pages = {{}}
    local stored_page = 1
    local item_in_page_index = 0
    for i = 1, #items do
        item_in_page_index = item_in_page_index + 1
        if item_in_page_index > max_items_per_page then
            item_in_page_index = 1
            stored_page = stored_page + 1
            item_pages[stored_page] = {}
        end
        item_pages[stored_page][item_in_page_index] = items[i]
    end
    item_page_max = stored_page
    return item_pages
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param items MenuItemLink[]
local function render_item_list(x, y, width, height, items)
    local hovering_over_item = false
    local slot_width, column_count = determine_slot_width(65, width)
    local slot_height, row_count = determine_slot_height(65, height)
    local item_pages = determine_pages(column_count, row_count, items)

    for index, item in ipairs(item_pages[current_item_page]) do
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

----------------------------------------------------

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
local function render_interior_rectangle(x, y, width, height)
    local interior_rect_x = x + width * 0.05
    local interior_rect_y = y + height * 0.15
    local interior_rect_width = width * 0.9
    local interior_rect_height = height * 0.7
    local color = {r = 175, g = 175, b = 175, a = 255}
    djui_hud_set_color_with_table(color)
    djui_hud_render_rect(interior_rect_x, interior_rect_y, interior_rect_width, interior_rect_height)
    render_item_list(interior_rect_x, interior_rect_y, interior_rect_width, interior_rect_height, TabItemList[active_tab])
end

------------------------------------------------------------------------------------------------

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

--------------------------

---@param x number
---@param y number
---@param width number
---@param height number
---@param name string
---@param buttons {prefix: string?, texture: TextureInfo}[]
local function render_controls_rect(x, y, width, height, name, buttons)
    -- Rect
    local colors = {{r = 120, g = 120, b = 120, a = 255}, {r = 186, g = 186, b = 186, a = 255}, {r = 98, g = 98, b = 98, a = 255}}
    render_bordered_rectangle(x, y, width, height, colors, 0.004, 0.06)

    local text_scale = 1.1
    render_shadowed_text(name, x + (width * 0.03) * text_scale, y + (height * 0.15) * text_scale, text_scale)

    -- Texture
    djui_hud_set_color(255, 255, 255, 255)
    local texture_scale = 2
    local initial_texture_x = 0
    if buttons[1] then
        initial_texture_x = (x + width) - buttons[1].texture.width * texture_scale * 1.5
    end
    local texture_y = y + height * 0.1 * texture_scale
    for i, button in ipairs(buttons) do
        local texture = button.texture
        local texture_x = initial_texture_x - texture.width * texture_scale
        if button.prefix then
            ---@type string
            local prefix = button.prefix
            local text_size = djui_hud_measure_text(prefix) * text_scale
            local text_x = texture_x - text_size
            render_shadowed_text(prefix, text_x, texture_y, text_scale)
            initial_texture_x = text_x
        end
        djui_hud_render_texture(texture, texture_x, texture_y, texture_scale, texture_scale)
    end
end

---@param x number
---@param y number
---@param width number
---@param height number
local function render_help_tab(x, y, width, height)
    render_tab_header(x, y, width, height, "Controls")
    do -- render_tab_header() inlined
        djui_hud_set_color(0, 0, 0, 255)
        djui_hud_set_font(FONT_NORMAL)
        local scale = 1.2
        local text = "All controls are Build Mode only"
        local size = djui_hud_measure_text(text) * scale
        local text_x = x + width * 0.5 - size * 0.5
        local text_y = y + height * 0.11
        djui_hud_print_text(text, text_x, text_y, scale)
    end

    local rect_x = x + (width * 0.035)
    local rect_y = y + (height * 0.15)
    local rect_width = width * 0.93
    local rect_height = height * 0.09

    item_page_max = 3
    if current_item_page == 1 then
        render_controls_rect(rect_x, rect_y * 1.1, rect_width, rect_height, "Fly / Enter/Exit Build Mode",
            {{prefix = " + ", texture = L_TRIG_TEX}, {prefix = "(Usable outside Build Mode) ", texture = L_TRIG_TEX}})
        render_controls_rect(rect_x, rect_y * 1.3, rect_width, rect_height, "Fly Up",
            {{texture = A_BUTTON_TEX}})
        render_controls_rect(rect_x, rect_y * 1.5, rect_width, rect_height, "Fly Down",
            {{texture = Z_TRIG_TEX}})
        render_controls_rect(rect_x, rect_y * 1.7, rect_width, rect_height, "Sprint Fly",
            {{texture = B_BUTTON_TEX}})
        render_controls_rect(rect_x, rect_y * 1.9, rect_width, rect_height, "Slow Fly",
            {{prefix = " and ", texture = L_TRIG_TEX}, {prefix = "Hold ", texture = B_BUTTON_TEX}})
        render_controls_rect(rect_x, rect_y * 2.1, rect_width, rect_height, "Lock Angle",
            {{prefix = "Hold ", texture = L_TRIG_TEX}})

        render_tab_header(x, y + height * 0.83, width, height, "Flying Controls")
    elseif current_item_page == 2 then
        render_controls_rect(rect_x, rect_y * 1.1, rect_width, rect_height, "Place/Delete Item",
            {{texture = Y_BUTTON_TEX}})
        render_controls_rect(rect_x, rect_y * 1.3, rect_width, rect_height, "Change Hotbar Selection",
            {{prefix = " / ", texture = R_JPAD_TEX}, {texture = L_JPAD_TEX}})
        render_controls_rect(rect_x, rect_y * 1.5, rect_width, rect_height, "Change Angle (Pitch)",
            {{prefix = " / ", texture = D_JPAD_TEX}, {texture = U_JPAD_TEX}})
        render_controls_rect(rect_x, rect_y * 1.7, rect_width, rect_height, "Change Angle (Yaw)",
            {{prefix = " / ", texture = R_JPAD_TEX}, {prefix = " then ", texture = L_JPAD_TEX}, {prefix = "Hold ", texture = L_TRIG_TEX}})
        render_controls_rect(rect_x, rect_y * 1.9, rect_width, rect_height, "Change Angle (Roll)",
            {{prefix = " / ", texture = D_JPAD_TEX}, {prefix = " then ", texture = U_JPAD_TEX}, {prefix = "Hold ", texture = L_TRIG_TEX}})
        render_controls_rect(rect_x, rect_y * 2.1, rect_width, rect_height, "Reset Angle",
            {{prefix = " then ", texture = X_BUTTON_TEX}, {prefix = "Hold ", texture = L_TRIG_TEX}})

        render_tab_header(x, y + height * 0.83, width, height, "Build Mode Controls")
    elseif current_item_page == 3 then
        render_controls_rect(rect_x, rect_y * 1.1, rect_width, rect_height, "Open/Close Menu",
            {{texture = X_BUTTON_TEX}})
        render_controls_rect(rect_x, rect_y * 1.3, rect_width, rect_height, "Change Item Selection",
            {{texture = CONTROL_STICK_TEX}})
        render_controls_rect(rect_x, rect_y * 1.5, rect_width, rect_height, "Change Pages",
            {{prefix = " / ", texture = R_CBUTTON_TEX}, {texture = L_CBUTTON_TEX}})
        render_controls_rect(rect_x, rect_y * 1.7, rect_width, rect_height, "Change Tabs",
            {{prefix = " / ", texture = R_TRIG_TEX}, {texture = L_TRIG_TEX}})
        render_controls_rect(rect_x, rect_y * 1.9, rect_width, rect_height, "Change Hotbar Selection",
            {{prefix = " / ", texture = R_JPAD_TEX}, {texture = L_JPAD_TEX}})
        render_controls_rect(rect_x, rect_y * 2.1, rect_width, rect_height, "Send To Hotbar",
            {{texture = A_BUTTON_TEX}})

        render_tab_header(x, y + height * 0.83, width, height, "Menu Navigation Controls")
    end
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
    local colors = {{r = 200, g = 200, b = 200, a = 255}, {r = 255, g = 255, b = 255, a = 255}, {r = 90, g = 88, b = 88, a = 255}}
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
    local y = screen_height - (height * 1.5)
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

----------------------------------------------------

local function handle_change_tab_inputs(pressed)
    if pressed & L_TRIG ~= 0 then
        active_tab = active_tab - 1
        if active_tab < 1 then
            active_tab = TAB_MAIN_END
        end
        selected_item_index = 0
        current_item_page = 1
        play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    elseif pressed & R_TRIG ~= 0 then
        active_tab = active_tab + 1
        if active_tab > TAB_MAIN_END then
            active_tab = 1
        end
        selected_item_index = 0
        current_item_page = 1
        play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    elseif mouse_tab_was_clicked_on > 0 then
        active_tab = mouse_tab_was_clicked_on
        mouse_tab_was_clicked_on = 0
        selected_item_index = 0
        current_item_page = 1
        play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    end
end

-- Control stick direction
local csd = {up = false, left = false, down = false, right = false}
local used_csd = {up = false, left = false, down = false, right = false}

local function handle_control_stick_inputs(m)
    local controller = m.controller

    if not csd.up and controller.stickY <= 30 then used_csd.up = false end
    if not csd.down and controller.stickY >= -30 then used_csd.down = false end
    if not csd.left and controller.stickX >= -30 then used_csd.left = false end
    if not csd.right and controller.stickX <= 30 then used_csd.right = false end
    if not used_csd.up and controller.stickY > 30 then csd.up = true used_csd.up = true else csd.up = false end
    if not used_csd.down and controller.stickY < -30 then csd.down = true used_csd.down = true else csd.down = false end
    if not used_csd.left and controller.stickX < -30 then csd.left = true used_csd.left = true else csd.left = false end
    if not used_csd.right and controller.stickX > 30 then csd.right = true used_csd.right = true else csd.right = false end
end

---@param m MarioState
local function handle_item_selection_inputs(m)
    local current_item_set_count = #TabItemList[active_tab]
    if current_item_set_count == 0 then return end
    handle_control_stick_inputs(m)

    if csd.up or csd.left or csd.down or csd.right then
        play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
        if selected_item_index == 0 then
            selected_item_index = 1
        end

        if csd.up and selected_item_index > item_list_column_count then
            selected_item_index = selected_item_index - item_list_column_count
        elseif csd.down and selected_item_index < current_item_set_count then
            local remaining = math.min(current_item_set_count - selected_item_index, item_list_column_count)
            selected_item_index = selected_item_index + remaining
        end
        if csd.left and selected_item_index > 1 then
            selected_item_index = selected_item_index - 1
        elseif csd.right and selected_item_index < current_item_set_count then
            selected_item_index = selected_item_index + 1
        end
    end
end

---@param pressed integer
local function handle_pick_item_inputs(pressed)
    if moved_mouse then
        if mouse_prev_item_index ~= selected_item_index then
            play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
        end
        mouse_prev_item_index = selected_item_index
        if mouse_has_clicked and TabItemList[active_tab] and TabItemList[active_tab][selected_item_index] then
            HotbarItemList[selected_hotbar_index] = table.deepcopy(TabItemList[active_tab][selected_item_index])
            play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        end
    elseif not moved_mouse and pressed & A_BUTTON ~= 0 and TabItemList[active_tab] and TabItemList[active_tab][selected_item_index] then
        HotbarItemList[selected_hotbar_index] = table.deepcopy(TabItemList[active_tab][selected_item_index])
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
    end
end

---@param pressed integer
local function handle_paging_inputs(pressed)
    if pressed & L_CBUTTONS ~= 0 and current_item_page > 1 then
        current_item_page = current_item_page - 1
        play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    elseif pressed & R_CBUTTONS ~= 0 and current_item_page < item_page_max then
        current_item_page = current_item_page + 1
        play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    end
end

---@param m MarioState
local function handle_standard_inputs(m)
    local pressed = m.controller.buttonPressed
    if moved_mouse and pressed ~= 0 and not mouse_has_clicked and not mouse_has_right_clicked then
        moved_mouse = false
    end
    if (pressed & START_BUTTON ~= 0) or (not moved_mouse and pressed & X_BUTTON ~= 0) or (moved_mouse and mouse_has_right_clicked) then
        MenuOpen = false
        return
    end

    handle_change_tab_inputs(pressed)
    handle_item_selection_inputs(m)
    handle_paging_inputs(pressed)
    if selected_item_index > 0 then
        handle_pick_item_inputs(pressed)
    end
end

----------------------------------------------------

---@param m MarioState
local function handle_menu_inputs(m)
    if active_tab <= TAB_MAIN_END then
        handle_standard_inputs(m)
        m.controller.buttonPressed = 0
    end
end

----------------------------------------------------

---@param m MarioState
local function before_mario_update(m)
    if m.playerIndex ~= 0 then return end
    if not CanBuild then
        camera_romhack_allow_dpad_usage(1)
        camera_config_enable_dpad(true)
        return
    end

    if not MenuOpen and m.controller.buttonDown & L_TRIG == 0 and m.controller.buttonPressed & X_BUTTON ~= 0 then
        MenuOpen = true
        return
    end

    handle_hotbar_inputs(m)
    if MenuOpen then
        m.freeze = 1
        handle_mouse_input()
        handle_menu_inputs(m)
    end

    camera_romhack_allow_dpad_usage(0)
    camera_config_enable_dpad(false)
    if HotbarItemList[selected_hotbar_index] then
        gCurrentItem = HotbarItemList[selected_hotbar_index].item
    end
end

------------------------------------------------------------------------------------------------

hook_event(HOOK_ON_HUD_RENDER_BEHIND, hud_render)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)

------------------------------------------------------------------------------------------------

local function on_controls_chat_command()
    CanBuild = true
    MenuOpen = true
    active_tab = TAB_HELP
    set_mario_action(gMarioStates[0], ACT_FREE_MOVE, 0)
    return true
end

hook_chat_command("controls", "Displays the controls used in this mod", on_controls_chat_command)