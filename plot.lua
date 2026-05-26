gLevelValues.floorLowerLimit = -32768
gLevelValues.floorLowerLimitMisc = -32768
gLevelValues.floorLowerLimitShadow = -32768
gLevelValues.cellHeightLimit = 32767

smlua_audio_utils_replace_sequence(0x64, 0x25, 75, "03_Seq_sms_custom")

LEVEL_PLOT = level_register("level_plot_entry", COURSE_NONE, "Plot", "plot", 20000, 0x28, 0x28, 0x28)

local MUSIC_CROSSCODE_TITLE = audio_stream_load("crosscode-title.ogg")
local MUSIC_DKC_AQUATIC_AQUARIUM = audio_stream_load("dkc-aquaticambience.ogg")
local MUSIC_BOTW_ZORAS_DOMAIN = audio_stream_load("zelda-zorasdomainday.ogg")
local MUSIC_DELTA_CASTLE_TOWN = audio_stream_load("delta-mycastletown.ogg")
local MUSIC_SMG_SPACE_JUNK = audio_stream_load("smg-spacejunk.ogg")
local MUSIC_ZELDA_ASTRAL_OBSERVATORY = audio_stream_load("zelda-astralobservatory.ogg")
local MUSIC_MOTHER_GENTLE_RAIN = audio_stream_load("mother-gentlerain.ogg")
local MUSIC_PVZ_LIVING_MICE = audio_stream_load("pvz2-livingmice.ogg")

-- alter to loop at certain points
audio_stream_set_looping(MUSIC_CROSSCODE_TITLE, true)
audio_stream_set_looping(MUSIC_DKC_AQUATIC_AQUARIUM, true)
audio_stream_set_looping(MUSIC_BOTW_ZORAS_DOMAIN, true)
audio_stream_set_looping(MUSIC_DELTA_CASTLE_TOWN, true)
audio_stream_set_looping(MUSIC_SMG_SPACE_JUNK, true)
audio_stream_set_looping(MUSIC_ZELDA_ASTRAL_OBSERVATORY, true)
audio_stream_set_looping(MUSIC_MOTHER_GENTLE_RAIN, true)
audio_stream_set_looping(MUSIC_PVZ_LIVING_MICE, true)

---@param name string
---@return integer?
local function get_player_index_from_name(name)
    local np = gNetworkPlayers
    for i = 0, MAX_PLAYERS - 1, 1 do
        if get_uncolored_string(np[i].name):lower() == get_uncolored_string(name):lower() then
            return network_global_index_from_local(i)
        end
    end
end

local sInvitedBy = {}
for i = 0, MAX_PLAYERS - 1, 1 do
    sInvitedBy[i] = false
end

---@param msg string
local function on_chat_command(msg)
    local commands = msg:split(" ")
    if tonumber(commands[1]) then
        local act = math.clamp(tonumber(commands[1]) or 0, 0, 255)
        if act >= 100 and act <= 100 + MAX_PLAYERS - 1 then
            djui_chat_message_create("This is a reserved plot. Cannot teleport")
            return true
        end
        warp_to_warpnode(LEVEL_PLOT, 1, act, 0xA)
    elseif commands[1] == "private" then
        ---@type NetworkPlayer
        local np = gNetworkPlayers[0]
        local act = 100 + np.globalIndex
        warp_to_warpnode(LEVEL_PLOT, 1, act, 0xA)
    elseif commands[1] == "invite" then
        local index = tonumber(commands[2]) or get_player_index_from_name(commands[2])
        if not index then
            djui_chat_message_create("Could not find player: " .. tostring(commands[2]))
            return true
        end
        network_send_to(network_local_index_from_global(index), true, { invite = true, index = gNetworkPlayers[0].globalIndex })
    elseif commands[1] == "join" then
        local index = tonumber(commands[2]) or get_player_index_from_name(commands[2])
        if not index then
            djui_chat_message_create("Could not find player: " .. tostring(commands[2]))
            return true
        end
        local np = network_player_from_global_index(index)
        if np.currActNum >= 100 and np.currActNum <= 100 + MAX_PLAYERS - 1 and not sInvitedBy[index] then
            djui_chat_message_create("You have not been invited to this plot")
            return true
        end
        warp_to_warpnode(LEVEL_PLOT, 1, np.currActNum, 0xA)
    end
    return true
end

local function on_packet_recieve(data)
    if data.invite then
        sInvitedBy[data.index] = true
        local np = network_player_from_global_index(data.index)
        local message = "You have been invited to " .. np.name .. "\\#dcdcdc\\ (" .. data.index .. ")" .. "'s private plot"
        djui_chat_message_create(message)
    end
end

