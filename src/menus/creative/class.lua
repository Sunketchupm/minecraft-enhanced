local Mouse = require("../mouse")

local Shapes = require("../../block/shapes")

local Items = require("list")

---@class CreativeMenu
    ---@field tab integer
    ---@field grid CreativeMenuGrid
    ---@field settings CreativeMenuSettings
    ---@field [integer] CreativeMenuTab

---@class CreativeMenuTab : MenuTab
    ---@field type integer
    ---@field [integer] (CreativeMenuItemLink | CreativeMenuOption)

---@class CreativeMenuGrid
    ---@field item CreativeMenuItem
    ---@field reset CreativeMenuReset

---@class CreativeMenuItem
    ---@field link CreativeMenuItemLink?
    ---@field index integer

---@class CreativeMenuReset
    ---@field active boolean
    ---@field progress integer
    ---@field leniency integer

---@class CreativeMenuSettings
    ---@field index integer
    ---@field rendered_max_index integer
    ---@field doing_inputs boolean

---@class CreativeMenuItemLink
    ---@field item Item
    ---@field icon Icon
    ---@field held boolean

---@class CreativeMenuOption
    ---@field name string
    ---@field type integer
    ---@field rect Rectangle
    ---@field action fun(...: any): any
    ---@field update fun(...: any): any

---@type CreativeMenu
local Menu = {
    tab = 1,
    grid = {
        item = {
            link = nil,
            index = 0,
        },
        reset = {
            active = false,
            progress = 0,
            leniency = 0,
        },
    },
    settings = {
        index = 1,
        rendered_max_index = 1,
        doing_inputs = false,
    }
}

TAB_TYPE_GRID = 1
TAB_TYPE_SETTINGS = 2

CREATIVE_TAB_BUILDING_BLOCKS = 1
CREATIVE_TAB_BUILDING_BLOCKS_COLORS = 2
CREATIVE_TAB_LEVEL_OBJECTS = 3
CREATIVE_TAB_ENEMIES = 4
CREATIVE_TAB_ITEM_SETTINGS = 5
CREATIVE_TAB_BLOCK_SHAPES = 6
CREATIVE_TAB_BLOCK_SURFACES = 7
CREATIVE_TAB_COUNT = 7

SETTINGS_OPTION_TYPE_BUTTON = 1
SETTINGS_OPTION_TYPE_CHECKBOX = 2
SETTINGS_OPTION_TYPE_SLIDER = 3
SETTINGS_OPTION_TYPE_ONLY_TEXT = 4
SETTINGS_OPTION_TYPE_SURFACE_BUTTON = 5

local function __default_rect()
    return { x = 0, y = 0, width = 0, height = 0 }
end

local function __fill_grid_tabs()
    ---@param tab integer
    ---@param items CreativeMenuItemLink[]
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
            ---@type CreativeMenuItemLink
            local menu_item = {
                item = get_default_item(),
                icon = icon,
                held = false,
                rect = __default_rect()
            }
            menu_item.item.behavior = behavior
            menu_item.item.model = model
            menu_item.item.animState = anim_state
            menu_item.item.params = params
            Menu[tab][i] = menu_item
        end
    end

    Items.fill_item_lists()

    fill_item_grid(CREATIVE_TAB_BUILDING_BLOCKS, Items.block_textured_link)
    fill_item_grid(CREATIVE_TAB_BUILDING_BLOCKS_COLORS, Items.block_colored_link)
    fill_item_grid(CREATIVE_TAB_LEVEL_OBJECTS, Items.level_objects_link)
    fill_item_grid(CREATIVE_TAB_ENEMIES, Items.enemies_link)
end
add_first_update(__fill_grid_tabs)

local function __name(name)
    return {
        name = name,
        type = SETTINGS_OPTION_TYPE_ONLY_TEXT,
        action = function () end,
        update = function () end,
    }
end

