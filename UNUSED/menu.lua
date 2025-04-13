--[[
    Hardcoded incarnent, the file
    I am sorry for the very messy code here
    ----
    message from sherb
    this file was originally going to be used for a minecraft style menu
    it has been discontinued due to sunk's dying interest in continuing 
    the menu will not work properly in game if you choose to readd it in its current state
    you are free to attempt to fix it and send me the finished files to add to the next potential update
]]

menuOpen = false

--------------------------------------------------------------------------------------------

local get_texture_info, djui_hud_set_color, djui_hud_render_rect, djui_hud_render_texture, djui_hud_set_font, djui_hud_print_text, djui_hud_measure_text, djui_hud_set_rotation
    = get_texture_info, djui_hud_set_color, djui_hud_render_rect, djui_hud_render_texture, djui_hud_set_font, djui_hud_print_text, djui_hud_measure_text, djui_hud_set_rotation

--------------------------------------------------------------------------------------------

local TEX_BLOCK = get_texture_info("block")
local TEX_HAND_OPEN = get_texture_info("hand_open")
local TEX_HAND_CLOSED = get_texture_info("hand_closed")
local TEX_LEFT_ARROW = get_texture_info("left_arrow")
local TEX_RIGHT_ARROW = get_texture_info("right_arrow")

---@alias MenuTab integer

local MENU_TAB_HOTBAR = 0
local MENU_TAB_BLOCKS = 1
local MENU_TAB_BLOCK_SETTINGS = 2
local current_tab = MENU_TAB_BLOCKS

---@alias SubMenu integer

---@alias MenuFlag integer

local MENU_FLAG_CHANGES_MENU = (1 << 0)

local InputPressed = 0

----------------------------------------------

---@type SelectableElement?
local current_selected_element = nil

---@type table<MenuTab, SelectableElement?>
local selected_menu_element = {
    [MENU_TAB_BLOCKS] = nil,
    [MENU_TAB_BLOCK_SETTINGS] = nil
}

----------------------------------------------

local function djui_hud_set_color_with_table(color)
    djui_hud_set_color(color.r, color.g, color.b, color.a)
end

local function set_default_selection_color()
    djui_hud_set_color(20, 20, 20, 80)
end

--------------------------------------------------------------------------------------------

---@class SelectableElement
    ---@field posX number X
    ---@field posY number Y
    ---@field width number Width
    ---@field height number Height
    ---@field texture TextureInfo Custom texture, used for some renders
    ---@field text string String that goes on the element, used for some renders
    ---@field textScale number Size of the string, used for some renders
    ---@field condition boolean Boolean that is used for some renders
    ---@field color DjuiColor Color
    ---@field isHovered boolean Is this element currently selected
    ---@field activatedAction fun(self:SelectableElement):boolean Perform an action; Return `true` if action is successful
    ---@field overrideAction fun(self:SelectableElement):boolean Return `true` to override most default button input behaviors
    ---@field nearbySelectables {up: SelectableElement?, left: SelectableElement?, down: SelectableElement?, right: SelectableElement?} Link elements
    ---@field tab MenuTab Tab this element belongs to
    ---@field menu MenuTab Submenu this element belongs to
    ---@field args integer Misc args
    ---@field flags integer Misc flags

---@class SelectableElement
local SelectableElement = {
    ---@type table<MenuTab, SelectableElement[]>
    --- Used for mouse input
    groups = {
        [MENU_TAB_BLOCKS] = {},
        [MENU_TAB_BLOCK_SETTINGS] = {}
    },
    ---@type table<MenuTab, SelectableElement>
    lastSelected = {
        [MENU_TAB_BLOCKS] = {
            [1] = {},
            [2] = {},
            [3] = {},
        },
        [MENU_TAB_BLOCK_SETTINGS] = {
            [1] = {},
            [2] = {},
            [3] = {},
        },
    }
}
SelectableElement.__index = SelectableElement

