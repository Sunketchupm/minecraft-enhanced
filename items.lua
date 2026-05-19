
require("src/block/builder")
local Hotbar = require("src/menu/hotbar")
local BlockTextures = require("src/block/textures")
local Shapes = require("src/block/shapes")

---@class (exact) Item
    ---@field behavior BehaviorId
    ---@field model ModelExtendedId
    ---@field animState integer
    ---@field dimensions ItemDimensions
    ---@field preview ItemPreview
    ---@field params ItemParameters

---@class (exact) ItemDimensions
    ---@field size Vec3f
    ---@field rotation Vec3s x = pitch, y = yaw, z = roll
    ---@field grid Vec3f

---@class (exact) ItemParameters
    ---@field yOffset number
    ---@field color DjuiColor
    ---@field params integer
    ---@field flags integer

---@class (exact) ItemPreview
    ---@field billboard boolean?
    ---@field scale number?
    ---@field animate PreviewAnimations?

---@class (exact) PreviewAnimations
    ---@field animation Pointer_ObjectAnimPointer?
    ---@field animIndex integer?
    ---@field animState integer?
    ---@field faceAngleYaw integer?

---@class (exact) Object
    ---@field oScaleX number
    ---@field oScaleY number
    ---@field oScaleZ number
    ---@field oOwner number
    ---@field oItemParams integer
    ---@field oItemFlags integer
    ---@field oColor integer
    ---@field _pointer integer

define_custom_obj_fields({
    oScaleX = "f32",
    oScaleY = "f32",
    oScaleZ = "f32",
    oOwner = "u32",
    oItemParams = "u32",
    oItemFlags = "u32",
    oColor = "u32"
})

---@return Item
function get_default_item()
    ---@type Item
    local item = {
        behavior = bhvMceBlock,
        model = E_MODEL_MCE_BLOCK,
        animState = 0,
        dimensions = {
            size = gVec3fOne(),
            rotation = gVec3sZero(),
            grid = gVec3fOne(),
        },
        preview = {
            billboard = false,
            scale = 1,
            animate = {}
        },
        params = {
            yOffset = 0,
            color = { r = 255, g = 255, b = 255, a = 255 },
            params = 0,
            flags = 0,
        },
    }
    return item
end

---@type Item?
gCurrentItem = nil
gItemBhvIds = {}

local sEnemyItemBehaviors = {}
local sVanillaClearImmune = {}
add_first_update(function ()
    ---@type Item
    gCurrentItem = get_default_item()
    ---@type BehaviorId[]
    gItemBhvIds = {
        bhvMceBlock,
        bhvMceStar,
        bhvMceCoin,
        bhvMceExclamationBox,
        bhvMceTree,
        bhvMceDoor,
        bhvMceFlame,
        bhvMce1Up,
    }
    ---@type BehaviorId[]
    sEnemyItemBehaviors = {
        id_bhvGoomba,
        id_bhvBobomb,
        id_bhvChuckya,
        id_bhvCirclingAmp,
        id_bhvMadPiano,
        id_bhvSmallBully,
        id_bhvKoopa,
        --id_bhvSpiny,
        id_bhvHeaveHo,
        id_bhvSmallWhomp,
        id_bhvThwomp,
        id_bhvSpindrift,
        id_bhvFlyGuy,
        --id_bhvBoo,
        --id_bhvPokey,
        id_bhvScuttlebug,
        id_bhvSwoop,
        id_bhvSnufit,
        id_bhvMrBlizzard,
        id_bhvBulletBill,
    }
    ---@type BehaviorId[]
    sVanillaClearImmune = {
        [id_bhvMario] = true,
        [id_bhvInstantActiveWarp] = true,
        [id_bhvAirborneWarp] = true,
        [id_bhvHardAirKnockBackWarp] = true,
        [id_bhvSpinAirborneCircleWarp] = true,
        [id_bhvDeathWarp] = true,
        [id_bhvSpinAirborneWarp] = true,
        [id_bhvFlyingWarp] = true,
        [id_bhvPaintingStarCollectWarp] = true,
        [id_bhvPaintingDeathWarp] = true,
        [id_bhvAirborneDeathWarp] = true,
        [id_bhvAirborneStarCollectWarp] = true,
        [id_bhvLaunchStarCollectWarp] = true,
        [id_bhvLaunchDeathWarp] = true,
        [id_bhvSwimmingWarp] = true,
        [id_bhvDoor] = true,
        [id_bhvStarDoor] = true,
        [id_bhvWarp] = true,
        [id_bhvWarpPipe] = true,
        [id_bhvDoorWarp] = true,
        [id_bhvFadingWarp] = true,
    }
end)

