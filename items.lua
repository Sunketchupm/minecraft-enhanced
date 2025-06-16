---@class Item
    ---@field behavior BehaviorId
    ---@field model ModelExtendedId
    ---@field spawnYOffset number
    ---@field params integer
    ---@field size Vec3f
    ---@field rotation Vec3s x = pitch, y = yaw, z = roll
    ---@field animState integer
    ---@field mock table

---@class Object
    ---@field oScaleX number
    ---@field oScaleY number
    ---@field oScaleZ number
    ---@field oModelId integer
    ---@field oItemParams integer
    ---@field oOwner integer

define_custom_obj_fields({
    oScaleX = "f32",
    oScaleY = "f32",
    oScaleZ = "f32",
    oModelId = "u32",
    oItemParams = "u32",
    oOwner = "s32"
})

gCurrentItem = {behavior = nil, model = E_MODEL_NONE, params = {}}
all_item_behaviors = {}
local level_item_behaviors = {}
local enemy_item_behaviors = {}
local vanilla_clear_immune = {}
add_first_update(function ()
    ---@type Item
    gCurrentItem = {
        behavior = bhvMceBlock,
        model = E_MODEL_MCE_BLOCK,
        spawnYOffset = 0,
        params = 0,
        size = gVec3fOne(),
        rotation = gVec3sZero(),
        animState = 0,
        mock = {}
    }
    ---@type BehaviorId[]
    all_item_behaviors = {
        bhvMceBlock,
        bhvMceStar,
        bhvMceCoin,
        bhvMceExclamationBox
    }
    ---@type BehaviorId[]
    level_item_behaviors = {
        bhvMceStar,
        bhvMceCoin,
        bhvMceExclamationBox
    }
    ---@type BehaviorId[]
    enemy_item_behaviors = {
        --
    }
    ---@type BehaviorId[]
    vanilla_clear_immune = {
        [id_bhvSpinAirborneWarp] = true,
        [bhvMceBlock] = true,
        [bhvMceStar] = true,
        [bhvMceCoin] = true,
        [bhvMceExclamationBox] = true,
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

---@param obj Object
---@return Object? item
function obj_get_any_nearest_item(obj)
    local nearest_item = nil
    local nearest_dist = 0xFFFF
    for _, item_behavior in ipairs(all_item_behaviors) do
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

---@param m MarioState
---@param block Object
local function mario_is_within_block(m, block)
    -- ! Use a better checking system as this does not at all account for angles
    return m.pos.x > block.oPosX - (100 * block.oScaleX) and m.pos.x < block.oPosX + (100 * block.oScaleX) and
            m.pos.y > block.oPosY - (100 * block.oScaleY) and m.pos.y < block.oPosY + (100 * block.oScaleY) and
            m.pos.z > block.oPosZ - (100 * block.oScaleZ) and m.pos.z < block.oPosZ + (100 * block.oScaleZ)
end

------------------------------------------------------------------------------------------

local COL_MCE_BLOCK_DEFAULT = smlua_collision_util_get("mce_block_col_default")
local COL_MCE_BLOCK_LAVA = smlua_collision_util_get("mce_block_col_lava")
local COL_MCE_BLOCK_DEATH = smlua_collision_util_get("mce_block_col_death")
local COL_MCE_BLOCK_QUICKSAND = smlua_collision_util_get("mce_block_col_quicksand")
local COL_MCE_BLOCK_SHALLOW_QUICKSAND = smlua_collision_util_get("mce_block_col_shallowsand")
local COL_MCE_BLOCK_NOT_SLIPPERY = smlua_collision_util_get("mce_block_col_not_slippery")
local COL_MCE_BLOCK_SLIPPERY = smlua_collision_util_get("mce_block_col_slippery")
local COL_MCE_BLOCK_VERY_SLIPPERY = smlua_collision_util_get("mce_block_col_very_slippery")
local COL_MCE_BLOCK_HANGABLE = smlua_collision_util_get("mce_block_col_hangable")
local COL_MCE_BLOCK_VANISH = smlua_collision_util_get("mce_block_col_vanish")

local MCE_BLOCK_COL_ID_NO_COLLISION = 0xFF
local MCE_BLOCK_COL_ID_DEFAULT = 0
local MCE_BLOCK_COL_ID_LAVA = 1
local MCE_BLOCK_COL_ID_DEATH = 2
local MCE_BLOCK_COL_ID_QUICKSAND = 3
local MCE_BLOCK_COL_ID_SHALLOW_QUICKSAND = 4
local MCE_BLOCK_COL_ID_NOT_SLIPPERY = 5
local MCE_BLOCK_COL_ID_SLIPPERY = 6
local MCE_BLOCK_COL_ID_VERY_SLIPPERY = 7
local MCE_BLOCK_COL_ID_HANGABLE = 8
local MCE_BLOCK_COL_ID_VANISH = 9
local MCE_BLOCK_COL_ID_VERTICAL_WIND = 10
local MCE_BLOCK_COL_ID_WATER = 11
local MCE_BLOCK_COL_ID_CHECKPOINT = 12
local MCE_BLOCK_COL_ID_BOUNCE = 13
local MCE_BLOCK_COL_ID_FIRSTY = 14
local MCE_BLOCK_COL_ID_WIDE_WALLKICK = 15
local MCE_BLOCK_COL_ID_BOOSTER = 16
local MCE_BLOCK_COL_ID_HEAL = 17
local MCE_BLOCK_COL_ID_NO_A = 18
local MCE_BLOCK_COL_ID_ANY_BONK_WALLKICK = 19
local MCE_BLOCK_COL_ID_NO_FALL_DAMAGE = 20
local MCE_BLOCK_COL_ID_CONVEYOR = 21
local MCE_BLOCK_COL_ID_BREAKABLE = 22
local MCE_BLOCK_COL_ID_DISAPPEARING = 23
local MCE_BLOCK_COL_ID_REMOVE_CAPS = 24
local MCE_BLOCK_COL_ID_NO_WALLKICKS = 25
local MCE_BLOCK_COL_ID_DASH_PANEL = 26
local MCE_BLOCK_COL_ID_TOXIC_GAS = 27
local MCE_BLOCK_COL_ID_JUMP_PAD = 28

BLOCK_ANIM_STATE_TRANSPARENT_START = 110
BLOCK_BARRIER_ANIM = (BLOCK_ANIM_STATE_TRANSPARENT_START * 2) + 1

local standard_collision_lookup = {
    [MCE_BLOCK_COL_ID_DEFAULT] = COL_MCE_BLOCK_DEFAULT,
    [MCE_BLOCK_COL_ID_LAVA] = COL_MCE_BLOCK_LAVA,
    [MCE_BLOCK_COL_ID_DEATH] = COL_MCE_BLOCK_DEATH,
    [MCE_BLOCK_COL_ID_QUICKSAND] = COL_MCE_BLOCK_QUICKSAND,
    [MCE_BLOCK_COL_ID_SHALLOW_QUICKSAND] = COL_MCE_BLOCK_SHALLOW_QUICKSAND,
    [MCE_BLOCK_COL_ID_NOT_SLIPPERY] = COL_MCE_BLOCK_NOT_SLIPPERY,
    [MCE_BLOCK_COL_ID_SLIPPERY] = COL_MCE_BLOCK_SLIPPERY,
    [MCE_BLOCK_COL_ID_VERY_SLIPPERY] = COL_MCE_BLOCK_VERY_SLIPPERY,
    [MCE_BLOCK_COL_ID_HANGABLE] = COL_MCE_BLOCK_HANGABLE,
    [MCE_BLOCK_COL_ID_VANISH] = COL_MCE_BLOCK_VANISH,
}

local ignore_collision_lookup = {
    [MCE_BLOCK_COL_ID_NO_COLLISION] = true,
    [MCE_BLOCK_COL_ID_VERTICAL_WIND] = true,
    [MCE_BLOCK_COL_ID_WATER] = true,
}

--- Called from bhvMceBlock.bhv

---@param obj Object
function bhv_mce_block_init(obj)
    local surface_id = obj.oItemParams & 0xFF
    if not ignore_collision_lookup[surface_id] then
        local collision = COL_MCE_BLOCK_DEFAULT
        if standard_collision_lookup[surface_id] then
            collision = standard_collision_lookup[surface_id]
        end
        obj.collisionData = collision
    end
    if obj.oAnimState >= BLOCK_ANIM_STATE_TRANSPARENT_START then
        obj.oOpacity = 100
    end
    obj.oCollisionDistance = 500 * vec3f_length({x = obj.oScaleX, y = obj.oScaleY, z = obj.oScaleZ})
    obj.header.gfx.skipInViewCheck = true
    network_init_object(obj, false, {
        "activeFlags",
        "oOpacity",
        "oAnimState",
        "oOwner",
        "oFaceAnglePitch",
        "oMoveAnglePitch",
        "oFaceAngleYaw",
        "oMoveAngleYaw",
        "oFaceAngleRoll",
        "oMoveAngleRoll",
        "oScaleX",
        "oScaleY",
        "oScaleZ",
        "oItemParams",
        "oCollisionDistance"
    })
end

---@param obj Object
function bhv_mce_block_loop(obj)
    if obj.oAnimState > BLOCK_BARRIER_ANIM then
        obj.oAnimState = BLOCK_BARRIER_ANIM
    end
    if obj.oAnimState == BLOCK_BARRIER_ANIM and gMarioStates[0].action ~= ACT_FREE_MOVE then
        obj.header.gfx.node.flags = obj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
    else
        obj.header.gfx.node.flags = obj.header.gfx.node.flags & ~GRAPH_RENDER_INVISIBLE
    end

    ----------------------- Custom surfaces -----------------------
    -- Handle surfaces that affect the block itself
end

----------------------- Custom surfaces -----------------------

---@param m MarioState
local function custom_surface_mario_update(m)
    if m.playerIndex ~= 0 then return end
    local block = (m.floor and m.floor.object) or (m.wall and m.wall.object) or (m.ceil and m.ceil.object)
    if block then
        local surface_id = block.oItemParams & 0xFF

        if surface_id == MCE_BLOCK_COL_ID_CHECKPOINT and m.pos.y == m.floorHeight then
            respawn_location = {x = block.oPosX, y = block.oPosY + block.oScaleY * 200, z = block.oPosZ}
        end
    end

    block = obj_get_first_with_behavior_id(bhvMceBlock)
    while block do
        surface_id = block.oItemParams & 0xFF

        if surface_id == MCE_BLOCK_COL_ID_VERTICAL_WIND and mario_is_within_block(m, block) then
            if m.action ~= ACT_CUSTOM_VERTICAL_WIND and m.action & ACT_FLAG_ALLOW_VERTICAL_WIND_ACTION ~= 0 then
                drop_and_set_mario_action(m, ACT_CUSTOM_VERTICAL_WIND, 0)
            end
            m.vel.y = m.vel.y + 15
            if m.vel.y > 50 then
                m.vel.y = 50
            end
            spawn_wind_particles(1, 0)
            play_sound(SOUND_ENV_WIND2, m.marioObj.header.gfx.cameraToObject)
        end
        block = obj_get_next_with_same_behavior_id(block)
    end
end

---@param m MarioState
local function vanilla_mario_update_geometry_inputs(m)
    resolve_and_return_wall_collisions(m.pos, 60, 50)
    resolve_and_return_wall_collisions(m.pos, 30, 24)

    m.floor = collision_find_floor(m.pos.x, m.pos.y, m.pos.z)
    m.floorHeight = find_floor_height(m.pos.x, m.pos.y, m.pos.z)

    -- If Mario is OOB, move his position to his graphical position (which was not updated)
    -- and check for the floor there.
    -- This can cause errant behavior when combined with astral projection,
    -- since the graphical position was not Mario's previous location.
    if not m.floor then
        vec3f_copy(m.pos, m.marioObj.header.gfx.pos)
        m.floorHeight = find_floor_height(m.pos.x, m.pos.y, m.pos.z)
    end

    m.ceil = collision_find_ceil(m.pos.x, m.floorHeight, m.pos.z)
    m.ceilHeight = find_ceil_height(m.pos.x, m.floorHeight, m.pos.z)
    gasLevel = find_poison_gas_level(m.pos.x, m.pos.z)
    m.waterLevel = find_water_level(m.pos.x, m.pos.z)

    if m.floor then
        m.floorAngle = atan2s(m.floor.normal.z, m.floor.normal.x)
        m.terrainSoundAddend = mario_get_terrain_sound_addend(m)

        if m.pos.y > m.waterLevel - 40 and mario_floor_is_slippery(m) ~= 0 then
            m.input = m.input | INPUT_ABOVE_SLIDE
        end

        if (m.floor.flags & SURFACE_FLAG_DYNAMIC ~= 0)
            or (m.ceil and m.ceil.flags & SURFACE_FLAG_DYNAMIC ~= 0) then
            ceilToFloorDist = m.ceilHeight - m.floorHeight

            if 0.0 <= ceilToFloorDist and ceilToFloorDist <= 150.0 then
                m.input = m.input | INPUT_SQUISHED
            end
        end

        if m.pos.y > m.floorHeight + 100.0 then
            m.input = m.input | INPUT_OFF_FLOOR
        end

        if m.pos.y < m.waterLevel - 10 then
            m.input = m.input | INPUT_IN_WATER
        end

        if m.pos.y < gasLevel - 100.0 then
            m.input = m.input | INPUT_IN_POISON_GAS
        end
    end
end

---@param m MarioState
local function custom_surface_override_geometry_inputs(m)
    if m.playerIndex ~= 0 then return end

    local block = obj_get_first_with_behavior_id(bhvMceBlock)
    local highest_water_y = gLevelValues.floorLowerLimit
    local first_check = true
    local in_water_block = false
    while block do
        local surface_id = block.oItemParams & 0xFF
        if surface_id == MCE_BLOCK_COL_ID_WATER and mario_is_within_block(m, block) then
            if first_check then
                vanilla_mario_update_geometry_inputs(m)
                first_check = false
                highest_water_y = m.waterLevel
            end
            local new_water_level = block.oPosY + block.oScaleY * 100
            if new_water_level > highest_water_y then
                m.waterLevel = new_water_level
                highest_water_y = new_water_level
            else
                m.waterLevel = highest_water_y
            end
            in_water_block = true
        end
        block = obj_get_next_with_same_behavior_id(block)
    end
    if in_water_block then
        return false
    end
end

hook_event(HOOK_MARIO_UPDATE, custom_surface_mario_update)
hook_event(HOOK_MARIO_OVERRIDE_GEOMETRY_INPUTS, custom_surface_override_geometry_inputs)

------------------------------------------------------------------------------------------

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
    network_init_object(obj, false, {
        "activeFlags",
        "oOwner",
        "oScaleX",
        "oScaleY",
        "oScaleZ",
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
    })
end

---@param obj Object
function bhv_mce_coin_loop(obj)
    if obj.oAction == 0 then
        if obj.oInteractStatus & INT_STATUS_INTERACTED ~= 0 then
            spawn_non_sync_object(id_bhvGoldenCoinSparkles, E_MODEL_SPARKLES, obj.oPosX, obj.oPosY, obj.oPosZ, nil)
            cur_obj_disable_rendering_and_become_intangible(obj)
            obj.oAction = 1
        end
    end

    obj.oInteractStatus = 0
end

------------------------------------------------------------------------------------------

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

---@param obj Object
function bhv_mce_exclamation_box_init(obj)
    network_init_object(obj, false, {
        "activeFlags",
        "oOwner",
        "oScaleX",
        "oScaleY",
        "oScaleZ",
    })
end

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

local function network_is_privileged()
    return network_is_server() or network_is_moderator()
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
local function on_clear_chat_command(msg)
    local args = split_string(msg, " ")
    local command = args[1] and args[1]:lower() or ""
    if command == "all" or command == "" then
        for _, behavior in ipairs(all_item_behaviors) do
            local obj = obj_get_first_with_behavior_id(behavior)
            while obj do
                if object_removal_criteria(obj, args[2]) then
                    obj_mark_for_deletion(obj)
                end
                obj = obj_get_next_with_same_behavior_id(obj)
            end
        end
        djui_chat_message_create("Removed all placed items")
    elseif command == "vanilla" and network_is_privileged() then
        for i = OBJ_LIST_PLAYER + 1, NUM_OBJ_LISTS - 1, 1 do
            local obj = obj_get_first(i)
            while obj do
                local behavior_id = get_id_from_behavior(obj.behavior)
                if not vanilla_clear_immune[behavior_id] then
                    obj_mark_for_deletion(obj)
                end
                obj_mark_for_deletion(obj)
                obj = obj_get_next(obj)
            end
        end
        djui_chat_message_create("Removed all non-mce objects")
    elseif command == "blocks" then
        local obj = obj_get_first_with_behavior_id(bhvMceBlock)
        while obj  do
            if object_removal_criteria(obj, args[2]) then
                obj_mark_for_deletion(obj)
            end
            obj = obj_get_next_with_same_behavior_id(obj)
        end
        djui_chat_message_create("Removed all placed blocks")
    elseif command == "items" then
        for _, behavior in ipairs(level_item_behaviors) do
            local obj = obj_get_first_with_behavior_id(behavior)
            while obj do
                if object_removal_criteria(obj, args[2]) then
                    obj_mark_for_deletion(obj)
                end
                obj = obj_get_next_with_same_behavior_id(obj)
            end
        end
        djui_chat_message_create("Removed all placed level items")
    elseif command == "enemies" then
        for _, behavior in ipairs(enemy_item_behaviors) do
            local obj = obj_get_first_with_behavior_id(behavior)
            while obj  do
                if object_removal_criteria(obj, args[2]) then
                    obj_mark_for_deletion(obj)
                end
                obj = obj_get_next_with_same_behavior_id(obj)
            end
        end
        djui_chat_message_create("Removed all placed enemies")
    else
        if network_is_privileged() then
            djui_chat_message_create("USAGE: [all|vanilla|blocks|items|enemies] [ALL|orphaned]")
        else
            djui_chat_message_create("USAGE: [all|blocks|items|enemies]")
        end
    end
    return true
end

local function unrendered_items_update()
    for _, behavior in ipairs(all_item_behaviors) do
        if behavior ~= bhvMceBlock then
            local obj = obj_get_first_with_behavior_id(behavior)
            while obj do
                local render_flags = obj.header.gfx.node.flags
                if gMarioStates[0].action == ACT_FREE_MOVE and (render_flags & GRAPH_RENDER_INVISIBLE ~= 0 or render_flags & GRAPH_RENDER_ACTIVE == 0) then
                    obj.header.gfx.node.flags = obj.header.gfx.node.flags &~ GRAPH_RENDER_INVISIBLE
                    obj.header.gfx.node.flags = obj.header.gfx.node.flags | GRAPH_RENDER_ACTIVE
                    obj_become_tangible(obj)
                    obj.oAction = 0
                end
                obj = obj_get_next_with_same_behavior_id(obj)
            end
        end
    end
end

hook_chat_command("objects", "Counts the amount of objects in the current area", on_object_count_chat_commmand)
hook_chat_command("clear", "[all|blocks|items|enemies] | Removes all objects placed by you that fit the specified criteria", on_clear_chat_command)
if network_is_privileged() then
    update_chat_command_description("clear", "[all|blocks|items|enemies] | Removes all objects placed by you that fit the specified criteria \
    MODERATORS: [all|vanilla|blocks|items|enemies] [ALL|orphaned] \
    Use 'ALL' to remove EVERY object of that criteria \
    Use 'orphaned' to remove all objects of that criteria with no owner")
end
hook_event(HOOK_UPDATE, unrendered_items_update)

------------------------------------------------------------------------------------------

---@param msg string
local function on_set_item_size_chat_command(msg)
    local sizes = split_string(msg, " ")
	local sizes_count = #sizes

	if not sizes[1] then
		djui_chat_message_create("Usage: [num] or [x|y|z]")
		return true
	end

    local current_selected = HotbarItemList[SelectedHotbarIndex].item
    if current_selected then
            current_selected.size = gVec3fOne()
        if sizes_count == 1 then
            local new_size = math.clamp(tonumber(sizes[1]) or 1, 0.01, 25)
            local grid_size = new_size * 200
            vec3f_set(current_selected.size, new_size, new_size, new_size)
		    vec3f_set(GridSize, grid_size, grid_size, grid_size)
            djui_chat_message_create("Set item size to " .. new_size)
        elseif sizes_count == 3 then
            local new_size_x = math.clamp(tonumber(sizes[1]) or 1, 0.01, 25)
            local new_size_y = math.clamp(tonumber(sizes[2]) or 1, 0.01, 25)
            local new_size_z = math.clamp(tonumber(sizes[3]) or 1, 0.01, 25)
            local grid_size_x = new_size_x * 200
            local grid_size_y = new_size_y * 200
            local grid_size_z = new_size_z * 200
            vec3f_set(GridSize, grid_size_x, grid_size_y, grid_size_z)
            vec3f_set(current_selected.size, new_size_x, new_size_y, new_size_z)
            djui_chat_message_create("Set item size to (" .. new_size_x, new_size_y, new_size_z .. ")")
        else
            djui_chat_message_create("Usage: [num] or [x y z] or [on|off]")
        end
    else
        djui_chat_message_create("You must have an item selected to change its size!")
    end

    return true
end

local block_id_lookup = {
    ["default"] = MCE_BLOCK_COL_ID_DEFAULT,
    ["normal"] = MCE_BLOCK_COL_ID_DEFAULT,
    ["none"] = -1,
    ["no collision"] = -1,
    ["intangible"] = -1,
    ["lava"] = MCE_BLOCK_COL_ID_LAVA,
    ["death"] = MCE_BLOCK_COL_ID_DEATH,
    ["quicksand"] = MCE_BLOCK_COL_ID_QUICKSAND,
    ["shallow quicksand"] = MCE_BLOCK_COL_ID_SHALLOW_QUICKSAND,
    ["shallowsand"] = MCE_BLOCK_COL_ID_SHALLOW_QUICKSAND,
    ["s sand"] = MCE_BLOCK_COL_ID_SHALLOW_QUICKSAND,
    ["not slippery"] = MCE_BLOCK_COL_ID_NOT_SLIPPERY,
    ["n slippery"] = MCE_BLOCK_COL_ID_NOT_SLIPPERY,
    ["slippery"] = MCE_BLOCK_COL_ID_SLIPPERY,
    ["very slippery"] = MCE_BLOCK_COL_ID_VERY_SLIPPERY,
    ["v slippery"] = MCE_BLOCK_COL_ID_VERY_SLIPPERY,
    ["hangable"] = MCE_BLOCK_COL_ID_HANGABLE,
    ["vanish"] = MCE_BLOCK_COL_ID_VANISH,
    ["vertical wind"] = MCE_BLOCK_COL_ID_VERTICAL_WIND,
    ["v wind"] = MCE_BLOCK_COL_ID_VERTICAL_WIND,
    ["water"] = MCE_BLOCK_COL_ID_WATER,
    ["checkpoint"] = MCE_BLOCK_COL_ID_CHECKPOINT,
    ["bounce"] = MCE_BLOCK_COL_ID_BOUNCE,
    ["firsty"] = MCE_BLOCK_COL_ID_FIRSTY,
    ["wide"] = MCE_BLOCK_COL_ID_WIDE_WALLKICK,
    ["wide wallkick"] = MCE_BLOCK_COL_ID_WIDE_WALLKICK,
    ["booster"] = MCE_BLOCK_COL_ID_BOOSTER,
    ["heal"] = MCE_BLOCK_COL_ID_HEAL,
    ["no a"] = MCE_BLOCK_COL_ID_NO_A,
    ["jumpless"] = MCE_BLOCK_COL_ID_NO_A,
    ["any bonk"] = MCE_BLOCK_COL_ID_ANY_BONK_WALLKICK,
    ["anykick"] = MCE_BLOCK_COL_ID_ANY_BONK_WALLKICK,
    ["no fall damage"] = MCE_BLOCK_COL_ID_NO_FALL_DAMAGE,
    ["no fall"] = MCE_BLOCK_COL_ID_NO_FALL_DAMAGE,
    ["conveyor"] = MCE_BLOCK_COL_ID_CONVEYOR,
    ["breakable"] = MCE_BLOCK_COL_ID_BREAKABLE,
    ["disappearing"] = MCE_BLOCK_COL_ID_DISAPPEARING,
    ["remove caps"] = MCE_BLOCK_COL_ID_REMOVE_CAPS,
    ["no wallkicks"] = MCE_BLOCK_COL_ID_NO_WALLKICKS,
    ["dash"] = MCE_BLOCK_COL_ID_DASH_PANEL,
    ["dash panel"] = MCE_BLOCK_COL_ID_DASH_PANEL,
    ["toxic gas"] = MCE_BLOCK_COL_ID_TOXIC_GAS,
    ["toxic"] = MCE_BLOCK_COL_ID_TOXIC_GAS,
    ["jump pad"] = MCE_BLOCK_COL_ID_JUMP_PAD,
}

---@param msg string
local function on_set_surface_chat_command(msg)
    if block_id_lookup[msg:lower()] then
        if HotbarItemList[SelectedHotbarIndex].item and HotbarItemList[SelectedHotbarIndex].item.behavior == bhvMceBlock then
            HotbarItemList[SelectedHotbarIndex].item.params = block_id_lookup[msg:lower()]
            djui_chat_message_create("Set the surface type to " .. msg)
        else
            djui_chat_message_create("You must have a block selected to change its surface type!")
        end
    else
        djui_chat_message_create("Could not find surface type " .. "\"" .. msg .. "\"")
    end
    return true
end

hook_chat_command("size", "[num] or [x y z] | Sets the size scaling of the currently selected item. Clamped between 0.01 and 25", on_set_item_size_chat_command)
hook_chat_command("surface", "! BLOCK ONLY ! Sets the surface type of a block. Refer to the Surface Types tab for which exist and what they do", on_set_surface_chat_command)
hook_chat_command("surf", "! SAME AS /surface !", on_set_surface_chat_command)