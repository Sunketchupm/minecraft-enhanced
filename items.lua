---@class Item
    ---@field behavior BehaviorId
    ---@field model ModelExtendedId
    ---@field spawnYOffset number
    ---@field params integer
    ---@field size Vec3f
    ---@field animState integer
    ---@field mock table

---@class Object
    ---@field oScaleX number
    ---@field oScaleY number
    ---@field oScaleZ number
    ---@field oItemParams integer
    ---@field oOwner integer

define_custom_obj_fields({
    oScaleX = "f32",
    oScaleY = "f32",
    oScaleZ = "f32",
    oItemParams = "u32",
    oOwner = "s32"
})

gCurrentItem = {behavior = nil, model = E_MODEL_NONE, params = {}}
local item_behaviors = {}
add_first_update(function ()
    ---@type Item
    gCurrentItem = { behavior = bhvMceBlock, model = E_MODEL_MCE_BLOCK, spawnYOffset = 0, params = 0, size = gVec3fOne(), animState = 0, mock = {} }
    ---@type BehaviorId[]
    item_behaviors = {
        bhvMceBlock,
        bhvMceStar,
        bhvMceCoin,
        bhvMceExclamationBox
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

---@param obj Object
local function network_send_object_owner_only(obj)
    if obj.oOwner == network_global_index_from_local(0) + 1 then
        if obj.oTimer >= 300 then
            network_send_object(obj, true)
        end
    end
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

local MCE_BLOCK_NO_COLLISION_ID = 0xFF
local MCE_BLOCK_DEFAULT_ID = 0
local MCE_BLOCK_LAVA_ID = 1
local MCE_BLOCK_DEATH_ID = 2
local MCE_BLOCK_QUICKSAND_ID = 3
local MCE_BLOCK_SHALLOW_QUICKSAND_ID = 4
local MCE_BLOCK_NOT_SLIPPERY_ID = 5
local MCE_BLOCK_SLIPPERY_ID = 6
local MCE_BLOCK_VERY_SLIPPERY_ID = 7
local MCE_BLOCK_HANGABLE_ID = 8
local MCE_BLOCK_VANISH_ID = 9

BLOCK_ANIM_STATE_TRANSPARENT_START = 110
BLOCK_BARRIER_ANIM = (BLOCK_ANIM_STATE_TRANSPARENT_START * 2) + 1

local standard_collision_lookup = {
    [MCE_BLOCK_DEFAULT_ID] = COL_MCE_BLOCK_DEFAULT,
    [MCE_BLOCK_LAVA_ID] = COL_MCE_BLOCK_LAVA,
    [MCE_BLOCK_DEATH_ID] = COL_MCE_BLOCK_DEATH,
    [MCE_BLOCK_QUICKSAND_ID] = COL_MCE_BLOCK_QUICKSAND,
    [MCE_BLOCK_SHALLOW_QUICKSAND_ID] = COL_MCE_BLOCK_SHALLOW_QUICKSAND,
    [MCE_BLOCK_NOT_SLIPPERY_ID] = COL_MCE_BLOCK_NOT_SLIPPERY,
    [MCE_BLOCK_SLIPPERY_ID] = COL_MCE_BLOCK_SLIPPERY,
    [MCE_BLOCK_VERY_SLIPPERY_ID] = COL_MCE_BLOCK_VERY_SLIPPERY,
    [MCE_BLOCK_HANGABLE_ID] = COL_MCE_BLOCK_HANGABLE,
    [MCE_BLOCK_VANISH_ID] = COL_MCE_BLOCK_VANISH,
}

--- Called from bhvMceBlock.bhv

---@param obj Object
function bhv_mce_block_init(obj)
    local surface_id = obj.oItemParams & 0xFF
    if surface_id ~= MCE_BLOCK_NO_COLLISION_ID then
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
    network_send_object_owner_only(obj)
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
        end
    else
        cur_obj_disable_rendering_and_become_intangible(obj)
        if obj.oTimer > 300 then
            obj.oAction = 0
            cur_obj_enable_rendering_and_become_tangible(obj)
        end
    end

    obj.oInteractStatus = 0

    network_send_object_owner_only(obj)
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
    else
        cur_obj_disable_rendering_and_become_intangible(obj)
        if obj.oTimer > 300 then
            obj.oAction = 0
            cur_obj_enable_rendering_and_become_tangible(obj)
        end
    end

    obj.oInteractStatus = 0

    network_send_object_owner_only(obj)
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

    network_send_object_owner_only(obj)
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

------------------------------------------------------------------------------------------

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
local function bhv_barrier_init(obj)
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj.oFaceAnglePitch = 0
    obj.oFaceAngleYaw = 0
    obj.oFaceAngleRoll = 0
end

id_bhvBarrier = hook_behavior(nil, OBJ_LIST_UNIMPORTANT, false, bhv_barrier_init, function (obj) obj_mark_for_deletion(obj) end)

local function unrendered_items_update()
    for _, behavior in ipairs(item_behaviors) do
        if behavior ~= bhvMceBlock then
            local obj = obj_get_first_with_behavior_id(behavior)
            while obj do
                local render_flags = obj.header.gfx.node.flags
                if gMarioStates[0].action == ACT_FREE_MOVE and (render_flags & GRAPH_RENDER_INVISIBLE ~= 0 or render_flags & GRAPH_RENDER_ACTIVE == 0) then
                    obj.oTimer = 301
                end
                obj = obj_get_next_with_same_behavior_id(obj)
            end
        end
    end
end

hook_chat_command("objects", "Counts the amount of objects in the current area", on_object_count_chat_commmand)
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
            local new_size = math.clamp(tonumber(sizes[1]) or 1, 0.01, 20)
            local grid_size = new_size * 200
            vec3f_set(current_selected.size, new_size, new_size, new_size)
		    vec3f_set(GridSize, grid_size, grid_size, grid_size)
            djui_chat_message_create("Set item size to " .. new_size)
        elseif sizes_count == 3 then
            local new_size_x = math.clamp(tonumber(sizes[1]) or 1, 0.01, 20)
            local new_size_y = math.clamp(tonumber(sizes[2]) or 1, 0.01, 20)
            local new_size_z = math.clamp(tonumber(sizes[3]) or 1, 0.01, 20)
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
    ["default"] = MCE_BLOCK_DEFAULT_ID,
    ["normal"] = MCE_BLOCK_DEFAULT_ID,
    ["none"] = -1,
    ["no collision"] = -1,
    ["intangible"] = -1,
    ["lava"] = MCE_BLOCK_LAVA_ID,
    ["death"] = MCE_BLOCK_DEATH_ID,
    ["quicksand"] = MCE_BLOCK_QUICKSAND_ID,
    ["shallow quicksand"] = MCE_BLOCK_SHALLOW_QUICKSAND_ID,
    ["shallowsand"] = MCE_BLOCK_SHALLOW_QUICKSAND_ID,
    ["not slippery"] = MCE_BLOCK_NOT_SLIPPERY_ID,
    ["slippery"] = MCE_BLOCK_SLIPPERY_ID,
    ["very slippery"] = MCE_BLOCK_VERY_SLIPPERY_ID,
    ["hangable"] = MCE_BLOCK_HANGABLE_ID,
    ["vanish"] = MCE_BLOCK_VANISH_ID,
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

hook_chat_command("size", "[num] or [x y z] | Sets the size scaling of the currently selected item. Clamped between 0.01 and 20", on_set_item_size_chat_command)
hook_chat_command("surface", "! BLOCK ONLY ! Sets the surface type of a block. Refer to the Surface Types tab for which exist and what they do", on_set_surface_chat_command)
hook_chat_command("surf", "! SAME AS /surface !", on_set_surface_chat_command)