local Items = require("item_list")

---@class (exact) MenuItemLink
    ---@field item Item
    ---@field icon Icon
    ---@field held boolean

---@type Menu
gMenu = {
    open = false,
    settings = {
        transparent = false,
        invert_scroll = false,
        show_controls = true,
    },
}

gCurrentTab = 1 ---@type TabIndex

---@type MenuItemLink?
gCurrentItemLink = nil

---@class Rectangle
    ---@field x number
    ---@field y number
    ---@field width number
    ---@field height number

---@class Directions
    ---@field up boolean
    ---@field left boolean
    ---@field down boolean
    ---@field right boolean

---@class Menu
    ---@field open boolean
    ---@field settings MenuSettings
    ---@field [TabIndex] MenuTab

---@class MenuSettings
    ---@field transparent boolean
    ---@field invert_scroll boolean
    ---@field show_controls boolean

---@class MenuTab
    ---@field renderer fun(rect: Rectangle, tab: MenuTab)
    ---@field icon Icon
    ---@field vars ItemGrid | Scroll | Button
    ---@field input_type TabInputType
    ---@field index integer

---@class Icon
    ---@field texture TextureInfo?
    ---@field color DjuiColor

---@alias TabIndex integer
TAB_BUILDING_BLOCKS = 1 ---@type TabIndex
TAB_BUILDING_BLOCKS_COLORS = 2 ---@type TabIndex
TAB_LEVEL_OBJECTS = 3 ---@type TabIndex
TAB_ENEMIES = 4 ---@type TabIndex
TAB_SURFACE_TYPES = 5 ---@type TabIndex
TAB_COUNT = 5 ---@type TabIndex

TAB_SETTINGS = 90 ---@type TabIndex

---@alias TabInputType integer
TAB_INPUT_TYPE_ITEM_GRID = 1 ---@type TabIndex
TAB_INPUT_TYPE_SCROLL = 2 ---@type TabIndex
TAB_INPUT_TYPE_BUTTONS = 3 ---@type TabIndex

do
    local function default(tab_index)
        local index_to_type = {
            [TAB_BUILDING_BLOCKS] = TAB_INPUT_TYPE_ITEM_GRID,
            [TAB_BUILDING_BLOCKS_COLORS] = TAB_INPUT_TYPE_ITEM_GRID,
            [TAB_LEVEL_OBJECTS] = TAB_INPUT_TYPE_ITEM_GRID,
            [TAB_ENEMIES] = TAB_INPUT_TYPE_ITEM_GRID,
            [TAB_SURFACE_TYPES] = TAB_INPUT_TYPE_SCROLL,
        }
        ---@type MenuTab
        local ret = {
            renderer = function () end,
            icon = { texture = gTextures.no_camera, color = WHITE },
            vars = {
                index = 0,
                offset = 0,
                items = {},
                elements = {},
                elements_rendered = 0,
                pages = { count = 0, index = 0, item_count = 0 },
                rows = 0,
                columns = 0,
            },
            input_type = index_to_type[tab_index],
            index = tab_index
        }
        return ret
    end

    gMenu[TAB_BUILDING_BLOCKS] = default(TAB_BUILDING_BLOCKS)
    gMenu[TAB_BUILDING_BLOCKS_COLORS] = default(TAB_BUILDING_BLOCKS_COLORS)
    gMenu[TAB_LEVEL_OBJECTS] = default(TAB_LEVEL_OBJECTS)
    gMenu[TAB_ENEMIES] = default(TAB_ENEMIES)
    gMenu[TAB_SURFACE_TYPES] = default(TAB_SURFACE_TYPES)

    -- Unlisted tabs
    gMenu[TAB_SETTINGS] = default()
end