---@param tab MenuTab
---@param menu SubMenu
---@return SelectableElement
function SelectableElement:New(tab, menu)
    local element = setmetatable({}, self)
    element.posX = 0
    element.posY = 0
    element.width = 0
    element.height = 0
    element.texture = gTextures.star
    element.text = ""
    element.textScale = 1
    element.condition = false
    element.color = {r = 255, g = 255, b = 255, a = 255}
    element.isHovered = false
    element.activatedAction = function () return true end
    element.overrideAction = function () return false end
    element.nearbySelectables = {up = nil, left = nil, down = nil, right = nil}
    element.tab = tab
    element.menu = menu
    element.args = 0
    element.flags = 0
    table.insert(SelectableElement.groups[menu], element)
    return element
end

---@param x number
---@param y number
---@param width number
---@param height number
---@return SelectableElement
function SelectableElement:SetPositionAndDimensions(x, y, width, height)
    self.posX = x
    self.posY = y
    self.width = width
    self.height = height
    return self
end

---@param func fun(self:SelectableElement):boolean
---@return SelectableElement
function SelectableElement:SetActivatedAction(func)
    self.activatedAction = func
    return self
end

---@param func fun(self:SelectableElement):boolean
---@return SelectableElement
function SelectableElement:SetOverrideAction(func)
    self.overrideAction = func
    return self
end

---@param nearby {up: SelectableElement?, left: SelectableElement?, down: SelectableElement?, right: SelectableElement?}
---@return SelectableElement
function SelectableElement:SetNearby(nearby)
    self.nearbySelectables.up = nearby.up
    self.nearbySelectables.left = nearby.left
    self.nearbySelectables.down = nearby.down
    self.nearbySelectables.right = nearby.right
    return self
end

---@return SelectableElement
function SelectableElement:SetDefault()
    SelectableElement.lastSelected[self.menu] = self
    return self
end

---@param args integer
---@return SelectableElement
function SelectableElement:SetArgs(args)
    self.args = args
    return self
end

---@param color DjuiColor
---@return SelectableElement
function SelectableElement:SetColor(color)
    self.color = {r = color.r, g = color.g, b = color.b, a = color.a}
    return self
end

function SelectableElement:RenderRectangleWithText()
    djui_hud_set_color(185, 185, 185, 255)
    if self.isHovered then
        djui_hud_set_color(255, 255, 255, 255)
    end
    djui_hud_render_rect(self.posX, self.posY, self.width, self.height)
    djui_hud_set_font(FONT_ALIASED)
    djui_hud_set_color(0, 0, 0, 255)
    local text_measurement = djui_hud_measure_text(self.text) * self.textScale
    local text_x = (self.posX + self.width * 0.5) - (text_measurement * 0.5)
    local text_y = (self.posY + self.height * 0.5) - ((30 * self.textScale) * 0.5)
    djui_hud_print_text(self.text, text_x, text_y, self.textScale)
end

function SelectableElement:RenderConditionRectangle()
    if self.condition then
        djui_hud_set_color(100, 200, 100, 255)
        if self.isHovered then
            djui_hud_set_color(160, 255, 160, 255)
        end
    else
        djui_hud_set_color(185, 185, 185, 255)
        if self.isHovered then
            djui_hud_set_color(255, 255, 255, 255)
        end
    end
    djui_hud_render_rect(self.posX, self.posY, self.width, self.height)
    if self.text and self.textScale then
        djui_hud_set_font(FONT_ALIASED)
        djui_hud_set_color(0, 0, 0, 255)
        local text_measurement = djui_hud_measure_text(self.text) * self.textScale
        local text_x = (self.posX + self.width * 0.5) - (text_measurement * 0.5)
        local text_y = (self.posY + self.height * 0.5) - ((30 * self.textScale) * 0.5)
        djui_hud_print_text(self.text, text_x, text_y, self.textScale)
    end
end

function SelectableElement:RenderTexture()
    if self.isHovered then
        local color = djui_hud_get_color()
        djui_hud_set_color(math.min(color.r + 50, 255), math.min(color.g + 50, 255), math.min(color.b + 50, 255), math.min(color.a + 50, 255))
    end
    djui_hud_render_texture(self.texture, self.posX, self.posY, self.width, self.height)
end

