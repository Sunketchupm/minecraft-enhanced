MenuOpen = false

local active_tab = 1
local selected_item_index = 1
local current_item_page = 1
local item_page_max = 1
---@type MenuItemLink[][]
local item_pages = {}

local TAB_BUILDING_BLOCKS = 1
local TAB_ITEMS = 2
local TAB_ENEMIES = 3
local TAB_HELP = 4
local TAB_MAIN_END = 4

local item_list_row_count = 10
local item_list_column_count = 10

local show_controls = true

-------------- TEXTURES --------------
local A_BUTTON_TEX = get_texture_info("Abutton")
local B_BUTTON_TEX = get_texture_info("Bbutton")
local X_BUTTON_TEX = get_texture_info("Xbutton")
local Y_BUTTON_TEX = get_texture_info("Ybutton")
--local U_JPAD_TEX = get_texture_info("UJpad")
--local L_JPAD_TEX = get_texture_info("LJpad")
--local D_JPAD_TEX = get_texture_info("DJpad")
--local R_JPAD_TEX = get_texture_info("RJpad")
local UD_JPAD_TEX = get_texture_info("U-Djpad")
local LR_JPAD_TEX = get_texture_info("L-Rjpad")
local U_CBUTTON_TEX = get_texture_info("Ucbutton")
local L_CBUTTON_TEX = get_texture_info("Lcbutton")
local D_CBUTTON_TEX = get_texture_info("Dcbutton")
local R_CBUTTON_TEX = get_texture_info("Rcbutton")
local L_TRIG_TEX = get_texture_info("Ltrig")
local R_TRIG_TEX =  get_texture_info("Rtrig")
local Z_TRIG_TEX =  get_texture_info("Ztrig")
local CONTROL_STICK_TEX = get_texture_info("Ctrlstick")
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
SelectedHotbarIndex = 1
local HOTBAR_SIZE = 10
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
        rotation = gVec3sZero(),
        animState = anim_state,
        mock = mock_settings
    }, icon = icon }

    item.self = item
    table.insert(TabItemList[tab], item)
end