------------------------------------------------------------------------------------------

---@param obj Object
---@param hitbox ObjectHitbox
local function obj_set_hitbox(obj, hitbox)
    if not obj or not hitbox then return end
    if obj.oFlags & OBJ_FLAG_30 == 0 then
        obj.oFlags = obj.oFlags | OBJ_FLAG_30

        obj.oInteractType = hitbox.interactType
        obj.oDamageOrCoinValue = hitbox.damageOrCoinValue
        obj.oHealth = hitbox.health
        obj.oNumLootCoins = hitbox.numLootCoins

        cur_obj_become_tangible()
    end

    obj.hitboxRadius = obj.header.gfx.scale.x * hitbox.radius
    obj.hitboxHeight = obj.header.gfx.scale.y * hitbox.height
    obj.hurtboxRadius = obj.header.gfx.scale.x * hitbox.hurtboxRadius
    obj.hurtboxHeight = obj.header.gfx.scale.y * hitbox.hurtboxHeight
    obj.hitboxDownOffset = obj.header.gfx.scale.y * hitbox.downOffset
end

---@param obj Object
---@param scale number
function obj_scale_mult_to(obj, scale)
    obj.header.gfx.scale.x = obj.header.gfx.scale.x * scale
    obj.header.gfx.scale.y = obj.header.gfx.scale.y * scale
    obj.header.gfx.scale.z = obj.header.gfx.scale.z * scale
end

------------------------------------------------------------------------------------------

