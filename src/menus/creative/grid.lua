local Utils = require("../utils")
local Mouse = require("../mouse")

local Hotbar = require("../hotbar/class")

local Menu = require("class")
local List = require("list")

local Grid = {}

local BASE_SLOT_SIZE = 65

Grid.row_count = 0
Grid.column_count = 0
Grid.begin_index = 0
Grid.end_index = 0
Grid.current_mouse_slot = 0

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
---@param items MenuItemLink
---@param scroll MenuScroll
function Grid.render(rect, items, scroll)
    local row_count, column_count, slot_width, slot_height = calculate_slots(rect.width, rect.height)

    local items_per_page = column_count * row_count

    local page_begin = column_count * (scroll.index - 1)
    local page_end = page_begin + items_per_page

    scroll.max = (math.ceil(#items / column_count) - row_count) + 1
    Grid.row_count = row_count
    Grid.column_count = column_count
    Grid.begin_index = page_begin
    Grid.end_index = page_end

    local mouse_on_grid = false
    for absolute_index = page_begin, page_end - 1, 1 do
        if not items[absolute_index + 1] then
            break
        end

        local relative_index = absolute_index - page_begin

        local slot_x = rect.x + ((slot_width * (relative_index % column_count)))
        local slot_y = rect.y + ((slot_height * (relative_index // column_count)))
        local slot_rect = Utils.into_rect(slot_x, slot_y, slot_width, slot_height)

        if Mouse.moved and Mouse.is_within(slot_rect) then
            Menu.item.index = absolute_index
            if sCurrentMouseSlot ~= absolute_index then
                audio_sample_play(SOUND_MCE_MOVE, gGlobalSoundSource, 1)
            end
            sCurrentMouseSlot = absolute_index
            mouse_on_grid = true
        end

        if absolute_index == Menu.item.index then
            djui_hud_set_color(255, 255, 255, 150)
            djui_hud_render_rect(slot_x, slot_y, slot_width, slot_height)
        end

        List.render_on_rect(slot_rect, items[absolute_index + 1].icon)
    end
    if Mouse.moved and not mouse_on_grid then
        Menu.item.index = -1
    end

    -- Render lines
    for i = 1, column_count + 1, 1 do
        Utils.set_color_with_table(MAIN_RECT_COLORS.shine)
        djui_hud_render_rect(rect.x + (slot_width * (i - 1) - 1), rect.y, 2, rect.height)
        Utils.set_color_with_table(MAIN_RECT_COLORS.shade)
        djui_hud_render_rect(rect.x + (slot_width * (i - 1) + 1), rect.y, 2, rect.height)
    end
    for i = 1, row_count + 1, 1 do
        Utils.set_color_with_table(MAIN_RECT_COLORS.shine)
        djui_hud_render_rect(rect.x, rect.y + (slot_height * (i - 1) - 1), rect.width, 2)
        Utils.set_color_with_table(MAIN_RECT_COLORS.shade)
        djui_hud_render_rect(rect.x, rect.y + (slot_height * (i - 1) + 1), rect.width, 2)
    end
end

-------------------------------------------------------------------------------------------

---@param inputs Inputs
local function handle_holding_inputs(inputs)
    if Menu.item.link and (Mouse.released.left or inputs.buttons.released & A_BUTTON ~= 0) then
        ---@type MenuItemLink
        local link = table.deepcopy(Menu.item.link)
        if Menu.tab == CREATIVE_TAB_BUILDING_BLOCKS_COLORS then
            mce_block_toggle_flag(link.item, MCE_BLOCK_FLAG_COLORED)
        end
        Hotbar[Hotbar.index].link = link
        Menu.item.link = nil
        audio_sample_play(SOUND_MCE_PRESS, gGlobalSoundSource, 1)
    end
end

local function __select_item(change)
    local scroll = Menu[Menu.tab].scroll
    Menu.item.index = Menu.item.index + change
    if Menu.item.index < Grid.begin_index then
        scroll.index = scroll.index - 1
    elseif Menu.item.index > Grid.end_index - 1 then
        scroll.index = scroll.index + 1
    end
    Menu.item.index = math.clamp(Menu.item.index, 0, #Menu[Menu.tab].grid - 1)
    scroll.index = math.clamp(scroll.index, 1, scroll.max)
    audio_sample_play(SOUND_MCE_MOVE, gGlobalSoundSource, 1)
end

---@param inputs Inputs
local function handle_selection_inputs(inputs)
    if Menu.item.link then return end
    if inputs.stick.left then
        __select_item(-1)
    elseif inputs.stick.right then
        __select_item(1)
    end

    if inputs.stick.up then
        __select_item(-Grid.column_count)
    elseif inputs.stick.down then
        __select_item(Grid.column_count)
    end

    if Mouse.pressed.left or (not Mouse.moved and inputs.buttons.pressed & A_BUTTON ~= 0) then
        local selected_item = Menu[Menu.tab].grid[Menu.item.index + 1]
        if selected_item then
            Menu.item.link = selected_item
        end
    end
end

----------------------------------------------

---@param inputs Inputs
function Grid.inputs(inputs)
    handle_selection_inputs(inputs)
    handle_holding_inputs(inputs)
end

return Grid