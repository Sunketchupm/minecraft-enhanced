local Shapes = require("shapes")
local Hotbar = require("../menus/hotbar/class")

--[[ Custom properties:
    oAnimState:
        - 1st+2nd byte: texture id
        - 3rd byte: shape id
        - 4th byte: flags:
        - - 1st bit: is colored
        - - 2nd bit: is shaded
        - - 3rd bit: is untiled
]]

MCE_BLOCK_FLAG_COLORED = (1 << 24)
MCE_BLOCK_FLAG_UNSHADED = (1 << 25)
MCE_BLOCK_FLAG_UNTILED = (1 << 26)

MCE_BLOCK_SHAPE_CUBE = 0
MCE_BLOCK_SHAPE_PYRAMID = 1

-- Surfaces
MCE_BLOCK_COL_ID_NO_COLLISION = 0xFF
MCE_BLOCK_COL_ID_DEFAULT = 0
MCE_BLOCK_COL_ID_LAVA = 1
MCE_BLOCK_COL_ID_DEATH = 2
MCE_BLOCK_COL_ID_QUICKSAND = 3
MCE_BLOCK_COL_ID_SHALLOW_QUICKSAND = 4
MCE_BLOCK_COL_ID_NOT_SLIPPERY = 5
MCE_BLOCK_COL_ID_SLIPPERY = 6
MCE_BLOCK_COL_ID_VERY_SLIPPERY = 7
MCE_BLOCK_COL_ID_HANGABLE = 8
MCE_BLOCK_COL_ID_VANISH = 9
MCE_BLOCK_COL_ID_VERTICAL_WIND = 10
MCE_BLOCK_COL_ID_WATER = 11
MCE_BLOCK_COL_ID_BOUNCE = 12
MCE_BLOCK_COL_ID_BOOSTER = 13
MCE_BLOCK_COL_ID_DASH_PANEL = 14
MCE_BLOCK_COL_ID_TOXIC_GAS = 15
MCE_BLOCK_COL_ID_JUMP_PAD = 16
MCE_BLOCK_COL_ID_SPRINGBOARD = 17

-- Properties
MCE_BLOCK_PROPERTY_FIRSTY = (1 << 0)
MCE_BLOCK_PROPERTY_WIDE_WALLKICK = (1 << 1)
MCE_BLOCK_PROPERTY_NO_A = (1 << 2)
MCE_BLOCK_PROPERTY_ANY_BONK_WALLKICK = (1 << 3)
MCE_BLOCK_PROPERTY_NO_FALL_DAMAGE = (1 << 4)
MCE_BLOCK_PROPERTY_CONVEYOR = (1 << 5)
MCE_BLOCK_PROPERTY_BREAKABLE = (1 << 6)
MCE_BLOCK_PROPERTY_DISAPPEARING = (1 << 7)
MCE_BLOCK_PROPERTY_REMOVE_CAPS = (1 << 8)
MCE_BLOCK_PROPERTY_NO_WALLKICKS = (1 << 9)
MCE_BLOCK_PROPERTY_SHRINKING = (1 << 10)
MCE_BLOCK_PROPERTY_CHECKPOINT = (1 << 11)

MCE_BLOCK_ACT_RESET = 10

gIgnoreCollisionLookup = {
    [MCE_BLOCK_COL_ID_NO_COLLISION] = true,
    [MCE_BLOCK_COL_ID_VERTICAL_WIND] = true,
    [MCE_BLOCK_COL_ID_WATER] = true,
    [MCE_BLOCK_COL_ID_TOXIC_GAS] = true,
    [MCE_BLOCK_COL_ID_BOOSTER] = true,
}

---@type table<integer, StaticObjectCollision>
gBlockCollisionLookup = {}

