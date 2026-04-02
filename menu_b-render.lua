local BASE_SLOT_SIZE = 65
local MAIN_RECT_COLORS = {
    { r = 200, g = 200, b = 200, a = 255 },
    { r = 255, g = 255, b = 255, a = 255 },
    { r = 90, g = 88, b = 88, a = 255 }
}

local sShowControls = true

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
    djui_hud_set_color_with_table(BLACK)
    djui_hud_print_text(text, shadow_x, shadow_y, scale)

    local text_x = shadow_x - 2
    local text_y = shadow_y - 2
    djui_hud_set_color_with_table(WHITE)
    djui_hud_print_text(text, text_x, text_y, scale)
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param color DjuiColor
---@param pixel_size number
local function render_pixel_border(x, y, width, height, color, pixel_size) ---------------------needs to be re-adjusted due to margin overlap
    djui_hud_set_color_with_table(color)
    djui_hud_render_rect(x, y, width, pixel_size)
    djui_hud_render_rect(x, y, pixel_size, height)
    djui_hud_render_rect(x, y + height, width, pixel_size)
    djui_hud_render_rect(x + width, y, pixel_size, height + pixel_size)
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
---@param colors DjuiColor[] {base, shine, shade}
---@param margin_width number
---@param margin_height number
---@param remove_pixel_border boolean
local function render_bordered_rectangle(x, y, width, height, colors, margin_width, margin_height, remove_pixel_border)
    render_rectangle_borders(x, y, width, height, colors[2], colors[3], margin_width, margin_height)
    if not remove_pixel_border then
        render_pixel_border(x, y, width, height, BLACK, 2)
    end
    djui_hud_set_color_with_table(colors[1])
    djui_hud_render_rect(x + width * margin_width, y + height * margin_height, width - width * margin_width * 2, height - height * margin_height * 2)
end

----------------------------------------------------

---@param icon TextureInfo
local function rescale_icon(icon)
    local texture_width = icon.width
    local texture_height = icon.height
    local item_scale_x = 1
    local item_scale_y = 1
    -- Normalize to 32x32
    if texture_width > 32 then
        local exponent = 2^(math.log(texture_width, 2) - 5)
        if exponent ~= 0 then
            item_scale_x = item_scale_x * (1/exponent)
        end
    end
    if texture_height > 32 then
        local exponent = 2^(math.log(texture_height, 2) - 5)
        if exponent ~= 0 then
            item_scale_y = item_scale_y * (1/exponent)
        end
    end
    return item_scale_x, item_scale_y
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param icon Icon
local function render_icon(x, y, width, height, icon)
    if icon.texture then
        local texture = icon.texture --[[@as TextureInfo]]
        local texture_width = texture.width
        local texture_height = texture.height
        local item_scale_x, item_scale_y = rescale_icon(texture)
        item_scale_x = item_scale_x * 1.5
        item_scale_y = item_scale_y * 1.5
        local item_x = (x + width * 0.5) - (texture_width * 0.5 * item_scale_x)
        local item_y = (y + height * 0.5) - (texture_height * 0.5 * item_scale_y)
        djui_hud_set_color_with_table(icon.color)

        djui_hud_render_texture(texture, item_x, item_y, item_scale_x, item_scale_y)
    else
        local color = icon.color
        djui_hud_set_color_with_table(color)
        local rect_width = 48
        local rect_height = 48
        local rect_x = (x + width * 0.5) - 24
        local rect_y = (y + height * 0.5) - 24
        djui_hud_render_rect(rect_x, rect_y, rect_width, rect_height)
    end
end

----------------------------------------------------

local function render_mouse()
    if not gMouse.moved then return end

    gMouse.prev.x = gMouse.pos.x
    gMouse.prev.y = gMouse.pos.y
    gMouse.pos.x = djui_hud_get_mouse_x()
    gMouse.pos.y = djui_hud_get_mouse_y()
    djui_hud_set_color_with_table(WHITE)
    djui_hud_render_texture_interpolated(MOUSE_TEX,
        gMouse.prev.x - MOUSE_TEX.width * 0.5, gMouse.prev.y- MOUSE_TEX.height * 0.5, 1, 1,
        gMouse.pos.x - MOUSE_TEX.width * 0.5, gMouse.pos.y - MOUSE_TEX.height * 0.5, 1, 1)
    --djui_hud_render_texture(gTextures.camera, mouse_x, mouse_y, 1, 1)
end