local function fill_menu()
    ---@param tab integer
    ---@param items MenuItemLink[]
    local function fill_item_grid(tab, items)
        for i = 1, #items, 1 do
            local icon = items[i].icon or { texture = gTextures.no_camera, color = WHITE }
            local behavior = items[i].item.behavior
            local model = items[i].item.model
            local params = items[i].item.params
            local anim_state = items[i].item.params.forceAnimState or i
            ---@type MenuItemLink
            local menu_item = {
                item = {
                    behavior = behavior,
                    model = model,
                    animState = anim_state,
                    params = params
                },
                icon = icon,
                held = false
            }
            gMenu[tab].vars.items[i] = menu_item
        end
    end

    Items.fill_item_lists()

    fill_item_grid(TAB_BUILDING_BLOCKS, Items.block_textured_link)
    fill_item_grid(TAB_BUILDING_BLOCKS_COLORS, Items.block_colored_link)
    fill_item_grid(TAB_LEVEL_OBJECTS, Items.level_objects_link)
    fill_item_grid(TAB_ENEMIES, Items.enemies_link)

    -- Insert barrier
    table.insert(gMenu[TAB_BUILDING_BLOCKS_COLORS].vars.items, {
        item = {
            behavior = bhvMceBlock,
            model = E_MODEL_MCE_COLOR_BLOCK,
            animState = MCE_COLOR_BLOCK_BARRIER_ANIM,
            params = get_default_item_params(),
        },
        icon = { texture = get_texture_info("barrier"), color = WHITE },
        held = false
    })

    local tab_icons = {
        { texture = DPLAT_BLOCK_TEX, color = WHITE},
        { texture = DPLAT_BLOCK_TEX, color = WHITE},
        { texture = get_texture_info("starslot"), color = WHITE},
        { texture = get_texture_info("goombaslot"), color = WHITE},
        { texture = CPLAT_BLOCK_TEX, color = WHITE},
    }
    for i = TAB_BUILDING_BLOCKS, TAB_COUNT do
        gMenu[i].icon = tab_icons[i]
    end
end
add_first_update(fill_menu)