-- If TextureInfo, use the texture
-- If a table of coordinates, use the coordinates
local block_icons = {
    get_texture_info("outside_09000000"),
    get_texture_info("outside_0900B400"),
    get_texture_info("outside_09004000"),
    get_texture_info("outside_09008000"),
    get_texture_info("outside_09009800"),
    get_texture_info("outside_09009000"),
    get_texture_info("outside_09000800"),
    get_texture_info("outside_09007800"),
    get_texture_info("outside_09003000"),
    get_texture_info("outside_09005800"),
    get_texture_info("cave_09006800"),
    get_texture_info("cave_09009800"),
    get_texture_info("cave_09001000"),
    get_texture_info("fire_0900A000"),
    get_texture_info("fire_0900A800"),
    get_texture_info("fire_0900B000"),
    get_texture_info("fire_0900B800"),
    get_texture_info("fire_09000800"),
    get_texture_info("fire_09001000"),
    get_texture_info("fire_09001800"),
    get_texture_info("fire_09002000"),
    get_texture_info("fire_09002800"),
    get_texture_info("fire_09003000"),
    get_texture_info("fire_09003800"),
    get_texture_info("fire_09004000"),
    get_texture_info("fire_09004800"),
    get_texture_info("fire_09005000"),
    get_texture_info("fire_09005800"),
    get_texture_info("fire_09006000"),
    get_texture_info("fire_09007000"),
    get_texture_info("fire_09008000"),
    get_texture_info("fire_09009000"),
    get_texture_info("generic_0900A000"),
    get_texture_info("generic_0900A800"),
    get_texture_info("generic_09000800"),
    get_texture_info("generic_09001000"),
    get_texture_info("generic_09001800"),
    get_texture_info("generic_09002000"),
    get_texture_info("generic_09002800"),
    get_texture_info("generic_09003000"),
    get_texture_info("generic_09003800"),
    get_texture_info("generic_09004800"),
    get_texture_info("generic_09005000"),
    get_texture_info("generic_09007800"),
    get_texture_info("generic_09008000"),
    get_texture_info("generic_09008800"),
    get_texture_info("generic_09009000"),
    get_texture_info("grass_09000000"),
    get_texture_info("grass_0900A800"),
    get_texture_info("grass_09000800"),
    get_texture_info("grass_09001000"),
    get_texture_info("grass_09002000"),
    get_texture_info("grass_09003000"),
    get_texture_info("grass_09003800"),
    get_texture_info("grass_09004000"),
    get_texture_info("grass_09004800"),
    get_texture_info("grass_09006800"),
    get_texture_info("grass_09007000"),
    get_texture_info("grass_09008000"),
    get_texture_info("grass_09008800"),
    get_texture_info("grass_09009000"),
    get_texture_info("grass_09009800"),
    get_texture_info("inside_09003000"),
    get_texture_info("inside_09003800"),
    get_texture_info("inside_09004000"),
    get_texture_info("inside_09005000"),
    get_texture_info("machine_09000000"),
    get_texture_info("machine_09001000"),
    get_texture_info("machine_09002000"),
    get_texture_info("machine_09002800"),
    get_texture_info("machine_09003800"),
    get_texture_info("machine_09005000"),
    get_texture_info("machine_09007000"),
    get_texture_info("machine_09008400"),
    get_texture_info("mountain_09000000"),
    get_texture_info("mountain_0900A800"),
    get_texture_info("mountain_0900B800"),
    get_texture_info("mountain_0900C000"),
    get_texture_info("mountain_09003800"),
    get_texture_info("mountain_09004000"),
    get_texture_info("mountain_09004800"),
    get_texture_info("mountain_09005000"),
    get_texture_info("mountain_09006800"),
    get_texture_info("mountain_09007000"),
    get_texture_info("sky_09000800"),
    get_texture_info("sky_09001000"),
    get_texture_info("sky_09001800"),
    get_texture_info("sky_09003000"),
    get_texture_info("sky_09004800"),
    get_texture_info("sky_09007000"),
    get_texture_info("sky_09007800"),
    get_texture_info("snow_09000800"),
    get_texture_info("snow_09002000"),
    get_texture_info("snow_09002800"),
    get_texture_info("snow_09003000"),
    get_texture_info("snow_09003800"),
    get_texture_info("snow_09004000"),
    get_texture_info("snow_09004800"),
    get_texture_info("snow_09005000"),
    get_texture_info("snow_09006000"),
    get_texture_info("snow_09008000"),
    get_texture_info("snow_09008800"),
    get_texture_info("spooky_09000000"),
    get_texture_info("spooky_0900A000"),
    get_texture_info("spooky_09004800"),
    get_texture_info("spooky_09006000"),
    get_texture_info("spooky_09006800"),
    get_texture_info("water_09000000"),
    get_texture_info("water_0900A000"),
    get_texture_info("water_09005800"),
    get_texture_info("barrier")
}

