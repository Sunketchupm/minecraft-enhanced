local Mouse = require("../mouse")
local Shapes = require("../../block/shapes")

---@class SettingsMenu
    ---@field tab integer
    ---@field option_index integer
    ---@field rendered_max_index integer
    ---@field doing_inputs boolean
    ---@field [integer] SettingsMenuTab

---@class SettingsMenuTab : MenuTab
    ---@field [integer] SettingsMenuOption

---@class SettingsMenuOption
    ---@field name string
    ---@field type integer
    ---@field rect Rectangle?
    ---@field action fun(...: any): any
    ---@field update fun(...: any): any

---@type SettingsMenu
local Settings = {
    tab = 1,
    option_index = 1,
    rendered_max_index = 1,
    doing_inputs = false
}

SETTINGS_TAB_ITEM_SETTINGS = 1
SETTINGS_TAB_BLOCK_SHAPES = 2
SETTINGS_TAB_BLOCK_SURFACES = 3
SETTINGS_TAB_COUNT = 3

SETTINGS_OPTION_TYPE_BUTTON = 1
SETTINGS_OPTION_TYPE_CHECKBOX = 2
SETTINGS_OPTION_TYPE_SLIDER = 3
SETTINGS_OPTION_TYPE_ONLY_TEXT = 4
SETTINGS_OPTION_TYPE_SURFACE_BUTTON = 5

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
        rect = { x = 0, y = 0, width = 0, height = 0 }
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
                local current_option = Settings[Settings.tab][Settings.option_index]
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
        rect = { x = 0, y = 0, width = 0, height = 0 }
    }
    ---@param inputs Inputs
    ret.action = function (inputs)
        if gCurrentItem then
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
        rect = { x = 0, y = 0, width = 0, height = 0 }
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
        rect = { x = 0, y = 0, width = 0, height = 0 }
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
        rect = { x = 0, y = 0, width = 0, height = 0 }
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

Settings[SETTINGS_TAB_ITEM_SETTINGS] = {
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

Settings[SETTINGS_TAB_BLOCK_SHAPES] = {
    __shape_button("Cube", Shapes.SHAPE_CUBE),
    __shape_button("Cylinder", Shapes.SHAPE_CYLINDER),
    __shape_button("Pyramid", Shapes.SHAPE_PYRAMID),
    __shape_button("Sphere", Shapes.SHAPE_SPHERE),
    __shape_button("Stair", Shapes.SHAPE_STAIR),
    __shape_button("Slope", Shapes.SHAPE_SLOPE),
}
Settings[SETTINGS_TAB_BLOCK_SURFACES] = {
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

Settings[SETTINGS_TAB_ITEM_SETTINGS].icon = { texture = gTextures.star, color = WHITE }
Settings[SETTINGS_TAB_ITEM_SETTINGS].name = "Item Settings"
Settings[SETTINGS_TAB_ITEM_SETTINGS].scroll = { index = 1, max = -1 }

Settings[SETTINGS_TAB_BLOCK_SHAPES].icon = { texture = gTextures.no_camera, color = WHITE }
Settings[SETTINGS_TAB_BLOCK_SHAPES].name = "Block Shapes"
Settings[SETTINGS_TAB_BLOCK_SHAPES].scroll = { index = 1, max = -1 }

Settings[SETTINGS_TAB_BLOCK_SURFACES].icon = { texture = gTextures.arrow_up, color = WHITE }
Settings[SETTINGS_TAB_BLOCK_SURFACES].name = "Block Surfaces"
Settings[SETTINGS_TAB_BLOCK_SURFACES].scroll = { index = 1, max = -1 }

return Settings