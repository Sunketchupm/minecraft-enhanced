camera_set_use_course_specific_settings(0)
camera_set_romhack_override(RCO_ALL)
rom_hack_cam_set_collisions(0)
camera_romhack_allow_centering(0)
camera_romhack_allow_dpad_usage(1)

gLevelValues.floorLowerLimit = -32768
gLevelValues.floorLowerLimitMisc = -32768
gLevelValues.floorLowerLimitShadow = -32768
gLevelValues.cellHeightLimit = 32767

local LEVEL_EMPTY = level_register("level_empty_entry", COURSE_NONE, "Empty Plate", "ep", 20000, 0x28, 0x28, 0x28)

local function on_chat_command(msg)
    local act = 1
    if tonumber(msg) then
        act = tonumber(msg)
    end
    warp_to_warpnode(LEVEL_EMPTY, 1, act, 0xA)
    return true
end

hook_chat_command("empty-level", "| !! LEGACY COMMAND; USE /plot !!", on_chat_command)
hook_chat_command("plot", "| Warp to a level with no textures or objects. Pass an argument to go to a specific act.", on_chat_command)