require("src/block/settings")

local __djui_chat_message_create = djui_chat_message_create
function djui_chat_message_create(...)
    local args = {...}
    local args_length = #args
    if args_length == 0 then
        error("`djui_chat_message_create` recieved 0 args")
        return
    end
    local str = tostring(args[1])
    for i = 1, args_length do
        if i ~= 1 then
            str = str .. ", " .. tostring(args[i])
        end
    end
    __djui_chat_message_create(tostring(str))
end

-- Converts string into a table using a delimiter
---@param s string
---@param delimiter string
---@return string[]
function string.split(s, delimiter)
    local result = {}
    for match in (s):gmatch(("[^%s]+"):format(delimiter)) do
        table.insert(result, match)
    end
    return result
end

function network_is_privileged()
    return network_is_server() or network_is_moderator()
end

---@param color DjuiColor
---@return integer
function color_table_to_integer(color)
    return (color.r << 24) | (color.g << 16) | (color.b << 8) | color.a
end

---@param color integer
---@return DjuiColor
function integer_to_color_table(color)
    return {
        r = (color >> 24) & 0xFF,
        g = (color >> 16) & 0xFF,
        b = (color >> 8) & 0xFF,
        a = color & 0xFF
    }
end

---@param deg number
---@return integer
function degrees_to_sm64(deg)
    return deg * 0x8000 / 180.0
end

---@param angle integer
---@return number
function sm64_to_degrees(angle)
    return angle * 180.0 / 0x8000;
end

---@param x number
---@param min number
---@param max number
---@return number
function math.wrap(x, min, max)
    if x > max then return min + x - max end
    if x < min then return max + x - min end
    return x
end

-------------------------------------------------------------

function iterate_entire_item_list()
    local current_index = 1
    local key, list = next(gItemBhvIds, nil)
    local current_obj = nil
    return function ()
        ::restart::
        if list then
            if list[current_index] then
                if current_obj then
                    current_obj = obj_get_next_with_same_behavior_id(current_obj)
                else
                    current_obj = obj_get_first_with_behavior_id(list[current_index])
                end

                if not current_obj then
                    current_index = current_index + 1
                    goto restart
                end
            else
                current_index = 1
                key, list = next(gItemBhvIds, key)
                goto restart
            end
        end

        if not current_obj then
            return nil
        end
        return key, current_obj
    end
end

---@param id_list BehaviorId[]
function iterate_item_list(id_list)
    local current_index = 1
    local current_obj = nil
    return function ()
        if not current_obj then
            current_obj = obj_get_first_with_behavior_id(id_list[current_index])
        else
            current_obj = obj_get_next_with_same_behavior_id(current_obj)
        end

        if not current_obj then
            while not current_obj do
                current_index = current_index + 1
                if not id_list[current_index] then
                    return nil
                end
                current_obj = obj_get_first_with_behavior_id(id_list[current_index])
            end
        end

        return current_obj
    end
end

---@param point Vec3f
---@param intersectee Object
---@return boolean
function point_is_intersecting_obj(point, intersectee)
    if not point or not intersectee then return false end

    if obj_has_behavior_id(intersectee, bhvMceBlock) == 0 then
        -- Bounding box detection
        local scale_x = intersectee.oScaleX * BLOCK_DEFAULT_SIZE * 0.5
        local scale_y = intersectee.oScaleY * BLOCK_DEFAULT_SIZE * 0.5
        local scale_z = intersectee.oScaleZ * BLOCK_DEFAULT_SIZE * 0.5
        local within_x = point.x > intersectee.oPosX - scale_x and point.x < intersectee.oPosX + scale_x
        local within_y = point.y > intersectee.oPosY - scale_y and point.y < intersectee.oPosY + scale_y
        local within_z = point.z > intersectee.oPosZ - scale_z and point.z < intersectee.oPosZ + scale_z
        return within_x and within_y and within_z
    end

    local col = gBlockCollisionLookup[intersectee._pointer]
    if not col then return false end
    for i = 0, col.length - 1, 1 do
        local surface = get_static_object_surface(col, i)

        local intersectee_pos = gVec3fZero()
        object_pos_to_vec3f(intersectee_pos, intersectee)
        local v1 = vec3s_to_vec3f(gVec3fZero(), surface.vertex1)
        local v2 = vec3s_to_vec3f(gVec3fZero(), surface.vertex2)
        local v3 = vec3s_to_vec3f(gVec3fZero(), surface.vertex3)
        local midpoint = {
            x = (v1.x + v2.x + v3.x) / 3,
            y = (v1.y + v2.y + v3.y) / 3,
            z = (v1.z + v2.z + v3.z) / 3,
        }

        local intersector_rel_pos = vec3f_dif(gVec3fZero(), point, midpoint)
        vec3f_normalize(intersector_rel_pos)

        local dot = vec3f_dot(surface.normal, intersector_rel_pos)
        local rounded_dot = tonumber(string.format("%.2f", dot)) or dot
        if rounded_dot > 0 then return false end
    end
    return true