add_first_update(function ()
    for i = 1, 110, 1 do
        local texture = block_icons[i] or gTextures.no_camera
        ---@type MenuItemLink
        local menu_item = {
            item = {
                behavior = bhvMceBlock,
                model = E_MODEL_MCE_BLOCK,
                spawnYOffset = 0,
                params = 0,
                size = gVec3fOne(),
                rotation = gVec3sZero(),
                animState = i,
                mock = {}
            },
            icon = texture
        }
        menu_item.self = menu_item
        TabItemList[TAB_BUILDING_BLOCKS][i] = menu_item
    end
    table.insert(TabItemList[TAB_BUILDING_BLOCKS], {
        item = {
            behavior = bhvMceBlock,
            model = E_MODEL_MCE_BLOCK,
            spawnYOffset = 0,
            params = 0,
            size = gVec3fOne(),
            rotation = gVec3sZero(),
            animState = BLOCK_BARRIER_ANIM,
            mock = {}
        },
        icon = get_texture_info("barrier")
    })

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
local mouse_has_scrolled = 0

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
    mouse_has_scrolled = djui_hud_get_mouse_scroll_y()
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
    local new_item_pages = {{}}
    local stored_page = 1
    local item_in_page_index = 0
    for i = 1, #items do
        item_in_page_index = item_in_page_index + 1
        if item_in_page_index > max_items_per_page then
            item_in_page_index = 1
            stored_page = stored_page + 1
            new_item_pages[stored_page] = {}
        end
        new_item_pages[stored_page][item_in_page_index] = items[i]
    end
    item_page_max = stored_page
    return new_item_pages
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
    item_pages = determine_pages(column_count, row_count, items)
    local items_per_page = column_count * row_count

    for index, item in ipairs(item_pages[current_item_page]) do
        local slot_x = x + ((slot_width * ((index - 1) % item_list_column_count)))
        local slot_y = y + ((slot_height * ((index - 1) // item_list_column_count)))
        if moved_mouse and mouse_is_within(slot_x, slot_y, slot_x + slot_width, slot_y + slot_height) then
            selected_item_index = index + (items_per_page * (current_item_page - 1))
            hovering_over_item = true
        end

        if index + (items_per_page * (current_item_page - 1)) == selected_item_index then
            djui_hud_set_color(255, 255, 255, 150)
            djui_hud_render_rect(slot_x, slot_y, slot_width, slot_height)
        end
        if item.icon then
            local item_scale = 1.5
            local item_x = (slot_x + slot_width * 0.5) - (item.icon.width * 0.5 * item_scale)
            local item_y = (slot_y + slot_height * 0.5) - (item.icon.height * 0.5 * item_scale)
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_render_texture(item.icon, item_x, item_y, item_scale, item_scale)
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
    local text_scale = 1.25
    local text = "Clear Hotbar"
    local text_size = djui_hud_measure_text(text) * text_scale
    local text_x = (x + width * 0.55) - (text_size * 0.5)
    local text_y = (y + height) - 50 * text_scale
    local texture_scale = 2.5
    local texture_x = (x + width * 0.46) - (text_size * 0.5)
    local texture_y = (y + height) - 24 * texture_scale
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_render_texture(Y_BUTTON_TEX, texture_x, texture_y, texture_scale, texture_scale)
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_print_text(text, text_x, text_y, text_scale)
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
local function render_help_tab(x, y, width, height)
    render_tab_header(x, y, width, height, "Help")
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
    local y = screen_height - ((show_controls and height * 1.8) or height) --need space for on-screen controls
    djui_hud_set_color(64, 64, 32, 192)
    djui_hud_render_rect(x, y, width, height)
    for index, item in ipairs(HotbarItemList) do
        local slot_width = width * 0.1
        local slot_height = height * 0.95
        local slot_x = x + slot_width * (index - 1)
        local slot_y = y
        if MenuOpen and moved_mouse and mouse_is_within(slot_x, slot_y, slot_x + slot_width, slot_y + slot_height) then
            SelectedHotbarIndex = index
        end

        if index == SelectedHotbarIndex then
            djui_hud_set_color(255, 255, 255, 150)
            djui_hud_render_rect(slot_x, slot_y, slot_width, slot_height)
        end
        if item.icon then
            local item_scale = 1.5
            local item_x = (slot_x + slot_width * 0.5) - (item.icon.width * 0.5 * item_scale)
            local item_y = (slot_y + slot_height * 0.5) - (item.icon.height * 0.5 * item_scale)
            djui_hud_set_color(255, 255, 255, 255)
            djui_hud_render_texture(item.icon, item_x, item_y, item_scale, item_scale)
        end
        djui_hud_set_color(128, 128, 128, 255)
        djui_hud_render_rect(slot_x, y, 3, slot_height)
    end
    render_rectangle_borders(x, y, width, height, {r = 128, g = 128, b = 128, a = 255}, {r = 128, g = 128, b = 128, a = 255}, 0.01, 0.08)
    render_pixel_border(x, y, width, height, {r = 0, g = 0, b = 0, a = 255}, 2)
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

---@param x number
---@param y number
---@param buttons {prefix: string?, postfix: string?, texture: TextureInfo}[]
local function render_controls_tip(x, y, buttons)
    local screen_width = djui_hud_get_screen_width()
    local screen_height = djui_hud_get_screen_height()
    local text_scale = (screen_width/screen_height) * 0.55
    local texture_scale = (screen_width/screen_height) * 1.1
    local initial_x = x
    local texture_y = y

    djui_hud_set_color(255, 255, 255, 255)
    for i, button in ipairs(buttons) do
        local texture = button.texture
        local texture_x = initial_x
        if button.prefix then
            ---@type string
            local prefix = button.prefix
            local text_size = djui_hud_measure_text(prefix) * text_scale
            local text_x = texture_x
            texture_x = text_x + text_size
            render_shadowed_text(prefix, text_x, texture_y, text_scale)
            initial_x = texture_x + texture.width * texture_scale
        end
        if button.postfix then
            ---@type string
            local postfix = button.postfix
            local text_size = djui_hud_measure_text(postfix) * text_scale
            local text_x = texture_x + texture.width * text_scale
            render_shadowed_text(postfix, text_x, texture_y, text_scale)
            initial_x = text_x + text_size
        end
        djui_hud_render_texture(texture, texture_x, texture_y, texture_scale, texture_scale)
    end
end

---@param screen_width number
---@param screen_height number
local function render_controls(screen_width, screen_height)
    local x = screen_width * 0.02
    local y = screen_height * 0.955
    if not CanBuild then
        djui_hud_set_color(0, 0, 0, 60)
        render_controls_tip(x * 0.98, y, {{prefix = "", texture = L_TRIG_TEX}, {postfix = "  Fly (Enter Build Mode)", texture = L_TRIG_TEX}})
    else
        if not MenuOpen then
            local l_held_modifier = gMarioStates[0].controller.buttonDown & L_TRIG ~= 0
            if not l_held_modifier then
                if not gCurrentItem then -- no hold L, no selected item
                    render_controls_tip(x, y, {{postfix = "  Fly Up", texture = A_BUTTON_TEX}})
                    render_controls_tip(x * 5.3, y, {{postfix = "  Fly Down", texture = Z_TRIG_TEX}})
                    render_controls_tip(x * 10.4, y, {{postfix = "  Sprint Fly", texture = B_BUTTON_TEX}})
                    render_controls_tip(x * 16.2, y, {{postfix = "  Open Menu", texture = X_BUTTON_TEX}})
                    render_controls_tip(x * 21.7, y, {{postfix = "  Cycle Hotbar", texture = LR_JPAD_TEX}})
                    render_controls_tip(x * 28.4, y, {{prefix = "", texture = L_TRIG_TEX}, {postfix = "  Stop Flying", texture = L_TRIG_TEX}})
                    render_controls_tip(x * 35.6, y, {{postfix = "  Lock Face Angle/More", texture = L_TRIG_TEX}})
                else -- no hold L, item selected
                    render_controls_tip(x, y, {{postfix = "  Open Menu", texture = X_BUTTON_TEX}})
                    render_controls_tip(x * 6.4, y, {{postfix = "  Place/Delete Item", texture = Y_BUTTON_TEX}})
                    render_controls_tip(x * 14.7, y, {{postfix = "  Item Elevation", texture = UD_JPAD_TEX}})
                    render_controls_tip(x * 22, y, {{postfix = "  Cycle Hotbar", texture = LR_JPAD_TEX}})
                    render_controls_tip(x * 28.6, y, {{prefix = "", texture = L_TRIG_TEX}, {postfix = "  Stop Flying", texture = L_TRIG_TEX}})
                    render_controls_tip(x * 35.7, y, {{postfix = "  Lock Face Angle/More", texture = L_TRIG_TEX}})
                end
            else
                if not gCurrentItem then -- L held, no selected item
                    render_controls_tip(x, y, {{postfix = "  Slow Fly", texture = B_BUTTON_TEX}})
                    render_controls_tip(x * 6.1, y, {{prefix = "", texture = U_CBUTTON_TEX}, {postfix = "  Adjust Pitch", texture = D_CBUTTON_TEX}})
                    render_controls_tip(x * 13.4, y, {{prefix = "", texture = L_CBUTTON_TEX}, {postfix = "  Adjust Yaw", texture = R_CBUTTON_TEX}})
                    render_controls_tip(x * 20.1, y, {{postfix = "  Adjust Roll", texture = LR_JPAD_TEX}})
                    render_controls_tip(x * 26.2, y, {{postfix = "  Reset Angle", texture = X_BUTTON_TEX}})
                else -- L held, item selected
                    render_controls_tip(x, y, {{postfix = "  Slow Fly", texture = B_BUTTON_TEX}})
                    render_controls_tip(x * 6.1, y, {{postfix = "  Place/Delete Item", texture = Y_BUTTON_TEX}})
                    render_controls_tip(x * 14.4, y, {{postfix = "  Adjust Size", texture = UD_JPAD_TEX}})
                    render_controls_tip(x * 20.5, y, {{prefix = "", texture = U_CBUTTON_TEX}, {postfix = "  Adjust Pitch", texture = D_CBUTTON_TEX}})
                    render_controls_tip(x * 27.8, y, {{prefix = "", texture = L_CBUTTON_TEX}, {postfix = "  Adjust Yaw", texture = R_CBUTTON_TEX}})
                    render_controls_tip(x * 34.5, y, {{postfix = "  Adjust Roll", texture = LR_JPAD_TEX}})
                    render_controls_tip(x * 40.6, y, {{postfix = "  Reset Angle", texture = X_BUTTON_TEX}})
                end
            end
        else
            render_controls_tip(x, y, {{postfix = "  Move Selection", texture = CONTROL_STICK_TEX}})
            render_controls_tip(x * 8.3, y, {{postfix = "  Select Item", texture = A_BUTTON_TEX}})
            render_controls_tip(x * 14.5, y, {{postfix = "  Close Menu", texture = X_BUTTON_TEX}})
            render_controls_tip(x * 20.3, y , {{prefix = "", texture = L_CBUTTON_TEX}, {postfix = "  Next/Previous Page", texture = R_CBUTTON_TEX}})
            render_controls_tip(x * 29.9, y, {{prefix = "", texture = L_TRIG_TEX}, {postfix = "  Next/Previous Tab", texture = R_TRIG_TEX}})
            render_controls_tip(x * 39, y, {{postfix = "  Cycle Hotbar", texture = LR_JPAD_TEX}})
        end
    end
end

----------------------------------------------------

local function hud_render()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_SPECIAL)
    local screen_width = djui_hud_get_screen_width()
    local screen_height = djui_hud_get_screen_height()
    if CanBuild then
        render_menu(screen_width, screen_height)
    end
    if show_controls then
        render_controls(screen_width, screen_height)
    end
end

------------------------------------------------------------------------------------------------

---@param m MarioState
local function handle_hotbar_inputs(m)
    if m.controller.buttonDown & L_TRIG ~= 0 then return end

    if m.controller.buttonPressed & L_JPAD ~= 0 then
        SelectedHotbarIndex = SelectedHotbarIndex - 1
        if SelectedHotbarIndex < 1 then
            SelectedHotbarIndex = HOTBAR_SIZE
        end
        if gCurrentItem then
            vec3f_copy(GridSize, gCurrentItem.size)
            vec3f_mul(GridSize, 200)
        end
    elseif m.controller.buttonPressed & R_JPAD ~= 0 then
        SelectedHotbarIndex = SelectedHotbarIndex + 1
        if SelectedHotbarIndex > HOTBAR_SIZE then
            SelectedHotbarIndex = 1
        end
        if gCurrentItem then
            vec3f_copy(GridSize, gCurrentItem.size)
            vec3f_mul(GridSize, 200)
        end
    end
    m.controller.buttonPressed = m.controller.buttonPressed & ~(L_JPAD | R_JPAD)
end

----------------------------------------------------

local function on_change_tab_input()
    mouse_tab_was_clicked_on = 0
    selected_item_index = 0
    current_item_page = 1
    play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
end

local function handle_change_tab_inputs(pressed)
    if pressed & L_TRIG ~= 0 then
        active_tab = active_tab - 1
        if active_tab < 1 then
            active_tab = TAB_MAIN_END
        end
        on_change_tab_input()
    elseif pressed & R_TRIG ~= 0 then
        active_tab = active_tab + 1
        if active_tab > TAB_MAIN_END then
            active_tab = 1
        end
        on_change_tab_input()
    elseif mouse_tab_was_clicked_on > 0 then
        active_tab = mouse_tab_was_clicked_on
        on_change_tab_input()
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
    if not used_csd.up and controller.stickY > 30 then csd.up = true used_csd.up = true moved_mouse = false else csd.up = false end
    if not used_csd.down and controller.stickY < -30 then csd.down = true used_csd.down = true moved_mouse = false else csd.down = false end
    if not used_csd.left and controller.stickX < -30 then csd.left = true used_csd.left = true moved_mouse = false else csd.left = false end
    if not used_csd.right and controller.stickX > 30 then csd.right = true used_csd.right = true moved_mouse = false else csd.right = false end
end

---@param m MarioState
local function handle_item_selection_inputs(m)
    local current_item_set_count = #item_pages[current_item_page]
    if current_item_set_count == 0 then return end
    handle_control_stick_inputs(m)
    local items_per_page = item_list_row_count * item_list_column_count
    local selected_item_offset = items_per_page * (current_item_page - 1)
    local relative_item_index = selected_item_index - selected_item_offset

    if selected_item_index == 0 then
        selected_item_index = selected_item_offset
        relative_item_index = 1
    end

    if csd.up or csd.left or csd.down or csd.right then
        if csd.up and relative_item_index > 1 then
            local remaining = relative_item_index - (relative_item_index - item_list_column_count)
            selected_item_index = math.max(selected_item_index - remaining, selected_item_offset + 1)
        elseif csd.down and relative_item_index < current_item_set_count then
            local remaining = math.min(current_item_set_count - relative_item_index, item_list_column_count)
            selected_item_index = selected_item_index + remaining
        end
        if csd.left and relative_item_index > 1 then
            selected_item_index = selected_item_index - 1
        elseif csd.right and relative_item_index < current_item_set_count then
            selected_item_index = selected_item_index + 1
        end

        play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
    end
end

local function on_pick_item_input()
    ---@type MenuItemLink
    local hotbar_item = table.deepcopy(TabItemList[active_tab][selected_item_index])
    HotbarItemList[SelectedHotbarIndex] = hotbar_item
    vec3f_set(GridSize, 200, 200, 200)
    play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
end

---@param pressed integer
local function handle_pick_item_inputs(pressed)
    if not TabItemList[active_tab] or not TabItemList[active_tab][selected_item_index] then return end
    if moved_mouse then
        if mouse_prev_item_index ~= selected_item_index then
            play_sound(SOUND_MENU_MESSAGE_NEXT_PAGE, gGlobalSoundSource)
        end
        mouse_prev_item_index = selected_item_index
        if mouse_has_clicked then
            on_pick_item_input()
        end
    elseif pressed & A_BUTTON ~= 0 then
        on_pick_item_input()
    end
end

---@param pressed integer
local function handle_paging_inputs(pressed)
    if (pressed & L_CBUTTONS ~= 0 or (moved_mouse and mouse_has_scrolled < 0)) and current_item_page > 1 then
        current_item_page = current_item_page - 1
        selected_item_index = 0
        play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    elseif (pressed & R_CBUTTONS ~= 0 or (moved_mouse and mouse_has_scrolled > 0)) and current_item_page < item_page_max then
        current_item_page = current_item_page + 1
        selected_item_index = 0
        play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    end
end

---@param pressed integer
local function handle_extra_inputs(pressed)
    if pressed & Y_BUTTON ~= 0 then
        for i = 1, HOTBAR_SIZE, 1 do
            HotbarItemList[i] = { item = nil, icon = nil } ---@diagnostic disable-line: assign-type-mismatch
        end
        play_sound(SOUND_MENU_LET_GO_MARIO_FACE, gGlobalSoundSource)
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
    handle_extra_inputs(pressed)
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

    if not MenuOpen and m.controller.buttonPressed & X_BUTTON ~= 0 then
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
    if HotbarItemList[SelectedHotbarIndex] then
        gCurrentItem = HotbarItemList[SelectedHotbarIndex].item
    end
end

------------------------------------------------------------------------------------------------

hook_event(HOOK_ON_HUD_RENDER_BEHIND, hud_render)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)

------------------------------------------------------------------------------------------------

local function on_show_controls_mod_menu(_, show)
    show_controls = show
    return true
end

hook_mod_menu_checkbox("Show Controls", true, on_show_controls_mod_menu)

local function on_transparent_chat_command()
    local item = HotbarItemList[SelectedHotbarIndex].item
    if item and item.model == E_MODEL_MCE_BLOCK then
        if item.animState >= BLOCK_ANIM_STATE_TRANSPARENT_START then
            item.animState = item.animState - BLOCK_ANIM_STATE_TRANSPARENT_START
            djui_chat_message_create("The current block is no longer transparent")
        else
            item.animState = item.animState + BLOCK_ANIM_STATE_TRANSPARENT_START
            if item.animState > BLOCK_BARRIER_ANIM then
                item.animState = BLOCK_BARRIER_ANIM
            end
            djui_chat_message_create("The current block is now transparent")
        end
    else
        djui_chat_message_create("A block must be selected in the hotbar")
    end
    return true
end

hook_chat_command("transparent", "Makes the current selected block transparent", on_transparent_chat_command)