local __djui_chat_message_create = djui_chat_message_create
function djui_chat_message_create(message)
    __djui_chat_message_create(tostring(message))
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

---@param obj Object
---@param hitbox ObjectHitbox
function obj_set_hitbox(obj, hitbox)
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