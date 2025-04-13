local render_item_details = true

local item_id_to_name = {
    [ITEM_ID_BLOCK] = "Block",
    [ITEM_ID_EXCLAMATION] = "Exclamation Box",
    [ITEM_ID_STAR] = "Star",
}

local type_name = {
    [ITEM_ID_BLOCK] = {
        [BLOCK_SURFACE_ID_NO_COLLISION] = "No Collision",
        [BLOCK_SURFACE_ID_DEFAULT] = "Default",
        [BLOCK_SURFACE_ID_LAVA] = "Lava",
        [BLOCK_SURFACE_ID_QUICKSAND] = "Quicksand",
        [BLOCK_SURFACE_ID_SLIPPERY] = "Slippery",
        [BLOCK_SURFACE_ID_VERY_SLIPPERY] = "Very slippery",
        [BLOCK_SURFACE_ID_NOT_SLIPPERY] = "Not slippery",
        [BLOCK_SURFACE_ID_HANGABLE] = "Hangable",
        [BLOCK_SURFACE_ID_SHALLOWSAND] = "Shallowsand",
        [BLOCK_SURFACE_ID_DEATH] = "Death",
        [BLOCK_SURFACE_ID_VANISH] = "Vanish",
        [BLOCK_SURFACE_ID_CHECKPOINT] = "Checkpoint",
        [BLOCK_SURFACE_ID_BOUNCE] = "Bounce",
        [BLOCK_SURFACE_ID_FIRSTY] = "Firsty",
        [BLOCK_SURFACE_ID_WIDE_WALLKICK] = "Widekick",
        [BLOCK_SURFACE_ID_BOOSTER] = "Booster",
        [BLOCK_SURFACE_ID_HEAL] = "Heal",
        [BLOCK_SURFACE_ID_NO_A] = "Jumpless",
        [BLOCK_SURFACE_ID_ANY_BONK_WALLKICK] = "Anykick",
        [BLOCK_SURFACE_ID_NO_FALL_DAMAGE] = "Nofall",
        [BLOCK_SURFACE_ID_CONVEYOR] = "Conveyor",
        [BLOCK_SURFACE_ID_BREAKABLE] = "Breakable",
        [BLOCK_SURFACE_ID_DISAPPEARING] = "Disappearing",
        [BLOCK_SURFACE_ID_REMOVE_CAPS] = "Capless",
        [BLOCK_SURFACE_ID_NO_WALLKICKS] = "Wallkickless",
        [BLOCK_SURFACE_ID_DASH_PANEL] = "Dash panel",
        [BLOCK_SURFACE_ID_TOXIC_GAS] = "Toxic",
        [BLOCK_SURFACE_ID_JUMP_PAD] = "Jump pad"
    },
    [ITEM_ID_EXCLAMATION] = {
        [0] = "Empty",
        [1] = "Wing",
        [2] = "Metal",
        [3] = "Vanish",
        [4] = "Shell",
    },
    [ITEM_ID_STAR] = {
        [0] = "Real",
        [1] = "Real",
        [2] = "Fake",
    }
}

---@param text string
---@param y number
---@param scale number
local function display_centered_text(text, y, scale)
    local text_size = djui_hud_measure_text(text)
    local screen_width = djui_hud_get_screen_width()
    local text_x = (screen_width * 0.5 - (text_size * scale) * 0.5)
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_print_text(text, text_x, y, scale)
end

local function hud_render()
    if not render_item_details then return end
    if gMarioStates[0].action ~= ACT_FREE_MOVE then return end

    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_set_rotation(0, 0, 0)

    local screen_width = djui_hud_get_screen_width()
    local screen_height = djui_hud_get_screen_height()
    local top_rect_width = 70
    local top_rect_height = 35
    local x = screen_width * 0.5 - top_rect_width * 0.5
    local y = 0

    if gCurrentItem.itemId == ITEM_ID_BLOCK then
        top_rect_height = 55
    end
    djui_hud_set_color(0, 0, 0, 127)
    djui_hud_render_rect(x, y, top_rect_width, top_rect_height)

    djui_hud_set_color(255, 255, 255, 255)
    display_centered_text("Current Item", y, 0.4)
    display_centered_text("Item: " .. (item_id_to_name[gCurrentItem.itemId] or ("Unknown (ID: " .. gCurrentItem.itemId .. ")")), y + 12, 0.3)
    display_centered_text("Type: " .. (type_name[gCurrentItem.itemId][itemParams] or ("Unknown (Params: " .. itemParams .. ")")), y + 22, 0.3)
    if gCurrentItem.itemId == ITEM_ID_BLOCK then
        display_centered_text("Transparent?: " .. tostring(isTransparent), y + 32, 0.3)
        display_centered_text("Shaded?: " .. tostring(isShaded), y + 42, 0.3)
    end
end

local function on_render_item_details_chat_command()
    render_item_details = not render_item_details
    return true
end

hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_chat_command("show-item-details", "| Shows the current item and its properties", on_render_item_details_chat_command)