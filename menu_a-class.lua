---@class (exact) MenuItemLink
    ---@field item Item
    ---@field icon Icon
    ---@field self MenuItemLink?

gMenu = {
    open = false,
    ---@type MenuTabs
    tabs = {
        current = 1,
        slots = {
            width = 65,
            height = 65,
            rows = 10,
            columns = 10,
        }
    },
    ---@type Hotbar
    hotbar = {
        index = 1,
        items = {},
        clear = 0,
    },
    ---@type CurrentMenuItem
    current_item = {
        index = 1,
        is_held = false
    },
    settings = {
        transparent = false
    }
}

---@return MenuTab
gMenu.get_current_tab = function ()
    return gMenu.tabs[gMenu.tabs.current]
end

---@return MenuItemLink[]
gMenu.get_current_tab_items = function ()
    return gMenu.tabs[gMenu.tabs.current].items
end

---@return MenuPages
gMenu.get_current_tab_pages = function ()
    return gMenu.tabs[gMenu.tabs.current].pages
end

---@return MenuItemLink
gMenu.get_current_item = function ()
    return gMenu.tabs[gMenu.tabs.current].items[gMenu.current_item.index]
end

---@return MenuPage
gMenu.get_current_page = function ()
    return gMenu.tabs[gMenu.tabs.current].pages[gMenu.tabs[gMenu.tabs.current].pages.current]
end

---@return integer
gMenu.get_current_page_index = function ()
    return gMenu.tabs[gMenu.tabs.current].pages.current
end

---@alias Tab integer

---@class MenuTabs
    ---@field current integer
    ---@field slots ItemSlots
    ---@field [Tab] MenuTab

---@class MenuTab
    ---@field renderer fun(x: number, y: number, width: number, height: number)
    ---@field icon Icon
    ---@field pages MenuPages
    ---@field items MenuItemLink[]
    ---@field misc table

---@class MenuPages
    ---@field current integer
    ---@field count integer
    ---@field item_count integer
    ---@field [integer] MenuPage

---@class MenuPage
    ---@field items MenuItemLink[]

---@class ItemSlots
    ---@field width number
    ---@field height number
    ---@field columns integer
    ---@field rows integer

---@class Hotbar
    ---@field index integer
    ---@field items MenuItemLink[]
    ---@field clear integer

---@class CurrentMenuItem
    ---@field index integer
    ---@field is_held boolean

---@class ItemSettings
    ---@field transparent boolean

---@class Icon
    ---@field texture TextureInfo?
    ---@field color DjuiColor

TAB_BUILDING_BLOCKS = 1 ---@type Tab
TAB_BUILDING_BLOCKS_COLORS = 2 ---@type Tab
TAB_LEVEL_OBJECTS = 3 ---@type Tab
TAB_ENEMIES = 4 ---@type Tab
TAB_SURFACE_TYPES = 5 ---@type Tab
TAB_MAIN_END = 5 ---@type Tab

TAB_BLOCK_SETTINGS = 90 ---@type Tab
TAB_OBJECT_SETTINGS = 91 ---@type Tab

TAB_TO_SETTINGS = {
    [TAB_BUILDING_BLOCKS] = TAB_BLOCK_SETTINGS,
    [TAB_BUILDING_BLOCKS_COLORS] = TAB_BLOCK_SETTINGS,
    [TAB_LEVEL_OBJECTS] = TAB_OBJECT_SETTINGS,
    [TAB_ENEMIES] = TAB_OBJECT_SETTINGS,
}

do
    local function default()
        return {
            renderer = function () end,
            icon = { color = WHITE },
            pages = {
                current = 1,
                count = 1,
                item_count = 1,
            },
            items = {},
            misc = {},
        }
    end

    for i = TAB_BUILDING_BLOCKS, TAB_MAIN_END do
        gMenu.tabs[i] = default()
    end

    -- Unlisted tabs
    gMenu.tabs[TAB_BLOCK_SETTINGS] = default()
    gMenu.tabs[TAB_OBJECT_SETTINGS] = default()
end

local function fill_menu()
    ---@param tab integer
    ---@param items MenuItemLink[]
    local function fill_tab(tab, items)
        for i = 1, #items, 1 do
            local icon = items[i].icon or { texture = gTextures.no_camera }
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
                icon = icon
            }
            menu_item.self = menu_item
            gMenu.tabs[tab].items[i] = menu_item
        end
    end

    fill_item_lists()

    fill_tab(TAB_BUILDING_BLOCKS, gMenuBlockTextureIcons)
    fill_tab(TAB_BUILDING_BLOCKS_COLORS, gMenuBlockColorIcons)
    fill_tab(TAB_LEVEL_OBJECTS, gMenuLevelObjectsIcons)
    fill_tab(TAB_ENEMIES, gMenuEnemyIcons)

    -- Insert barrier
    table.insert(gMenu.tabs[TAB_BUILDING_BLOCKS_COLORS].items, {
        item = {
            behavior = bhvMceBlock,
            model = E_MODEL_MCE_COLOR_BLOCK,
            animState = MCE_COLOR_BLOCK_BARRIER_ANIM,
            params = get_default_item_params(),
        },
        icon = { texture = get_texture_info("barrier"), color = WHITE }
    })

    local tab_icons = {
        { texture = DPLAT_BLOCK_TEX, color = WHITE},
        { texture = DPLAT_BLOCK_TEX, color = WHITE},
        { texture = get_texture_info("starslot"), color = WHITE},
        { texture = get_texture_info("goombaslot"), color = WHITE},
        { texture = CPLAT_BLOCK_TEX, color = WHITE},
    }
    for i = TAB_BUILDING_BLOCKS, TAB_MAIN_END do
        gMenu.tabs[i].icon = tab_icons[i]
    end
end
add_first_update(fill_menu)

HOTBAR_SIZE = 10
for i = 1, HOTBAR_SIZE do
    gMenu.hotbar.items[i] = {} ---@diagnostic disable-line: missing-fields
end

gMenuBlockTextureIcons = {}
gMenuBlockColorIcons = {}
--gMenuBlockCustomIcons = {}
gMenuLevelObjectsIcons = {}
gMenuEnemyIcons = {}
--gMenuCustomItemsIcons = {}

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