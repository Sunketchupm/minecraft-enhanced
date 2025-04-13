---@param val number
---@param min number
---@param max number
---@return number
function lua_clamp(val, min, max)
    if val > max then return max end
    if val < min then return min end
    return val
end

---@param obj Object
function lua_create_sound_spawner(obj)
    local sound = spawn_non_sync_object(id_bhvSoundSpawner, E_MODEL_NONE, 0, 0, 0, nil)
    if not sound then return end
    obj_copy_pos_and_angle(sound, obj)
    sound.oSoundEffectUnkF4 = SOUND_GENERAL_BREAK_BOX
end

--- @param obj Object
--- @param hitbox ObjectHitbox
function lua_obj_set_hitbox(obj, hitbox)
    if not obj or not hitbox then return end
    if (obj.oFlags & OBJ_FLAG_30) == 0 then
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