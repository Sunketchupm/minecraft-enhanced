local Menu = require("class")
local Grid = require("grid")
local Settings = require("settings")

---@param m MarioState
---@param inputs Inputs
local function handle_inputs(m, inputs)
    local current_tab = Menu[Menu.tab]
    if current_tab.type == TAB_TYPE_GRID then
        Grid.inputs(m, inputs)
    elseif current_tab.type == TAB_TYPE_SETTINGS then
        Settings.inputs(m, inputs)
    end

    m.controller.buttonPressed = 0
end

return handle_inputs