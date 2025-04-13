-- name: Minecraft Enhanced [WIP]
-- description: This is a heavily modified version of the original Minecraft mod created by zKevin.\n\nMinecraft Enhanced contains: \nNew Colors and Variants\nDifferent Surface Types\nBlock Rotation\n\n\\#7B00FF\\Credits:\n\\#DBDBDB\\Color implementation by \\#B1B9FF\\sherbie \\#DBDBDB\\and \\#FFF000\\janKali\n\\#DBDBDB\\Surface types and block rotation by \\#FF9EB6\\Sunk\n\\#DBDBDB\\Optimizations by \\#FFF000\\janKali\n\\#DBDBDB\\Playtesting and Pop-Up Message by \\#B1B9FF\\sherbie\n\n\\#DBDBDB\\Minecraft mod created by zKevin

-- localize functions to improve performance
local obj_get_first,obj_has_behavior_id,obj_mark_for_deletion,obj_get_next,math_floor,obj_get_nearest_object_with_behavior_id,play_sound,spawn_sync_object,djui_chat_message_create,max,math_max,obj_get_first_with_behavior_id,spawn_non_sync_object,obj_copy_pos_and_angle,camera_romhack_allow_centering,camera_romhack_allow_dpad_usage,is_game_paused,drop_and_set_mario_action,mario_set_forward_vel,min,math_min,network_is_moderator,network_is_server,tonumber,obj_count_objects_with_behavior_id,network_global_index_from_local,network_local_index_from_global,network_player_from_global_index,obj_get_next_with_same_behavior_id
    = obj_get_first,obj_has_behavior_id,obj_mark_for_deletion,obj_get_next,math.floor,obj_get_nearest_object_with_behavior_id,play_sound,spawn_sync_object,djui_chat_message_create,max,math.max,obj_get_first_with_behavior_id,spawn_non_sync_object,obj_copy_pos_and_angle,camera_romhack_allow_centering,camera_romhack_allow_dpad_usage,is_game_paused,drop_and_set_mario_action,mario_set_forward_vel,min,math.min,network_is_moderator,network_is_server,tonumber,obj_count_objects_with_behavior_id,network_global_index_from_local,network_local_index_from_global,network_player_from_global_index,obj_get_next_with_same_behavior_id

gLevelValues.fixCollisionBugs = true
gLevelValues.fixCollisionBugsFalseLedgeGrab = false
gLevelValues.fixCollisionBugsGroundPoundBonks = false
gLevelValues.fixVanishFloors = true

allowBuild = true

local setYaw = 0
local setPitch = 0

---------------------------------------------------------------------------------------------------------

---@type Object?
local itemOutline = nil
---@type Object?
local outlineLines = nil

---@param obj Object
local function bhv_placement_outline_init(obj)
    obj.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj.oOpacity = 255
    obj.oFaceAnglePitch = 0
    obj.oFaceAngleYaw = 0
    obj.oFaceAngleRoll = 0
    obj_scale_xyz(obj, itemScale.x, itemScale.y, itemScale.z)
end

local id_bhvOutlineBlock = hook_behavior(nil, OBJ_LIST_DEFAULT, true, bhv_placement_outline_init, nil)
local id_bhvOutlineLines = hook_behavior(nil, OBJ_LIST_DEFAULT, true, bhv_placement_outline_init, nil)

---------------------------------------------------------------------------------------------------------

local function remove_objects_exclude_items()
    ---@type ObjectList
    for i = OBJ_LIST_PLAYER + 1, NUM_OBJ_LISTS, 1 do -- All object lists
        local obj = obj_get_first(i)
        while obj do
            if obj_has_behavior_id(obj, id_bhvSpinAirborneWarp) == 0 and obj ~= itemOutline and not gItems[get_id_from_behavior(obj.behavior)] then
                obj_mark_for_deletion(obj)
            end
            obj = obj_get_next(obj)
        end
    end
end

