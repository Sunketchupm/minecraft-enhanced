local Mouse = require("mouse")
local ItemGrid = require("item_grid")
local Scroll = require("scroll")
local Hotbar = require("hotbar") ---@diagnostic disable-line: different-requires
local Buttons = require("buttons")
local Controls = require("controls")

------------------------------------------------------------------------------------------------

---@param rect Rectangle
local function render_reset_hotbar(rect)
    local x, y, width, height = from_rect(rect)
    local text_x = x + width * 0.5
    local text_y = y + height * 0.9
    local button_rect = into_rect(text_x, text_y, width, height)
    local button_x, button_y, button_width, button_height =
        from_rect(Buttons.render_menu_button(button_rect, "Reset Hotbar", Y_BUTTON_TEX, Hotbar.handle_reset_inputs, false))

    local reset_bar_width = button_width * math.remap(0, 60, 0, 1, Hotbar.clear)
    local reset_bar_height = 10
    local reset_bar_x = button_x
    local reset_bar_y = button_y + button_height
    djui_hud_set_color_with_table(GREEN)
    djui_hud_render_rect(reset_bar_x, reset_bar_y, reset_bar_width, reset_bar_height)
end

--[[
---@param rect Rectangle
local function render_settings_button(rect)
    local x, y, width, height = from_rect(rect)
    local text_x = x + width * 0.2
    local text_y = y + height * 0.9
    local button_rect = into_rect(text_x, text_y, width, height)
    -- TEMPORARY
    local override_darken = gMenu.settings.transparent
    Buttons.render_menu_button(button_rect, "Transparent", D_CBUTTON_TEX, Mouse.handle_open_settings_inputs, override_darken)
end
]]

---@param rect Rectangle
---@param tab MenuTab
---@param text string
local function render_tab_header(rect, tab, text)
    local x, y, width, height = from_rect(rect)

    djui_hud_set_color(63, 63, 63, 255)
    local scale = 1.5
    local size = djui_hud_measure_text(text) * scale
    local text_x = x + width * 0.5 - size * 0.5
    local text_y = y + height * 0.04
    djui_hud_print_text(text, text_x, text_y, scale)

    local pages = tab.vars.pages
    if pages.count == 0 then return end
    if pages.index > 1 then
        local texture_scale = 3
        local texture_x = (x + width * 0.1) - (L_CBUTTON_TEX.width * 0.5 * texture_scale)
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_render_texture(L_CBUTTON_TEX, texture_x, text_y, texture_scale, texture_scale)
    end
    if pages.index < pages.count then
        local texture_scale = 3
        local texture_x = (x + width * 0.9) - (R_CBUTTON_TEX.width * 0.5 * texture_scale)
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_render_texture(R_CBUTTON_TEX, texture_x, text_y, texture_scale, texture_scale)
    end
end

---@param rect Rectangle
---@param tab MenuTab
local function render_interior_rectangle(rect, tab)
    local interior_rect_x = rect.x + rect.width * 0.05
    local interior_rect_y = rect.y + rect.height * 0.15
    local interior_rect_width = rect.width * 0.9
    local interior_rect_height = rect.height * 0.7
    local interior_rect = into_rect(
        interior_rect_x,
        interior_rect_y,
        interior_rect_width,
        interior_rect_height
    )
    djui_hud_set_color(175, 175, 175, 255)
    djui_hud_render_rect(interior_rect_x, interior_rect_y, interior_rect_width, interior_rect_height)
    ItemGrid.render(interior_rect, tab.vars --[[@as ItemGrid]])
end

---@param rect Rectangle
---@param tab MenuTab
---@param name string
local function render_item_list_tab(rect, tab, name)
    render_interior_rectangle(rect, tab)
    render_tab_header(rect, tab, name)
    render_reset_hotbar(rect)
    --render_settings_button(rect)
end

---@param rect Rectangle
---@param tab MenuTab
gMenu[TAB_BUILDING_BLOCKS].renderer = function (rect, tab)
    render_item_list_tab(rect, tab, "Building Blocks")
end

---@param rect Rectangle
---@param tab MenuTab
gMenu[TAB_BUILDING_BLOCKS_COLORS].renderer = function (rect, tab)
    render_item_list_tab(rect, tab, "Building Blocks")
end

---@param rect Rectangle
---@param tab MenuTab
gMenu[TAB_LEVEL_OBJECTS].renderer = function (rect, tab)
    render_item_list_tab(rect, tab, "Items")
end

