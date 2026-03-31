gLevelValues.floorLowerLimit = -32768
gLevelValues.floorLowerLimitMisc = -32768
gLevelValues.floorLowerLimitShadow = -32768
gLevelValues.cellHeightLimit = 32767

smlua_audio_utils_replace_sequence(0x64, 0x25, 50, "03_Seq_sms_custom")

local LEVEL_PLOT = level_register("level_plot_entry", COURSE_CAKE_END, "Plot", "plot", 20000, 0x28, 0x28, 0x28)

local function on_chat_command(msg)
    local act = tonumber(msg) or 0
    warp_to_warpnode(LEVEL_PLOT, 1, act, 0xA)
    return true
end

local function on_lvl_init()
    if gNetworkPlayers[0].currLevelNum == LEVEL_PLOT then
        play_music(0, 0x64, 1)
    end
end

local function on_pause_exit(exit_to_castle)
    if gNetworkPlayers[0].currLevelNum == LEVEL_PLOT then
        trigger_on_death()
    end
end

hook_chat_command("plot", "| Warp to a level with no textures or objects. Pass an argument to go to a specific act.", on_chat_command)
hook_event(HOOK_ON_LEVEL_INIT, on_lvl_init)
hook_event(HOOK_ON_PAUSE_EXIT, on_pause_exit)