local function remove_items(all, localIndex)
    for itemBhvId in pairs(gItems) do -- All object lists
        local obj = obj_get_first_with_behavior_id(itemBhvId)
        while obj do
            if obj_has_behavior_id(obj, id_bhvSpinAirborneWarp) == 0 and obj ~= itemOutline and
                ((obj.globalPlayerIndex == gNetworkPlayers[localIndex].globalIndex) or all) then
                obj_mark_for_deletion(obj)
            end
            obj = obj_get_next(obj)
        end
    end
end

local item_limits = {
    [gItemInfoLUT["block"].behaviorId] = OBJECT_POOL_CAPACITY,
    [gItemInfoLUT["exclamation"].behaviorId] = 10,
    [gItemInfoLUT["star"].behaviorId] = 10
}

local function is_item_reached_limit(behaviorId)
    return obj_count_objects_with_behavior_id(behaviorId) >= item_limits[behaviorId]
end

----------------------------------------------------

---@param pos number
---@return integer
local function to_grid_x(pos)
    return gridEnabled and
        math_floor(pos/gridSize.x + 0.5) * gridSize.x
        or pos
end

---@param pos number
---@return integer
local function to_grid_y(pos)
    return gridEnabled and
        math_floor(pos/gridSize.y + 0.5) * gridSize.y
        or pos
end

---@param pos number
---@return integer
local function to_grid_z(pos)
    return gridEnabled and
        math_floor(pos/gridSize.z + 0.5) * gridSize.z
        or pos
end

---@param m MarioState
local function spawn_item(m)
    if not itemOutline then return end

    if itemAllowDeletion and is_item_too_close(itemOutline) then
        local nearest = obj_get_nearest_item(itemOutline)
        if nearest then
            obj_mark_for_deletion(nearest)
            play_sound(SOUND_GENERAL_BOX_LANDING, m.marioObj.header.gfx.cameraToObject)
        else
            play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
            djui_chat_message_create("\\#ffa0a0\\Failed to delete item.")
        end
        return
    end

    if is_item_reached_limit(gCurrentItem.behaviorId) then
        play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
        djui_chat_message_create("\\#ffa0a0\\Failed to spawn item. The item limit for this item in this area has been reached.")
        return
    end

    local spawnPos = {x = itemOutline.oPosX, y = itemOutline.oPosY, z = itemOutline.oPosZ}
    if spawnPos.x > 32767 or spawnPos.x < -32768 or spawnPos.z > 32767 or spawnPos.z < -32768 then
        djui_chat_message_create("WARNING: Outside normal level boundaries! Blocks may be unstable.")
    end

    local item = spawn_sync_object(
        gCurrentItem.behaviorId,
        gCurrentItem.model,
        spawnPos.x, spawnPos.y, spawnPos.z,
        ---@param obj Object
        function (obj)
            obj.oOpacity = 255
            obj.oFaceAngleYaw = setYaw
            obj.oFaceAnglePitch = setPitch
            obj.oFaceAngleRoll = 0
            obj.oScaleX = itemScale.x
            obj.oScaleY = itemScale.y
            obj.oScaleZ = itemScale.z
            obj.globalPlayerIndex = gNetworkPlayers[0].globalIndex

            if gCurrentItem.itemId == ITEM_ID_BLOCK then
                if isInvisible then
                    obj.oAnimState = BLOCK_INVISIBLE_STATE
                else
                    local extra = isTransparent and BLOCK_START_TRANSPARENT_STATES or 0
                    extra = extra + ((not isShaded) and BLOCK_START_UNSHADED_STATES or 0)
                    obj.oAnimState = itemAnimState + blockColorVariant + extra
                end
            else
                obj.oAnimState = itemAnimState
            end

            obj.oBehParams = obj.oBehParams | itemParams
            obj.oItemId = gCurrentItem.itemId
        end)

    if item then
        play_sound(SOUND_GENERAL_BOX_LANDING, m.marioObj.header.gfx.cameraToObject)
    else
        play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
        djui_chat_message_create("\\#ffa0a0\\Failed to spawn item. The object limit may have been reached.")
    end
end

