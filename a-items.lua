---@class Item
    ---@field behaviorId BehaviorId
    ---@field itemId integer
    ---@field model ModelExtendedId
    ---@field paramsLUT any[]
    ---@field paramsForceAnim any[]
    ---@field animLUT any[]
    ---@field paramsSuccessMessage string
    ---@field animSuccessMessage string
    ---@field paramsErrorMessage string
    ---@field animErrorMessage string

---@type Item<string, Item>
gItemInfoLUT = {}

--------------------------------------------------------------------------------------------
------------------------------------------ Blocks ------------------------------------------
--------------------------------------------------------------------------------------------

local NEW_COLOR_ID = 9

gCollisionTypes = {
    [BLOCK_SURFACE_ID_DEFAULT] = COL_CUSTOM_BOX_DEFAULT,
    [BLOCK_SURFACE_ID_LAVA] = COL_CUSTOM_BOX_LAVA,
    [BLOCK_SURFACE_ID_QUICKSAND] = COL_CUSTOM_BOX_QUICKSAND,
    [BLOCK_SURFACE_ID_SLIPPERY] = COL_CUSTOM_BOX_SLIPPERY,
    [BLOCK_SURFACE_ID_VERY_SLIPPERY] = COL_CUSTOM_BOX_VERY_SLIPPERY,
    [BLOCK_SURFACE_ID_NOT_SLIPPERY] = COL_CUSTOM_BOX_NOT_SLIPPERY,
    [BLOCK_SURFACE_ID_HANGABLE] = COL_CUSTOM_BOX_HANGABLE,
    [BLOCK_SURFACE_ID_SHALLOWSAND] = COL_CUSTOM_BOX_SHALLOWSAND,
    [BLOCK_SURFACE_ID_DEATH] = COL_CUSTOM_BOX_DEATH,
    [BLOCK_SURFACE_ID_VANISH] = COL_CUSTOM_BOX_VANISH
}

local sSpecialOverrideNormalSurface = {
    [BLOCK_SURFACE_ID_NO_COLLISION] = 0,
    [BLOCK_SURFACE_ID_CONVEYOR] = COL_CUSTOM_BOX_HANGABLE,
    [BLOCK_SURFACE_ID_BOOSTER] = 0,
    [BLOCK_SURFACE_ID_TOXIC_GAS] = 0
}

---@type Item
gItemInfoLUT["block"] = {
    behaviorId = id_bhvPushableMetalBox,
    itemId = ITEM_ID_BLOCK,
    model = E_MODEL_COLOR_BOX,
    paramsLUT = {
        ["nocol"] = BLOCK_SURFACE_ID_NO_COLLISION,
        ["default"] = BLOCK_SURFACE_ID_DEFAULT,
        ["none"] = BLOCK_SURFACE_ID_DEFAULT,
        ["lava"] = BLOCK_SURFACE_ID_LAVA,
        ["quicksand"] = BLOCK_SURFACE_ID_QUICKSAND,
        ["slippery"] = BLOCK_SURFACE_ID_SLIPPERY,
        ["very slippery"] = BLOCK_SURFACE_ID_VERY_SLIPPERY,
        ["not slippery"] = BLOCK_SURFACE_ID_NOT_SLIPPERY,
        ["hangable"] = BLOCK_SURFACE_ID_HANGABLE,
        ["shallowsand"] = BLOCK_SURFACE_ID_SHALLOWSAND,
        ["death"] = BLOCK_SURFACE_ID_DEATH,
        ["vanish"] = BLOCK_SURFACE_ID_VANISH,
        ["checkpoint"] = BLOCK_SURFACE_ID_CHECKPOINT,
        ["bounce"] = BLOCK_SURFACE_ID_BOUNCE,
        ["firsty"] = BLOCK_SURFACE_ID_FIRSTY,
        ["widekick"] = BLOCK_SURFACE_ID_WIDE_WALLKICK,
        ["booster"] = BLOCK_SURFACE_ID_BOOSTER,
        ["heal"] = BLOCK_SURFACE_ID_HEAL,
        ["jumpless"] = BLOCK_SURFACE_ID_NO_A,
        ["anykick"] = BLOCK_SURFACE_ID_ANY_BONK_WALLKICK,
        ["nofall"] = BLOCK_SURFACE_ID_NO_FALL_DAMAGE,
        ["conveyor"] = BLOCK_SURFACE_ID_CONVEYOR,
        ["breakable"] = BLOCK_SURFACE_ID_BREAKABLE,
        ["disappearing"] = BLOCK_SURFACE_ID_DISAPPEARING,
        ["shrinking"] = BLOCK_SURFACE_ID_DISAPPEARING,
        ["capless"] = BLOCK_SURFACE_ID_REMOVE_CAPS,
        ["wallkickless"] = BLOCK_SURFACE_ID_NO_WALLKICKS,
        ["dash panel"] = BLOCK_SURFACE_ID_DASH_PANEL,
        ["toxic"] = BLOCK_SURFACE_ID_TOXIC_GAS,
        ["jump pad"] = BLOCK_SURFACE_ID_JUMP_PAD
    },
    animLUT = {
        ["red"] =     NEW_COLOR_ID * 0,
        ["orange"] =  NEW_COLOR_ID * 1,
        ["yellow"] =  NEW_COLOR_ID * 2,
        ["green"] =   NEW_COLOR_ID * 3,
        ["lime"] =    NEW_COLOR_ID * 4,
        ["cyan"] =    NEW_COLOR_ID * 5,
        ["teal"] =    NEW_COLOR_ID * 6,
        ["blue"] =    NEW_COLOR_ID * 7,
        ["purple"] =  NEW_COLOR_ID * 8,
        ["magenta"] = NEW_COLOR_ID * 9,
        ["pink"] =    NEW_COLOR_ID * 10,
        ["brown"] =   NEW_COLOR_ID * 11,
        ["skin"] =    NEW_COLOR_ID * 12,
        ["black"] =   NEW_COLOR_ID * 13,
        ["grey"] =    NEW_COLOR_ID * 14,
        ["white"] =   NEW_COLOR_ID * 15,
    },
    paramsForceAnim = {},
    paramsSuccessMessage = "Surface type has been set: ",
    paramsErrorMessage = "Enter a valid surface type: ",
    animSuccessMessage = "Block color has been set: ",
    animErrorMessage = "Enter a valid color: "
}