local function on_lvl_init()
    if gNetworkPlayers[0].currLevelNum == LEVEL_PLOT then
        play_music(0, 0x64, 1)
        if get_current_background_music() == 0x64 then
            audio_stream_stop(MUSIC_DKC_AQUATIC_AQUARIUM)
            audio_stream_stop(MUSIC_BOTW_ZORAS_DOMAIN)
            audio_stream_stop(MUSIC_CROSSCODE_TITLE)
            audio_stream_stop(MUSIC_DELTA_CASTLE_TOWN)
            audio_stream_stop(MUSIC_SMG_SPACE_JUNK)
            audio_stream_stop(MUSIC_ZELDA_ASTRAL_OBSERVATORY)
            audio_stream_stop(MUSIC_MOTHER_GENTLE_RAIN)
            audio_stream_stop(MUSIC_PVZ_LIVING_MICE)
        end
    else
        audio_stream_stop(MUSIC_DKC_AQUATIC_AQUARIUM)
        audio_stream_stop(MUSIC_BOTW_ZORAS_DOMAIN)
        audio_stream_stop(MUSIC_CROSSCODE_TITLE)
        audio_stream_stop(MUSIC_DELTA_CASTLE_TOWN)
        audio_stream_stop(MUSIC_SMG_SPACE_JUNK)
        audio_stream_stop(MUSIC_ZELDA_ASTRAL_OBSERVATORY)
        audio_stream_stop(MUSIC_MOTHER_GENTLE_RAIN)
        audio_stream_stop(MUSIC_PVZ_LIVING_MICE)
    end
end

local function on_pause_exit(exit_to_castle)
    if gNetworkPlayers[0].currLevelNum == LEVEL_PLOT and not exit_to_castle then
        trigger_on_death()
    end
end