--[[ Custom properties:
    oAnimState:
        - 1st+2nd byte: texture id
        - 3rd byte: shape id
        - 4th byte: flags:
        - - 1st bit: is colored
        - - 2nd bit: is shaded
        - - 3rd bit: is untiled
        - - 4th bit: has no collision
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

local sIgnoreCollisionLookup = {
    [MCE_BLOCK_COL_ID_NO_COLLISION] = true,
    [MCE_BLOCK_COL_ID_VERTICAL_WIND] = true,
    [MCE_BLOCK_COL_ID_WATER] = true,
    [MCE_BLOCK_COL_ID_TOXIC_GAS] = true,
    [MCE_BLOCK_COL_ID_BOOSTER] = true,
}

---@type table<integer, StaticObjectCollision>
gBlockCollisionLookup = {}

---@param surface_id integer
---@param shape_id integer
---@return Pointer_Collision
local __get_collision = function (surface_id, shape_id)
    return smlua_collision_util_get("mce_block_col_" .. surface_id .. "_" .. shape_id)
            or smlua_collision_util_get("mce_block_col_0_" .. shape_id)
end

---@param obj Object
local function block_collision_lookup(obj)
    local surface_id = mce_block_get_surface_index(obj)
    local shape_id = mce_block_get_shape_index(obj)
    if not sIgnoreCollisionLookup[surface_id] then
        obj.collisionData = __get_collision(surface_id, shape_id)
        if surface_id == MCE_BLOCK_PROPERTY_CONVEYOR then
            obj.collisionData = __get_collision(MCE_BLOCK_COL_ID_HANGABLE, shape_id)
        end
    else
        obj.collisionData = __get_collision(MCE_BLOCK_COL_ID_NO_COLLISION, shape_id)
    end
    -- As shrinking is dynamic, don't put it in the static pool
    if obj.oItemFlags & MCE_BLOCK_PROPERTY_SHRINKING == 0 then
        gBlockCollisionLookup[obj._pointer] = load_static_object_collision()
    end
end

--- Called from bhvMceBlock.bhv

---@param obj Object
function bhv_mce_block_init(obj)
    block_collision_lookup(obj)
    local longest_side = obj.header.gfx.scale.x
    if longest_side < obj.header.gfx.scale.y then
        longest_side = obj.header.gfx.scale.y
    end
    if longest_side < obj.header.gfx.scale.z then
        longest_side = obj.header.gfx.scale.z
    end
    obj.header.gfx.skipInViewCheck = true
    network_init_object(obj, false, {
        "oPosX",
        "oPosY",
        "oPosZ",
        "oScaleX",
        "oScaleY",
        "oScaleZ",
        "oFaceAnglePitch",
        "oMoveAnglePitch",
        "oFaceAngleYaw",
        "oMoveAngleYaw",
        "oFaceAngleRoll",
        "oMoveAngleRoll",
        "activeFlags",
        "oOwner",
        "oOpacity",
        "oAnimState",
        "oItemParams",
        "oItemFlags",
        "oColor"
    })
end

---@param obj Object
function bhv_mce_block_loop(obj)
    obj.parentObj = obj

    if obj.oAction == MCE_BLOCK_ACT_RESET then
        mce_block_enable_collision(obj)
        obj_scale_xyz(obj, obj.oScaleX, obj.oScaleY, obj.oScaleZ)
        obj.oAction = 0
        if obj.oOpacity == 0 then
            obj.oOpacity = 255
        end
    end

    if obj.oAnimState & 0xFFFF == #BlockTextures then
        if gMarioStates[0].action ~= ACT_FREE_MOVE then
            obj.header.gfx.node.flags = obj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
        else
            obj.header.gfx.node.flags = obj.header.gfx.node.flags & ~GRAPH_RENDER_INVISIBLE
        end
    end

    -- Handle breakable surfaces, so that their particles properly spawn
    if obj.oItemFlags & MCE_BLOCK_PROPERTY_BREAKABLE ~= 0 then
        if gHitBreakableBlock == obj then
            obj.oAction = 1
            obj.oTimer = 0
            gHitBreakableBlock = nil
        end

        if obj.oAction == 1 then
            ---@type MarioState
            local m = gMarioStates[0]
            if m.action == ACT_WALL_KICK_AIR then
                obj.oAction = 2
            elseif obj.oTimer > 5 then
                obj.oAction = 0
                obj.oTimer = 0
            end
        elseif obj.oAction == 2 then
            spawn_mist_particles()
            spawn_triangle_break_particles(20, 138, 0.7, 3)
            create_sound_spawner(SOUND_GENERAL_BREAK_BOX)
            obj.oOpacity = 0
            obj.oAction = 3
            mce_block_disable_collision(obj)
        end
    -- Turn the object collision dynamic if it's shrinking
    elseif obj.oItemFlags & MCE_BLOCK_PROPERTY_SHRINKING ~= 0 then
        load_object_collision_model()
    end
end

---@param obj Object
local function on_object_unload(obj)
    if obj_has_behavior_id(obj, bhvMceBlock) ~= 0 then
        mce_block_disable_collision(obj)
        gBlockCollisionLookup[obj._pointer] = nil
    end
end

hook_event(HOOK_ON_OBJECT_UNLOAD, on_object_unload)

------------------------------------------------------------------------------------------

local sStarHitbox = {
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
    obj_set_hitbox(obj, sStarHitbox)
    network_init_object(obj, false, {
        "activeFlags",
        "oOwner",
        "oScaleX",
        "oScaleY",
        "oScaleZ",
        "oPosX",
        "oPosY",
        "oPosZ",
    })
end

---@param obj Object
function bhv_mce_star_loop(obj)
    if obj.oAction == 0 then
        if obj.oInteractStatus & INT_STATUS_INTERACTED ~= 0 then
            obj.oAction = 1
            cur_obj_disable_rendering_and_become_intangible(obj)
        end
    end

    obj.oInteractStatus = 0
end

------------------------------------------------------------------------------------------

local sCoinHitbox = {
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
    obj_set_hitbox(obj, sCoinHitbox)
    local model = obj_get_model_id_extended(obj)
    if model == E_MODEL_YELLOW_COIN then
        obj.oDamageOrCoinValue = 1
    elseif model == E_MODEL_RED_COIN then
        obj.oDamageOrCoinValue = 2
    elseif model == E_MODEL_BLUE_COIN then
        obj.oDamageOrCoinValue = 5
        obj_scale_mult_to(obj, 1.25)
    end

    network_init_object(obj, false, {
        "activeFlags",
        "oOwner",
        "oScaleX",
        "oScaleY",
        "oScaleZ",
        "oPosX",
        "oPosY",
        "oPosZ",
    })
end

---@param obj Object
function bhv_mce_coin_loop(obj)
    if obj.oAction == 0 then
        if obj.oInteractStatus & INT_STATUS_INTERACTED ~= 0 then
            spawn_non_sync_object(id_bhvGoldenCoinSparkles, E_MODEL_SPARKLES, obj.oPosX, obj.oPosY, obj.oPosZ, function () end)
            cur_obj_disable_rendering_and_become_intangible(obj)
            obj.oAction = 1
        end
    end

    obj.oInteractStatus = 0
end

------------------------------------------------------------------------------------------

local sExclamaitonBoxHitbox = {
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

local sExclamationBoxContents = {
    { behavior = id_bhvWingCap, model = E_MODEL_MARIOS_WING_CAP },
    { behavior = id_bhvMetalCap, model = E_MODEL_MARIOS_METAL_CAP },
    { behavior = id_bhvVanishCap, model = E_MODEL_MARIOS_CAP },
    { behavior = id_bhvKoopaShell, model = E_MODEL_KOOPA_SHELL },
}

--- Called from bhvMceExclamationBox.bhv

---@param obj Object
function bhv_mce_exclamation_box_init(obj)
    network_init_object(obj, false, {
        "activeFlags",
        "oOwner",
        "oScaleX",
        "oScaleY",
        "oScaleZ",
        "oPosX",
        "oPosY",
        "oPosZ",
    })
end

---@param obj Object
function bhv_mce_exclamation_box_loop(obj)
    obj_scale(obj, 2)
    if obj.oAction == 0 then
        obj_set_hitbox(obj, sExclamaitonBoxHitbox)
        if obj.oTimer == 1 then
            cur_obj_unhide()
            cur_obj_become_tangible()
            obj.oInteractStatus = 0
            obj.oPosY = obj.oHomeY
            obj.oGraphYOffset = 0
            local index = obj.oItemParams & 0xFF
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
        local index = obj.oItemParams & 0xFF
        local content = sExclamationBoxContents[index]
        if content then
            local behavior_id = content.behavior
            local model = content.model
            local spawned = spawn_non_sync_object(behavior_id, model, obj.oPosX, obj.oPosY, obj.oPosZ, function () end)
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

local function koopa_shell_delete_if_unused()
    local obj = obj_get_first_with_behavior_id(id_bhvKoopaShell)
    while obj do
        if obj.oAction == 0 and obj.oTimer >= 300 then
            obj_mark_for_deletion(obj)
        end
        obj = obj_get_next_with_same_behavior_id(obj)
    end
end

hook_event(HOOK_UPDATE, koopa_shell_delete_if_unused)

---------------------------------------------------------------------------------------------------------------------------------------

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

---@param obj Object
---@param mod_command string?
---@return boolean
local function object_removal_criteria(obj, mod_command)
    local remove_all = false
    local remove_orphaned = false
    if network_is_privileged() and mod_command then
        if mod_command == "ALL" then
            remove_all = true
        elseif mod_command:lower() == "orphaned" then
            remove_orphaned = true
        end
    end
    local owner_index = network_global_index_from_local(0) + 1
    local index = network_local_index_from_global(obj.oOwner - 1)
    --djui_chat_message_create(remove_orphaned, index, is_player_in_local_area(gMarioStates[index]))
    if remove_orphaned then
        return index == -1 or is_player_in_local_area(gMarioStates[index]) == 0
    end
    return obj.oOwner == owner_index or remove_all
end

---@param msg string
function on_clear_chat_command(msg)
    local args = string.split(msg, " ")
    local command = args[1] and args[1]:lower() or ""

    if command == "all" or command == "" then
        for obj in iterate_id_list(gItemBhvIds) do
            if object_removal_criteria(obj, args[2]) then
                obj_mark_for_deletion(obj)
            end
        end
        for obj in iterate_id_list(sEnemyItemBehaviors) do
            if object_removal_criteria(obj, args[2]) then
                obj_mark_for_deletion(obj)
            end
        end
        djui_chat_message_create("Removed all placed objects")
    elseif command == "blocks" then
        for obj in iterate_id_list({bhvMceBlock}) do
            if object_removal_criteria(obj, args[2]) then
                obj_mark_for_deletion(obj)
            end
        end
        djui_chat_message_create("Removed all placed blocks")
    elseif command == "items" then
        for obj in iterate_id_list(gItemBhvIds) do
            if obj_has_behavior_id(obj, bhvMceBlock) == 0 and object_removal_criteria(obj, args[2]) then
                obj_mark_for_deletion(obj)
            end
        end
        djui_chat_message_create("Removed all placed level items")
    elseif command == "enemies" then
        for obj in iterate_id_list(sEnemyItemBehaviors) do
            if object_removal_criteria(obj, args[2]) then
                obj_mark_for_deletion(obj)
            end
        end
        djui_chat_message_create("Removed all placed enemies")
    elseif command == "vanilla" and network_is_privileged() then
        for i = OBJ_LIST_PLAYER + 1, NUM_OBJ_LISTS - 1, 1 do
            local obj = obj_get_first(i)
            while obj do
                local behavior_id = get_id_from_behavior(obj.behavior)
                if not sVanillaClearImmune[behavior_id] or behavior_id > 0x7FFF then
                    obj_mark_for_deletion(obj)
                end
                obj = obj_get_next(obj)
            end
        end
        djui_chat_message_create("Removed all non-mce objects")
    else
        if network_is_privileged() then
            djui_chat_message_create("USAGE: [all|vanilla|blocks|items|enemies] [ALL|orphaned]")
        else
            djui_chat_message_create("USAGE: [all|blocks|items|enemies]")
        end
    end
    return true
end

-- HOOK_UPDATE passes no parameters (so far) and so this param will
-- always be false, so other places where this function gets called can pass a
-- parameter to disable the free move check
---@param override_free_move_check boolean?
function reset_all_items(override_free_move_check)
    local m = gMarioStates[0]
    if m.action == ACT_FREE_MOVE or override_free_move_check then
        for obj in iterate_id_list(gItemBhvIds) do
            if obj_has_behavior_id(obj, bhvMceBlock) == 0 then
                local render_flags = obj.header.gfx.node.flags
                if render_flags & GRAPH_RENDER_INVISIBLE ~= 0 or render_flags & GRAPH_RENDER_ACTIVE == 0 then
                    obj.header.gfx.node.flags = obj.header.gfx.node.flags &~ GRAPH_RENDER_INVISIBLE
                    obj.header.gfx.node.flags = obj.header.gfx.node.flags | GRAPH_RENDER_ACTIVE
                    obj_become_tangible(obj)
                    obj.oAction = 0
                end
            else
                if obj.oAction ~= MCE_BLOCK_ACT_RESET then
                    obj.oAction = MCE_BLOCK_ACT_RESET
                end
            end
        end

        for _, func in ipairs(gHookedResetItemFunctions) do
            if func then
                func()
            end
        end
    end
end

hook_chat_command("objects", "Counts the amount of objects in the current area", on_object_count_chat_commmand)
hook_chat_command("clear", "[all|blocks|items|enemies] | Removes all objects placed by you that fit the specified criteria", on_clear_chat_command)
add_first_update(function ()
    if network_is_privileged() then
        update_chat_command_description("clear", "[all|blocks|items|enemies] | Removes all objects placed by you that fit the specified criteria \
        MODERATORS: [all|vanilla|blocks|items|enemies] [ALL|orphaned] \
        Use 'ALL' to remove EVERY object of that criteria \
        Use 'orphaned' to remove all objects of that criteria with no owner")
    end
end)
hook_event(HOOK_UPDATE, reset_all_items)

------------------------------------------------------------------------------------------

---@param item Item
---@param size string
---@param key string
---@return number
local __parse_size = function (item, size, key)
    if size == "_" then
        return item.dimensions.size[key]
    end

    local new_size = 0
    local symbol = size:sub(1, 1)
    if symbol == "+" or symbol == "-" then
        local number = size:sub(2)
        if symbol == "-" then
            number = "-" .. number
        end
        if tonumber(number) then
            new_size = item.dimensions.size[key] + number
        end
        return math.clamp(new_size, 0.01, 25)
    end

    return math.clamp(tonumber(size) or item.dimensions.size[key], 0.01, 25)
end

---@param msg string
local function on_set_item_size_chat_command(msg)
    local sizes = string.split(msg, " ")
	local sizes_count = #sizes

	if not sizes[1] then
		djui_chat_message_create("Usage: [num] or [x|y|z]")
		return true
	end

    ---@type Item?
    local item = gCurrentItem
    if item then
        if sizes_count == 1 then
            local new_size = __parse_size(item, sizes[1], "x")
            local grid_size = new_size
            vec3f_set(item.dimensions.size, new_size, new_size, new_size)
		    vec3f_set(item.dimensions.grid, grid_size, grid_size, grid_size)
            djui_chat_message_create("Set item size to " .. new_size)
        elseif sizes_count == 3 then
            local new_size_x = __parse_size(item, sizes[1], "x")
            local new_size_y = __parse_size(item, sizes[2], "y")
            local new_size_z = __parse_size(item, sizes[3], "z")
            vec3f_set(item.dimensions.size, new_size_x, new_size_y, new_size_z)
            vec3f_set(item.dimensions.grid, new_size_x, new_size_y, new_size_z)
            djui_chat_message_create("Set item size to (" .. new_size_x, new_size_y, new_size_z .. ")")
        else
            djui_chat_message_create("Usage: [num] or [x y z] or [on|off]")
        end
    else
        djui_chat_message_create("You must have an item selected to change its size!")
    end

    return true
end

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
            local alpha = math.clamp(number_msg, 32, 255)
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
    local new_hotbar_item = Hotbar.items[new_hotbar_index].item --[[@as Item?]]
    if not new_hotbar_item then
        djui_chat_message_create("Can't replace using an empty slot")
        return true
    end

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

---@param item Item
---@param color string
---@param key string
---@return number
local __parse_color = function (item, color, key)
    if color == "_" then
        return item.params.color[key]
    end

    local symbol = color:sub(1, 1)
    if symbol == "+" or symbol == "-" then
        local new_color = 0
        local is_hex = color:sub(2, 3) == "0x"
        local base = is_hex and 16 or 10
        local start = is_hex and 4 or 2
        local number = color:sub(start)
        if symbol == "-" then
            number = "-" .. number
        end

        local addend = tonumber(number, base) or 0
        new_color = item.params.color[key] + addend
        return math.floor(math.clamp(new_color, 0, 255))
    end
    local is_hex = color:sub(1, 2) == "0x"
    local base = is_hex and 16 or 10
    local start = is_hex and 3 or 1
    local number = color:sub(start)

    return math.floor(math.clamp(tonumber(number, base) or item.params.color[key], 0, 255))
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

hook_chat_command("size", "[num] or [x y z] | Sets the size scaling of the currently selected item. Clamped between 0.01 and 25", on_set_item_size_chat_command)
hook_chat_command("surface", "! BLOCK ONLY ! Sets the surface type of a block. Refer to the Surface Types tab for which exist and what they do", on_set_surface_chat_command)
hook_chat_command("surf", "! SAME AS /surface !", on_set_surface_chat_command)
hook_chat_command("transparent", "[<opacity>] | Makes the current selected block transparent", on_transparent_chat_command)
hook_chat_command("replace", "[hotbar index] | Replaces the placed blocks with the same held model, with the block model of the supplied hotbar index.", on_replace_chat_command)
hook_chat_command("color", "[<r> <g> <b>] | Sets the color of the currently selected block", on_set_color_chat_command)
hook_chat_command("shade", "| Toggle shading on the currently selected block", on_set_shade_chat_command)
hook_chat_command("tile", "| Toggle tiling on the currently selected block", on_set_tiling_chat_command)
hook_chat_command("shape", "[cube|pyramid|cylinder|sphere] | Sets the shape of the block", on_set_shape_chat_command)