local surface_message = "["
for name in pairs(gItemInfoLUT["block"].paramsLUT) do
    surface_message = surface_message .. name .. "|"
end
surface_message = surface_message:sub(1, -2) .. "]"
gItemInfoLUT["block"].paramsErrorMessage = "Enter a valid surface type: " .. surface_message

local colors_message = "["
for name in pairs(gItemInfoLUT["block"].animLUT) do
    colors_message = colors_message .. name .. "|"
end
colors_message = colors_message .. "transparent|invisible|shaded]"
gItemInfoLUT["block"].animErrorMessage = "Enter a valid color: " .. colors_message

--- Ran from bhvPushableMetalBox.bhv

--- @param obj Object
function bhv_custom_pushable_metal_box_init(obj)
    local surface_id = obj.oBehParams & 0xFF
    ---@type Pointer_Collision?
    local collision = gCollisionTypes[surface_id] or (sSpecialOverrideNormalSurface[surface_id] or COL_CUSTOM_BOX_DEFAULT)
    if collision == 0 then
        collision = nil
    end
    obj.collisionData = collision --[[@as Pointer_Collision]]
    obj.header.gfx.skipInViewCheck = true
    obj_scale_xyz(obj, obj.oScaleX, obj.oScaleY, obj.oScaleZ)
    obj_set_model_extended(obj, E_MODEL_COLOR_BOX)
    obj.oBackupAnimState = obj.oAnimState

    network_init_object(obj, true, {})
end

--- @param obj Object
function bhv_custom_pushable_metal_box_loop(obj)
    obj.oAnimState = obj.oBackupAnimState
    if obj.oAnimState == BLOCK_INVISIBLE_STATE then
        obj_set_model_extended(obj, gMarioStates[0].action == ACT_FREE_MOVE and E_MODEL_OUTLINE or E_MODEL_NONE)
    end
end

------------------------------------------------------------------------------------------------------
------------------------------------------ Exclamtion boxes ------------------------------------------
------------------------------------------------------------------------------------------------------

---@type Item
gItemInfoLUT["exclamation"] = {
    behaviorId = id_bhvExclamationBox,
    itemId = ITEM_ID_EXCLAMATION,
    model = E_MODEL_EXCLAMATION_BOX,
    paramsLUT = {
        ["empty"] = 0,
        ["wing"] = 1,
        ["metal"] = 2,
        ["vanish"] = 3,
        ["shell"] = 4
    },
    animLUT = {},
    paramsForceAnim = {
        [0] = 3,
        [1] = 0,
        [2] = 1,
        [3] = 2,
        [4] = 3,
    },
    paramsSuccessMessage = "Exclamtion box contents has been set: ",
    paramsErrorMessage = "Enter a content. Resetting to default... [empty|wing|metal|vanish|shell]",
    animSuccessMessage = "This message shouldn't appear. It appeared with message: ",
    animErrorMessage = "Exclamation boxes don't have a recolor"
}
gItemInfoLUT["exclam"] = gItemInfoLUT["exclamation"]