local posSwap = 1
--- @param m MarioState
--- @return number
local function get_grid_position_y(m)
    if (m.controller.buttonPressed & X_BUTTON) ~= 0 and (m.controller.buttonDown & L_TRIG) == 0 then
        posSwap = (posSwap + 1) % 3
    end

    return (m.pos.y + 60) + gridSize.y * (posSwap - 1)
end

local seeOutline = true
---@param m MarioState
local function update_outline_block(m)
    local distX = sins(m.intendedYaw)
    local distZ = coss(m.intendedYaw)

    local outlinePosX = to_grid_x(m.pos.x + distX * math_max(gridSize.x, 200))
    local outlinePosY = to_grid_y(get_grid_position_y(m))
    local outlinePosZ = to_grid_z(m.pos.z + distZ * math_max(gridSize.z, 200))

    itemOutline = obj_get_first_with_behavior_id(id_bhvOutlineBlock)
    if not itemOutline then
        itemOutline = spawn_non_sync_object(
            id_bhvOutlineBlock,
            (seeOutline and gCurrentItem.model or E_MODEL_NONE),
            outlinePosX, outlinePosY, outlinePosZ,
            function () end
        )
    else
        itemOutline.oPosX = outlinePosX + 1.5
        itemOutline.oPosY = outlinePosY - 6.5
        itemOutline.oPosZ = outlinePosZ + 1.5
        obj_set_model_extended(itemOutline, gCurrentItem.model)
        local newAnimState = itemAnimState
        if gCurrentItem.itemId == ITEM_ID_BLOCK then
            newAnimState = itemAnimState + blockColorVariant + BLOCK_START_TRANSPARENT_STATES
            if isInvisible then
                obj_set_model_extended(itemOutline, E_MODEL_NONE)
            end
        end
        itemOutline.oAnimState = newAnimState
        if itemOutline.oAnimState > MAX_ANIM_STATES then
            itemOutline.oAnimState = MAX_ANIM_STATES
        end
        itemOutline.oFaceAngleYaw = setYaw
        itemOutline.oFaceAnglePitch = setPitch
        obj_scale_xyz(itemOutline, itemScale.x, itemScale.y, itemScale.z)

        outlineLines = obj_get_first_with_behavior_id(id_bhvOutlineLines)
        if not outlineLines then
            outlineLines = spawn_non_sync_object(
                id_bhvOutlineLines,
                (seeOutline and E_MODEL_OUTLINE or E_MODEL_NONE), 0, 0, 0,
                ---@param obj Object
                function(obj)
                obj.parentObj = itemOutline
            end)
        else
            obj_copy_pos_and_angle(outlineLines, itemOutline)
            obj_scale_xyz(outlineLines, itemScale.x, itemScale.y, itemScale.z)
        end
    end
end

--- @param m MarioState
local function set_color_variant(m)
    if (m.controller.buttonDown & L_JPAD) ~= 0 then return end

    if (m.controller.buttonPressed & U_JPAD) ~= 0 and blockColorVariant < 8 then
        if blockColorVariant == 0 then
            blockColorVariant = 5
        elseif blockColorVariant < 5 then
            blockColorVariant = blockColorVariant - 1
        else
            blockColorVariant = blockColorVariant + 1
        end
    elseif (m.controller.buttonPressed & D_JPAD) ~= 0 then
        if blockColorVariant == 0 then
            blockColorVariant = 1
        elseif blockColorVariant == 5 then
            blockColorVariant = 0
        elseif blockColorVariant < 4 then
            blockColorVariant = blockColorVariant + 1
        elseif blockColorVariant > 5 then
            blockColorVariant = blockColorVariant - 1
        end
    end
end

local function spawn_angle_indicator()
    if not itemOutline then return end

    spawn_non_sync_object(
        id_bhvSparkle,
        E_MODEL_SPARKLES_ANIMATION,
        itemOutline.oPosX + sins(itemOutline.oFaceAngleYaw) * 100 * itemScale.x,
        itemOutline.oPosY - 1 * itemScale.y,
        itemOutline.oPosZ + coss(itemOutline.oFaceAngleYaw) * 100 * itemScale.z,
        --- @param obj Object
        function(obj)
            obj_scale(obj, 0.3)
        end
    )

    spawn_non_sync_object(
        id_bhvSparkle,
        E_MODEL_SPARKLES_ANIMATION,
        itemOutline.oPosX,
        itemOutline.oPosY + sins(itemOutline.oFaceAnglePitch) * 100 * itemScale.y,
        itemOutline.oPosZ,
        --- @param obj Object
        function(obj)
            obj_scale(obj, 0.3)
        end
    )