function SelectableElement:RenderCheckbox()
    djui_hud_set_color(125, 125, 125, 255)
    djui_hud_render_rect(self.posX, self.posY, self.width, self.height)
    if self.condition then
        djui_hud_set_color(70, 70, 70, 255)
    else
        djui_hud_set_color(205, 205, 205, 255)
    end
    djui_hud_render_rect(self.posX + 0.5, self.posY + 0.5, self.width - 1, self.height - 1)
end

---@param pos_x number
---@param pos_y number
---@param row_count integer
---@param column_count integer
---@param space_width number
---@param space_height number
---@param space_spacing number
---@param texture_fill TextureTable[]
---@param escape_elements {up: SelectableElement?, left: SelectableElement?, down: SelectableElement?, right: SelectableElement?}
---@param tab MenuTab
---@return SelectableElement[]
local function create_grid(pos_x, pos_y, row_count, column_count, space_width, space_height, space_spacing, texture_fill, escape_elements, tab)
    local indexer = 0
    ---@type SelectableElement[]
    local elements = {}
    for row = 0, row_count - 1 do
        for column = 0, column_count - 1 do
            indexer = indexer + 1
            if not texture_fill[indexer] then
                goto end_loop
            end

            local current_space_x = pos_x + space_spacing * column
            local current_space_y = pos_y + space_spacing * row
            local element = SelectableElement
                :New(tab, function () return true end)
                :SetPositionAndDimensions(current_space_x, current_space_y, space_width, space_height)
                :SetTexture(texture_fill[indexer])

            element.storeSelected = true

            table.insert(elements, element)
        end
    end
    ::end_loop::

    for index, current_element in ipairs(elements) do
        if elements[index - column_count] then
            current_element.nearbySelectables.up = elements[index - column_count]
        elseif escape_elements.up then
            current_element.nearbySelectables.up = escape_elements.up
        end
        if elements[index - 1] then
            current_element.nearbySelectables.left = elements[index - 1]
        elseif escape_elements.left then
            current_element.nearbySelectables.left = escape_elements.left
        end
        if elements[index + column_count] then
            current_element.nearbySelectables.down = elements[index + column_count]
        elseif escape_elements.down then
            current_element.nearbySelectables.down = escape_elements.down
        end
        if elements[index + 1] then
            current_element.nearbySelectables.right = elements[index + 1]
        elseif escape_elements.right then
            current_element.nearbySelectables.right = escape_elements.right
        end
    end

    return elements
end

---@param x number
---@param y number
---@param width number
---@param height number
---@param text string
---@param text_scale number
local function render_non_selectable_textbox(x, y, width, height, text, text_scale)
    djui_hud_set_color(225, 225, 225, 255)
    djui_hud_render_rect(x, y, width, height)
    djui_hud_set_color(0, 0, 0, 255)
    local text_measurement = djui_hud_measure_text(text) * text_scale
    local text_x = (x + width * 0.5) - (text_measurement * 0.5)
    local text_y = (y + height * 0.5) - ((15 * text_scale) * 0.5)
    djui_hud_print_text(text, text_x, text_y, text_scale)
end

----------------------------------------------

-- Linear array
local block_texture_colors = {
    {r = 255, g = 0,   b = 0,   a = 255}, {r = 255, g = 131, b = 0,   a = 255}, {r = 255, g = 255, b = 0,   a = 255}, {r = 0,   g = 160, b = 0,   a = 255},
    {r = 96,  g = 255, b = 0,   a = 255}, {r = 0,   g = 255, b = 255, a = 255}, {r = 16,  g = 122, b = 144, a = 255}, {r = 0,   g = 0,   b = 255, a = 255},
    {r = 91, g = 14,   b = 216, a = 255}, {r = 228, g = 12,  b = 109, a = 255}, {r = 234, g = 89,  b = 111, a = 255}, {r = 114, g = 39,  b = 0,   a = 255},
    {r = 160, g = 95,  b = 53,  a = 255}, {r = 0,   g = 0,   b = 0,   a = 255}, {r = 127, g = 127, b = 127, a = 255}, {r = 255, g = 255, b = 255, a = 255},
}

----------------------------------------------

