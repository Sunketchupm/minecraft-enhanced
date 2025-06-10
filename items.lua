---@class Item
    ---@field behavior BehaviorId
    ---@field model ModelExtendedId
    ---@field spawnYOffset number
    ---@field mock table
    ---@field behaviorParams integer
    ---@field misc table

gCurrentItem = {behavior = nil, model = E_MODEL_NONE, params = {}}
local item_behaviors = {}
add_first_update(function ()
    ---@type Item
    gCurrentItem = { behavior = bhvMceBlock, model = E_MODEL_MCE_BLOCK, spawnYOffset = 0, mock = {}, behaviorParams = 0, misc = {} }
    ---@type BehaviorId[]
    item_behaviors = {
        bhvMceBlock,
        bhvMceStar,
        bhvMceCoin,
        bhvMceExclamationBox
    }
end)

------------------------------------------------------------------------------------------

--- Called from bhvMceBlock.bhv

---@param obj Object
function bhv_mce_block_init(obj)
    obj.collisionData = COL_MCE_BLOCK_DEFAULT
end

--[[ -- Unused for now
---@param obj Object
function bhv_mce_block_loop(obj)
    
end
]]

--- Called from mce_box.geo

function lua_asm_set_color(node, _misc)
    local graphNode = cast_graph_node(node.next)
    local dl = graphNode.displayList

    local obj = geo_get_current_object()
    local color = obj.oBehParams
    local r = (obj.oBehParams & 0x00FF0000) >> 16
    local g = (obj.oBehParams & 0x0000FF00) >> 8
    local b = (obj.oBehParams & 0x000000FF) >> 0
    if color then
        gfx_parse(dl, function(cmd, op)
            if op == G_SETPRIMCOLOR then
                gfx_set_command(cmd, "gsDPSetPrimColor(0, 0, %i, %i, %i, %i)", r, g, b, 255)
            end
        end)
    end
end


---------------------------------------------

local star_hitbox = {
    interactType = INTERACT_STAR_OR_KEY,
    downOffset = 0,
    damageOrCoinValue = 0,
    health = 0,
    numLootCoins = 0,
    radius = 80,
    height = 50,
    hurtboxRadius = 0,
    hurtboxHeight = 0,
}

--- Called from bhvMceStar.bhv

---@param obj Object
function bhv_mce_star_init(obj)
    obj_set_hitbox(obj, star_hitbox)
end

---@param obj Object
function bhv_mce_star_loop(obj)
    if obj.oAction == 0 then
        if obj.oInteractStatus & INT_STATUS_INTERACTED ~= 0 then
            obj.oAction = 1
        end
    else
        cur_obj_disable_rendering_and_become_intangible(obj)
        if obj.oTimer > 300 then
            obj.oAction = 0
            cur_obj_enable_rendering_and_become_tangible(obj)
        end
    end
    obj.oInteractStatus = 0
end

---------------------------------------------

local coin_hitbox = {
    interactType = INTERACT_COIN,
    downOffset = 0,
    damageOrCoinValue = 1,
    health = 0,
    numLootCoins = 0,
    radius = 100,
    height = 64,
    hurtboxRadius = 0,
    hurtboxHeight = 0,
}

--- Called from bhvMceCoin.bhv

---@param obj Object
function bhv_mce_coin_init(obj)
    obj_set_hitbox(obj, coin_hitbox)
    local model = obj_get_model_id_extended(obj)
    if model == E_MODEL_YELLOW_COIN then
        obj.oNumLootCoins = 1
    elseif model == E_MODEL_RED_COIN then
        obj.oNumLootCoins = 2
    elseif model == E_MODEL_BLUE_COIN then
        obj.oNumLootCoins = 5
        obj_scale(obj, 1.25)
    end
end

---@param obj Object
function bhv_mce_coin_loop(obj)
    if obj.oAction == 0 then
        if obj.oInteractStatus & INT_STATUS_INTERACTED ~= 0 then
            spawn_non_sync_object(id_bhvGoldenCoinSparkles, E_MODEL_SPARKLES, obj.oPosX, obj.oPosY, obj.oPosZ, nil)
            obj.oAction = 1
        end
    else
        cur_obj_disable_rendering_and_become_intangible(obj)
        if obj.oTimer > 300 then
            obj.oAction = 0
            cur_obj_enable_rendering_and_become_tangible(obj)
        end
    end

    obj.oInteractStatus = 0
end

---------------------------------------------

local exclamation_box_hitbox = {
    interactType = INTERACT_BREAKABLE,
    downOffset = 5,
    damageOrCoinValue = 0,
    health = 1,
    numLootCoins = 0,
    radius = 40,
    height = 30,
    hurtboxRadius = 40,
    hurtboxHeight = 30,
}