end

----------------------------------------------------

local angleAdjustment = degrees(15)

--- @param m MarioState
local function set_block_angles(m)
    if (m.controller.buttonPressed & L_CBUTTONS) ~= 0 then
        setYaw = s16(setYaw - angleAdjustment)
    elseif (m.controller.buttonPressed & R_CBUTTONS) ~= 0 then
        setYaw = s16(setYaw + angleAdjustment)
    end
    if (m.controller.buttonPressed & U_CBUTTONS) ~= 0 then
        setPitch = s16(setPitch - angleAdjustment)
    elseif (m.controller.buttonPressed & D_CBUTTONS) ~= 0 then
        setPitch = s16(setPitch + angleAdjustment)
    end

    if (m.controller.buttonPressed & X_BUTTON) ~= 0 then
        setYaw = 0
        setPitch = 0
    end
    camera_romhack_allow_centering(0)
end

---------------------------------------------------------------------------------------------------------

local continueSpawnBlock = false
local continueSpawnBlockDelete = false
local continueSpawnTimer = 5
---@param m MarioState
local function builder_mode_update(m)
    update_outline_block(m)

    camera_romhack_allow_dpad_usage(0)
    if is_game_paused() or menuOpen then return end
    if not itemOutline then return end

    if (m.controller.buttonPressed & Y_BUTTON) ~= 0 then
        spawn_item(m)
        if continueSpawnBlock then
            -- Flipping the output is desired here since a block was already placed/deleted
            -- and that placement/deletion will be detected in the next conditional
            continueSpawnBlockDelete = not is_item_too_close(itemOutline)
        end
    end

    if continueSpawnBlock and (m.controller.buttonDown & Y_BUTTON) ~= 0 then
        continueSpawnTimer = continueSpawnTimer - 1
        if continueSpawnTimer <= 0 then
            if continueSpawnBlockDelete and is_item_too_close(itemOutline) then
                spawn_item(m)
            elseif not continueSpawnBlockDelete and not is_item_too_close(itemOutline) then
                spawn_item(m)
            end
            continueSpawnTimer = 5
        end
    end

    if (m.controller.buttonDown & L_TRIG) ~= 0 then
        spawn_angle_indicator()
    end

    if gCurrentItem.itemId == gItemInfoLUT["block"].itemId then
        set_color_variant(m)
    else
        blockColorVariant = 0
    end
end

---@param m MarioState
local function builder_mode_before_update(m)
    if is_game_paused() or menuOpen then return end

    if (m.controller.buttonPressed & L_TRIG) ~= 0 then
        savedMarioYaw = m.faceAngle.y
    end
    if (m.controller.buttonDown & L_TRIG) ~= 0 then
        set_block_angles(m)
        disable_inputs(m, (L_CBUTTONS | R_CBUTTONS | U_CBUTTONS | D_CBUTTONS | X_BUTTON))
    end
end

----------------------------------------------------

local isInActFreeMove = false
local lPressTimer = 10

---@param m MarioState
local function check_enable_flying(m)
    if is_game_paused() or menuOpen or welcomeMsgIsOpen then return end

    -- Fly by double pressing L
    if lPressTimer > 0 and (m.controller.buttonPressed & L_TRIG) ~= 0 then
        isInActFreeMove = true
        drop_and_set_mario_action(m, m.action ~= ACT_FREE_MOVE and ACT_FREE_MOVE or ACT_FREEFALL, 0)
        mario_set_forward_vel(m, math.min(32, m.forwardVel))
        m.vel.y = 0
        isInActFreeMove = false
    end
    if (m.controller.buttonPressed & L_TRIG) ~= 0 then
        lPressTimer = 10
    end
    if lPressTimer > 0 then
        lPressTimer = lPressTimer - 1
    end

    if isInActFreeMove then
        drop_and_set_mario_action(m, ACT_FREE_MOVE, 0)
    end