end

---@param obj Object
---@param intersectee Object
---@return boolean
function obj_is_intersecting_obj(obj, intersectee)
    if not obj then return false end
    local pos = gVec3fZero()
    object_pos_to_vec3f(pos, obj)
    return point_is_intersecting_obj(pos, intersectee)
end

-------------------------------------------------------------

---@param t table
---@param val string
---@param key string
---@param min number
---@param max number
---@param is_integer boolean
---@return number
function parse_dimension(t, val, key, min, max, is_integer)
    if val == "_" then
        return t[key]
    end

    local symbol = val:sub(1, 1)
    if symbol == "+" or symbol == "-" then
        local new_val = 0
        local is_hex = val:sub(2, 3) == "0x"
        local base = is_hex and 16 or nil
        local start = is_hex and 4 or 2
        local number = val:sub(start)
        if symbol == "-" then
            number = "-" .. number
        end

        local addend = tonumber(number, base --[[@as number]]) or 0
        new_val = t[key] + addend
        new_val = math.clamp(new_val, min, max)
        if is_integer then
            new_val = math.floor(new_val)
        end
        return math.clamp(new_val, min, max)
    end
    local is_hex = val:sub(1, 2) == "0x"
    local base = is_hex and 16 or nil
    local start = is_hex and 3 or 1
    local number = val:sub(start)

    local new_val = math.clamp(tonumber(number, base --[[@as number]]) or t[key], min, max)
    if is_integer then
        new_val = math.floor(new_val)
    end
    return new_val
end

-------------------------------------------------------------

---@param item Item | Object
---@param flag integer
function mce_block_check_flag(item, flag)
    if item.oAction == nil then
        ---@cast item Item
        return item.animState & flag ~= 0
    else
        return item.oAnimState & flag ~= 0
    end
end

---@param item Item | Object
---@param flag integer
function mce_block_toggle_flag(item, flag)
    if item.oAction == nil then
        ---@cast item Item
        if item.animState & flag ~= 0 then
            item.animState = item.animState & ~flag
        else
            item.animState = item.animState | flag
        end
    else
        ---@cast item Object
        if item.oAnimState & flag ~= 0 then
            item.oAnimState = item.oAnimState & ~flag
        else
            item.oAnimState = item.oAnimState | flag
        end
    end
end

---@param obj Object
function mce_block_get_shape_index(obj)
    return (obj.oAnimState >> 16) & 0xFF
end

---@param obj Object
function mce_block_get_surface_index(obj)
    return obj.oItemParams & 0xFF
end

---@param item Item | Object
---@param shape integer
function mce_block_set_shape(item, shape)
    if item.oAction == nil then
        ---@cast item Item
        item.animState = item.animState & ~0x00FF0000
        item.animState = item.animState + (shape << 16)
    else
        ---@cast item Object
        item.oAnimState = item.oAnimState & ~0x00FF0000
        item.oAnimState = item.oAnimState + (shape << 16)
    end
end

local __common_collision = function (obj, toggle)
    local col = gBlockCollisionLookup[obj._pointer]
    if col then
        toggle_static_object_collision(col, toggle)
    end
end

---@param obj Object
function mce_block_enable_collision(obj)
    __common_collision(obj, true)
end

---@param obj Object
function mce_block_disable_collision(obj)
    __common_collision(obj, false)
end

-------------------------------------------------------------

local first_update_functions = {}
function add_first_update(func)
    table.insert(first_update_functions, func)
end

local sFirstUpdate = true
local function on_first_update()
    if not sFirstUpdate then return end
    sFirstUpdate = false
    for _, func in pairs(first_update_functions) do
        func()
    end
end
hook_event(HOOK_UPDATE, on_first_update)

local BlockTextures = require("src/block/textures")
local sRenderTimer = 3
local function hud_render()
    if sRenderTimer > 0 then
        djui_hud_set_resolution(RESOLUTION_N64)
        djui_hud_set_color(255, 255, 255, 255)
        for _, texture in ipairs(BlockTextures) do
            djui_hud_render_texture(texture, 0, 0, 0.1, 0.1)
        end
        sRenderTimer = sRenderTimer - 1
    end
end

hook_event(HOOK_ON_HUD_RENDER, hud_render)

-------------------------------------------------------------