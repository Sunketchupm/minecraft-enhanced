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

---@param id_list BehaviorId[]
function iterate_id_list(id_list)
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
    elseif intersectee.numSurfaces == 0 then
        -- Out of collision range
        return false
    end

    for i = 0, intersectee.numSurfaces - 1, 1 do
        local surface = obj_get_surface_from_index(intersectee, i)

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
        if dot > 0 then return false end
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

---@param anim_state integer
function mce_block_is_colored(anim_state)
    return anim_state & (1 << 24) ~= 0
end

---@param anim_state integer
function mce_block_is_unshaded(anim_state)
    return anim_state & (1 << 25) ~= 0
end

---@param item Item | Object
function mce_block_set_colored(item)
    if item.oAction == nil then
        ---@cast item Item
        item.animState = item.animState | (1 << 24)
    else
        ---@cast item Object
        item.oAnimState = item.oAnimState | (1 << 24)
    end
end

---@param item Item | Object
function mce_block_set_unshaded(item)
    if item.oAction == nil then
        ---@cast item Item
        item.animState = item.animState | (1 << 25)
    else
        ---@cast item Object
        item.oAnimState = item.oAnimState | (1 << 25)
    end
end

---@param item Item | Object
function mce_block_set_uncolored(item)
    if item.oAction == nil then
        ---@cast item Item
        item.animState = item.animState & ~(1 << 24)
    else
        ---@cast item Object
        item.oAnimState = item.oAnimState & ~(1 << 24)
    end
end

---@param item Item | Object
function mce_block_set_shaded(item)
    if item.oAction == nil then
        ---@cast item Item
        item.animState = item.animState & ~(1 << 25)
    else
        ---@cast item Object
        item.oAnimState = item.oAnimState & ~(1 << 25)
    end
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