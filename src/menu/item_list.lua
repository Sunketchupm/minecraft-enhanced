local BlockTextures = require("../block/textures") ---@diagnostic disable-line: different-requires

local Items = {}

---@return MenuItemLink
local __get_default_item_link = function ()
    ---@type MenuItemLink
    local link = { item = get_default_item(), icon = { texture = nil, color = WHITE }, held = true }
    return link
end

---@param tex_info TextureInfo
---@return MenuItemLink
local function add_block(tex_info)
    local link = __get_default_item_link()
    link.icon.texture = tex_info
    return link
end

---@param color DjuiColor
---@return MenuItemLink
local function add_color_block(color)
    local link = __get_default_item_link()
    link.icon.color = color
    link.icon.color.a = 255
    link.item.params.color = color
    return link
end

---@param texture TextureInfo
---@param color DjuiColor
---@param behavior BehaviorId
---@param model ModelExtendedId
---@param preview ItemPreview?
---@param params ItemParameters?
---@return MenuItemLink
local function add_behavior_with_params(texture, color, behavior, model, preview, params)
    ---@type Item
    local item = get_default_item()
    item.behavior = behavior
    item.model = model

    if preview then
        for key, value in pairs(preview) do
            item.preview[key] = value
        end
    end

    if params then
        for key, value in pairs(params) do
            item.params[key] = value
        end
    end

    ---@type MenuItemLink
    local link = { item = item, icon = { texture = texture, color = color }, held = false }
    return link
end

Items.fill_item_lists = function()

Items.block_textured_link = {}
for _, texture in ipairs(BlockTextures) do
    table.insert(Items.block_textured_link, add_block(texture))
end