---@param rect Rectangle
---@param tab MenuTab
gMenu[TAB_ENEMIES].renderer = function (rect, tab)
    render_item_list_tab(rect, tab, "Enemies")
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
local sSurfaceDescriptions = {
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
local sSurfaceButtons = {
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

local sSurfaceLastDescriptionIndex = 1

---@param rect Rectangle
---@param description Description
local function render_description_box(rect, description)
    local x, y, width, height = from_rect(rect)
    local description_rect = {
        x = x + width * 0.47,
        y = y + height * 0.16,
        width = width * 0.5,
        height = height * 0.8
    }
    local rect_colors = {{r = 0, g = 16, b = 69, a = 255}, {r = 255, g = 255, b = 255, a = 255}, {r = 255, g = 255, b = 255, a = 255}}
    render_bordered_rectangle(description_rect, rect_colors, 0.006, 0.01, true)

    local desc_x = description_rect.x + width * 0.03
    local desc_y = description_rect.y + height * 0.03
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
    local image_x = description_rect.x + description_rect.width * 0.5 - (image.width * image_scale) * 0.5
    local image_y = description_rect.y + description_rect.height - (image.height * image_scale) - 5
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_render_texture(image, image_x, image_y, image_scale, image_scale)
end

---@param rect Rectangle
---@param tab MenuTab
gMenu[TAB_SURFACE_TYPES].renderer = function (rect, tab)
    render_tab_header(rect, tab, "Surface Types")
    local button_dimensions = {
        x = rect.x + rect.width * 0.09,
        y = rect.y + rect.height * 0.25,
        width = rect.width * 0.33,
        height = rect.height * 0.075
    }
    local offset_y = -(rect.height * 0.08)
    local scroll = tab.vars --[[@as Scroll]]
    Scroll.render(button_dimensions, rect, offset_y, scroll, sSurfaceButtons)

    local current_description = sSurfaceDescriptions[scroll.index]
    if current_description then
        sSurfaceLastDescriptionIndex = scroll.index
        Mouse.menu.hoveringSurfaceTip = true
    else
        current_description = sSurfaceDescriptions[sSurfaceLastDescriptionIndex]
        Mouse.menu.hoveringSurfaceTip = false
    end
    render_description_box(rect, current_description)
end

----------------------------------------------------

---@param rect Rectangle
---@param tab MenuTab
gMenu[TAB_SETTINGS].renderer = function (rect, tab)
    -- Unimplemented
end

----------------------------------------------------

---@param rect Rectangle
---@param index integer
local function render_menu_tab(rect, index)
    local x, y, width, height = from_rect(rect)
    local colors = {{r = 125, g = 125, b = 125, a = 255}, {r = 175, g = 175, b = 175, a = 255}, {r = 75, g = 75, b = 75, a = 255}}
    if index == gCurrentTab then
        colors = MAIN_RECT_COLORS
    end

    local tab_width = width * 0.1
    local tab_height = height * 0.1
    local tab_x = x + (tab_width * (index - 1))
    local tab_y = y - (tab_height - (tab_height * 0.1))
    local tab_rect = into_rect(tab_x, tab_y, tab_width, tab_height)
    render_bordered_rectangle(tab_rect, colors, 0.05, 0.07, false)

    local icon = gMenu[index].icon
    djui_hud_set_color_with_table(icon.color)
    local texture_scale = 1
    local texture_x = tab_x + tab_width * 0.5 - icon.texture.width * 0.5 * texture_scale
    local texture_y = tab_y + tab_height * 0.5 - icon.texture.height * 0.5 * texture_scale
    djui_hud_render_texture(icon.texture, texture_x, texture_y, texture_scale, texture_scale)

    if Mouse.is_within(tab_rect) and Mouse.pressed.left then
        Mouse.menu.clickedTabIndex = index
    end
end

---@param screen_width number
---@param screen_height number
---@return Rectangle
local function render_main_rectangle(screen_width, screen_height)
    local main_rect = {
        x = screen_width * 0.25,
        y = screen_height * 0.2,
        width = screen_width * 0.5,
        height = screen_height * 0.6,
    }
    local colors = MAIN_RECT_COLORS
    for i = 1, TAB_COUNT do
        render_menu_tab(main_rect, i)
    end
    render_bordered_rectangle(main_rect, colors, 0.008, 0.01, false)
    return main_rect
end

---@param screen_width number
---@param screen_height number
local function render_menu(screen_width, screen_height)
    Hotbar.render(screen_width, screen_height)
    if not gMenu.open then return end

    local rect = render_main_rectangle(screen_width, screen_height)
    local current_tab = gMenu[gCurrentTab]
    current_tab.renderer(rect, current_tab)
    Mouse.render()
    if gCurrentItemLink and gCurrentItemLink.held then
        ItemGrid.render_dragging_icon(gCurrentItemLink)
    end
end

------------------------------------------------------------------------------------------------

local function hud_render()
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_font(FONT_SPECIAL)
    local screen_width = djui_hud_get_screen_width()
    local screen_height = djui_hud_get_screen_height()
    if gCanBuild then
        render_menu(screen_width, screen_height)
    end

    if gMenu.settings.show_controls then
        Controls.render(screen_width, screen_height)
    end
end

return hud_render