local sBlockSurfaceIdLookup = {
    ["default"] = MCE_BLOCK_COL_ID_DEFAULT,
    ["normal"] = MCE_BLOCK_COL_ID_DEFAULT,
    --------
    ["none"] = MCE_BLOCK_COL_ID_NO_COLLISION,
    ["no collision"] = MCE_BLOCK_COL_ID_NO_COLLISION,
    ["intangible"] = MCE_BLOCK_COL_ID_NO_COLLISION,
    --------
    ["lava"] = MCE_BLOCK_COL_ID_LAVA,
    --------
    ["toxic gas"] = MCE_BLOCK_COL_ID_TOXIC_GAS,
    ["toxic"] = MCE_BLOCK_COL_ID_TOXIC_GAS,
    ["gas"] = MCE_BLOCK_COL_ID_TOXIC_GAS,
    --------
    ["death"] = MCE_BLOCK_COL_ID_DEATH,
    --------
    ["quicksand"] = MCE_BLOCK_COL_ID_QUICKSAND,
    ["qsand"] = MCE_BLOCK_COL_ID_QUICKSAND,
    --------
    ["shallow quicksand"] = MCE_BLOCK_COL_ID_SHALLOW_QUICKSAND,
    ["shallowsand"] = MCE_BLOCK_COL_ID_SHALLOW_QUICKSAND,
    ["ssand"] = MCE_BLOCK_COL_ID_SHALLOW_QUICKSAND,
    --------
    ["not slippery"] = MCE_BLOCK_COL_ID_NOT_SLIPPERY,
    ["not slip"] = MCE_BLOCK_COL_ID_NOT_SLIPPERY,
    ["nslip"] = MCE_BLOCK_COL_ID_NOT_SLIPPERY,
    ["n slippery"] = MCE_BLOCK_COL_ID_NOT_SLIPPERY,
    --------
    ["slippery"] = MCE_BLOCK_COL_ID_SLIPPERY,
    ["slip"] = MCE_BLOCK_COL_ID_SLIPPERY,
    --------
    ["very slippery"] = MCE_BLOCK_COL_ID_VERY_SLIPPERY,
    ["v slippery"] = MCE_BLOCK_COL_ID_VERY_SLIPPERY,
    ["vslip"] = MCE_BLOCK_COL_ID_VERY_SLIPPERY,
    --------
    ["hangable"] = MCE_BLOCK_COL_ID_HANGABLE,
    ["hang"] = MCE_BLOCK_COL_ID_HANGABLE,
    --------
    ["vanish"] = MCE_BLOCK_COL_ID_VANISH,
    --------
    ["vertical wind"] = MCE_BLOCK_COL_ID_VERTICAL_WIND,
    ["vwind"] = MCE_BLOCK_COL_ID_VERTICAL_WIND,
    --------
    ["water"] = MCE_BLOCK_COL_ID_WATER,
    ["swim"] = MCE_BLOCK_COL_ID_WATER,
    --------
    ["bounce"] = MCE_BLOCK_COL_ID_BOUNCE,
    --------
    ["booster"] = MCE_BLOCK_COL_ID_BOOSTER,
    ["boost"] = MCE_BLOCK_COL_ID_BOOSTER,
    --------
    ["dash"] = MCE_BLOCK_COL_ID_DASH_PANEL,
    ["dash panel"] = MCE_BLOCK_COL_ID_DASH_PANEL,
    --------
    ["springboard"] = MCE_BLOCK_COL_ID_SPRINGBOARD,
    ["spring"] = MCE_BLOCK_COL_ID_SPRINGBOARD,
    ["noteblock"] = MCE_BLOCK_COL_ID_SPRINGBOARD,
    --------
    ["jump pad"] = MCE_BLOCK_COL_ID_JUMP_PAD,
    ["jpad"] = MCE_BLOCK_COL_ID_JUMP_PAD,
}

local sBlockPropertyLookup = {
    ["conveyor"] = MCE_BLOCK_PROPERTY_CONVEYOR,
    --------
    ["firsty"] = MCE_BLOCK_PROPERTY_FIRSTY,
    ["firstie"] = MCE_BLOCK_PROPERTY_FIRSTY,
    --------
    ["wide"] = MCE_BLOCK_PROPERTY_WIDE_WALLKICK,
    ["wide wallkick"] = MCE_BLOCK_PROPERTY_WIDE_WALLKICK,
    ["widekick"] = MCE_BLOCK_PROPERTY_WIDE_WALLKICK,
    --------
    ["any bonk"] = MCE_BLOCK_PROPERTY_ANY_BONK_WALLKICK,
    ["anykick"] = MCE_BLOCK_PROPERTY_ANY_BONK_WALLKICK,
    --------
    ["no wallkicks"] = MCE_BLOCK_PROPERTY_NO_WALLKICKS,
    ["wallkickless"] = MCE_BLOCK_PROPERTY_NO_WALLKICKS,
    ["wkless"] = MCE_BLOCK_PROPERTY_NO_WALLKICKS,
    --------
    ["no a"] = MCE_BLOCK_PROPERTY_NO_A,
    ["abc"] = MCE_BLOCK_PROPERTY_NO_A,
    ["jumpless"] = MCE_BLOCK_PROPERTY_NO_A,
    --------
    ["breakable"] = MCE_BLOCK_PROPERTY_BREAKABLE,
    ["break"] = MCE_BLOCK_PROPERTY_BREAKABLE,
    --------
    ["disappear"] = MCE_BLOCK_PROPERTY_DISAPPEARING,
    ["disappearing"] = MCE_BLOCK_PROPERTY_DISAPPEARING,
    --------
    ["remove caps"] = MCE_BLOCK_PROPERTY_REMOVE_CAPS,
    ["capsless"] = MCE_BLOCK_PROPERTY_REMOVE_CAPS,
    ["capless"] = MCE_BLOCK_PROPERTY_REMOVE_CAPS,
    --------
    ["shrink"] = MCE_BLOCK_PROPERTY_SHRINKING,
    ["shrinking"] = MCE_BLOCK_PROPERTY_SHRINKING,
    --------
    ["no fall damage"] = MCE_BLOCK_PROPERTY_NO_FALL_DAMAGE,
    ["nofall"] = MCE_BLOCK_PROPERTY_NO_FALL_DAMAGE,
    --------
    ["checkpoint"] = MCE_BLOCK_PROPERTY_CHECKPOINT,
    ["respawn"] = MCE_BLOCK_PROPERTY_CHECKPOINT,
}