local tab_images = {
    [MENU_TAB_BLOCKS] = {
        texture = TEX_BLOCK,
        x = 4,
        y = 3,
        color = {r = 127, g = 127, b = 127, a = 255},
        scale = 0.5
    },
    [MENU_TAB_BLOCK_SETTINGS] = {
        texture = TEX_BLOCK,
        x = 4,
        y = 3,
        color = {r = 127, g = 127, b = 127, a = 255},
        scale = 0.5
    }
}

---@param x number
---@param tab_id MenuTab
local function render_tab(x, tab_id)
    local tab_y_pos = MAIN_RECT_Y_POS - 20
    local tab_width = 25
    local tab_height = 20
    local offset_color = (current_tab == tab_id and 0 or 50)
    djui_hud_set_color(98 - offset_color, 98 - offset_color, 98 - offset_color, 255)
    djui_hud_render_rect(MAIN_RECT_X_POS + x, tab_y_pos, tab_width, tab_height)
    djui_hud_set_color(255 - offset_color, 255 - offset_color, 255 - offset_color, 255)
    djui_hud_render_rect(MAIN_RECT_X_POS + x, tab_y_pos, tab_width - 2, tab_height)
    djui_hud_set_color(205 - offset_color, 205 - offset_color, 205 - offset_color, 255)
    djui_hud_render_rect(MAIN_RECT_X_POS + 2 + x, tab_y_pos + 2, tab_width - 4, tab_height - (current_tab == tab_id and 0 or 2))
    local image = tab_images[tab_id]
    if image then
        djui_hud_set_color_with_table(image.color)
        djui_hud_render_texture(image.texture, MAIN_RECT_X_POS + x + image.x, tab_y_pos + image.y, image.scale, image.scale)
    end
end

local function render_main_rectangle()
    local screen_width = djui_hud_get_screen_width()
    local screen_height = djui_hud_get_screen_height()
    MAIN_RECT_X_POS  = screen_width * 0.25
    MAIN_RECT_Y_POS  = screen_height * 0.15
    MAIN_RECT_WIDTH  = screen_width * 0.5
    MAIN_RECT_HEIGHT = screen_height * 0.7
    MAIN_RECT_END_X  = MAIN_RECT_X_POS + MAIN_RECT_WIDTH
    MAIN_RECT_END_Y  = MAIN_RECT_Y_POS + MAIN_RECT_HEIGHT
    djui_hud_set_color(98, 98, 98, 255)
    djui_hud_render_rect(MAIN_RECT_X_POS, MAIN_RECT_Y_POS, MAIN_RECT_WIDTH, MAIN_RECT_HEIGHT)
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_render_rect(MAIN_RECT_X_POS, MAIN_RECT_Y_POS, MAIN_RECT_WIDTH - 2, MAIN_RECT_HEIGHT - 2)
    djui_hud_set_color(205, 205, 205, 255)
    djui_hud_render_rect(MAIN_RECT_X_POS + 2, MAIN_RECT_Y_POS + 2, MAIN_RECT_WIDTH - 4, MAIN_RECT_HEIGHT - 4)

    local tab_x_offset = 25
    render_tab(0, MENU_TAB_BLOCKS)
    render_tab(tab_x_offset, MENU_TAB_BLOCK_SETTINGS)
end

---@param text string
local function render_header(text)
    local scale = 1
    local text_length = djui_hud_measure_text(text)
    local x = (MAIN_RECT_X_POS + MAIN_RECT_WIDTH * 0.5) - (text_length * 0.5)
    local y = MAIN_RECT_Y_POS + 2
    djui_hud_set_color(0, 0, 0, 255)
    djui_hud_print_text(text, x, y, scale)
end

----------------------------------------------

local NEW_COLOR_ID = 9

local block_colors = {
    NEW_COLOR_ID * 0,  NEW_COLOR_ID * 1,  NEW_COLOR_ID * 2,  NEW_COLOR_ID * 3,
    NEW_COLOR_ID * 4,  NEW_COLOR_ID * 5,  NEW_COLOR_ID * 6,  NEW_COLOR_ID * 7,
    NEW_COLOR_ID * 8,  NEW_COLOR_ID * 9,  NEW_COLOR_ID * 10, NEW_COLOR_ID * 11,
    NEW_COLOR_ID * 12, NEW_COLOR_ID * 13, NEW_COLOR_ID * 14, NEW_COLOR_ID * 15,
}