end

---------------------------------------------------------------------------------------------------------

local forceBuilderMode = false
---@param m MarioState
local function mario_update(m)
    if m.playerIndex ~= 0 then return end

    if allowBuild then
        if m.action == ACT_FREE_MOVE or forceBuilderMode then
            builder_mode_update(m)
        else
            obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvOutlineBlock))
            obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvOutlineLines))
        end
    end

    if network_is_server() or network_is_moderator() then
        allowBuild = true
    end

    check_enable_flying(m)
end

---@param m MarioState
local function before_mario_update(m)
    if m.playerIndex ~= 0 then return end

    if m.action == ACT_FREE_MOVE then
        builder_mode_before_update(m)
    else
        camera_romhack_allow_dpad_usage(1)
    end
end

--- @param m MarioState
--- @param incomingAction integer
--- @return integer?
local function before_set_mario_action(m, incomingAction)
    if m.playerIndex ~= 0 then return end

    if incomingAction == ACT_SQUISHED then
        m.pos.y = m.pos.y + 1
        return m.action == ACT_FREE_MOVE and ACT_FREE_MOVE or ACT_FREEFALL
    end
end

local function on_warp()
    if itemOutline then
        obj_mark_for_deletion(itemOutline)
    end
end

---@param m MarioState
local function allow_hazard_surface(m)
    if m.playerIndex ~= 0 then return end
    return m.action ~= ACT_FREE_MOVE
end

hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, before_set_mario_action)
hook_event(HOOK_ON_WARP, on_warp)
hook_event(HOOK_ALLOW_HAZARD_SURFACE, allow_hazard_surface)

---------------------------------------------------------------------------------------------------------

local sBlockSpecialCommands = {
    ["transparent"] = {
        action = function () isTransparent = not isTransparent return isTransparent end,
        enabledMessage = "Blocks are now transparent. Use this command again to turn off transparency.",
        disabledMessage = "Blocks are no longer transparent."
    },
    ["shade"] = {
        action = function () isShaded = not isShaded return isShaded end,
        enabledMessage = "Blocks are shaded. Use this command again to turn off shading.",
        disabledMessage = "Blocks are no longer shaded."
    },
    ["invisible"] = {
        action = function () isInvisible = not isInvisible return isInvisible end,
        enabledMessage = "Blocks are now invisible. Use this command again to make them visible.",
        disabledMessage = "Blocks are no longer invisible."
    }
}

---@param msg string
local function swapblock_command(msg)
    local commands = split_string(msg, " ")

    if commands[1] then
        if gCurrentItem.itemId == gItemInfoLUT["block"].itemId and sBlockSpecialCommands[commands[1]] then
            local block_commands = sBlockSpecialCommands[commands[1]]
            local condition = block_commands.action()
            djui_chat_message_create(condition and block_commands.enabledMessage or block_commands.disabledMessage)
        else
            ---@type integer
            local animState = gCurrentItem.animLUT[commands[1]]
            if animState then
                itemAnimState = animState
                blockColorVariant = 0
                djui_chat_message_create(gCurrentItem.animSuccessMessage .. msg)
            else
                djui_chat_message_create(gCurrentItem.animErrorMessage)
            end
        end
    else
        djui_chat_message_create(gCurrentItem.animErrorMessage)
    end
    return true
end

---@param msg string
local function set_surface_type_chat_command(msg)
    if gCurrentItem.paramsLUT[msg] then
        itemParams = gCurrentItem.paramsLUT[msg]
        itemAnimState = gCurrentItem.paramsForceAnim[itemParams] or itemAnimState
        djui_chat_message_create(gCurrentItem.paramsSuccessMessage .. msg)
    else
        djui_chat_message_create(gCurrentItem.paramsErrorMessage)
    end
    return true
end

local function set_outline_angle_chat_command(msg)
    if tonumber(msg) then
        setYaw = s16(degrees(msg))
    else
        djui_chat_message_create("Invalid argument: Expecting a number between 0 to 360.")
    end
    return true
