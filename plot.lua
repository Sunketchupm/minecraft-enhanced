gLevelValues.floorLowerLimit = -32768
gLevelValues.floorLowerLimitMisc = -32768
gLevelValues.floorLowerLimitShadow = -32768
gLevelValues.cellHeightLimit = 32767

local LEVEL_EMPTY = level_register("level_empty_entry", COURSE_NONE, "Plot", "plot", 20000, 0x28, 0x28, 0x28)

local function on_chat_command(msg)
    local act = 1
    if tonumber(msg) then
        act = tonumber(msg)
    end
    warp_to_warpnode(LEVEL_EMPTY, 1, act, 0xA)
    return true
end

hook_chat_command("plot", "| Warp to a level with no textures or objects. Pass an argument to go to a specific act.", on_chat_command)