---@param msg string
function on_set_surface_chat_command(msg)
    ---@type Item?
    local item = gCurrentItem
    if item and item.behavior == bhvMceBlock then
        if msg:lower() == "reset" or msg:lower() == "clear" then
            item.params.params = item.params.params & ~0xFF
            item.params.flags = 0
            djui_chat_message_create("The surface has been reset")
            return true
        end

        local surf = sBlockSurfaceIdLookup[msg:lower()]
        if surf then
            item.params.params = surf
            djui_chat_message_create("Set the surface type to " .. msg)
        else
            surf = sBlockPropertyLookup[msg:lower()]
            if surf then
                local properties = item.params.flags
                if properties & surf == 0 then
                    local is_selecting_incompatible = surf & (MCE_BLOCK_PROPERTY_BREAKABLE | MCE_BLOCK_PROPERTY_DISAPPEARING | MCE_BLOCK_PROPERTY_SHRINKING) ~= 0
                    local currently_has_incompatible = properties & (MCE_BLOCK_PROPERTY_BREAKABLE | MCE_BLOCK_PROPERTY_DISAPPEARING | MCE_BLOCK_PROPERTY_SHRINKING) ~= 0
                    if is_selecting_incompatible and currently_has_incompatible then
                        properties = properties & ~(MCE_BLOCK_PROPERTY_BREAKABLE | MCE_BLOCK_PROPERTY_DISAPPEARING | MCE_BLOCK_PROPERTY_SHRINKING)
                        djui_chat_message_create("The breakable, disappearing, and shrinking properties are incompatible with each other. Incompatibilities removed")
                    end
                    item.params.flags = properties | surf
                    djui_chat_message_create("Added the surface property " .. msg)
                else
                    item.params.flags = properties & ~surf
                    djui_chat_message_create("Removed the surface property " .. msg)
                end
            else
                djui_chat_message_create("Could not find surface type or property " .. "\"" .. msg .. "\"")
            end
        end
    else
        djui_chat_message_create("You must have a block selected to change its surface type!")
    end
    return true
end

---@param msg string
local function on_transparent_chat_command(msg)
    local item = gCurrentItem
    if item and item.behavior == bhvMceBlock then
        local number_msg = tonumber(msg)
        if number_msg then
            local alpha = math.clamp(number_msg, 0, 255)
            item.params.color.a = alpha

            djui_chat_message_create("The current block's alpha has been set to " .. alpha)
        else
            local alpha = item.params.color.a
            if alpha < 255 then
                alpha = 255
                djui_chat_message_create("The current block is no longer transparent")
            else
                alpha = 127
                djui_chat_message_create("The current block is now transparent")
            end
            item.params.color.a = alpha
        end
    else
        djui_chat_message_create("A block must be selected!")
    end
    return true
end

---@param msg string
local function on_replace_chat_command(msg)
    local commands = string.split(msg, " ")
    if not commands[1] or not tonumber(commands[1]) then
        djui_chat_message_create("You need to supply the hotbar index to replace the current block with")
        return true
    end
    if not gCurrentItem then
        djui_chat_message_create("You need to be holding the block you want to replace")
        return true
    end

    local new_hotbar_index = math.floor(tonumber(commands[1]) --[[@as integer]])
    local new_hotbar_item_link = Hotbar[new_hotbar_index].link
    if not new_hotbar_item_link or not new_hotbar_item_link.item then
        djui_chat_message_create("Can't replace using an empty slot")
        return true
    end
    local new_hotbar_item = new_hotbar_item_link.item

    local owner_index = network_global_index_from_local(0) + 1

    local obj = obj_get_first_with_behavior_id(bhvMceBlock)
    while obj do
        if obj.oOwner == owner_index and obj.oAnimState & 0xFFFF == gCurrentItem.animState & 0xFFFF then
            obj.oAnimState = new_hotbar_item.animState
            local color = color_table_to_integer(new_hotbar_item.params.color)
            obj.oColor = color
            obj.oOpacity = color & 0xFF
            network_send_object(obj, true)
        end
        obj = obj_get_next_with_same_behavior_id(obj)
    end
    djui_chat_message_create("Successfully replaced objects")
    return true