--[[
local sExclamationBoxHitbox = {
    interactType = INTERACT_BREAKABLE,
    downOffset = 5,
    damageOrCoinValue = 0,
    health = 1,
    numLootCoins = 0,
    radius = 40,
    height = 30,
    hurtboxRadius = 40,
    hurtboxHeight = 30
}

local sContentIdsLUT = {
    [1] = {id = id_bhvWingCap, model = E_MODEL_MARIOS_WING_CAP},
    [2] = {id = id_bhvMetalCap, model = E_MODEL_MARIOS_METAL_CAP},
    [3] = {id = id_bhvVanishCap, model = E_MODEL_MARIOS_CAP},
    [4] = {id = id_bhvKoopaShell, model = E_MODEL_KOOPA_SHELL}
}

--- @param obj Object
function bhv_minecraft_exclamation_box_init(obj)
    --obj.collisionData = gGlobalObjectCollisionData.exclamation_box_outline_seg8_collision_08025F78

    obj.areaTimerType = AREA_TIMER_TYPE_MAXIMUM
    obj.areaTimer = 0
    obj.areaTimerDuration = 300

    local content = obj.oBehParams & 0xFF
    local anim_state = content - 1
    if anim_state < 0 or anim_state > 2 then
        anim_state = 3
    end
    obj.oAnimState = anim_state

    obj_scale_xyz(obj, obj.oScaleX * 2, obj.oScaleY * 2, obj.oScaleZ * 2)
    obj_set_model_extended(obj, E_MODEL_EXCLAMATION_BOX)

    network_init_object(obj, true, {})
end

--- @param obj Object
function bhv_minecraft_exclamation_box_loop(obj)
    if obj.oAction == 0 then -- Idle
        -- Force
        if obj.oTimer > 150 then
            obj.oTimer = 0
        end

        if obj.oTimer == 0 then
            cur_obj_unhide()
            cur_obj_become_tangible()
            obj.oInteractStatus = 0
            obj.oPosY = obj.oHomeY
            obj.oGraphYOffset = 0
            lua_obj_set_hitbox(obj, sExclamationBoxHitbox)
            obj_set_model_extended(obj, E_MODEL_EXCLAMATION_BOX)
        end

        if cur_obj_was_attacked_or_ground_pounded() ~= 0 then
            cur_obj_become_intangible()
            obj.oExclamationBoxUnkFC = 0x4000
            obj.oVelY = 30
            obj.oGravity = -8
            obj.oFloorHeight = obj.oPosY
            obj.oAction = 1
            queue_rumble_data_object(obj, 5, 80)
        end
        --load_object_collision_model()
    elseif obj.oAction == 1 then -- Breaking
        cur_obj_move_using_fvel_and_gravity()
        if obj.oVelY < 0 then
            obj.oVelY = 0
            obj.oGravity = 0
        end
        obj.oExclamationBoxUnkF8 = (sins(obj.oExclamationBoxUnkFC) + 1) * 0.3 + 0.0
        obj.oExclamationBoxUnkF4 = (-sins(obj.oExclamationBoxUnkFC) + 1) * 0.5 + 1.0
        obj.oGraphYOffset = (-sins(obj.oExclamationBoxUnkFC) + 1) * 26.0
        obj.oExclamationBoxUnkFC = obj.oExclamationBoxUnkFC + 0x1000
        obj.header.gfx.scale.x = obj.oExclamationBoxUnkF4 * 2
        obj.header.gfx.scale.y = obj.oExclamationBoxUnkF8 * 2
        obj.header.gfx.scale.z = obj.oExclamationBoxUnkF4 * 2
        if obj.oTimer == 7 then
            obj.oAction = 2
            -- Reset all of the above
            obj.oExclamationBoxUnkF8 = 0
            obj.oExclamationBoxUnkF4 = 0
            obj.oGraphYOffset = 0
            obj.oExclamationBoxUnkFC = 0
            obj.header.gfx.scale.x = obj.oScaleX * 2
            obj.header.gfx.scale.y = obj.oScaleY * 2
            obj.header.gfx.scale.z = obj.oScaleZ * 2
        end
    elseif obj.oAction == 2 then -- Broken
        spawn_mist_particles_variable(0, 0, 46)
        spawn_triangle_break_particles(20, 139, 0.3, obj.oAnimState)
        play_sound(SOUND_GENERAL_BREAK_BOX, obj.header.gfx.cameraToObject)
        cur_obj_hide()

        ---@type integer
        local content = obj.oBehParams & 0xFF
        if sContentIdsLUT[content] then
            local id = sContentIdsLUT[content].id
            local model = sContentIdsLUT[content].model
            ---@type MarioState
            local m = gMarioStates[0]
            local replace_model = {
                [E_MODEL_MARIOS_CAP] =               m.character.capModelId,
                [E_MODEL_MARIOS_METAL_CAP] =         m.character.capMetalModelId,
                [E_MODEL_MARIOS_WING_CAP] =          m.character.capWingModelId,
                [E_MODEL_MARIOS_WINGED_METAL_CAP] =  m.character.capMetalWingModelId
            }
            local new_model = replace_model[model] or model
            local spawned = spawn_non_sync_object(id, new_model, obj.oPosX, obj.oPosY, obj.oPosZ, function () end)
            if spawned then
                spawned.oVelY = 20
                spawned.oForwardVel = 3
                spawned.oMoveAngleYaw = m.marioObj.oMoveAngleYaw
            end
        end

        obj.oAction = 3
    elseif obj.oAction == 3 then -- Respawning
        if obj.oTimer > 150 then
            obj.oAction = 0
        end
    end
end
]]

