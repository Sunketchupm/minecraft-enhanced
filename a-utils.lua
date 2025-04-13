-- localize functions to improve performance
local table_insert = table.insert

itemAnimState = 0
blockColorVariant = 0
---@type Vec3f
itemScale = {x = 1, y = 1, z = 1}
itemParams = 1
itemAllowDeletion = true

---@type Vec3f
gridSize = {x = 200, y = 200, z = 200}
gridEnabled = true

isTransparent = false
isShaded = true
isInvisible = false

--- @param m MarioState
--- @param buttons integer
--- Disable certain inputs on a Mario's controller
function disable_inputs(m, buttons)
    m.controller.buttonPressed = m.controller.buttonPressed & ~buttons
end

--- @param value integer
--- Emulates a signed 16 bit integer in Lua
function s16(value)
    if value > 32767 then
        value = value - 65536
    elseif value < -32768 then
        value = value + 65536
    end
    return value
end

--- @param x number
--- Converts standard degrees to SM64 degrees
function degrees(x)
    return x * 0x10000 / 360
end

--- @param s string
--- @param delimiter string
--- @return table
--- Splits a string into a table
function split_string(s, delimiter)
    local result = {}
    for match in (s):gmatch(("[^%s]+"):format(delimiter)) do
        table_insert(result, match)
    end
    return result
end

---@param obj Object
---@return Object?
function obj_get_nearest_item(obj)
    local nearest_dist = 0xFFFFFFFF
    local nearest_item = nil
    for behaviorId in pairs(gItems) do
        local candidate = obj_get_nearest_object_with_behavior_id(obj, behaviorId)
        if candidate then
            local dist = dist_between_objects(obj, candidate)
            if dist_between_objects(obj, candidate) <= nearest_dist then
                nearest_dist = dist
                nearest_item = candidate
            end
        end
    end
    return nearest_item
end

---@param obj Object
function is_item_too_close(obj)
    if not obj then return false end
    ---@type Object?
    local nearest = obj_get_nearest_item(obj)

    if nearest then
        ---@type Vec3f
        local dist = {x = math.abs(obj.oPosX - nearest.oPosX), y = math.abs(obj.oPosY - nearest.oPosY), z = math.abs(obj.oPosZ - nearest.oPosZ)}
        return not ((dist.x >= gridSize.x - 5 * itemScale.x) or (dist.y >= gridSize.y - 5 * itemScale.y) or (dist.z >= gridSize.z - 5 * itemScale.z))
    end
    return false
end

function obj_get_total_count()
    local all_objects_count = 0
    ---@type ObjectList
    for i = OBJ_LIST_PLAYER, NUM_OBJ_LISTS, 1 do -- All object lists
        local obj = obj_get_first(i)
        while obj do
            all_objects_count = all_objects_count + 1
            obj = obj_get_next(obj)
        end
    end
    return all_objects_count
end

local obj_get_first_with_behavior_id, obj_get_next_with_same_behavior_id = obj_get_first_with_behavior_id, obj_get_next_with_same_behavior_id

local function iterate(id, obj)
    if not obj then
        obj = obj_get_first_with_behavior_id(id)
    else
        obj = obj_get_next_with_same_behavior_id(obj)
    end
    return obj
end

---@param behavior_id BehaviorId
--- This is an iterator function, so use it in a `for` loop
function obj_get_all_with_behavior_id(behavior_id)
    return iterate, behavior_id, nil
end

---@class Object
---@field oScaleX number
---@field oScaleY number
---@field oScaleZ number
---@field oBackupAnimState integer
---@field oItemId integer
---@field oSignalItem integer

define_custom_obj_fields({
    oScaleX = "f32",
    oScaleY = "f32",
    oScaleZ = "f32",
    oBackupAnimState = "s32",
    oItemId = "u32",
})

_G.MinecraftEnhanced = {
    version = "0.7"
}