local function render_dragging_icon()
    if not gMouse.moved then return end

    local menu_item = gMenu.get_current_tab().items[gMouse.menu.prevItemIndex]
    if menu_item then
        local icon = menu_item.icon
        if icon.texture then
            local scale_x, scale_y = rescale_icon(icon.texture)
            djui_hud_set_color_with_table(WHITE)
            djui_hud_render_texture_interpolated(icon.texture, gMouse.prev.x, gMouse.prev.y, scale_x, scale_y, gMouse.pos.x, gMouse.pos.y, scale_x, scale_y)
        elseif icon.color then
            djui_hud_set_color(icon.color.r, icon.color.g, icon.color.b, icon.color.a)
            djui_hud_render_rect_interpolated(gMouse.prev.x, gMouse.prev.y, 30, 30, gMouse.pos.x, gMouse.pos.y, 30, 30)
        end
    end
end

local function mouse_is_within(start_x, start_y, end_x, end_y)
    return gMouse.pos.x > start_x and gMouse.pos.y > start_y and gMouse.pos.x < end_x and gMouse.pos.y < end_y
end

------------------------------------------------------------------------------------------------

---@param x number
---@param y number
---@param width number
---@param height number
local function render_item_list(x, y, width, height)
    local slot_width = gMenu.tabs.slots.width
    local slot_height = gMenu.tabs.slots.height
    local row_count = gMenu.tabs.slots.rows
    local column_count = gMenu.tabs.slots.columns
    local items_per_page = column_count * row_count

    local page_items = gMenu.get_current_page().items
    local page_index = gMenu.get_current_page_index() - 1

    local hovering_over_item = false
    for index, item in ipairs(page_items) do
        local slot_x = x + ((slot_width * ((index - 1) % column_count)))
        local slot_y = y + ((slot_height * ((index - 1) // column_count)))
        if gMouse.moved and mouse_is_within(slot_x, slot_y, slot_x + slot_width, slot_y + slot_height) then
            gMenu.current_item.index = index + (items_per_page * page_index)
            gMenu.current_item.item = item
            hovering_over_item = true
        end

        if index + (items_per_page * page_index) == gMenu.current_item.index then
            djui_hud_set_color(255, 255, 255, 150)
            djui_hud_render_rect(slot_x, slot_y, slot_width, slot_height)
        end

        if item.icon then
            render_icon(slot_x, slot_y, slot_width, slot_height, item.icon)
        end
    end

    for i = 1, gMenu.tabs.slots.columns + 1, 1 do
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_render_rect(x + (slot_width * (i - 1) - 1), y, 2, height)
        djui_hud_set_color(96, 96, 96, 255)
        djui_hud_render_rect(x + (slot_width * (i - 1) + 1), y, 2, height)
    end
    for i = 1, gMenu.tabs.slots.rows + 1, 1 do
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_render_rect(x, y + (slot_height * (i - 1) - 1), width, 2)
        djui_hud_set_color(96, 96, 96, 255)
        djui_hud_render_rect(x, y + (slot_height * (i - 1) + 1), width, 2)
    end

    if gMouse.moved and not hovering_over_item then
        gMenu.current_item.index = 0
        gMenu.current_item.item = nil
    end
end

---------------------------

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

local function determine_pages(row_count, column_count)
    local items = gMenu.get_current_tab_items()
    local item_count = #items
    local max_items_per_page = row_count * column_count
    local page_index = 1
    local relative_item_index = 1
    local pages = gMenu.get_current_tab_pages()
    for index in ipairs(pages) do
        pages[index] = nil
    end
    for i = 1, item_count do
        if relative_item_index > max_items_per_page then
            page_index = page_index + 1
            relative_item_index = 1
        end

        if not pages[page_index] then
            pages[page_index] = { items = {} }
        end
        pages[page_index].items[relative_item_index] = items[i]
        relative_item_index = relative_item_index + 1
    end
    pages.count = page_index
end

---@param width number
---@param height number
local function calculate_slots(width, height)
    local slot_width, column_count = determine_slot_dimension(width)
    local slot_height, row_count = determine_slot_dimension(height)

    determine_pages(row_count, column_count)

    gMenu.tabs.slots.width = slot_width
    gMenu.tabs.slots.height = slot_height
    gMenu.tabs.slots.rows = row_count
    gMenu.tabs.slots.columns = column_count
end

------------------------------------------------------------------------------------------------

---@param x number
---@param y number
---@param width number
---@param height number
---@param text string
---@param texture TextureInfo
---@param input_func function
local function render_menu_button(x, y, width, height, text, texture, input_func, override_darken)
    local text_scale = 0.7 * (width/height)
    local text_size = djui_hud_measure_text(text) * text_scale
    local texture_scale = 1.3 * (width/height)
    local texture_x = (x - texture.width * texture_scale) - 12
    -- Render text and texture later

    local overall_size = x + text_size - texture_x

    local button_x = texture_x - 6
    local button_y = y - 6
    local button_width = overall_size + 12
    local button_height = texture.height * texture_scale + 12
    local colors = { MAIN_RECT_COLORS[1], MAIN_RECT_COLORS[2], MAIN_RECT_COLORS[3] }

    local darken = false
    if mouse_is_within(texture_x, y, x + text_size, button_y + button_height) then
        darken = input_func()
    end
    darken = override_darken or darken

    if darken then
        colors = {
            { r = 180, g = 180, b = 180, a = 255 },
            { r = 235, g = 235, b = 235, a = 255 },
            { r = 68, g = 68, b = 68, a = 255 },
        }
    end

    render_bordered_rectangle(button_x, button_y, button_width, button_height, colors, 0.008, 0.05, true)

    -- Render text and texture
    djui_hud_set_color_with_table(WHITE)
    djui_hud_render_texture(texture, texture_x, y, texture_scale, texture_scale)
    render_shadowed_text(text, x, y, text_scale)

    return texture_x, button_y, overall_size, button_height
end

---@param x number
---@param y number
---@param width number
---@param height number
local function render_reset_hotbar(x, y, width, height)
    local text_x = x + width * 0.65
    local text_y = y + height * 0.9
    local button_x, button_y, button_width, button_height = render_menu_button(text_x, text_y, width, height, "Reset Hotbar", Y_BUTTON_TEX, mouse_handle_reset_inputs)

    local reset_bar_width = button_width * math.remap(0, 60, 0, 1, gMenu.hotbar.clear)
    local reset_bar_height = 10
    local reset_bar_x = button_x - 3
    local reset_bar_y = button_y + button_height
    djui_hud_set_color_with_table(GREEN)
    djui_hud_render_rect(reset_bar_x, reset_bar_y, reset_bar_width, reset_bar_height)
end

---@param x number
---@param y number
---@param width number
---@param height number
local function render_settings_button(x, y, width, height)
    local text_x = x + width * 0.2
    local text_y = y + height * 0.9
    -- TEMPORARY
    local override_darken = gMenu.settings.transparent
    render_menu_button(text_x, text_y, width, height, "Transparent", D_CBUTTON_TEX, mouse_handle_open_settings_inputs, override_darken)
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param text string
local function render_tab_header(x, y, width, height, text)
    djui_hud_set_color(63, 63, 63, 255)
    local scale = 1.5
    local size = djui_hud_measure_text(text) * scale
    local text_x = x + width * 0.5 - size * 0.5
    local text_y = y + height * 0.04
    djui_hud_print_text(text, text_x, text_y, scale)
    local pages = gMenu.get_current_tab_pages()
    local index = pages.current
    if index > 1 then
        local texture_scale = 3
        local texture_x = (x + width * 0.1) - (L_CBUTTON_TEX.width * 0.5 * texture_scale)
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_render_texture(L_CBUTTON_TEX, texture_x, text_y, texture_scale, texture_scale)
    end
    if index < pages.count then
        local texture_scale = 3
        local texture_x = (x + width * 0.9) - (R_CBUTTON_TEX.width * 0.5 * texture_scale)
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_render_texture(R_CBUTTON_TEX, texture_x, text_y, texture_scale, texture_scale)
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
    local interior_rect_height = height * 0.7
    local color = {r = 175, g = 175, b = 175, a = 255}
    djui_hud_set_color_with_table(color)
    djui_hud_render_rect(interior_rect_x, interior_rect_y, interior_rect_width, interior_rect_height)
    calculate_slots(interior_rect_width, interior_rect_height)
    render_item_list(interior_rect_x, interior_rect_y, interior_rect_width, interior_rect_height)
end

local function render_standard_tab(x, y, width, height, name)
    render_interior_rectangle(x, y, width, height)
    render_tab_header(x, y, width, height, name)
    render_reset_hotbar(x, y, width, height)
    render_settings_button(x, y, width, height)
end

---@param x number
---@param y number
---@param width number
---@param height number
gMenu.tabs[TAB_BUILDING_BLOCKS].renderer = function (x, y, width, height)
    render_standard_tab(x, y, width, height, "Building Blocks")
end

---@param x number
---@param y number
---@param width number
---@param height number
gMenu.tabs[TAB_BUILDING_BLOCKS_COLORS].renderer = function (x, y, width, height)
    render_standard_tab(x, y, width, height, "Building Blocks")
end

---@param x number
---@param y number
---@param width number
---@param height number
gMenu.tabs[TAB_LEVEL_OBJECTS].renderer = function (x, y, width, height)
    render_standard_tab(x, y, width, height, "Items")
end

---@param x number
---@param y number
---@param width number
---@param height number
gMenu.tabs[TAB_ENEMIES].renderer = function (x, y, width, height)
    render_standard_tab(x, y, width, height, "Enemies")
end


---------------------------

---@class (exact) Description
    ---@field title string
    ---@field details {alias: string, type: string}
    ---@field lines {[1]: string, [2]: string, [3]: string, [4]: string}
    ---@field image TextureInfo

-- This is for the stuff in the box on the right side of the menu
-- {title = "", details = {alias = "Aliases: ", type = "Type: "}, lines = {"", "", "", ""}, image = }
---@type Description[]
gMenu.tabs[TAB_SURFACE_TYPES].misc.descriptions = {
    {title = "Default", details = {alias = "Aliases: normal", type = "Type: Surface"}, lines = {"The default SM64 surface.", "Can't go wrong with it.", "", ""}, image = DEFAULT_TEX},
    {title = "No Collision", details = {alias = "Aliases: intangible / none", type = "Type: Surface"}, lines = {"Removes all surface collision.", "Best used with ", "transparent blocks.", ""}, image = NOCOL_TEX},
    {title = "No Fall Damage", details = {alias = "Aliases: nofall", type = "Type: Property"}, lines = {"Prevents players from taking", "any fall damage when landing", "on this block.", ""}, image = NOFALL_TEX},
    {title = "Slippery", details = {alias = "Aliases: slip", type = "Type: Surface"}, lines = {"A slippery surface players", "can slide off.", "", ""}, image = SLIP_TEX},
    {title = "Not Slippery", details = {alias = "Aliases: not slip / nslip", type = "Type: Surface"}, lines = {"A surface players can always", "walk on.", "", ""}, image = NSLIP_TEX},
    {title = "Very Slippery", details = {alias = "Aliases: very slip / vslip", type = "Type: Surface"}, lines = {"Players will always slide", "off this surface. Can sillykick", "if the slope isn't too steep.", "Cannot framewalk."}, image = VSLIP_TEX},
    {title = "Shallowsand", details = {alias = "Aliases: ssand", type = "Type: Surface"}, lines = {"Restricts movement and jump", "height. Doesn't sink", "the player.", ""}, image = SHALLOWSAND_TEX},
    {title = "Quicksand", details = {alias = "Aliases: qsand", type = "Type: Surface"}, lines = {"Hazardous surface that ", "instantly sinks any player  ", "upon contact.", ""}, image = QUICKSAND_TEX},
    {title = "Lava", details = {alias = "Aliases: N/A", type = "Type: Surface"}, lines = {"Hazardous surface that", "launches the player upwards", "and deals damage.", ""}, image = LAVA_TEX},
    {title = "Toxic Gas", details = {alias = "Aliases: toxic / gas", type = "Type: Effect"}, lines = {"Hazardous gas that slowly", "depletes the player's HP. Has", "no collision.", ""}, image = TOXIC_TEX},
    {title = "Death", details = {alias = "Aliases: N/A", type = "Type: Surface"}, lines = {"Hazardous surface that kills", "the player if they're 10.25", "blocks above its surface.", ""}, image = DEATH_TEX},
    {title = "Vanish", details = {alias = "Aliases: N/A", type = "Type: Surface"}, lines = {"Acts like a normal surface, but", "can be phased through with the", "Vanish Cap.", ""}, image = VANISH_TEX},
    {title = "Hangable", details = {alias = "Aliases: hang", type = "Type: Surface"}, lines = {"Holding A while touching this", "surface's ceiling will make the", "player hang on until they let", "go."}, image = HANGABLE_TEX},
    {title = "Water", details = {alias = "Aliases: swim", type = "Type: Effect"}, lines = {"A block of water. Overlap", "multiple blocks to swim", "between them.", ""}, image = WATER_TEX},
    {title = "Vertical Wind", details = {alias = "Aliases: vwind", type = "Type: Effect"}, lines = {"A gust of wind that carries", "the player upwards. Best used", "with barrier blocks.", ""}, image = VWIND_TEX},
    {title = "Checkpoint", details = {alias = "Aliases: respawn", type = "Type: Property"}, lines = {"A surface block with standard", "properties, standing on it", "creates a respawn point.", ""}, image = CHECKPOINT_TEX},
    {title = "Bounce", details = {alias = "Aliases: N/A", type = "Type: Surface"}, lines = {"Bounces the player back when", "touching any surface face. Works", "best with the Wing Cap.", ""}, image = BOUNCE_TEX},
    {title = "Conveyor", details = {alias = "Aliases: N/A", type = "Type: Property"}, lines = {"Pushes the player in the", "direction of the arrow.", "Possible to hang on its", "ceiling."}, image = CONVEYOR_TEX},
    {title = "Firsty", details = {alias = "Aliases: firstie", type = "Type: Property"}, lines = {"When performing a wallkick on", "this surface, speed will always" , "be maintained.", ""}, image = FIRSTY_TEX},
    {title = "Widekick", details = {alias = "Aliases: wide / wide wallkick", type = "Type: Property"}, lines = {"Wallkicks can be performed", "from any angle facing this", "surface's wall.", ""}, image = WIDEKICK_TEX},
    {title = "Anykick", details = {alias = "Aliases: any bonk", type = "Type: Property"}, lines = {"Wallkicks can be performed", "after any bonking action such", "as dives, ground pounds, ", "ceilings, and 'out of bounds'."}, image = ANYKICK_TEX},
    {title = "Wallkickless", details = {alias = "Aliases: no wallkick / wkless", type = "Type: Property"}, lines = {"Attempting to wallkick on this", "surface will always fail.", "", ""}, image = WKLESS_TEX},
    {title = "Dash Panel", details = {alias = "Aliases: dash", type = "Type: Surface"}, lines = {"Forces the player to dash at", "great speeds when walking on", "this surface's floor.", ""}, image = DASH_TEX},
    {title = "Booster", details = {alias = "Aliases: boost", type = "Type: Effect"}, lines = {"Dractically increases the", "player's speed when within this", "surface block. Has no collision.", ""}, image = BOOST_TEX},
    {title = "Jumpless", details = {alias = "Aliases: no a / abc", type = "Type: Property"}, lines = {"Attempting to jump or wallkick", "on this surface will always", "fail.", ""}, image = ABC_TEX},
    {title = "Jump Pad", details = {alias = "Aliases: jpad", type = "Type: Surface"}, lines = {"Pressing A while standing on", "this surface will launch the", "player up to 7 blocks in the ", "air."}, image = JUMP_TEX},
    {title = "Capless", details = {alias = "Aliases: remove caps", type = "Type: Property"}, lines = {"If any players are wearing a ", "special cap when above this", "block, they will revert to", "wearing a normal cap."}, image = CAPLESS_TEX},
    {title = "Breakable", details = {alias = "Aliases: break", type = "Type: Property"}, lines = {"Attacking this surface will", "break the block completely.", "", ""}, image = BREAK_TEX},
    {title = "Disappearing", details = {alias = "Aliases: disappear", type = "Type: Property"}, lines = {"Touching this surface will", "quickly make this surface", "disappear entirely.", ""}, image = DISAPPEAR_TEX},
    {title = "Shrinking", details = {alias = "Aliases: shrink", type = "Type: Property"}, lines = {"Standing on this surface will", " slowly shrink the block until", "it disappears entirely.", ""}, image = SHRINK_TEX},
    {title = "Springboard", details = {alias = "Aliases: spring / noteblock", type = "Type: Surface"}, lines = {"Going onto this surface will", "make the player immediately jump", "high.", ""}, image = SPRINGBOARD_TEX},
}

-- This is for the names of the buttons on the left side of the menu
---@type string[]
gMenu.tabs[TAB_SURFACE_TYPES].misc.buttons = {
    "Default",
    "No Collision",
    "No Fall Damage",
    "Slippery",
    "Not Slippery",
    "Very Slippery",
    "Shallowsand",
    "Quicksand",
    "Lava",
    "Toxic Gas",
    "Death",
    "Vanish",
    "Hangable",
    "Water",
    "Vertical Wind",
    "Checkpoint",
    "Bounce",
    "Conveyor",
    "Firsty",
    "Widekick",
    "Anykick",
    "Wallkickless",
    "Dash Panel",
    "Booster",
    "Jumpless",
    "Jump Pad",
    "Capless",
    "Breakable",
    "Disappearing",
    "Shrinking",
    "Springboard"
}

gMenu.tabs[TAB_SURFACE_TYPES].misc.index = 0
gMenu.tabs[TAB_SURFACE_TYPES].misc.index_offset = 0
gMenu.tabs[TAB_SURFACE_TYPES].misc.buttons_rendered = 0

---@param x number
---@param y number
---@param width number
---@param height number
---@param description Description
local function render_description_box(x, y, width, height, description)
    local rect_x = x + width * 0.47
    local rect_y = y + height * 0.16
    local rect_width = width * 0.5
    local rect_height = height * 0.8
    local rect_colors = {{r = 0, g = 16, b = 69, a = 255}, {r = 255, g = 255, b = 255, a = 255}, {r = 255, g = 255, b = 255, a = 255}}
    render_bordered_rectangle(rect_x, rect_y, rect_width, rect_height, rect_colors, 0.006, 0.01, true)

    local desc_x = rect_x + width * 0.03
    local desc_y = rect_y + height * 0.03
    local text_scale = 0.5 * (width/height)
    local lines = description.lines
    render_shadowed_text(description.title, desc_x, desc_y, text_scale * 2)
    djui_hud_set_color(128, 128, 128, 255)
    djui_hud_print_text(description.details.alias, desc_x, desc_y + 55, text_scale * 0.9)
    djui_hud_print_text(description.details.type, desc_x, desc_y + 85, text_scale * 0.9)
    render_shadowed_text(lines[1], desc_x, desc_y + 115, text_scale)
    render_shadowed_text(lines[2], desc_x, desc_y + 145, text_scale)
    render_shadowed_text(lines[3], desc_x, desc_y + 175, text_scale)
    render_shadowed_text(lines[4], desc_x, desc_y + 205, text_scale)

    local image = description.image
    local image_scale = 0.7 * (width/height)
    local image_x = rect_x + rect_width * 0.5 - (image.width * image_scale) * 0.5
    local image_y = rect_y + rect_height - (image.height * image_scale) - 5
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_render_texture(image, image_x, image_y, image_scale, image_scale)
end

---@param x number
---@param y number
---@param width number
---@param height number
gMenu.tabs[TAB_SURFACE_TYPES].renderer = function (x, y, width, height)
    render_tab_header(x, y, width, height, "Surface Types")
    gMenu.get_current_tab_pages().count = 1

    local page_arrow_x = x + width * 0.21
    local arrow_scale = 2
    local page_up_arrow_y = y + 25 * arrow_scale
    local page_down_arrow_y = y + height - 25 * arrow_scale
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_render_texture(PAGE_UP_TEX, page_arrow_x, page_up_arrow_y, arrow_scale, arrow_scale)
    djui_hud_render_texture(PAGE_DOWN_TEX, page_arrow_x, page_down_arrow_y, arrow_scale, arrow_scale)

    local button_x = x + width * 0.04
    local button_y = page_up_arrow_y + 35
    local button_width = width * 0.4
    local button_height = 35
    local y_increm = button_height + 5
    local button_space = ((page_down_arrow_y - 35) - page_up_arrow_y)
    local button_count_div = button_space / y_increm

    local surface_tab = gMenu.get_current_tab().misc
    surface_tab.buttons_rendered = math.floor(button_count_div)
    y_increm = button_space / surface_tab.buttons_rendered
    gMouse.menu.hoveringSurfaceTip = false
    for i = 1, surface_tab.buttons_rendered, 1 do
        local absolute_index = i + surface_tab.index_offset
        if gMouse.moved and mouse_is_within(button_x, button_y + y_increm * (i - 1), button_x + button_width, (button_y + y_increm * (i - 1)) + button_height) then
            surface_tab.index = absolute_index
            gMouse.menu.hoveringSurfaceTip = true
        end

        local button_colors = {{r = 125, g = 125, b = 125, a = 255}, {r = 175, g = 175, b = 175, a = 255}, {r = 75, g = 75, b = 75, a = 255}}
        if surface_tab.index == absolute_index then
            button_colors = {{r = 65, g = 65, b = 65, a = 255}, {r = 175, g = 175, b = 175, a = 255}, {r = 75, g = 75, b = 75, a = 255}}
        end
        render_bordered_rectangle(button_x, button_y + y_increm * (i - 1), button_width, button_height, button_colors, 0.01, 0.06, false)

        if surface_tab.buttons[absolute_index] then
            render_shadowed_text(surface_tab.buttons[absolute_index], button_x + 12, button_y + 4.5 + y_increm * (i - 1), 0.8)
        end
    end

    if surface_tab.descriptions[surface_tab.index] then
        render_description_box(x, y, width, height, surface_tab.descriptions[surface_tab.index])
    end
end

----------------------------------------------------

---@param x number
---@param y number
---@param width number
---@param height number
gMenu.tabs[TAB_BLOCK_SETTINGS].renderer = function (x, y, width, height)
    -- Unimplemented
end

---@param x number
---@param y number
---@param width number
---@param height number
gMenu.tabs[TAB_OBJECT_SETTINGS].renderer = function (x, y, width, height)
    -- Unimplemented
end

----------------------------------------------------

---@param screen_width number
---@param screen_height number
local function render_hotbar(screen_width, screen_height)
    local width = screen_width * 0.5
    local height = screen_height * 0.08
    local x = screen_width * 0.25
    local y = screen_height - ((sShowControls and height * 1.8) or height) --need space for on-screen controls
    djui_hud_set_color(64, 64, 32, 192)
    djui_hud_render_rect(x, y, width, height)
    local slot_width = width * 0.1
    local slot_height = height * 0.95
    local slot_x = x
    local slot_y = y
    for index, item in ipairs(gMenu.hotbar.items) do
        slot_x = x + slot_width * (index - 1)

        if gMenu.open and gMouse.moved and mouse_is_within(slot_x, slot_y, slot_x + slot_width, slot_y + slot_height) then
            gMenu.hotbar.index = index
        end

        if index == gMenu.hotbar.index then
            djui_hud_set_color(255, 255, 255, 150)
            if gMenu.current_item.is_held then
                djui_hud_set_color(255, 255, 127, 150)
            end
            djui_hud_render_rect(slot_x, slot_y, slot_width, slot_height)
        end

        if item.icon then
            render_icon(slot_x, slot_y, slot_width, slot_height, item.icon)
        end

        if index == gMenu.hotbar.index and not gMouse.moved and gMenu.current_item.is_held then
            render_icon(slot_x, slot_y, slot_width, slot_height, gMenu.get_current_item().icon)
        end
        djui_hud_set_color(128, 128, 128, 255)
        djui_hud_render_rect(slot_x, y, 3, slot_height)
    end
    render_rectangle_borders(x, y, width, height, {r = 128, g = 128, b = 128, a = 255}, {r = 128, g = 128, b = 128, a = 255}, 0.01, 0.08)
    render_pixel_border(x, y, width, height, {r = 0, g = 0, b = 0, a = 255}, 2)
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param index integer
local function render_menu_tab(x, y, width, height, index)
    local colors = {{r = 125, g = 125, b = 125, a = 255}, {r = 175, g = 175, b = 175, a = 255}, {r = 75, g = 75, b = 75, a = 255}}
    if index == gMenu.tabs.current then
        colors = MAIN_RECT_COLORS
    end
    local tab_width = width * 0.1
    local tab_height = height * 0.1
    local tab_x = x + (tab_width * (index - 1))
    local tab_y = y - (tab_height - (tab_height * 0.1))
    render_bordered_rectangle(tab_x, tab_y, tab_width, tab_height, colors, 0.05, 0.07, false)

    local icon = gMenu.tabs[index].icon
    djui_hud_set_color_with_table(icon.color)
    local texture_scale = 1
    local texture_x = tab_x + tab_width * 0.5 - icon.texture.width * 0.5 * texture_scale
    local texture_y = tab_y + tab_height * 0.5 - icon.texture.height * 0.5 * texture_scale
    djui_hud_render_texture(icon.texture, texture_x, texture_y, texture_scale, texture_scale)

    if mouse_is_within(tab_x, tab_y, tab_x + tab_width, tab_y + tab_height) and gMouse.pressed.left then
        gMouse.menu.clickedTabIndex = index
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
    local colors = MAIN_RECT_COLORS
    for i = 1, TAB_MAIN_END do
        render_menu_tab(x, y, width, height, i)
    end
    render_bordered_rectangle(x, y, width, height, colors, 0.008, 0.01, false)
    return x, y, width, height
end

---@param screen_width number
---@param screen_height number
local function render_menu(screen_width, screen_height)
    render_hotbar(screen_width, screen_height)
    if gMenu.open then
        local x, y, width, height = render_main_rectangle(screen_width, screen_height)
        gMenu.get_current_tab().renderer(x, y, width, height)
        render_mouse()
        if gMenu.current_item.is_held then
            render_dragging_icon()
        end
    end
end

----------------------------------------------------

---@param screen { width: number, height: number } 
---@param x number
---@param y number
---@param buttons {prefix: string?, postfix: string?, texture: TextureInfo}[]
local function render_controls_tip(screen, x, y, buttons)
    local text_scale = (screen.width/screen.height) * 0.55
    local texture_scale = (screen.width/screen.height) * 1.1
    local initial_x = x
    local texture_y = y

    djui_hud_set_color_with_table(WHITE)
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
    local screen = { width = screen_width, height = screen_height }
    if not gCanBuild then
        djui_hud_set_color(0, 0, 0, 60)
        render_controls_tip(screen, x * 0.98, y, {{prefix = "", texture = L_TRIG_TEX}, {postfix = "  Fly (Enter Build Mode)", texture = L_TRIG_TEX}})
    else
        if not gMenu.open then
            local l_held_modifier = gMarioStates[0].controller.buttonDown & L_TRIG ~= 0
            if not l_held_modifier then
                if not gCurrentItem then -- no hold L, no selected item
                    render_controls_tip(screen, x, y, {{prefix = "", texture = L_TRIG_TEX}, {postfix = "  Stop Flying", texture = L_TRIG_TEX}})
                    render_controls_tip(screen, x, y * 0.95, {{postfix = "  Open Menu", texture = X_BUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.90, {{postfix = "  Fly Up", texture = A_BUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.85, {{postfix = "  Fly Down", texture = Z_TRIG_TEX}})
                    render_controls_tip(screen, x, y * 0.80, {{postfix = "  Sprint Fly", texture = B_BUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.75, {{postfix = "  Cycle Hotbar", texture = LR_JPAD_TEX}})
                    render_controls_tip(screen, x, y * 0.70, {{postfix = "  Lock Face Angle/More", texture = L_TRIG_TEX}})
                else -- no hold L, item selected
                    render_controls_tip(screen, x, y, {{prefix = "", texture = L_TRIG_TEX}, {postfix = "  Stop Flying", texture = L_TRIG_TEX}})
                    render_controls_tip(screen, x, y * 0.95, {{postfix = "  Open Menu", texture = X_BUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.90, {{postfix = "  Place/Delete Item", texture = Y_BUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.85, {{postfix = "  Adjust Elevation", texture = UD_JPAD_TEX}})
                    render_controls_tip(screen, x, y * 0.80, {{postfix = "  Cycle Hotbar", texture = LR_JPAD_TEX}})
                    render_controls_tip(screen, x, y * 0.75, {{postfix = "  Lock Face Angle/More", texture = L_TRIG_TEX}})
                end
            else
                if not gCurrentItem then -- L held, no selected item
                    render_controls_tip(screen, x, y, {{postfix = "  Slow Fly", texture = B_BUTTON_TEX}})
                else -- L held, item selected
                    render_controls_tip(screen, x, y, {{postfix = "  Slow Fly", texture = B_BUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.95, {{postfix = "  Place/Delete Item", texture = Y_BUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.90, {{postfix = "  Adjust Size", texture = UD_JPAD_TEX}})
                    render_controls_tip(screen, x, y * 0.85, {{prefix = "", texture = U_CBUTTON_TEX}, {postfix = "  Adjust Pitch", texture = D_CBUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.80, {{prefix = "", texture = L_CBUTTON_TEX}, {postfix = "  Adjust Yaw", texture = R_CBUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.75, {{postfix = "  Adjust Roll", texture = LR_JPAD_TEX}})
                    render_controls_tip(screen, x, y * 0.70, {{postfix = "  Reset Angle", texture = X_BUTTON_TEX}})
                    render_controls_tip(screen, x, y * 0.65, {{postfix = "  Disable Grid", texture = R_TRIG_TEX}})
                end
            end
        else
            render_controls_tip(screen, x, y, {{postfix = "  Move Selection", texture = CONTROL_STICK_TEX}})
            render_controls_tip(screen, x, y * 0.95, {{postfix = "  Select Item", texture = A_BUTTON_TEX}})
            render_controls_tip(screen, x, y * 0.90, {{prefix = "", texture = L_CBUTTON_TEX}, {postfix = "  Next/Previous Page", texture = R_CBUTTON_TEX}})
            render_controls_tip(screen, x, y * 0.85, {{prefix = "", texture = L_TRIG_TEX}, {postfix = "  Next/Previous Tab", texture = R_TRIG_TEX}})
            render_controls_tip(screen, x, y * 0.80, {{postfix = "  Cycle Hotbar", texture = LR_JPAD_TEX}})
            render_controls_tip(screen, x, y * 0.75, {{postfix = "  Close Menu", texture = X_BUTTON_TEX}})
        end
    end
end

----------------------------------------------------

local function hud_render()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_SPECIAL)
    local screen_width = djui_hud_get_screen_width()
    local screen_height = djui_hud_get_screen_height()
    if gCanBuild then
        render_menu(screen_width, screen_height)
    end
    if sShowControls then
        render_controls(screen_width, screen_height)
    end
end

------------------------------------------------------------------------------------------------

hook_event(HOOK_ON_HUD_RENDER_BEHIND, hud_render)

------------------------------------------------------------------------------------------------

local function on_show_controls_mod_menu(_, show)
    sShowControls = show
    return true
end

hook_mod_menu_checkbox("Show Controls", true, on_show_controls_mod_menu)

local function invert_scrolling_mod_menu(_, value)
    sInvertScroll = value
end

hook_mod_menu_checkbox("Invert Menu Mouse Scroll", false, invert_scrolling_mod_menu)