local function __item_slider(name, key, dimension)
    local ret = {
        name = name,
        type = SETTINGS_OPTION_TYPE_SLIDER,
        rect = __default_rect()
    }
    local min, max = 0.1, 25
    if key == "rotation" then
        min, max = -180, 180
    end
    ---@param inputs Inputs
    ret.action = function (inputs)
        if gCurrentItem then
            local is_rotation = key == "rotation"
            if Mouse.moved and (Mouse.down.left or Mouse.down.middle) then
                local current_option = Menu[Menu.tab][Menu.settings.index]
                local invlerp_min, invlerp_max = current_option.rect.x, current_option.rect.x + current_option.rect.width
                local invlerp = math.invlerp(invlerp_min, invlerp_max, Mouse.pos.x)
                local scale = is_rotation and 360 or 25
                local final_val = is_rotation and (math.round(invlerp * scale) - 180) or (invlerp * scale)
                if Mouse.down.middle then
                    final_val = is_rotation and
                        ((final_val // 5) * 5) or
                        (math.round(final_val * 10) * 0.1)
                end
                gCurrentItem.dimensions[key][dimension] = final_val
                if key == "size" then
                    gCurrentItem.dimensions.grid[dimension] = gCurrentItem.dimensions.size[dimension]
                end
            else
                local slowdown = inputs.buttons.down & Z_TRIG ~= 0
                local speedup = inputs.buttons.down & B_BUTTON ~= 0
                local normal = is_rotation and 5 or 1
                local fast = is_rotation and 15 or 5
                local slow = is_rotation and 1 or 0.1
                local speed = normal
                if slowdown then
                    speed = slow
                elseif speedup then
                    speed = fast
                end

                local is_size = key == "size"

                if inputs.stick.left then
                    gCurrentItem.dimensions[key][dimension] = gCurrentItem.dimensions[key][dimension] - speed
                    if is_size then
                        gCurrentItem.dimensions.grid[dimension] = gCurrentItem.dimensions.size[dimension]
                    end
                    audio_sample_play(SOUND_MCE_MOVE, gGlobalSoundSource, 1)
                elseif inputs.stick.right then
                    gCurrentItem.dimensions[key][dimension] = gCurrentItem.dimensions[key][dimension] + speed
                    if is_size then
                        gCurrentItem.dimensions.grid[dimension] = gCurrentItem.dimensions.size[dimension]
                    end
                    audio_sample_play(SOUND_MCE_MOVE, gGlobalSoundSource, 1)
                end
            end
            gCurrentItem.dimensions[key][dimension] = math.clamp(gCurrentItem.dimensions[key][dimension], min, max)
        end
    end
    ret.update = function ()
        if gCurrentItem then
            return {
                val = gCurrentItem.dimensions[key][dimension],
                min = min,
                max = max
            }
        end
    end

    return ret
end

local function __color_slider(name, color)
    local ret = {
        name = name,
        type = SETTINGS_OPTION_TYPE_SLIDER,
        rect = __default_rect()
    }
    ---@param inputs Inputs
    ret.action = function (inputs)
        if gCurrentItem then
            if Mouse.moved and (Mouse.down.left or Mouse.down.middle) then
                local current_option = Menu[Menu.tab][Menu.settings.index]
                local invlerp_min, invlerp_max = current_option.rect.x, current_option.rect.x + current_option.rect.width
                local invlerp = math.invlerp(invlerp_min, invlerp_max, Mouse.pos.x)
                local scale = 255
                local final_val = invlerp * scale
                if Mouse.down.middle then
                    final_val = ((final_val // 5) * 5)
                end
                gCurrentItem.params.color[color] = math.clamp(math.round(final_val), 0, 255)
            else
                local slowdown = inputs.buttons.down & Z_TRIG ~= 0
                local speedup = inputs.buttons.down & B_BUTTON ~= 0
                local normal = 5
                local fast = 15
                local slow = 1
                local speed = normal
                if slowdown then
                    speed = slow
                elseif speedup then
                    speed = fast
                end

                if inputs.stick.left then
                    gCurrentItem.params.color[color] = gCurrentItem.params.color[color] - speed
                    audio_sample_play(SOUND_MCE_MOVE, gGlobalSoundSource, 1)
                elseif inputs.stick.right then
                    gCurrentItem.params.color[color] = gCurrentItem.params.color[color] + speed
                    audio_sample_play(SOUND_MCE_MOVE, gGlobalSoundSource, 1)
                end
                gCurrentItem.params.color[color] = math.clamp(gCurrentItem.params.color[color], 0, 255)
            end
        end
    end
    ret.update = function ()
        if gCurrentItem then
            return {
                val = gCurrentItem.params.color[color],
                min = 0,
                max = 255
            }
        end
    end

    return ret
end

local function __flag_checkbox(name, flag)
    local ret = {
        name = name,
        type = SETTINGS_OPTION_TYPE_CHECKBOX,
        rect = __default_rect()
    }
    ---@param inputs Inputs
    ret.action = function (inputs)
        if gCurrentItem then
            if inputs.buttons.pressed & A_BUTTON ~= 0 then
                mce_block_toggle_flag(gCurrentItem, flag)
                audio_sample_play(SOUND_MCE_PRESS, gGlobalSoundSource, 1)
            end
        end
    end
    ret.update = function ()
        return gCurrentItem and not mce_block_check_flag(gCurrentItem, flag)
    end

    return ret
end

local function __shape_button(name, shape)
    local ret = {
        name = name,
        type = SETTINGS_OPTION_TYPE_BUTTON,
        rect = __default_rect()
    }
    ---@param inputs Inputs
    ret.action = function (inputs)
        if gCurrentItem then
            if inputs.buttons.pressed & A_BUTTON ~= 0 then
                mce_block_set_shape(gCurrentItem, shape)
                audio_sample_play(SOUND_MCE_PRESS, gGlobalSoundSource, 1)
            end
        end
    end
    ret.update = function () end

    return ret
end

local function __surface_button(name)
    local ret = {
        name = name,
        type = SETTINGS_OPTION_TYPE_SURFACE_BUTTON,
        rect = __default_rect()
    }
    ---@param inputs Inputs
    ret.action = function (inputs)
        if gCurrentItem then
            if inputs.buttons.pressed & A_BUTTON ~= 0 then
                on_set_surface_chat_command(name)
                audio_sample_play(SOUND_MCE_PRESS, gGlobalSoundSource, 1)
            end
        end
    end
    ret.update = function () end

    return ret
end

Menu[CREATIVE_TAB_BUILDING_BLOCKS] = {}
Menu[CREATIVE_TAB_BUILDING_BLOCKS_COLORS] = {}
Menu[CREATIVE_TAB_LEVEL_OBJECTS] = {}
Menu[CREATIVE_TAB_ENEMIES] = {}

Menu[CREATIVE_TAB_ITEM_SETTINGS] = {
    __name("Size"),
    __item_slider("Length: %.2f", "size", "x"),
    __item_slider("Height: %.2f", "size", "y"),
    __item_slider("Width: %.2f", "size", "z"),
    __name("Rotation"),
    __item_slider("Pitch: %d", "rotation", "x"),
    __item_slider("Yaw: %d", "rotation", "y"),
    __item_slider("Roll: %d", "rotation", "z"),
    __name("Grid"),
    __item_slider("X: %.2f", "grid", "x"),
    __item_slider("Y: %.2f", "grid", "y"),
    __item_slider("Z: %.2f", "grid", "z"),
    __flag_checkbox("Shaded", MCE_BLOCK_FLAG_UNSHADED),
    __flag_checkbox("Tiled", MCE_BLOCK_FLAG_UNTILED),
    __name("Color"),
    __color_slider("Red: %d", "r"),
    __color_slider("Green: %d", "g"),
    __color_slider("Blue: %d", "b"),
    __color_slider("Opacity: %d", "a"),
}

Menu[CREATIVE_TAB_BLOCK_SHAPES] = {
    __shape_button("Cube", Shapes.SHAPE_CUBE),
    __shape_button("Cylinder", Shapes.SHAPE_CYLINDER),
    __shape_button("Pyramid", Shapes.SHAPE_PYRAMID),
    __shape_button("Sphere", Shapes.SHAPE_SPHERE),
    __shape_button("Stair", Shapes.SHAPE_STAIR),
    __shape_button("Slope", Shapes.SHAPE_SLOPE),
}
Menu[CREATIVE_TAB_BLOCK_SURFACES] = {
    __surface_button("Default"),
    __surface_button("No Collision"),
    __surface_button("No Fall Damage"),
    __surface_button("Slippery"),
    __surface_button("Not Slippery"),
    __surface_button("Very Slippery"),
    __surface_button("Shallowsand"),
    __surface_button("Quicksand"),
    __surface_button("Lava"),
    __surface_button("Toxic Gas"),
    __surface_button("Death"),
    __surface_button("Vanish"),
    __surface_button("Hangable"),
    __surface_button("Water"),
    __surface_button("Vertical Wind"),
    __surface_button("Checkpoint"),
    __surface_button("Bounce"),
    __surface_button("Conveyor"),
    __surface_button("Firsty"),
    __surface_button("Widekick"),
    __surface_button("Anykick"),
    __surface_button("Wallkickless"),
    __surface_button("Dash Panel"),
    __surface_button("Booster"),
    __surface_button("Jumpless"),
    __surface_button("Jump Pad"),
    __surface_button("Capless"),
    __surface_button("Breakable"),
    __surface_button("Disappearing"),
    __surface_button("Shrinking"),
    __surface_button("Springboard"),
}

local function init_tab(tab, tab_type, name, icon)
    tab.name = name
    tab.icon = icon
    tab.type = tab_type
    tab.scroll = { index = 1, max = -1 }
end

init_tab(Menu[CREATIVE_TAB_BUILDING_BLOCKS], TAB_TYPE_GRID, "Building Blocks", { texture = get_texture_info("dashpanel"), color = WHITE })
init_tab(Menu[CREATIVE_TAB_BUILDING_BLOCKS_COLORS], TAB_TYPE_GRID, "Building Blocks", { texture = gTextures.no_camera, color = WHITE })
init_tab(Menu[CREATIVE_TAB_LEVEL_OBJECTS], TAB_TYPE_GRID, "Level Objects", { texture = get_texture_info("starslot"), color = WHITE })
init_tab(Menu[CREATIVE_TAB_ENEMIES], TAB_TYPE_GRID, "Enemies", { texture = get_texture_info("goombaslot"), color = WHITE })
init_tab(Menu[CREATIVE_TAB_ITEM_SETTINGS], TAB_TYPE_SETTINGS, "Item Settings", { texture = gTextures.coin, color = WHITE })
init_tab(Menu[CREATIVE_TAB_BLOCK_SHAPES], TAB_TYPE_SETTINGS, "Block Shapes", { texture = gTextures.camera, color = WHITE })
init_tab(Menu[CREATIVE_TAB_BLOCK_SURFACES], TAB_TYPE_SETTINGS, "Block Surfaces", { texture = get_texture_info("checkpoint"), color = WHITE })

return Menu