end

---@param msg string
local function on_set_color_chat_command(msg)
    if not gCurrentItem or gCurrentItem.model ~= E_MODEL_MCE_BLOCK or not mce_block_check_flag(gCurrentItem, MCE_BLOCK_FLAG_COLORED) then
        djui_chat_message_create("You need to be holding a color block to set its color")
        return true
    end

    local commands = string.split(msg, " ")
    if not (commands[1] and commands[2] and commands[3]) then
        djui_chat_message_create("Usage: [<r> <g> <b>]")
        return true
    end

    local __parse_color = function (item, color, key) return parse_dimension(item.params.color, color, key, 0, 255, true) end
    local r = __parse_color(gCurrentItem, commands[1], "r")
    local g = __parse_color(gCurrentItem, commands[2], "g")
    local b = __parse_color(gCurrentItem, commands[3], "b")
    gCurrentItem.params.color.r = r
    gCurrentItem.params.color.g = g
    gCurrentItem.params.color.b = b

    return true
end


local function on_set_shade_chat_command()
    if not gCurrentItem or gCurrentItem.model ~= E_MODEL_MCE_BLOCK then
        djui_chat_message_create("You need to be holding a block to toggle its shade")
        return true
    end

    mce_block_toggle_flag(gCurrentItem, MCE_BLOCK_FLAG_UNSHADED)
    local is_unshaded = mce_block_check_flag(gCurrentItem, MCE_BLOCK_FLAG_UNSHADED)
    djui_chat_message_create("The current block has now been " .. (is_unshaded and "unshaded" or "shaded"))

    return true
end

local function on_set_tiling_chat_command()
    if not gCurrentItem or gCurrentItem.model ~= E_MODEL_MCE_BLOCK then
        djui_chat_message_create("You need to be holding a block to toggle its tiling")
        return true
    end

    mce_block_toggle_flag(gCurrentItem, MCE_BLOCK_FLAG_UNTILED)
    local is_untiled = mce_block_check_flag(gCurrentItem, MCE_BLOCK_FLAG_UNTILED)
    djui_chat_message_create("The current block has now been " .. (is_untiled and "untiled" or "tiled"))

    return true
end

local shapes = {
    ["cube"] = Shapes.SHAPE_CUBE,
    ["pyramid"] = Shapes.SHAPE_PYRAMID,
    ["cylinder"] = Shapes.SHAPE_CYLINDER,
    ["sphere"] = Shapes.SHAPE_SPHERE,
    ["stair"] = Shapes.SHAPE_STAIR,
    ["slope"] = Shapes.SHAPE_SLOPE,
}

local function on_set_shape_chat_command(msg)
    if not gCurrentItem or gCurrentItem.model ~= E_MODEL_MCE_BLOCK then
        djui_chat_message_create("You need to be holding a block to change its shape")
        return true
    end

    local shape = shapes[msg]
    if not shape then
        djui_chat_message_create("Could not get valid shape: " .. msg)
        return true
    end

    mce_block_set_shape(gCurrentItem, shape)
    return true
end

hook_chat_command("surface", "! BLOCK ONLY ! Sets the surface type of a block. Refer to the Surface Types tab for which exist and what they do", on_set_surface_chat_command)
hook_chat_command("surf", "! SAME AS /surface !", on_set_surface_chat_command)
hook_chat_command("transparent", "[<opacity>] | Makes the current selected block transparent", on_transparent_chat_command)
hook_chat_command("replace", "[hotbar index] | Replaces the placed blocks with the same held model, with the block model of the supplied hotbar index.", on_replace_chat_command)
hook_chat_command("color", "[<r> <g> <b>] | Sets the color of the currently selected block", on_set_color_chat_command)
hook_chat_command("shade", "| Toggle shading on the currently selected block", on_set_shade_chat_command)
hook_chat_command("tile", "| Toggle tiling on the currently selected block", on_set_tiling_chat_command)
hook_chat_command("shape", "[cube|pyramid|cylinder|sphere] | Sets the shape of the block", on_set_shape_chat_command)