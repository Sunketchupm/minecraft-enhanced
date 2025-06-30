gItemListsLoaded = {}
gBlockListsLoaded = {}
gHookedResetItemFunctions = {}

_G.MinecraftEnhanced = {
    ---@param item_list {icon: TextureInfo, behavior: BehaviorId, model: ModelExtendedId, params: ItemParameters}
    add_item_list = function (item_list)
        -- Take in a list of items and put them onto a custom item tab
    end,

    ---@param model ModelExtendedId
    ---@param icons TextureInfo[]
    add_block_textures = function (model, icons)
        -- Take in a custom model with anim states and the icons to correspond to those models
    end,

    get_menu_open = function ()
        return gMenuOpen
    end,

    hook_on_reset_items = function (func)
        table.insert(gHookedResetItemFunctions, func)
    end
}