local contents = {
    [1] = {behavior = id_bhvWingCap, model = E_MODEL_MARIOS_WING_CAP},
    [2] = {behavior = id_bhvMetalCap, model = E_MODEL_MARIOS_METAL_CAP},
    [3] = {behavior = id_bhvVanishCap, model = E_MODEL_MARIOS_CAP},
    [4] = {behavior = id_bhvKoopaShell, model = E_MODEL_KOOPA_SHELL}
}

--- Called from bhvMceExclamationBox.bhv

--[[ -- Unused for now
---@param obj Object
function bhv_mce_exclamation_box_init(obj)
    
end
]]


---@param obj Object
function bhv_mce_exclamation_box_loop(obj)
    obj_scale(obj, 2)
    if obj.oAction == 0 then
        obj_set_hitbox(obj, exclamation_box_hitbox)
        if obj.oTimer == 1 then
            cur_obj_unhide()
            cur_obj_become_tangible()
            obj.oInteractStatus = 0
            obj.oPosY = obj.oHomeY
            obj.oGraphYOffset = 0
            local index = obj.oBehParams & 0xFF
            if index < 1 or index > 4 then
                index = 4
            end
            obj.oAnimState = index - 1
        end

        if cur_obj_was_attacked_or_ground_pounded() ~= 0 then
            cur_obj_become_intangible()
            obj.oExclamationBoxUnkFC = 0x4000
            obj.oVelY = 30.0
            obj.oGravity = -8.0
            obj.oFloorHeight = obj.oPosY
            obj.oAction = 1
        end
        load_object_collision_model()
        obj.oInteractStatus = 0
    elseif obj.oAction == 1 then
        cur_obj_move_using_fvel_and_gravity()
        if obj.oVelY < 0.0 then
            obj.oVelY = 0.0
            obj.oGravity = 0.0
        end
        obj.oExclamationBoxUnkF8 = (sins(obj.oExclamationBoxUnkFC) + 1.0) * 0.3 + 0.0
        obj.oExclamationBoxUnkF4 = (-sins(obj.oExclamationBoxUnkFC) + 1.0) * 0.5 + 1.0
        obj.oGraphYOffset = (-sins(obj.oExclamationBoxUnkFC) + 1.0) * 26.0
        obj.oExclamationBoxUnkFC = obj.oExclamationBoxUnkFC + 0x1000
        obj.header.gfx.scale.x = obj.oExclamationBoxUnkF4 * 2.0
        obj.header.gfx.scale.y = obj.oExclamationBoxUnkF8 * 2.0
        obj.header.gfx.scale.z = obj.oExclamationBoxUnkF4 * 2.0
        if obj.oTimer == 7 then
            obj.oAction = 2
        end
    elseif obj.oAction == 2 then
        local index = obj.oBehParams & 0xFF
        local content = contents[index]
        if content then
            local behavior_id = content.behavior
            local model = content.model
            local spawned = spawn_non_sync_object(behavior_id, model, obj.oPosX, obj.oPosY, obj.oPosZ, nil)
            if spawned then
                spawned.oVelY = 20.0
                spawned.oForwardVel = 3.0
                spawned.oMoveAngleYaw = gMarioStates[0].marioObj.oMoveAngleYaw
                spawned.globalPlayerIndex = gMarioStates[0].marioObj.globalPlayerIndex
            end
        end
        spawn_mist_particles_variable(0, 0, 46.0)
        spawn_triangle_break_particles(20, 139, 0.3, obj.oAnimState)
        create_sound_spawner(SOUND_GENERAL_BREAK_BOX)
        obj.oAction = 3
        cur_obj_hide()
    elseif obj.oAction == 3 then
        if obj.oTimer > 300 then
            obj.oAction = 0
        end
    end
end

------------------------------------------------------------------------------------------

---@param obj Object
---@return Object? item
function obj_get_any_nearest_item(obj)
    local nearest_item = nil
    local nearest_dist = 0xFFFF
    for _, item_behavior in ipairs(item_behaviors) do
        local item = obj_get_nearest_object_with_behavior_id(obj, item_behavior)
        if item then
            local dist = dist_between_objects(item, obj)
            if dist < nearest_dist then
                nearest_item = item
                nearest_dist = dist
            end
        end
    end
    return nearest_item
end

local function on_object_count_chat_commmand()
    local count = 0
    for i = OBJ_LIST_PLAYER, NUM_OBJ_LISTS - 1, 1 do
        local obj = obj_get_first(i)
        while obj do
            count = count + 1
            obj = obj_get_next(obj)
        end
    end
    djui_chat_message_create("Total objects: " .. count .. "/" .. OBJECT_POOL_CAPACITY)
    return true
end

hook_chat_command("objects", "Counts the amount of objects in the current area", on_object_count_chat_commmand)