local function musicplot(msg) -- Various music for plots, can be used to add more if needed
    local vanilla_music = {
        [1] = {name = "Title Screen", composer = "Koji Kondo", song = SEQ_MENU_TITLE_SCREEN},
        [2] = {name = "Bob-omb Battlefield", composer = "Koji Kondo", song = SEQ_LEVEL_GRASS},
        [3] = {name = "Peach's Castle", composer = "Koji Kondo", song = SEQ_LEVEL_INSIDE_CASTLE},
        [4] = {name = "Dire, Dire Docks", composer = "Koji Kondo", song = SEQ_LEVEL_WATER},
        [5] = {name = "Lethal Lava Land", composer = "Koji Kondo", song = SEQ_LEVEL_HOT},
        [6] = {name = "Princess' Secret Slide", composer = "Koji Kondo", song = SEQ_LEVEL_SLIDE},
        [7] = {name = "Big Boo's Haunt", composer = "Koji Kondo", song = SEQ_LEVEL_SPOOKY},
        [8] = {name = "Hazy Maze Cave", composer = "Koji Kondo", song = SEQ_LEVEL_UNDERGROUND},
        [9] = {name = "Merry-Go-Round", composer = "Koji Kondo", song = SEQ_EVENT_MERRY_GO_ROUND},
        [10] = {name = "The Endless Staircase", composer = "Koji Kondo", song = SEQ_EVENT_ENDLESS_STAIRS},
        [11] = {name = "Koopa Road", composer = "Koji Kondo", song = SEQ_LEVEL_KOOPA_ROAD},
        [12] = {name = "Stage Boss", composer = "Koji Kondo", song = SEQ_EVENT_BOSS},
        [13] = {name = "Bowser's Theme", composer = "Koji Kondo", song = SEQ_LEVEL_BOSS_KOOPA},
        [14] = {name = "Ultimate Bowser", composer = "Koji Kondo", song = SEQ_LEVEL_BOSS_KOOPA_FINAL},
    }

    local ogg_music = {
        [15] = {name = "Donkey Kong Country - Aquatic Ambience", composer = "David Wise", song = MUSIC_DKC_AQUATIC_AQUARIUM},
        [16] = {name = "The Legend of Zelda: Breath of the Wild - Zora's Domain (Day)", composer = "Koji Kondo", song = MUSIC_BOTW_ZORAS_DOMAIN},
        [17] = {name = "Crosscode - Title", composer = "Deniz Akbulut", song = MUSIC_CROSSCODE_TITLE},
        [18] = {name = "Deltarune - My Castle Town", composer = "Toby Fox", song = MUSIC_DELTA_CASTLE_TOWN},
        [19] = {name = "Super Mario Galaxy - Space Junk Galaxy", composer = "Mahito Yokota", song = MUSIC_SMG_SPACE_JUNK},
        [20] = {name = "The Legned of Zelda: Majora's Mask - Astral Observatory", composer = "Koji Kondo", song = MUSIC_ZELDA_ASTRAL_OBSERVATORY},
        [21] = {name = "Mother 3 - Gentle Rain", composer = "Shogo Sakai", song = MUSIC_MOTHER_GENTLE_RAIN},
        [22] = {name = "C418 - Living Mice (PvZ 2 Style)", composer = "J. Rivers", song = MUSIC_PVZ_LIVING_MICE},
    }

    local m64_music = {
        [23] = {name = "Super Mario Sunshine - Sky & Sea", composer = "Shinobu Tanaka (ported by ???)", song = "03_Seq_sms_custom", soundfont = 0x25},
        [24] = {name = "Chrono Trigger - Corridors of Time", composer = "Yasunori Mitsuda (ported by scuttlebug_raiser)", song = "0F_Seq_corridorsoftime_custom", soundfont = 0x2A},
        [25] = {name = "Pokemon Platinum :Eterna Forest", composer = "Hitomi Sato (ported by Asbeth)", song = "10_Seq_eternaforest_custom", soundfont = 0x0C},
        [26] = {name = "Animal Crossing: New Horizons - 12PM", composer = "Kazumi Totaka (ported by ???)", song = "11_Seq_nhorizons12pm_custom", soundfont = 0x11},
        [27] = {name = "Kirby's Adventure - Orange Ocean", composer = "Hirokazu Ando (ported by ???)", song = "12_Seq_kirbyoraocea_custom", soundfont = 0x25},
        [28] = {name = "Mario Kart 8 Deluxe - Results (Animal Crossing)", composer = "Atsuko Asahi (ported by ???)", song = "13_Seq_mk8acresults_custom", soundfont = 0x25},
        [29] = {name = "Rhythm Heaven - Lockstep", composer = "Tsunku (ported by Mese_Insanity)", song = "14_Seq_rhlockstep_custom", soundfont = 0x11},
        [30] = {name = "Super Mario World - Underwater", composer = "Koji Kondo (ported by ???)", song = "15_Seq_smwwater_custom", soundfont = 0x25},
        [31] = {name = "Mother 3 - Snowman", composer = "Shogo Sakai (ported by DaMemes)", song = "16_Seq_mothersnowman_custom", soundfont = 0x25},
        [32] = {name = "Sonna Koto Ura no Mata Urabanashi desho?", composer = "Megumi Nakajima (ported by DaMemes)", song = "04_Seq_kotourasanop_custom", soundfont = 0x25},
        [33] = {name = "Touhou 20: Fossilized Wonders - Golden Land of Prester John", composer = "ZUN (ported by DaMemes)", song = "05_Seq_th20stage3_custom", soundfont = 0x25},
        [34] = {name = "Touhou 20: Fossilized Wonders - Might As Well Stake Your Life to Solve the Riddle", composer = "ZUN (ported by DaMemes)", song = "06_Seq_th20nareko_custom", soundfont = 0x25},
        [35] = {name = "Touhou 11: Subterranean Animism - Walking the Streets of a Former Hell", composer = "ZUN (ported by DaMemes)", song = "07_Seq_th11stage3_custom", soundfont = 0x25},
        [36] = {name = "Touhou 9: Phantasmagoria of Flower View - Ghostly Band ~ Phantom Ensemble (Touhoumon Version)", composer = "ZUN (ported by DaMemes)", song = "08_Seq_touhoumonprismriver_custom", soundfont = 0x25},
        [37] = {name = "Touhou 16: Hidden Star in Four Seasons - Illusionary White Traveler", composer = "ZUN (ported by DaMemes)", song = "09_Seq_th16stage4r_custom", soundfont = 0x25},
        [38] = {name = "Touhou 16: Hidden Star in Four Seasons - Secret God Matara ~ Hidden Star in All Seasons", composer = "ZUN (ported by DaMemes)", song = "0A_Seq_th16okina2_custom", soundfont = 0x25},
        [39] = {name = "Xenoblade Chronicles - Gaur Plains (Day)", composer = "ACE+ (ported by Bubby64)", song = "0B_Seq_xenogaurday_custom", soundfont = 0x25},
        [40] = {name = "Pokémon Mystery Dungeon: Explorers of Time/Darkness/Sky - Dialga's Fight to the Finish!", composer = "Arata Iiyoshi (ported by Bubby64)", song = "0C_Seq_pmddialgafight_custom", soundfont = 0x25},
        [41] = {name = "Castlevania: Dawn of Sorrow - Cursed Clock Tower", composer = "Michiru Yamane (ported by Mosky2000)", song = "0D_Seq_castlevaniaclocktower_custom", soundfont = 0x25},
        [42] = {name = "Final Fantasy 8 - The Man with the Machine Gun", composer = "Nobuo Uematsu (ported by Bubby64)", song = "0E_Seq_ff8machinegun_custom", soundfont = 0x25}
    }

    if gNetworkPlayers[0].currLevelNum == LEVEL_PLOT then
        local selectionV = vanilla_music[tonumber(msg)]
        local selectionO = ogg_music[tonumber(msg)]
        local selectionM = m64_music[tonumber(msg)]

        if selectionV then
            djui_chat_message_create("Music: " .. selectionV.name .. " | Composer: " .. selectionV.composer)
            audio_stream_stop(MUSIC_DKC_AQUATIC_AQUARIUM)
            audio_stream_stop(MUSIC_BOTW_ZORAS_DOMAIN)
            audio_stream_stop(MUSIC_CROSSCODE_TITLE)
            audio_stream_stop(MUSIC_DELTA_CASTLE_TOWN)
            audio_stream_stop(MUSIC_SMG_SPACE_JUNK)
            audio_stream_stop(MUSIC_ZELDA_ASTRAL_OBSERVATORY)
            audio_stream_stop(MUSIC_MOTHER_GENTLE_RAIN)
            audio_stream_stop(MUSIC_PVZ_LIVING_MICE)
            smlua_audio_utils_reset_all()
            set_background_music(SEQ_PLAYER_LEVEL, selectionV.song, 0)
            return true
        elseif selectionO then
            djui_chat_message_create("Music: " .. selectionO.name .. " | Composer: " .. selectionO.composer)
            audio_stream_stop(MUSIC_DKC_AQUATIC_AQUARIUM)
            audio_stream_stop(MUSIC_BOTW_ZORAS_DOMAIN)
            audio_stream_stop(MUSIC_CROSSCODE_TITLE)
            audio_stream_stop(MUSIC_DELTA_CASTLE_TOWN)
            audio_stream_stop(MUSIC_SMG_SPACE_JUNK)
            audio_stream_stop(MUSIC_ZELDA_ASTRAL_OBSERVATORY)
            audio_stream_stop(MUSIC_MOTHER_GENTLE_RAIN)
            audio_stream_stop(MUSIC_PVZ_LIVING_MICE)
            play_music(0, 0, 1)
            audio_stream_play(selectionO.song, true, 1)
            return true
        elseif selectionM then
            djui_chat_message_create("Music: " .. selectionM.name .. " | Composer: " .. selectionM.composer)
            audio_stream_stop(MUSIC_DKC_AQUATIC_AQUARIUM)
            audio_stream_stop(MUSIC_BOTW_ZORAS_DOMAIN)
            audio_stream_stop(MUSIC_CROSSCODE_TITLE)
            audio_stream_stop(MUSIC_DELTA_CASTLE_TOWN)
            audio_stream_stop(MUSIC_SMG_SPACE_JUNK)
            audio_stream_stop(MUSIC_ZELDA_ASTRAL_OBSERVATORY)
            audio_stream_stop(MUSIC_MOTHER_GENTLE_RAIN)
            audio_stream_stop(MUSIC_PVZ_LIVING_MICE)
            smlua_audio_utils_replace_sequence(0x64, selectionM.soundfont, 75, selectionM.song)
            djui_popup_create("Be sure to save and reload your current plot to finalize your selection!", 2)
            return true
        else
            djui_chat_message_create("Invalid selection. Please enter a number corresponding to the music you want to play. [1-42]")
            return true
        end
    else
        djui_chat_message_create("You must enter a plot to run this command. [/plot]")
        return true
    end
