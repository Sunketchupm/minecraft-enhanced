local Items = require("item_list")
local Mouse = require("mouse")
local Hotbar = require("hotbar")

local ItemGrid = {}

---@class ItemGrid
    ---@field index integer
    ---@field items MenuItemLink[]
    ---@field rows integer
    ---@field columns integer
    ---@field pages { count: integer, index: integer, item_count: integer }

local BASE_SLOT_SIZE = 65

local sLastSelectedIndex = 0
local sIsHolding = false

---@param size number
---@return number
---@return integer
local function determine_slot_dimension(size)
    local count = size / BASE_SLOT_SIZE
    local whole_count = math.floor(count)
    local new_slot_size = 0
    if count ~= whole_count then
        local div_decimal = count - whole_count
        new_slot_size = BASE_SLOT_SIZE + (BASE_SLOT_SIZE * (div_decimal / whole_count))
    end
    return new_slot_size, whole_count
end

---@param width number
---@param height number
---@return integer, integer, number, number
local function calculate_slots(width, height)
    local slot_width, column_count = determine_slot_dimension(width)
    local slot_height, row_count = determine_slot_dimension(height)

    return row_count, column_count, slot_width, slot_height
end

---@param rect Rectangle
---@param item_grid ItemGrid
---@return integer
ItemGrid.render = function(rect, item_grid)
    local x, y, width, height = from_rect(rect)

    local row_count, column_count, slot_width, slot_height = calculate_slots(width, height)

    local items = item_grid.items
    local item_count = #items
    local items_per_page = column_count * row_count
    local page_count = item_count // items_per_page
    item_grid.pages.count = page_count

    local page_index = item_grid.pages.index
    local page_begin = page_index * items_per_page
    local page_end = page_begin + items_per_page

    item_grid.rows = row_count
    item_grid.columns = column_count
    item_grid.pages.item_count = items_per_page

    local hovered_index = -1
    for absolute_index = page_begin, page_end - 1, 1 do
        if not items[absolute_index + 1] then
            break
        end

        local relative_index = absolute_index - page_begin

        local slot_x = x + ((slot_width * (relative_index % column_count)))
        local slot_y = y + ((slot_height * (relative_index // column_count)))
        local slot_rect = into_rect(slot_x, slot_y, slot_width, slot_height)

        if Mouse.moved and Mouse.is_within(slot_rect) and not sIsHolding then
            item_grid.index = absolute_index
            hovered_index = absolute_index
        end

        if absolute_index == item_grid.index then
            djui_hud_set_color(255, 255, 255, 150)
            djui_hud_render_rect(slot_x, slot_y, slot_width, slot_height)
        end

        Items.render(slot_rect, items[absolute_index + 1].icon)
    end

    -- Render lines
    for i = 1, column_count + 1, 1 do
        djui_hud_set_color_with_table(MAIN_RECT_COLORS[2])
        djui_hud_render_rect(x + (slot_width * (i - 1) - 1), y, 2, height)
        djui_hud_set_color_with_table(MAIN_RECT_COLORS[3])
        djui_hud_render_rect(x + (slot_width * (i - 1) + 1), y, 2, height)
    end
    for i = 1, row_count + 1, 1 do
        djui_hud_set_color_with_table(MAIN_RECT_COLORS[2])
        djui_hud_render_rect(x, y + (slot_height * (i - 1) - 1), width, 2)
        djui_hud_set_color_with_table(MAIN_RECT_COLORS[3])
        djui_hud_render_rect(x, y + (slot_height * (i - 1) + 1), width, 2)
    end

    if Mouse.moved and hovered_index == -1 and not sIsHolding then
        item_grid.index = -1
    end
    return hovered_index
end

---@param item MenuItemLink
ItemGrid.render_dragging_icon = function(item)
    if not Mouse.moved then return end

    local menu_item = item
    if menu_item then
        local icon = menu_item.icon
        if icon.texture then
            local scale_x, scale_y = Items.rescale_icon(icon.texture)
            djui_hud_set_color_with_table(WHITE)
            djui_hud_render_texture_interpolated(icon.texture, Mouse.prev.x, Mouse.prev.y, scale_x, scale_y, Mouse.pos.x, Mouse.pos.y, scale_x, scale_y)
        elseif icon.color then
            djui_hud_set_color_with_table(icon.color)
            djui_hud_render_rect_interpolated(Mouse.prev.x, Mouse.prev.y, 30, 30, Mouse.pos.x, Mouse.pos.y, 30, 30)
        end
    end
end

----------------------------------------------------------------------------------------------

---@param item_grid ItemGrid
---@param stick Directions
local function handle_item_selection_inputs(item_grid, stick)
    local items_per_page = item_grid.pages.item_count
    local current_item_index = item_grid.index
    local current_page_index = item_grid.pages.index
    local relative_item_index = current_item_index % items_per_page
    local begin_page_index = ((current_page_index + 1) * items_per_page) - items_per_page

    if stick.up or stick.left or stick.down or stick.right then
        if current_item_index < 0 then
            current_item_index = begin_page_index
            audio_sample_play(SOUND_MCE_MOVE, gGlobalSoundSource, 1)
            item_grid.index = current_item_index
            return
        end

        if stick.up and relative_item_index > 0 then
            current_item_index = current_item_index - item_grid.columns
            relative_item_index = relative_item_index - item_grid.columns
        elseif stick.down and relative_item_index < items_per_page then
            current_item_index = current_item_index + item_grid.columns
            relative_item_index = relative_item_index + item_grid.columns
        end

        if stick.left and relative_item_index > 0 then
            current_item_index = current_item_index - 1
            relative_item_index = relative_item_index - 1
        elseif stick.right and relative_item_index < items_per_page - 1 then
            current_item_index = current_item_index + 1
            relative_item_index = relative_item_index + 1
        end

        if relative_item_index < 0 then
            current_item_index = begin_page_index
        elseif relative_item_index > items_per_page - 1 then
            current_item_index = begin_page_index + items_per_page - 1
        end

        if current_item_index >= #item_grid.items then
            current_item_index = #item_grid.items - 1
        end
        if not item_grid.items[current_item_index] then
            current_item_index = begin_page_index
        end

        audio_sample_play(SOUND_MCE_PRESS, gGlobalSoundSource, 1)
    end
    item_grid.index = current_item_index
end

---@param item_link MenuItemLink
---@return MenuItemLink
local function handle_item_settings(item_link)
    local item = item_link.item
    if gMenu.settings.transparent then
        if item.behavior == bhvMceBlock then
            local alpha = item.params.color.a
            if alpha < 0 then
                alpha = 255
            else
                alpha = 127
            end
            item.params.color.a = alpha
        end
    end
    if gCurrentTab == TAB_BUILDING_BLOCKS_COLORS then
        mce_block_set_colored(item)
    end
    return item_link
end

---@param item MenuItemLink
local function on_confirm_item_input(item)
    sIsHolding = false
    handle_item_settings(item)
    ---@type MenuItemLink
    local hotbar_item = table.deepcopy(item)
    Hotbar.items[Hotbar.index] = hotbar_item
    audio_sample_play(SOUND_MCE_PRESS, gGlobalSoundSource, 1)
end

---@param m MarioState
---@param item MenuItemLink
---@param stick Directions
local function handle_holding_item_inputs(m, item, stick)
    if Mouse.moved then
        if Mouse.released.left then
            item.held = false
            on_confirm_item_input(item)
        end
    else
        if stick.left and Hotbar.index > 1 then
            Hotbar.index = Hotbar.index - 1
            audio_sample_play(SOUND_MCE_PRESS, gGlobalSoundSource, 1)
        elseif stick.right and Hotbar.index < #Hotbar.items then
            Hotbar.index = Hotbar.index + 1
            audio_sample_play(SOUND_MCE_PRESS, gGlobalSoundSource, 1)
        end

        if m.controller.buttonReleased & A_BUTTON ~= 0 then
            item.held = false
            on_confirm_item_input(item)
        end
    end
end

---@param m MarioState
---@param item_grid ItemGrid
local function handle_pick_up_item_inputs(m, item_grid)
    local pressed = m.controller.buttonPressed
    local item = item_grid.items[item_grid.index + 1]
    if not item then return end

    if Mouse.moved then
        --[[ if sLastSelectedIndex ~= item_grid.index then
            audio_sample_play(SOUND_MCE_PRESS, gGlobalSoundSource, 1)
        end
        sLastSelectedIndex = item_grid.index]]

        if Mouse.pressed.left then
            item.held = true
            sIsHolding = true
        end
    elseif pressed & A_BUTTON ~= 0 then
        item.held = true
        sIsHolding = true
    end
end

--------------------------------------------------------

---@param item_grid ItemGrid
---@param c_stick Directions
local function handle_paging_inputs(item_grid, c_stick)
    local invert_multiplier = gMenu.settings.invert_scroll and -1 or 1
    local pages = item_grid.pages
    if not pages then return end

    if Mouse.moved then
        if Mouse.scroll.y * invert_multiplier > 0 and pages.index > 0 then
            pages.index = pages.index - 1
            item_grid.index = pages.item_count * pages.index
            audio_sample_play(SOUND_MCE_SCROLL, gGlobalSoundSource, 1)
        elseif Mouse.scroll.y * invert_multiplier < 0 and pages.index < pages.count then
            pages.index = pages.index + 1
            item_grid.index = pages.item_count * pages.index
            audio_sample_play(SOUND_MCE_SCROLL, gGlobalSoundSource, 1)
        end
    else
        if c_stick.left and pages.index > 0 then
            pages.index = pages.index - 1
            item_grid.index = pages.item_count * pages.index
            audio_sample_play(SOUND_MCE_SCROLL, gGlobalSoundSource, 1)
        elseif c_stick.right and pages.index < pages.count then
            pages.index = pages.index + 1
            item_grid.index = pages.item_count * pages.index
            audio_sample_play(SOUND_MCE_SCROLL, gGlobalSoundSource, 1)
        end
    end
end

---@param m MarioState
local function handle_open_settings_inputs(m)
    --gCurrentTab = TAB_TO_SETTINGS[gCurrentTab] or gCurrentTab
    --on_change_tab_input()

    -- TEMPORARY
    if m.controller.buttonPressed & D_CBUTTONS == 0 then return end
    gMenu.settings.transparent = not gMenu.settings.transparent
    if gMenu.settings.transparent then
        djui_chat_message_create("Transparency active. ONLY WORKS FOR BLOCKS.")
    else
        djui_chat_message_create("Transparency disabled.")
    end
    return true
end

---@param m MarioState
---@param item_grid ItemGrid
---@param stick Directions
---@param c_stick Directions
ItemGrid.inputs = function(m, item_grid, stick, c_stick)
    handle_paging_inputs(item_grid, c_stick)

    local item = item_grid.items[item_grid.index + 1]
    if item and item.held then
        handle_holding_item_inputs(m, item, stick)
    else
        --handle_open_settings_inputs(m)
        handle_item_selection_inputs(item_grid, stick)
        handle_pick_up_item_inputs(m, item_grid)
    end

    gCurrentItemLink = item
end

return ItemGrid