Items.block_colored_link = {
    add_color_block({r = 0, g = 0, b = 0, a = 255}),
    add_color_block({r = 10, g = 10, b = 10, a = 255}),
    add_color_block({r = 20, g = 20, b = 20, a = 255}),
    add_color_block({r = 29, g = 29, b = 29, a = 255}),
    add_color_block({r = 39, g = 39, b = 39, a = 255}),
    add_color_block({r = 49, g = 49, b = 49, a = 255}),
    add_color_block({r = 59, g = 59, b = 59, a = 255}),
    add_color_block({r = 69, g = 69, b = 69, a = 255}),
    add_color_block({r = 78, g = 78, b = 78, a = 255}),
    add_color_block({r = 88, g = 88, b = 88, a = 255}),
    add_color_block({r = 98, g = 98, b = 98, a = 255}),
    add_color_block({r = 108, g = 108, b = 108, a = 255}),
    add_color_block({r = 117, g = 117, b = 117, a = 255}),
    add_color_block({r = 128, g = 128, b = 128, a = 255}),
    add_color_block({r = 137, g = 137, b = 137, a = 255}),
    add_color_block({r = 147, g = 147, b = 147, a = 255}),
    add_color_block({r = 157, g = 157, b = 157, a = 255}),
    add_color_block({r = 167, g = 167, b = 167, a = 255}),
    add_color_block({r = 177, g = 177, b = 177, a = 255}),
    add_color_block({r = 186, g = 186, b = 186, a = 255}),
    add_color_block({r = 196, g = 196, b = 196, a = 255}),
    add_color_block({r = 206, g = 206, b = 206, a = 255}),
    add_color_block({r = 216, g = 216, b = 216, a = 255}),
    add_color_block({r = 226, g = 226, b = 226, a = 255}),
    add_color_block({r = 235, g = 235, b = 235, a = 255}),
    add_color_block({r = 245, g = 245, b = 245, a = 255}),
    add_color_block({r = 255, g = 255, b = 255, a = 255}),
    add_color_block({r = 51, g = 0, b = 0, a = 255}),
    add_color_block({r = 102, g = 0, b = 0, a = 255}),
    add_color_block({r = 153, g = 0, b = 0, a = 255}),
    add_color_block({r = 204, g = 0, b = 0, a = 255}),
    add_color_block({r = 255, g = 0, b = 0, a = 255}),
    add_color_block({r = 255, g = 51, b = 51, a = 255}),
    add_color_block({r = 255, g = 102, b = 102, a = 255}),
    add_color_block({r = 255, g = 153, b = 153, a = 255}),
    add_color_block({r = 255, g = 204, b = 204, a = 255}),
    add_color_block({r = 51, g = 25, b = 0, a = 255}),
    add_color_block({r = 102, g = 51, b = 0, a = 255}),
    add_color_block({r = 153, g = 76, b = 0, a = 255}),
    add_color_block({r = 206, g = 103, b = 0, a = 255}),
    add_color_block({r = 255, g = 128, b = 0, a = 255}),
    add_color_block({r = 255, g = 153, b = 51, a = 255}),
    add_color_block({r = 255, g = 178, b = 102, a = 255}),
    add_color_block({r = 255, g = 204, b = 153, a = 255}),
    add_color_block({r = 255, g = 229, b = 204, a = 255}),
    add_color_block({r = 51, g = 40, b = 0, a = 255}),
    add_color_block({r = 102, g = 81, b = 0, a = 255}),
    add_color_block({r = 153, g = 122, b = 0, a = 255}),
    add_color_block({r = 204, g = 163, b = 0, a = 255}),
    add_color_block({r = 255, g = 212, b = 0, a = 255}),
    add_color_block({r = 255, g = 214, b = 51, a = 255}),
    add_color_block({r = 255, g = 224, b = 102, a = 255}),
    add_color_block({r = 255, g = 234, b = 153, a = 255}),
    add_color_block({r = 255, g = 244, b = 204, a = 255}),
    add_color_block({r = 0, g = 38, b = 0, a = 255}),
    add_color_block({r = 0, g = 76, b = 0, a = 255}),
    add_color_block({r = 0, g = 114, b = 0, a = 255}),
    add_color_block({r = 0, g = 153, b = 0, a = 255}),
    add_color_block({r = 0, g = 192, b = 0, a = 255}),
    add_color_block({r = 40, g = 204, b = 40, a = 255}),
    add_color_block({r = 86, g = 216, b = 86, a = 255}),
    add_color_block({r = 137, g = 229, b = 137, a = 255}),
    add_color_block({r = 193, g = 242, b = 193, a = 255}),
    add_color_block({r = 0, g = 13, b = 51, a = 255}),
    add_color_block({r = 0, g = 27, b = 102, a = 255}),
    add_color_block({r = 0, g = 40, b = 153, a = 255}),
    add_color_block({r = 0, g = 54, b = 204, a = 255}),
    add_color_block({r = 0, g = 64, b = 255, a = 255}),
    add_color_block({r = 50, g = 105, b = 255, a = 255}),
    add_color_block({r = 102, g = 142, b = 255, a = 255}),
    add_color_block({r = 153, g = 180, b = 255, a = 255}),
    add_color_block({r = 204, g = 217, b = 255, a = 255}),
    add_color_block({r = 18, g = 0, b = 51, a = 255}),
    add_color_block({r = 37, g = 0, b = 102, a = 255}),
    add_color_block({r = 56, g = 0, b = 153, a = 255}),
    add_color_block({r = 74, g = 0, b = 204, a = 255}),
    add_color_block({r = 96, g = 0, b = 255, a = 255}),
    add_color_block({r = 125, g = 50, b = 255, a = 255}),
    add_color_block({r = 158, g = 102, b = 255, a = 255}),
    add_color_block({r = 190, g = 153, b = 255, a = 255}),
    add_color_block({r = 222, g = 204, b = 255, a = 255}),
    add_color_block({r = 25, g = 9, b = 0, a = 255}),
    add_color_block({r = 51, g = 19, b = 0, a = 255}),
    add_color_block({r = 76, g = 29, b = 0, a = 255}),
    add_color_block({r = 102, g = 39, b = 0, a = 255}),
    add_color_block({r = 127, g = 48, b = 0, a = 255}),
    add_color_block({r = 153, g = 75, b = 30, a = 255}),
    add_color_block({r = 178, g = 110, b = 71, a = 255}),
    add_color_block({r = 204, g = 152, b = 122, a = 255}),
    add_color_block({r = 229, g = 200, b = 183, a = 255}),
    add_color_block({r = 0, g = 0, b = 25, a = 255}),
    add_color_block({r = 0, g = 0, b = 53, a = 255}),
    add_color_block({r = 0, g = 0, b = 79, a = 255}),
    add_color_block({r = 0, g = 0, b = 107, a = 255}),
    add_color_block({r = 0, g = 0, b = 135, a = 255}),
    add_color_block({r = 31, g = 31, b = 158, a = 255}),
    add_color_block({r = 72, g = 72, b = 181, a = 255}),
    add_color_block({r = 122, g = 122, b = 204, a = 255}),
    add_color_block({r = 179, g = 179, b = 224, a = 255}),
    add_color_block({r = 4, g = 51, b = 32, a = 255}),
    add_color_block({r = 9, g = 102, b = 64, a = 255}),
    add_color_block({r = 13, g = 153, b = 97, a = 255}),
    add_color_block({r = 18, g = 204, b = 129, a = 255}),
    add_color_block({r = 21, g = 255, b = 165, a = 255}),
    add_color_block({r = 68, g = 255, b = 180, a = 255}),
    add_color_block({r = 114, g = 255, b = 198, a = 255}),
    add_color_block({r = 168, g = 255, b = 220, a = 255}),
    add_color_block({r = 209, g = 255, b = 236, a = 255}),
}

