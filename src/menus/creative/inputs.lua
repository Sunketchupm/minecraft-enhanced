local CommonMenu = require("../common_menu")

local Hotbar = require("../hotbar/class")

local Menu = require("class")
local Grid = require("grid")

local sResetCooldown = 0
local sPrevProgress = 0

local function handle_reset_hotbar_state()
    if sResetCooldown > 0 then
        Menu.reset.active = false
        Menu.reset.progress = 0
        Menu.reset.leniency = 0
        sResetCooldown = sResetCooldown - 1
    else
        if sPrevProgress ~= Menu.reset.progress then
            Menu.reset.leniency = 0
            if Menu.reset.progress >= 90 then
                for i = 1, HOTBAR_SIZE, 1 do
                    Hotbar[i].link = nil
                end
                Menu.reset.progress = 0
                Menu.reset.leniency = 0
                sResetCooldown = 39
            end
            Menu.reset.active = true
            play_sound(SOUND_MENU_COLLECT_SECRET + (math.floor((Menu.reset.progress / 90) * 5) << 16), gGlobalSoundSource)
        elseif Menu.reset.progress > 0 then
            Menu.reset.leniency = Menu.reset.leniency + 1
            if Menu.reset.leniency > 10 then
                Menu.reset.progress = 0
                Menu.reset.leniency = 0
            end
            Menu.reset.active = false
        end
        sPrevProgress = Menu.reset.progress
    end
end

---@param m MarioState
---@param inputs Inputs
local function handle_inputs(m, inputs)
    CommonMenu.menu_inputs(m, inputs, Menu, Menu.tab, {
        tab = function (index)
            Menu.tab = index
            Menu.item.index = 0
        end,
        scroll = function (direction, index)
            if direction.up then
                Menu.item.index = (Menu.item.index - Grid.column_count)
            elseif direction.down then
                Menu.item.index = (Menu.item.index + Grid.column_count)
            elseif direction.left then
                Menu[Menu.tab].scroll.index = index - Grid.row_count
                Menu.item.index = Menu.item.index - (Grid.row_count * Grid.column_count)
            elseif direction.right then
                Menu[Menu.tab].scroll.index = index + Grid.row_count
                Menu.item.index = Menu.item.index + (Grid.row_count * Grid.column_count)
            end
            Menu.item.index = math.clamp(Menu.item.index, 0, #Menu[Menu.tab].grid - 1)
        end
    })

    Grid.inputs(inputs)

    if inputs.buttons.pressed & Y_BUTTON ~= 0 then
        Hotbar[Hotbar.index].link = nil
    elseif inputs.buttons.down & Y_BUTTON ~= 0 then
        Menu.reset.progress = Menu.reset.progress + 1
    end

    handle_reset_hotbar_state()

    m.controller.buttonPressed = 0
end

return handle_inputs