end

local function mario_update(m)
    local np = gNetworkPlayers[m.playerIndex]
    if np.currLevelNum == LEVEL_PLOT then
        network_player_set_override_location(np, "Plot")
    else
        local level = get_level_name(np.currCourseNum, np.currLevelNum, np.currAreaIndex)
        network_player_set_override_location(np, level)
    end

    if is_game_paused() then
        audio_stream_pause(MUSIC_CROSSCODE_TITLE)
        audio_stream_pause(MUSIC_DKC_AQUATIC_AQUARIUM)
        audio_stream_pause(MUSIC_BOTW_ZORAS_DOMAIN)
        audio_stream_pause(MUSIC_DELTA_CASTLE_TOWN)
        audio_stream_pause(MUSIC_SMG_SPACE_JUNK)
        audio_stream_pause(MUSIC_ZELDA_ASTRAL_OBSERVATORY)
        audio_stream_stop(MUSIC_MOTHER_GENTLE_RAIN)
        audio_stream_stop(MUSIC_PVZ_LIVING_MICE)
    end
end

hook_chat_command("plot-music", "[1-42] | Changes what music plays while in a plot. Custom music requires you to reload your plot to apply changes.", musicplot)
hook_chat_command("plot", "[<act>|private|invite [<player name/index>]|join [<player name/index>]] | Warp to a level with no textures or objects. Pass an argument to go to a specific act.", on_chat_command)
hook_event(HOOK_ON_PACKET_RECEIVE, on_packet_recieve)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_LEVEL_INIT, on_lvl_init)
hook_event(HOOK_ON_PAUSE_EXIT, on_pause_exit)
hook_event(HOOK_MARIO_UPDATE, mario_update)