end

---@param msg string
local function set_block_place_angle_chat_command(msg)
    angleAdjustment = s16(degrees(tonumber(msg) or 15))
    djui_chat_message_create("Angle increment has been set.")
    return true
end

---@param msg string
local function set_grid_size_chat_command(msg)
    local args = split_string(msg, " ")
    if #args == 3 then
        local x = lua_clamp(tonumber(args[1]) or 1, 0.01, 10)
        local y = lua_clamp(tonumber(args[2]) or 1, 0.01, 10)
        local z = lua_clamp(tonumber(args[3]) or 1, 0.01, 10)

        gridSize.x = x * 200
        gridSize.y = y * 200
        gridSize.z = z * 200
        djui_chat_message_create(("Grid size set to X: %.2f, Y: %.2f, Z: %.2f"):format(x, y, z))
    elseif args[1] then
        if tonumber(args[1]) then
            local scale = lua_clamp(tonumber(args[1]) or 1, 0.01, 10)
            gridSize.x = scale * 200
            gridSize.y = scale * 200
            gridSize.z = scale * 200

            djui_chat_message_create("Grid size set to " .. scale .. ".")
        else
            local toggle = args[1]:lower()
            if toggle == "off" then
                gridEnabled = false
                djui_chat_message_create("The grid has now been disabled")
            elseif toggle == "on" then
                gridEnabled = true
                gridSize.x = itemScale.x * 200
                gridSize.y = itemScale.y * 200
                gridSize.z = itemScale.z * 200
                djui_chat_message_create("The grid has now been enabled")
            end
        end
    else
        djui_chat_message_create("Invalid argument: No arguments passed")
    end
    return true
end

---@param msg string
local function set_block_size_chat_command(msg)
    local args = split_string(msg, " ")
    if #args == 3 then
        local x = lua_clamp(tonumber(args[1]) or 1, 0.01, 10)
        local y = lua_clamp(tonumber(args[2]) or 1, 0.01, 10)
        local z = lua_clamp(tonumber(args[3]) or 1, 0.01, 10)

        vec3f_set(itemScale, x, y, z)
        vec3f_set(gridSize, x * 200, y * 200, z * 200)
        djui_chat_message_create(("Block size set to X: %.2f, Y: %.2f, Z: %.2f"):format(x, y, z))
    elseif args[1] then
        local scale = lua_clamp(tonumber(args[1]) or 1, 0.01, 10)

        vec3f_set(itemScale, scale, scale, scale)
        vec3f_set(gridSize, scale * 200, scale * 200, scale * 200)

        djui_chat_message_create("Block size set to " .. itemScale.x .. ".")
    else
        djui_chat_message_create("Invalid argument: No arguments passed")
    end
    return true
end

local function allow_deletion_chat_command()
    itemAllowDeletion = not itemAllowDeletion
    djui_chat_message_create("" .. (itemAllowDeletion and "" or "!! WARNING !! ") .. "Item deletion has been " .. (itemAllowDeletion and "enabled." or "disabled!") .. "")
    return true
end

local function clear_own_boxes_chat_command()
    if not allowBuild then return true end
    remove_items(false, 0)
    return true
end

local function count_blocks_chat_command()
    djui_chat_message_create("Total objects in this area: " .. obj_get_total_count() .. "/1200")

    djui_chat_message_create("Blocks in this area: " .. obj_count_objects_with_behavior_id(gItemInfoLUT["block"].behaviorId) .. "/" .. item_limits[gItemInfoLUT["block"].behaviorId])
    djui_chat_message_create("Exclamation boxes in this area: " .. obj_count_objects_with_behavior_id(gItemInfoLUT["exclamation"].behaviorId) .. "/" .. item_limits[gItemInfoLUT["exclamation"].behaviorId])
    djui_chat_message_create("Stars in this area: " .. obj_count_objects_with_behavior_id(gItemInfoLUT["star"].behaviorId) .. "/" .. item_limits[gItemInfoLUT["star"].behaviorId])
    return true