-------------- TEXTURES --------------
local t = get_texture_info
A_BUTTON_TEX = t("Abutton")
B_BUTTON_TEX = t("Bbutton")
X_BUTTON_TEX = t("Xbutton")
Y_BUTTON_TEX = t("Ybutton")
--local U_JPAD_TEX = g("UJpad")
--local L_JPAD_TEX = g("LJpad")
--local D_JPAD_TEX = g("DJpad")
--local R_JPAD_TEX = g("RJpad")
UD_JPAD_TEX = t("U-Djpad")
LR_JPAD_TEX = t("L-Rjpad")
U_CBUTTON_TEX = t("Ucbutton")
L_CBUTTON_TEX = t("Lcbutton")
D_CBUTTON_TEX = t("Dcbutton")
R_CBUTTON_TEX = t("Rcbutton")
L_TRIG_TEX = t("Ltrig")
R_TRIG_TEX =  t("Rtrig")
Z_TRIG_TEX =  t("Ztrig")
CONTROL_STICK_TEX = t("Ctrlstick")
PAGE_UP_TEX = t("page_up")
PAGE_DOWN_TEX = t("page_down")
MOUSE_TEX = t("mousecursor")
------------------- HELP PAGE IMAGES -------------------
DEFAULT_TEX = t("nonehelp")
NOCOL_TEX = t("nocolhelp")
NOFALL_TEX = t("placeholder")
NSLIP_TEX = t("nsliphelp")
SLIP_TEX = t("sliphelp")
VSLIP_TEX = t("vsliphelp")
HANGABLE_TEX = t("hangablehelp")
VWIND_TEX = t("vwindhelp")
WATER_TEX = t("waterhelp")
VANISH_TEX = t("vanishhelp")
TOXIC_TEX = t("toxichelp")
SHALLOWSAND_TEX = t("shallowsandhelp")
QUICKSAND_TEX = t("quicksandhelp")
LAVA_TEX = t("lavahelp")
DEATH_TEX = t("deathhelp")
CHECKPOINT_TEX = t("placeholder")
BOUNCE_TEX = t("placeholder")
CONVEYOR_TEX = t("conveyorhelp")
FIRSTY_TEX = t("placeholder")
WIDEKICK_TEX = t("placeholder")
ANYKICK_TEX = t("placeholder")
WKLESS_TEX = t("wklesshelp")
DASH_TEX = t("placeholder")
BOOST_TEX = t("placeholder")
ABC_TEX = t("placeholder")
JUMP_TEX = t("placeholder")
CAPLESS_TEX = t("placeholder")
BREAK_TEX = t("breakhelp")
DISAPPEAR_TEX = t("placeholder")
SHRINK_TEX = t("placeholder")
SPRINGBOARD_TEX = t("placeholder")
------------------- CUSTOM BLOCK TEXTURES -------------------
DPLAT_BLOCK_TEX = get_texture_info("dashpanel")
SPLAT_BLOCK_TEX = get_texture_info("shrinkingplatform")
CPLAT_BLOCK_TEX = get_texture_info("checkpoint")
------------------- MENU SLOTS -------------------
SLOT_GOOMBA_TEX = get_texture_info("goombaslot")
SLOT_BOBOMB_TEX = get_texture_info("bobombslot")
SLOT_CHUCKYA_TEX = get_texture_info("chuckyaslot")
SLOT_1UP_TEX = get_texture_info("1upslot")
SLOT_AMP_TEX = get_texture_info("ampslot")
SLOT_BOO_TEX = get_texture_info("booslot")
SLOT_BULLETBILL_TEX = get_texture_info("bulletbillslot")
SLOT_BULLY_TEX = get_texture_info("bullyslot")
SLOT_CHAINCHOMP_TEX = get_texture_info("chainchompslot") -- Unused
SLOT_CHILLBULLY_TEX = get_texture_info("chillbullyslot")
SLOT_RED_FLAME_TEX = get_texture_info("redflameslot")
SLOT_BLUE_FLAME_TEX = get_texture_info("blueflameslot")
SLOT_FLYGUY_TEX = get_texture_info("flyguyslot")
SLOT_HEAVEHO_TEX = get_texture_info("heavehoslot")
SLOT_KOOPA_TEX = get_texture_info("koopaslot")
SLOT_LAKITU_TEX = get_texture_info("lakituslot") -- Unused
SLOT_MADPIANO_TEX = get_texture_info("madpianoslot")
SLOT_MRBLIZZARD_TEX = get_texture_info("mrblizzardslot")
SLOT_MRI_TEX = get_texture_info("mrislot") -- Unused
SLOT_POKEY_TEX = get_texture_info("pokeyslot")
SLOT_SCUTTLEBUG_TEX = get_texture_info("scuttlebugslot")
SLOT_SMALLWHOMP_TEX = get_texture_info("smallwhompslot")
SLOT_SNUFIT_TEX = get_texture_info("snufitslot")
SLOT_SPINDRIFT_TEX = get_texture_info("spindriftslot")
SLOT_SPINY_TEX = get_texture_info("spinyslot")
SLOT_SWOOP_TEX = get_texture_info("swoopslot")
SLOT_THWOMP_TEX = get_texture_info("thwompslot")
SLOT_STAR_TEX = get_texture_info("starslot")
SLOT_COIN_TEX = get_texture_info("coin_seg3_texture_03005780")
SLOT_EXCLAMATION_BOX_VANISH = get_texture_info("exclamation_box_seg8_texture_08012E28")
SLOT_EXCLAMATION_BOX_METAL = get_texture_info("exclamation_box_seg8_texture_08014628")
SLOT_EXCLAMATION_BOX_WING = get_texture_info("exclamation_box_seg8_texture_08015E28")
SLOT_EXCLAMATION_BOX_NORMAL = get_texture_info("exclamation_box_seg8_texture_08017628")
SLOT_BUBBLY_TREE = get_texture_info("tree_seg3_texture_0302DE28")
SLOT_SPIKEY_TREE = get_texture_info("tree_seg3_texture_0302FF60")
SLOT_SNOWY_TREE = get_texture_info("tree_seg3_texture_03031048")
SLOT_PALM_TREE = get_texture_info("tree_seg3_texture_03032218")
SLOT_CASTLE_DOOR = get_texture_info("door_seg3_texture_03009D10")
SLOT_WOODEN_DOOR = get_texture_info("door_seg3_texture_0300BD10")
SLOT_METAL_DOOR = get_texture_info("door_seg3_texture_0300D510")
SLOT_MURAL_DOOR = get_texture_info("door_seg3_texture_0300ED10")
SLOT_BBH_DOOR = get_texture_info("door_seg3_texture_03010510")

