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
    if gNetworkPlayers[0].currLevelNum == LEVEL_PLOT then
        if msg == "1" then djui_chat_message_create("Music: Title Screen | Author: Koji Kondo")
            smlua_audio_utils_reset_all()
            set_background_music(SEQ_PLAYER_LEVEL, SEQ_MENU_TITLE_SCREEN, 0)
            return true
        elseif msg == "2" then djui_chat_message_create("Music: Bob-omb Battlefield | Author: Koji Kondo")
            smlua_audio_utils_reset_all()
            set_background_music(SEQ_PLAYER_LEVEL, SEQ_LEVEL_GRASS, 0)
            return true
        elseif msg == "3" then djui_chat_message_create("Music: Peach's Castle | Author: Koji Kondo")
            smlua_audio_utils_reset_all()
            set_background_music(SEQ_PLAYER_LEVEL, SEQ_LEVEL_INSIDE_CASTLE, 0)
            return true
        elseif msg == "4" then djui_chat_message_create("Music: Dire, Dire Docks | Author: Koji Kondo")
            smlua_audio_utils_reset_all()
            set_background_music(SEQ_PLAYER_LEVEL, SEQ_LEVEL_WATER, 0)
            return true
        elseif msg == "5" then djui_chat_message_create("Music: Lethal Lava Land | Author: Koji Kondo")
            smlua_audio_utils_reset_all()
            set_background_music(SEQ_PLAYER_LEVEL, SEQ_LEVEL_HOT, 0)
            return true
        elseif msg == "6" then djui_chat_message_create("Music: Princess' Secret Slide | Author: Koji Kondo")
            smlua_audio_utils_reset_all()
            set_background_music(SEQ_PLAYER_LEVEL, SEQ_LEVEL_SLIDE, 0)
            return true
        elseif msg == "7" then djui_chat_message_create("Music: Big Boo's Haunt | Author: Koji Kondo")
            smlua_audio_utils_reset_all()
            set_background_music(SEQ_PLAYER_LEVEL, SEQ_LEVEL_SPOOKY, 0)
            return true
        elseif msg == "8" then djui_chat_message_create("Music: Hazy Maze Cave | Author: Koji Kondo")
            smlua_audio_utils_reset_all()
            set_background_music(SEQ_PLAYER_LEVEL, SEQ_LEVEL_UNDERGROUND, 0)
            return true
        elseif msg == "9" then djui_chat_message_create("Music: Merry-Go-Round | Author: Koji Kondo")
            smlua_audio_utils_reset_all()
            set_background_music(SEQ_PLAYER_LEVEL, SEQ_EVENT_MERRY_GO_ROUND, 0)
            return true
        elseif msg == "10" then djui_chat_message_create("Music: The Endless Staircase | Author: Koji Kondo")
            smlua_audio_utils_reset_all()
            set_background_music(SEQ_PLAYER_LEVEL, SEQ_EVENT_ENDLESS_STAIRS, 0)
            return true
        elseif msg == "11" then djui_chat_message_create("Music: Koopa Road | Author: Koji Kondo")
            smlua_audio_utils_reset_all()
            set_background_music(SEQ_PLAYER_LEVEL, SEQ_LEVEL_KOOPA_ROAD, 0)
            return true
        elseif msg == "12" then djui_chat_message_create("Music: Stage Boss | Author: Koji Kondo")
            smlua_audio_utils_reset_all()
            set_background_music(SEQ_PLAYER_LEVEL, SEQ_EVENT_BOSS, 0)
            return true
        elseif msg == "13" then djui_chat_message_create("Music: Bowser's Theme | Author: Koji Kondo")
            smlua_audio_utils_reset_all()
            set_background_music(SEQ_PLAYER_LEVEL, SEQ_LEVEL_BOSS_KOOPA, 0)
            return true
        elseif msg == "14" then djui_chat_message_create("Music: Ultimate Bowser | Author: Koji Kondo")
            smlua_audio_utils_reset_all()
            set_background_music(SEQ_PLAYER_LEVEL, SEQ_LEVEL_BOSS_KOOPA_FINAL, 0)
            return true
        elseif msg == "15" then djui_chat_message_create("Music: Super Mario Sunshine - Sky & Sea | Author: Shinobu Tanaka")
            smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "03_Seq_sms_custom")
            djui_popup_create("Be sure to save and reload your current plot to finalize your selection!", 2)
            return true
        elseif msg == "16" then djui_chat_message_create("Music: Megumi Nakajima - Sonna Koto Ura no Mata Urabanashi desho? (Kotoura-san OP) | Author: DaMemes")
            smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "04_Seq_kotourasanop_custom")
            djui_popup_create("Be sure to save and reload your current plot to finalize your selection!", 2)
            return true
        elseif msg == "17" then djui_chat_message_create("Music: Touhou 20: Fossilized Wonders - Golden Land of Prester John | Author: DaMemes")
            smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "05_Seq_th20stage3_custom")
            djui_popup_create("Be sure to save and reload your current plot to finalize your selection!", 2)
            return true
        elseif msg == "18" then djui_chat_message_create("Music: Touhou 20: Fossilized Wonders - Might as Well Stake Your Life to Solve the Riddle | Author: DaMemes")
            smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "06_Seq_th20nareko_custom")
            djui_popup_create("Be sure to save and reload your current plot to finalize your selection!", 2)
            return true
        elseif msg == "19" then djui_chat_message_create("Music: Touhou 11: Subterranean Animism - Walking the Streets of a Former Hell | Author: DaMemes")
            smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "07_Seq_th11stage3_custom")
            djui_popup_create("Be sure to save and reload your current plot to finalize your selection!", 2)
            return true
        elseif msg == "20" then djui_chat_message_create("Music: Touhou 9: Phantasmagoria of Flower View - Ghostly Band ~ Phantom Ensemble (Touhoumon Version) | Author: DaMemes")
            smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "08_Seq_touhoumonprismriver_custom")
            djui_popup_create("Be sure to save and reload your current plot to finalize your selection!", 2)
            return true
        elseif msg == "21" then djui_chat_message_create("Music: Touhou 16: Hidden Star in Four Seasons - Illusionary White Traveler | Author: DaMemes")
            smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "09_Seq_th16stage4r_custom")
            djui_popup_create("Be sure to save and reload your current plot to finalize your selection!", 2)
            return true
        elseif msg == "22" then djui_chat_message_create("Music: Touhou 16: Hidden Star in Four Seasons - Secret God Matara ~ Hidden Star in All Seasons | Author: DaMemes")
            smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "0A_Seq_th16okina2_custom")
            djui_popup_create("Be sure to save and reload your current plot to finalize your selection!", 2)
            return true
        elseif msg == "23" then djui_chat_message_create("Music: Xenoblade Chronicles - Gaur Plains (Day) | Author: Bubby64")
            smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "0B_Seq_xenogaurday_custom")
            djui_popup_create("Be sure to save and reload your current plot to finalize your selection!", 2)
            return true
        elseif msg == "24" then djui_chat_message_create("Music: Pokémon Mystery Dungeon: Explorers of Time/Darkness/Sky - Dialga's Fight to the Finish! Author: Bubby64")
            smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "0C_Seq_pmddialgafight_custom")
            djui_popup_create("Be sure to save and reload your current plot to finalize your selection!", 2)
            return true
        elseif msg == "25" then djui_chat_message_create("Music: Castlevania: Dawn of Sorrow - Cursed Clock Tower | Author: Mosky2000")
            smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "0D_Seq_castlevaniaclocktower_custom")
            djui_popup_create("Be sure to save and reload your current plot to finalize your selection!", 2)
            return true
        elseif msg == "26" then djui_chat_message_create("Music: Final Fantasy 8 - The Man with the Machine Gun | Author: Bubby64")
            smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "0E_Seq_ff8machinegun_custom")
            djui_popup_create("Be sure to save and reload your current plot to finalize your selection!", 2)
            return true
        else 
            djui_chat_message_create("Input [1-14] for vanilla music. Input [15-26] for custom music")
            return true
        end
    else
        djui_chat_message_create("You must enter a plot to run this command. [/plot [#]]")
        return true
    end
end

hook_chat_command("plot-music", "[1-26] | Changes music that plays in plots (will display port author as well). Custom music requires you to reload your plot to apply changes.", musicplot)
hook_chat_command("plot", "| Warp to a level with no textures or objects. Pass an argument to go to a specific act.", on_chat_command)
hook_event(HOOK_ON_LEVEL_INIT, on_lvl_init)
hook_event(HOOK_ON_PAUSE_EXIT, on_pause_exit)