---@param param integer
---@return ItemParameters
local __set_item_params = function (param)
    return {
        yOffset = 0,
        color = { r = 255, g = 255, b = 255, a = 255 },
        params = param,
        flags = 0,
    }
end

Items.level_objects_link = {
    add_behavior_with_params(SLOT_STAR_TEX, WHITE, bhvMceStar, E_MODEL_STAR,
        { animate = { faceAngleYaw = 0x800 } }
    ),
    add_behavior_with_params(SLOT_STAR_TEX, BLACK, bhvMceStar, E_MODEL_TRANSPARENT_STAR,
        { animate = { faceAngleYaw = 0x800 } }
    ),
    add_behavior_with_params(SLOT_COIN_TEX, YELLOW, bhvMceCoin, E_MODEL_YELLOW_COIN,
        { animate = { animState = 1 }, billboard = true },
        __set_item_params(1)
    ),
    add_behavior_with_params(SLOT_COIN_TEX, RED, bhvMceCoin, E_MODEL_RED_COIN,
        { animate = { animState = 1 }, billboard = true },
        __set_item_params(2)
    ),
    add_behavior_with_params(SLOT_COIN_TEX, BLUE, bhvMceCoin, E_MODEL_BLUE_COIN,
        { animate = { animState = 1 }, billboard = true },
        __set_item_params(5)
    ),
    add_behavior_with_params(SLOT_EXCLAMATION_BOX_WING, WHITE, bhvMceExclamationBox, E_MODEL_EXCLAMATION_BOX,
        { scale = 2 },
        __set_item_params(1)
    ),
    add_behavior_with_params(SLOT_EXCLAMATION_BOX_METAL, WHITE, bhvMceExclamationBox, E_MODEL_EXCLAMATION_BOX,
        { scale = 2 },
        __set_item_params(2)
    ),
    add_behavior_with_params(SLOT_EXCLAMATION_BOX_VANISH, WHITE, bhvMceExclamationBox, E_MODEL_EXCLAMATION_BOX,
        { scale = 2 },
        __set_item_params(3)
    ),
    add_behavior_with_params(SLOT_EXCLAMATION_BOX_NORMAL, WHITE, bhvMceExclamationBox, E_MODEL_EXCLAMATION_BOX,
        { scale = 2 },
        __set_item_params(4)
    ),
    add_behavior_with_params(SLOT_EXCLAMATION_BOX_NORMAL, WHITE, bhvMceExclamationBox, E_MODEL_EXCLAMATION_BOX,
        { scale = 2 },
        __set_item_params(99)
    ),
    add_behavior_with_params(SLOT_BUBBLY_TREE, WHITE, bhvMceTree, E_MODEL_BUBBLY_TREE,
        { billboard = true }
    ),
    add_behavior_with_params(SLOT_SPIKEY_TREE, WHITE, bhvMceTree, E_MODEL_COURTYARD_SPIKY_TREE,
        { billboard = true }
    ),
    add_behavior_with_params(SLOT_SNOWY_TREE, WHITE, bhvMceTree, E_MODEL_SNOW_TREE,
        { billboard = true }
    ),
    add_behavior_with_params(SLOT_PALM_TREE, WHITE, bhvMceTree, E_MODEL_PALM_TREE,
        { billboard = true }
    ),
    add_behavior_with_params(SLOT_CASTLE_DOOR, WHITE, bhvMceDoor, E_MODEL_CASTLE_DOOR_0_STARS),
    add_behavior_with_params(SLOT_WOODEN_DOOR, WHITE, bhvMceDoor, E_MODEL_HMC_WOODEN_DOOR),
    add_behavior_with_params(SLOT_METAL_DOOR, WHITE, bhvMceDoor, E_MODEL_HMC_METAL_DOOR),
    add_behavior_with_params(SLOT_MURAL_DOOR, WHITE, bhvMceDoor, E_MODEL_HMC_HAZY_MAZE_DOOR),
    add_behavior_with_params(SLOT_BBH_DOOR, WHITE, bhvMceDoor, E_MODEL_BBH_HAUNTED_DOOR),
    add_behavior_with_params(SLOT_RED_FLAME_TEX, WHITE, bhvMceFlame, E_MODEL_RED_FLAME,
        { scale = 7.5, billboard = true, animate = { animState = 2 } }
    ),
    add_behavior_with_params(SLOT_BLUE_FLAME_TEX, WHITE, bhvMceFlame, E_MODEL_BLUE_FLAME,
        { scale = 7.5, billboard = true, animate = { animState = 2 } }
    ),
    add_behavior_with_params(SLOT_1UP_TEX, WHITE, bhvMce1Up, E_MODEL_1UP,
        { billboard = true }
    ),
}

