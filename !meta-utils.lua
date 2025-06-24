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

MinecraftDebug = {}
function MinecraftDebug.segments(x, y, width, height)
    djui_hud_set_color(0, 255, 0, 255)
    local rect_x = x
    while rect_x <= x + width do
        local rect_y = y
        while rect_y <= y + height do
            djui_hud_render_rect(rect_x, rect_y, 10 ,10)
            rect_y = rect_y + height * 0.05
        end
        rect_x = rect_x + width * 0.05
    end
end

MenuDebug = {}
MenuDebug.displacement_x = 0
MenuDebug.displacement_y = 0
function MenuDebug.move_hud_elements()
    ---@type MarioState
    local m = gMarioStates[0]
    if m.controller.buttonDown & L_JPAD ~= 0 then
        MenuDebug.displacement_x = MenuDebug.displacement_x - 1
        djui_chat_message_create(("%d, %d"):format(MenuDebug.displacement_x, MenuDebug.displacement_y))
    end
    if m.controller.buttonDown & R_JPAD ~= 0 then
        MenuDebug.displacement_x = MenuDebug.displacement_x + 1
        djui_chat_message_create(("%d, %d"):format(MenuDebug.displacement_x, MenuDebug.displacement_y))
    end
    if m.controller.buttonDown & U_JPAD ~= 0 then
        MenuDebug.displacement_y = MenuDebug.displacement_y - 1
        djui_chat_message_create(("%d, %d"):format(MenuDebug.displacement_x, MenuDebug.displacement_y))
    end
    if m.controller.buttonDown & D_JPAD ~= 0 then
        MenuDebug.displacement_y = MenuDebug.displacement_y + 1
        djui_chat_message_create(("%d, %d"):format(MenuDebug.displacement_x, MenuDebug.displacement_y))
    end
end

local first_update_functions = {}
function add_first_update(func)
    table.insert(first_update_functions, func)
end

local first_update = true
local function on_first_update()
    if not first_update then return end
    first_update = false
    for _, func in pairs(first_update_functions) do
        func()
    end
end
hook_event(HOOK_UPDATE, on_first_update)

-- Converts string into a table using a delimiter
---@param s string
---@param delimiter string
---@return string[]
function split_string(s, delimiter)
    local result = {}
    for match in (s):gmatch(("[^%s]+"):format(delimiter)) do
        table.insert(result, match)
    end
    return result
end

---@param x number
---@return integer
convert_s16 = function (x)
    x = math.floor(x) & (1 << 16) - 1
    return x - ((x & (1 << 15)) << 1)
end

local transparent_starts = {}
local last_anims = {}

add_first_update(function ()
    transparent_starts = {
        [E_MODEL_MCE_BLOCK] = MCE_BLOCK_TRANSPARENT_START,
        [E_MODEL_MCE_COLOR_BLOCK] = MCE_COLOR_BLOCK_TRANSPARENT_START,
    }

    last_anims = {
        [E_MODEL_MCE_BLOCK] = MCE_BLOCK_ANIM_MAX,
        [E_MODEL_MCE_COLOR_BLOCK] = MCE_COLOR_BLOCK_BARRIER_ANIM,
    }
end)

---@param obj Object
---@return integer
function mce_block_get_transparent_start_obj(obj)
    return transparent_starts[obj_get_model_id_extended(obj)]
end

---@param item Item
---@return integer
function mce_block_get_transparent_start_item(item)
    return transparent_starts[item.model]
end

---@param obj Object
---@return integer
function mce_block_get_anim_max_obj(obj)
    return last_anims[obj_get_model_id_extended(obj)]
end

---@param item Item
---@return integer
function mce_block_get_anim_max_item(item)
    return last_anims[item.model]
end