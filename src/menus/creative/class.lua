local Items = require("list")

---@class CreativeMenu
    ---@field tab integer
    ---@field item CreativeMenuItem
    ---@field reset CreativeMenuReset
    ---@field [integer] CreativeMenuTab

---@class CreativeMenuItem
    ---@field link MenuItemLink?
    ---@field index integer

---@class CreativeMenuScroll
    ---@field index integer
    ---@field max integer

---@class CreativeMenuReset
    ---@field active boolean
    ---@field progress integer
    ---@field leniency integer

---@class CreativeMenuTab : MenuTab
    ---@field grid MenuItemLink[]

---@class MenuItemLink
    ---@field item Item
    ---@field icon Icon
    ---@field held boolean

---@type CreativeMenu
local Menu = {
    tab = 1,
    item = {
        link = nil,
        index = 0,
    },
    reset = {
        active = false,
        progress = 0,
        leniency = 0,
    },
}

CREATIVE_TAB_BUILDING_BLOCKS = 1
CREATIVE_TAB_BUILDING_BLOCKS_COLORS = 2
CREATIVE_TAB_LEVEL_OBJECTS = 3
CREATIVE_TAB_ENEMIES = 4
CREATIVE_TAB_COUNT = 4

do
    local function default(tab_index, name, icon)
        ---@type CreativeMenuTab
        local ret = {
            name = name,
            icon = icon,
            scroll = {
                index = 1,
                max = 1,
            },
            grid = {},
        }
        return ret
    end

    Menu[CREATIVE_TAB_BUILDING_BLOCKS] = default(CREATIVE_TAB_BUILDING_BLOCKS, "Building Blocks", { texture = get_texture_info("dashpanel"), color = WHITE })
    Menu[CREATIVE_TAB_BUILDING_BLOCKS_COLORS] = default(CREATIVE_TAB_BUILDING_BLOCKS_COLORS, "Building Blocks", { texture = gTextures.no_camera, color = WHITE })
    Menu[CREATIVE_TAB_LEVEL_OBJECTS] = default(CREATIVE_TAB_LEVEL_OBJECTS, "Level Objects", { texture = get_texture_info("starslot"), color = WHITE })
    Menu[CREATIVE_TAB_ENEMIES] = default(CREATIVE_TAB_ENEMIES, "Enemies", { texture = get_texture_info("goombaslot"), color = WHITE })
end

local function fill_menu()
    ---@param tab integer
    ---@param items MenuItemLink[]
    local function fill_item_grid(tab, items)
        for i = 1, #items, 1 do
            local icon = items[i].icon
            local behavior = items[i].item.behavior
            local model = items[i].item.model
            local params = items[i].item.params
            local anim_state = 0
            if tab == CREATIVE_TAB_BUILDING_BLOCKS then
                anim_state = i
            end
            ---@type MenuItemLink
            local menu_item = {
                item = get_default_item(),
                icon = icon,
                held = false
            }
            menu_item.item.behavior = behavior
            menu_item.item.model = model
            menu_item.item.animState = anim_state
            menu_item.item.params = params
            Menu[tab].grid[i] = menu_item
        end
    end

    Items.fill_item_lists()

    fill_item_grid(CREATIVE_TAB_BUILDING_BLOCKS, Items.block_textured_link)
    fill_item_grid(CREATIVE_TAB_BUILDING_BLOCKS_COLORS, Items.block_colored_link)
    fill_item_grid(CREATIVE_TAB_LEVEL_OBJECTS, Items.level_objects_link)
    fill_item_grid(CREATIVE_TAB_ENEMIES, Items.enemies_link)
end
add_first_update(fill_menu)

return Menu