end

hook_chat_command('cc', "| !! Use /tcommands to view description !!", swapblock_command)
hook_chat_command('surf', "| !! LEGACY COMMAND; USE /type !!", set_surface_type_chat_command)
hook_chat_command('type', "| !! Use /tcommands to view description !!", set_surface_type_chat_command)
hook_chat_command('snap', "| !! Use /tcommands to view description !!", set_outline_angle_chat_command)
hook_chat_command('increm', "| !! Use /tcommands to view description !!", set_block_place_angle_chat_command)
hook_chat_command('grid', "| !! Use /tcommands to view description !!", set_grid_size_chat_command)
hook_chat_command('size', "| !! Use /tcommands to view description !!", set_block_size_chat_command)
hook_chat_command('delete', "| !! Use /tcommands to view description !!", allow_deletion_chat_command)
hook_chat_command('clear', "| !! Use /tcommands to view description !!", clear_own_boxes_chat_command)
hook_chat_command('count', "| !! Use /tcommands to view description !!", count_blocks_chat_command)

local function on_see_outline_command()
    seeOutline = not seeOutline
    if itemOutline and outlineLines then
        obj_set_model_extended(itemOutline, seeOutline and E_MODEL_COLOR_BOX or E_MODEL_NONE)
        obj_set_model_extended(outlineLines, seeOutline and E_MODEL_OUTLINE or E_MODEL_NONE)
        djui_chat_message_create("The outline is " .. (seeOutline and "now" or "no longer") .. " visible.")
    else
        djui_chat_message_create("The outline block or outline lines don't exist.")
    end
    return true
end

local function on_force_build_chat_command()
    forceBuilderMode = not forceBuilderMode
    djui_chat_message_create("You are " .. (forceBuilderMode and "now" or "no longer") .. " allowed to build without flying.")
    return true
end

local function on_auto_place_or_delete_command()
    continueSpawnBlock = not continueSpawnBlock
    djui_chat_message_create("Blocks will " .. (continueSpawnBlock and "now" or "no longer") .. " continuously spawn or delete while holding Y.")
    return true
end

hook_chat_command('outline', "| Toggles the block outline. Note that items can still be built.", on_see_outline_command)
hook_chat_command('force-build', "| Allows yourself to build regardless of if you're flying or not.", on_force_build_chat_command)
hook_chat_command('autobuild', "| Toggles whether or not items will be automatically placed/deleted while holding the button that places the item.", on_auto_place_or_delete_command)

local function on_set_current_item_command(msg)
    local command = msg:lower()
    gCurrentItem = gItemInfoLUT[command]
    if not gCurrentItem then
        djui_chat_message_create("Select a valid item. Resetting to block...")
        gCurrentItem = gItemInfoLUT["block"]
    else
        djui_chat_message_create("Item has been set: " .. msg)
        itemAnimState = 0
        itemParams = 1
    end
    return true
end

hook_chat_command('item', "| [block|exclamation|star]", on_set_current_item_command)

----------------- Server commands -----------------


local function strip_colors(name)
    local string = ''
    local inSlash = false
    for i = 1, #name do
        local character = name:sub(i,i)
        if character == '\\' then
            inSlash = not inSlash
        elseif not inSlash then
            string = string .. character
        end
    end
    return string
end

local function get_global_index_from_name(player_name)
    for i = 0, MAX_PLAYERS - 1, 1 do
        if gNetworkPlayers[i].connected then
            if (strip_colors(gNetworkPlayers[i].name)):lower() == (player_name):lower() then
                i = network_global_index_from_local(i)
                return i
            end
        end
    end
    return nil
end

local function check_valid_player(msg, ptr)
    ---@type integer?
    local index = -1
    if tonumber(msg) then
        index = tonumber(msg)
    elseif msg ~= "" then
        index = get_global_index_from_name(msg)
    else
        djui_chat_message_create("Please enter a valid name/ID.")
        return false
    end

    if not index then
        djui_chat_message_create("Please enter a valid name/ID.")
        return false
    end
    if index < 0 or index > MAX_PLAYERS - 1 then
        return false
    end
    local player = gMarioStates[network_local_index_from_global(index)]
    ptr[1] = player
    return true