Items.enemies_link = {
    add_behavior_with_params(SLOT_GOOMBA_TEX, WHITE, id_bhvGoomba, E_MODEL_GOOMBA,
        { animate = { animation = gObjectAnimations.goomba_seg8_anims_0801DA4C, animIndex = 0 } }
    ),
    add_behavior_with_params(SLOT_BOBOMB_TEX, WHITE, id_bhvBobomb, E_MODEL_BLACK_BOBOMB,
        { animate = { animation = gObjectAnimations.bobomb_seg8_anims_0802396C, animIndex = 0 } }
    ),
    add_behavior_with_params(SLOT_CHUCKYA_TEX, WHITE, id_bhvChuckya, E_MODEL_CHUCKYA,
        { animate = { animation = gObjectAnimations.chuckya_seg8_anims_0800C070, animIndex = 4 } }
    ),
    add_behavior_with_params(SLOT_AMP_TEX, WHITE, id_bhvCirclingAmp, E_MODEL_AMP,
        { animate = { animation = gObjectAnimations.amp_seg8_anims_08004034, animIndex = 2 } }
    ),
    add_behavior_with_params(SLOT_MADPIANO_TEX, WHITE, id_bhvMadPiano, E_MODEL_MAD_PIANO,
        { animate = { animation = gObjectAnimations.mad_piano_seg5_anims_05009B14, animIndex = 0 } }
    ),
    add_behavior_with_params(SLOT_BULLY_TEX, WHITE, id_bhvSmallBully, E_MODEL_BULLY,
        { animate = { animation = gObjectAnimations.bully_seg5_anims_0500470C, animIndex = 0 } }
    ),
    add_behavior_with_params(SLOT_CHILLBULLY_TEX, WHITE, id_bhvSmallBully, E_MODEL_CHILL_BULLY,
        { animate = { animation = gObjectAnimations.chilly_chief_seg6_anims_06003994, animIndex = 0 } }
    ),
    add_behavior_with_params(SLOT_KOOPA_TEX, WHITE, id_bhvKoopa, E_MODEL_KOOPA_WITH_SHELL,
        { animate = { animation = gObjectAnimations.koopa_seg6_anims_06011364, animIndex = 1 } }
    ),
    add_behavior_with_params(SLOT_HEAVEHO_TEX, WHITE, id_bhvHeaveHo, E_MODEL_HEAVE_HO,
        { animate = { animation = gObjectAnimations.heave_ho_seg5_anims_0501534C, animIndex = 0 } }
    ),
    add_behavior_with_params(SLOT_SMALLWHOMP_TEX, WHITE, id_bhvSmallWhomp, E_MODEL_WHOMP,
        { animate = { animation = gObjectAnimations.whomp_seg6_anims_06020A04, animIndex = 0 } }
    ),
    add_behavior_with_params(SLOT_THWOMP_TEX, WHITE, id_bhvThwomp, E_MODEL_THWOMP),
    add_behavior_with_params(SLOT_SPINDRIFT_TEX, WHITE, id_bhvSpindrift, E_MODEL_SPINDRIFT,
        { animate = { animation = gObjectAnimations.spindrift_seg5_anims_05002D68, animIndex = 0 } }
    ),
    add_behavior_with_params(SLOT_FLYGUY_TEX, WHITE, id_bhvFlyGuy, E_MODEL_FLYGUY,
        { animate = { animation = gObjectAnimations.flyguy_seg8_anims_08011A64, animIndex = 0 } }
    ),
    add_behavior_with_params(SLOT_SCUTTLEBUG_TEX, WHITE, id_bhvScuttlebug, E_MODEL_SCUTTLEBUG,
        { animate = { animation = gObjectAnimations.scuttlebug_seg6_anims_06015064, animIndex = 0 } }
    ),
    add_behavior_with_params(SLOT_SWOOP_TEX, WHITE, id_bhvSwoop, E_MODEL_SWOOP,
        { animate = { animation = gObjectAnimations.swoop_seg6_anims_060070D0, animIndex = 0 } }
    ),
    add_behavior_with_params(SLOT_SNUFIT_TEX, WHITE, id_bhvSnufit, E_MODEL_SNUFIT),
    add_behavior_with_params(SLOT_MRBLIZZARD_TEX, WHITE, id_bhvMrBlizzard, E_MODEL_MR_BLIZZARD,
        { animate = { animation = gObjectAnimations.snowman_seg5_anims_0500D118, animIndex = 0 } }
    ),
    add_behavior_with_params(SLOT_BULLETBILL_TEX, WHITE, id_bhvBulletBill, E_MODEL_BULLET_BILL),
    -- Chain chomp
    -- Lakitu
    --add_behavior_with_params(SLOT_BOO_TEX, WHITE, id_bhvBoo, E_MODEL_BOO, {}),
    --add_behavior_with_params(SLOT_POKEY_TEX, WHITE, id_bhvPokey, E_MODEL_POKEY_HEAD, {}),
    --add_behavior_with_params(SLOT_SPINY_TEX, WHITE, id_bhvSpiny, E_MODEL_SPINY, { preview = { animate = { animation = gObjectAnimations.spiny_seg5_anims_05016EAC, animIndex = 0 } } }),
}