----------------------------------------------

local BuildingBlocksTab = {}


----------------------------------------------

--[[local surface_name_for_dropdown = {
    "Default",
    "Lava",
    "Quicksand",
    "Slippery",
    "Very Slippery",
    "Not Slippery",
    "Hangable",
    "Shallow Quicksand",
    "Death",
    "Checkpoint",
    "Springboard",
    "Firsty",
    "Wide Wallkick",
    "Any Bonk Wallkick",
    "Jump Pad",
    "Heal",
    "Jumpless",
}

local surface_from_dropdown = {
    "default",
    "lava",
    "quicksand",
    "slippery",
    "very slippery",
    "not slippery",
    "hangable",
    "shallowsand",
    "death",
    "checkpoint",
    "springboard",
    "firsty",
    "widekick",
    "anykick",
    "jump pad",
    "heal",
    "jumpless",
}

local surface_dropdown_menu = DropdownMenu:new(surface_name_for_dropdown, function (self)
    blockSurface = surface_from_dropdown[self.currentIndex]
    blockSurfaceIsSpecial = self.currentIndex >= START_SPECIAL
    return true
end)]]

----------------------------------------------

local BlockSettingsTab = {}

------ Links ------

----------------------------------------------


--------------------------------------------------------------------------------------------

local function hud_render()
    djui_hud_set_resolution(RESOLUTION_N64)

end

local global_sound_source = {x = 0, y = 0, z = 0}
local used_control_stick = {
    up = false,
    left = false,
    down = false,
    right = false,
}

---@param m MarioState
local function before_mario_update(m)
    if m.playerIndex ~= 0 then return end
    if not allowBuild then return end

    if menuOpen then
        if m.controller.buttonPressed & (B_BUTTON | START_BUTTON) ~= 0 then
            menuOpen = false
            SelectableElement.lastSelected[current_tab] = current_selected_element
        end

        if current_selected_element and current_selected_element.__index == SelectableElement then
            if current_selected_element:overrideAction() then
                return
            end

            ---@type SelectableElement
            local next_element = nil
            current_selected_element.isHovered = false
            if current_selected_element.nearbySelectables then
                local nearby = current_selected_element.nearbySelectables
                if InputPressed & U_JPAD ~= 0 then
                    next_element = nearby.up and nearby.up or current_selected_element
                    play_sound(SOUND_MENU_CHANGE_SELECT, global_sound_source)
                end
                if InputPressed & L_JPAD ~= 0 then
                    next_element = nearby.left and nearby.left or current_selected_element
                    play_sound(SOUND_MENU_CHANGE_SELECT, global_sound_source)
                end
                if InputPressed & D_JPAD ~= 0 then
                    next_element = nearby.down and nearby.down or current_selected_element
                    play_sound(SOUND_MENU_CHANGE_SELECT, global_sound_source)
                end
                if InputPressed & R_JPAD ~= 0 then
                    next_element = nearby.right and nearby.right or current_selected_element
                    play_sound(SOUND_MENU_CHANGE_SELECT, global_sound_source)
                end
            end
            if not next_element then
                next_element = current_selected_element
            end
            next_element.isHovered = true
            ---@type SelectableElement
            current_selected_element = next_element

            if InputPressed & A_BUTTON ~= 0 then
                SelectableElement.lastSelected[current_tab] = current_selected_element
                local success = current_selected_element:activatedAction()
                if success then
                    if current_selected_element.flags & MENU_FLAG_CHANGES_MENU ~= 0 then
                        current_selected_element.isHovered = false
                        current_selected_element = nil
                    end
                    play_sound(SOUND_MENU_CLICK_FILE_SELECT, global_sound_source)
                else
                    play_sound(SOUND_MENU_CAMERA_BUZZ, global_sound_source)
                end
            end
        end
    end
end

hook_event(HOOK_ON_HUD_RENDER, hud_render)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)

hook_chat_command('mmenu', " ", function ()
    menuOpen = true
    return true
end)