WHITE = { r = 255, g = 255, b = 255, a = 255 }
BLACK = { r = 0, g = 0, b = 0, a = 255 }
RED = { r = 255, g = 0, b = 0, a = 255 }
YELLOW = { r = 255, g = 255, b = 0, a = 255 }
GREEN = { r = 0, g = 255, b = 0, a = 255 }
CYAN = { r = 0, g = 255, b = 255, a = 255 }
BLUE = { r = 0, g = 0, b = 255, a = 255 }
PURPLE = { r = 255, g = 0, b = 255, a = 255 }

MAIN_RECT_COLORS = {
    { r = 200, g = 200, b = 200, a = 255 },
    { r = 255, g = 255, b = 255, a = 255 },
    { r = 90, g = 88, b = 88, a = 255 }
}

---@param color DjuiColor
function djui_hud_set_color_with_table(color)
    djui_hud_set_color(color.r, color.g, color.b, color.a)
end

---@param text string
---@param x number
---@param y number
---@param scale number
function render_shadowed_text(text, x, y, scale)
    local shadow_x = x
    local shadow_y = y
    djui_hud_set_color_with_table(BLACK)
    djui_hud_print_text(text, shadow_x, shadow_y, scale)

    local text_x = shadow_x - 2
    local text_y = shadow_y - 2
    djui_hud_set_color_with_table(WHITE)
    djui_hud_print_text(text, text_x, text_y, scale)
end

---@param rect Rectangle
---@param color DjuiColor
---@param pixel_size number
function render_pixel_border(rect, color, pixel_size) ---------------------needs to be re-adjusted due to margin overlap
    djui_hud_set_color_with_table(color)
    local x, y, width, height = from_rect(rect)
    djui_hud_render_rect(x, y, width, pixel_size)
    djui_hud_render_rect(x, y, pixel_size, height)
    djui_hud_render_rect(x, y + height, width, pixel_size)
    djui_hud_render_rect(x + width, y, pixel_size, height + pixel_size)
end

---@param rect Rectangle
---@param shine DjuiColor
---@param shade DjuiColor
---@param margin_width number
---@param margin_height number
function render_rectangle_borders(rect, shine, shade, margin_width, margin_height)
    local x, y, width, height = from_rect(rect)
    djui_hud_set_color_with_table(shine)
    djui_hud_render_rect(x, y, width, height * margin_height)
    djui_hud_render_rect(x, y, width * margin_width, height)
    djui_hud_set_color_with_table(shade)
    djui_hud_render_rect(x, y + (height - height * margin_height), width, height * margin_height)
    djui_hud_render_rect(x + (width - width * margin_width), y, width * margin_width, height)
end

---@param rect Rectangle
---@param colors DjuiColor[] {base, shine, shade}
---@param margin_width number
---@param margin_height number
---@param remove_pixel_border boolean
function render_bordered_rectangle(rect, colors, margin_width, margin_height, remove_pixel_border)
    render_rectangle_borders(rect, colors[2], colors[3], margin_width, margin_height)
    if not remove_pixel_border then
        render_pixel_border(rect, BLACK, 2)
    end
    djui_hud_set_color_with_table(colors[1])

    local x, y, width, height = from_rect(rect)
    djui_hud_render_rect(
        x + width * margin_width,
        y + height * margin_height,
        width - width * margin_width * 2,
        height - height * margin_height * 2
    )
end

---@param rect Rectangle
---@return number, number, number, number
function from_rect(rect)
    return rect.x, rect.y, rect.width, rect.height
end

---@param x number
---@param y number
---@param width number
---@param height number
---@return Rectangle
function into_rect(x, y, width, height)
    return { x = x, y = y, width = width, height = height }
end