local sContentIdsTo2ndByte = {
    [0] = 255,
    [1] = 0,
    [2] = 1,
    [3] = 2,
    [4] = 3
}

---@param obj Object
function bhv_exclamation_box_inject_pre_loop(obj)
    local content = sContentIdsTo2ndByte[obj.oBehParams & 0xFF]
    if content then
        obj.oBehParams2ndByte = content
    end
    obj_set_model_extended(obj, E_MODEL_EXCLAMATION_BOX)
end

---@param obj Object
function bhv_exclamation_box_inject_post_loop(obj)
    if obj.oAction == 6 then
        obj.oAction = 5
    end
    if obj.oAction == 5 and obj.oTimer < 150 then
        obj.oTimer = 150
    end
end

--id_bhvExclamationBox = hook_behavior(id_bhvExclamationBox, OBJ_LIST_SURFACE, false, bhv_exclamation_box_inject_pre_loop, bhv_exclamation_box_inject_post_loop, "bhvExclamationBox")

-- Technically part of exclamation boxes

---@param obj Object
local function koopa_shell_inject_loop(obj)
    if obj.oAction == 0 and obj.oTimer > 300 then
        obj_mark_for_deletion(obj)
    end
end

id_bhvKoopaShell = hook_behavior(id_bhvKoopaShell, OBJ_LIST_LEVEL, false, nil, koopa_shell_inject_loop, "bhvKoopaShell")

-------------------------------------------------------------------------------------------
------------------------------------------ Stars ------------------------------------------
-------------------------------------------------------------------------------------------

gServerSettings.stayInLevelAfterStar = 1 -- Just in case

local sCollectStarHitbox = {
    interactType      = INTERACT_STAR_OR_KEY,
    downOffset        = 0,
    damageOrCoinValue = 0,
    health            = 0,
    numLootCoins      = 0,
    radius            = 80,
    height            = 50,
    hurtboxRadius     = 0,
    hurtboxHeight     = 0,
}

---@type Item
gItemInfoLUT["star"] = {
    behaviorId = id_bhvStar,
    itemId = ITEM_ID_STAR,
    model = E_MODEL_STAR,
    paramsLUT = {
        ["real"] = (1 << 0),
        ["fake"] = (1 << 1)
    },
    animLUT = {},
    paramsForceAnim = {},
    paramsSuccessMessage = "Star property has now been set: ",
    paramsErrorMessage = "Enter a property: [real|fake]",
    animSuccessMessage = "This message shouldn't appear. It appeared with message: ",
    animErrorMessage = "Stars don't have a recolor",
}

--- Ran from bhvStar.bhv

---@param obj Object
function bhv_custom_collect_star_init(obj)
    obj.header.gfx.skipInViewCheck = true
    obj_scale_xyz(obj, obj.oScaleX, obj.oScaleY, obj.oScaleZ)
    obj.oAnimState = 0

    lua_obj_set_hitbox(obj, sCollectStarHitbox)
    obj_set_model_extended(obj, E_MODEL_STAR)
    network_init_object(obj, true, {})
end

---@param obj Object
function bhv_custom_collect_star_loop(obj)
    obj.oFaceAngleYaw = obj.oFaceAngleYaw & 0xFFFF
end

---@param m MarioState
---@param obj Object
hook_event(HOOK_ALLOW_INTERACT, function (m, obj)
    if m.playerIndex ~= 0 then return end

    if obj_has_behavior_id(obj, id_bhvStar) ~= 0 and obj.oBehParams & (1 << 1) ~= 0 then
        hurt_and_set_mario_action(m, ACT_HARD_BACKWARD_AIR_KB, 0, 36)
        return false
    end
end)

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

gItems = {
    [gItemInfoLUT["block"].behaviorId] = true,
    [gItemInfoLUT["exclamation"].behaviorId] = true,
    [gItemInfoLUT["star"].behaviorId] = true,
}

gIdToItem = {
    [0] = gItemInfoLUT["block"],
    [1] = gItemInfoLUT["block"],
    [2] = gItemInfoLUT["exclamation"],
    [3] = gItemInfoLUT["star"]
}

---@type Item
gCurrentItem = gItemInfoLUT["block"]