end

local function gbuild_chat_command(msg)
    ---@type (MarioState?)[]
    local ptr = {nil}
    if check_valid_player(msg, ptr) then
        if ptr[1].playerIndex ~= 0 then
            network_send_to(ptr[1].playerIndex, true, { gbuild = true })
        else
            allowBuild = true
        end
    end
    return true
end

local function rbuild_chat_command(msg)
    ---@type (MarioState?)[]
    local ptr = {nil}
    if check_valid_player(msg, ptr) then
        if ptr[1].playerIndex ~= 0 then
            network_send_to(ptr[1].playerIndex, true, { rbuild = true })
        else
            allowBuild = false
            obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvOutlineBlock))
            obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvOutlineLines))
        end
    end
    return true
end

local function clear_player_chat_command(msg)
    ---@type (MarioState?)[]
    local ptr = {nil}
    if check_valid_player(msg, ptr) then
        remove_items(false, ptr[1].playerIndex)
    end
    return true
end

local function clear_orphaned_chat_command()
    for itemBhvId in pairs(gItems) do
        local item = obj_get_first_with_behavior_id(itemBhvId)
        while item do
            local check_np = network_player_from_global_index(item.globalPlayerIndex)
            if not check_np or (check_np and not check_np.connected) then
                obj_mark_for_deletion(item)
            end
            item = obj_get_next_with_same_behavior_id(item)
        end
    end
    return true
end

local function clear_all_chat_command()
    remove_items(true, 0)
    return true
end

local function on_packet_recieve(datatable)
    local m = gMarioStates[0]
    if m.playerIndex ~= 0 then return end

    if datatable.gbuild then
        allowBuild = true
    end

    if datatable.rbuild then
        allowBuild = false
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvOutlineBlock))
        obj_mark_for_deletion(obj_get_first_with_behavior_id(id_bhvOutlineLines))
    end
end

hook_event(HOOK_ON_PACKET_RECEIVE, on_packet_recieve)

local function allow_same_level_save_load_chat_command()
    gGlobalSyncTable.allowSameAreaSaveLoad = not gGlobalSyncTable.allowSameAreaSaveLoad
    djui_chat_message_create((gGlobalSyncTable.allowSameAreaSaveLoad and "Players can now always use /load, even if other players are in the same area." or "Players can no longer use /load if other players are in the same area."))
    return true
end

local function set_item_limit_chat_command(msg)
    local commands = split_string(msg, " ")
        if commands[1] then
            local item_type = commands[1]
            if not commands[2] then
                djui_chat_message_create("Enter the item limit")
            elseif not tonumber(commands[2]) then
                djui_chat_message_create("Item limit must be a number")
            else
                local count = tonumber(commands[2])
                if item_limits[item_type] then
                    item_limits[item_type] = count
                    djui_chat_message_create("Item limit for " .. item_type .. " has been set to " .. count)
                else
                    djui_chat_message_create("Select a valid item to limit.")
                end
            end
        else
            djui_chat_message_create("Select a valid item to limit.")
        end
        return true
end

if network_is_server() or network_is_moderator() then
    hook_chat_command('gbuild', "| [NAME/ID] - Permits building for designated player.", gbuild_chat_command)
    hook_chat_command('rbuild', "| [NAME/ID] - Revokes building for designated player.", rbuild_chat_command)
    hook_chat_command('clearplayer', "| [NAME/ID] - Clears every block placed by a specified player", clear_player_chat_command)
    hook_chat_command('clearorphaned', "| Clears every block that is assigned to an unconnected player", clear_orphaned_chat_command)
    hook_chat_command('clearall', "| !! WARNING !! Deletes all blocks in one area!", clear_all_chat_command)
    hook_chat_command('same-area-save-load', "| Toggles whether or not players can use /load if anyone else is in the same area.", allow_same_level_save_load_chat_command)
    hook_chat_command('item-limit', "| [block|exclamation|star] [number]", set_item_limit_chat_command)
end