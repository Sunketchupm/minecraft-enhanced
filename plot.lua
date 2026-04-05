gLevelValues.floorLowerLimit = -32768
gLevelValues.floorLowerLimitMisc = -32768
gLevelValues.floorLowerLimitShadow = -32768
gLevelValues.cellHeightLimit = 32767

smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "03_Seq_sms_custom")

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
    if gNetworkPlayers[0].currLevelNum == LEVEL_PLOT and not exit_to_castle then
        trigger_on_death()
    end
end

local function musicplot(msg) -- Various music for plots, can be used to add more if needed
    if msg == "1" then djui_chat_message_create("Music: Super Mario Sunshine - Sky & Sea. Author: ???")
        smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "03_Seq_sms_custom")
        return true
    elseif msg == "2" then djui_chat_message_create("Music: Megumi Nakajima - Sonna Koto Ura no Mata Urabanashi desho? (Kotoura-san OP). Author: DaMemes")
        smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "04_Seq_kotourasanop_custom")
        return true
    elseif msg == "3" then djui_chat_message_create("Music: Touhou 20: Fossilized Wonders - Golden Land of Prester John. Author: DaMemes")
        smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "05_Seq_th20stage3_custom")
        return true
    elseif msg == "4" then djui_chat_message_create("Music: Touhou 20: Fossilized Wonders - Might as Well Stake Your Life to Solve the Riddle. Author: DaMemes")
        smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "06_Seq_th20nareko_custom")
        return true
    elseif msg == "5" then djui_chat_message_create("Music: Touhou 11: Subterranean Animism - Walking the Streets of a Former Hell. Author: DaMemes")
        smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "07_Seq_th11stage3_custom")
        return true
    elseif msg == "6" then djui_chat_message_create("Music: Touhou 9: Phantasmagoria of Flower View - Ghostly Band ~ Phantom Ensemble (Touhoumon Version). Author: DaMemes")
        smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "08_Seq_touhoumonprismriver_custom")
        return true
    elseif msg == "7" then djui_chat_message_create("Music: Touhou 16: Hidden Star in Four Seasons - Illusionary White Traveler. Author: DaMemes")
        smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "09_Seq_th16stage4_custom")
        return true
    elseif msg == "8" then djui_chat_message_create("Music: Touhou 16: Hidden Star in Four Seasons - Secret God Matara ~ Hidden Star in All Seasons. Author: DaMemes")
        smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "0A_Seq_th16okina2_custom")
        return true
    end
    return false
end

hook_chat_command("plot-music", "[1-8] Changes music that plays in plots (will display port author as well). Re-enter plot if you have decided to change the song while you're in it.", musicplot)
hook_chat_command("plot", "| Warp to a level with no textures or objects. Pass an argument to go to a specific act.", on_chat_command)
hook_event(HOOK_ON_LEVEL_INIT, on_lvl_init)
hook_event(HOOK_ON_PAUSE_EXIT, on_pause_exit)
