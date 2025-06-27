gLevelValues.floorLowerLimit = -32768
gLevelValues.floorLowerLimitMisc = -32768
gLevelValues.floorLowerLimitShadow = -32768
gLevelValues.cellHeightLimit = 32767

smlua_audio_utils_replace_sequence(0x64, 0x25, 50, "03_Seq_sms_custom")

local LEVEL_PLOT = level_register("level_plot_entry", COURSE_BOB, "Plot", "plot", 20000, 0x28, 0x28, 0x28)

local function on_chat_command(msg)
    local act = 1
    if tonumber(msg) then
        act = tonumber(msg)
    end
    warp_to_warpnode(LEVEL_PLOT, 1, act, 0xA)
    return true
end

local function on_lvl_init()
    if gNetworkPlayers[0].currLevelNum == LEVEL_PLOT then
        play_music(0, 0x64, 1)
    end
end

hook_chat_command("plot", "| Warp to a level with no textures or objects. Pass an argument to go to a specific act.", on_chat_command)
hook_event(HOOK_ON_LEVEL_INIT, on_lvl_init)