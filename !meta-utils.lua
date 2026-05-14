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

---@param anim_state integer
function mce_block_is_colored(anim_state)
    return anim_state & (1 << 24) ~= 0
end

---@param anim_state integer
function mce_block_is_shaded(anim_state)
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
function mce_block_set_shaded(item)
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
function mce_block_set_unshaded(item)
    if item.oAction == nil then
        ---@cast item Item
        item.animState = item.animState & ~(1 << 25)
    else
        ---@cast item Object
        item.oAnimState = item.oAnimState & ~(1 << 25)
    end
end