end

------------------------------------------------------------

---@param icon TextureInfo
Items.rescale_icon = function(icon)
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

---@param rect Rectangle
---@param icon Icon
Items.render = function(rect, icon)
    local x, y, width, height = from_rect(rect)
    if icon.texture then
        local texture = icon.texture --[[@as TextureInfo]]
        local texture_width = texture.width
        local texture_height = texture.height
        local texture_scale = 1.5
        local item_scale_x, item_scale_y = Items.rescale_icon(texture)
        item_scale_x = item_scale_x * texture_scale
        item_scale_y = item_scale_y * texture_scale
        local item_x = (x + width * 0.5) - (texture_width * 0.5 * item_scale_x)
        local item_y = (y + height * 0.5) - (texture_height * 0.5 * item_scale_y)

        local color = icon.color
        djui_hud_set_color(color.r, color.g, color.b, color.a)
        djui_hud_render_texture(texture, item_x, item_y, item_scale_x, item_scale_y)
    else
        local rect_width = 48
        local rect_height = 48
        local rect_x = (x + width * 0.5) - 24
        local rect_y = (y + height * 0.5) - 24

        local color = icon.color
        djui_hud_set_color(color.r, color.g, color.b, color.a)
        djui_hud_render_rect(rect_x, rect_y, rect_width, rect_height)
    end
end

return Items