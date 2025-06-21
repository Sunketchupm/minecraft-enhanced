local stages = {
    {"bob","c1",LEVEL_BOB},
    {"wf","c2",LEVEL_WF},
    {"jrb","c3",LEVEL_JRB},
    {"ccm","c4",LEVEL_CCM},
    {"bbh","c5",LEVEL_BBH},
    {"hmc","c6",LEVEL_HMC},
    {"lll","c7",LEVEL_LLL},
    {"ssl","c8",LEVEL_SSL},
    {"ddd","c9",LEVEL_DDD},
    {"sl","c10",LEVEL_SL},
    {"wdw","c11",LEVEL_WDW},
    {"ttm","c12",LEVEL_TTM},
    {"thi","c13",LEVEL_THI},
    {"ttc","c14",LEVEL_TTC},
    {"rr","c15",LEVEL_RR},

    {'pss',"s1",LEVEL_PSS},
    {'wmotr',"s2",LEVEL_WMOTR},
    {'sa',"s3",LEVEL_SA},
    {'ending',"s4",LEVEL_ENDING},

    {'totwc',"wc",LEVEL_TOTWC},
    {'vcutm',"vc",LEVEL_VCUTM},
    {'cotmc',"mc",LEVEL_COTMC},

    {"bitdw","b1",LEVEL_BITDW},
    {"bowser1fight","b1f",LEVEL_BOWSER_1},
    {"bitfs","b2",LEVEL_BITFS},
    {"bowser2fight","b2f",LEVEL_BOWSER_2},
    {"bits","b3",LEVEL_BITS},
    {"bowser3fight","b3f",LEVEL_BOWSER_3},

    {'castlegrounds',"ow1",LEVEL_CASTLE_GROUNDS},
    {'castleinside',"ow2",LEVEL_CASTLE},
    {'castlecourtyard',"ow3",LEVEL_CASTLE_COURTYARD}
}

local level_to_course = {
    [LEVEL_BOB] = COURSE_BOB,
    [LEVEL_WF ] = COURSE_WF,
    [LEVEL_JRB] = COURSE_JRB,
    [LEVEL_CCM] = COURSE_CCM,
    [LEVEL_BBH] = COURSE_BBH,
    [LEVEL_HMC] = COURSE_HMC,
    [LEVEL_LLL] = COURSE_LLL,
    [LEVEL_SSL] = COURSE_SSL,
    [LEVEL_DDD] = COURSE_DDD,
    [LEVEL_SL ] = COURSE_SL,
    [LEVEL_WDW] = COURSE_WDW,
    [LEVEL_TTM] = COURSE_TTM,
    [LEVEL_THI] = COURSE_THI,
    [LEVEL_TTC] = COURSE_TTC,
    [LEVEL_RR ] = COURSE_RR,

    [LEVEL_BITDW] = COURSE_BITDW,
    [LEVEL_BITFS] = COURSE_BITFS,
    [LEVEL_BITS]  =  COURSE_BITS,
    [LEVEL_BOWSER_1] = COURSE_BITDW,
    [LEVEL_BOWSER_2] = COURSE_BITFS,
    [LEVEL_BOWSER_3] = COURSE_BITS,

    [LEVEL_COTMC] = COURSE_COTMC,
    [LEVEL_TOTWC] = COURSE_TOTWC,
    [LEVEL_VCUTM] = COURSE_VCUTM,

    [LEVEL_PSS]    = COURSE_PSS,
    [LEVEL_SA]     = COURSE_SA,
    [LEVEL_WMOTR]  = COURSE_WMOTR,
    [LEVEL_ENDING] = COURSE_CAKE_END,

    [LEVEL_CASTLE] = COURSE_NONE,
    [LEVEL_CASTLE_GROUNDS] = COURSE_NONE,
    [LEVEL_CASTLE_COURTYARD] = COURSE_NONE,
}

local function on_warp_command(msg)
    msg = split_string(msg, " ")

	local level = LEVEL_BOB
    local area = 1
    local act = 1
    local node = 10
    for _, value in pairs(stages) do
        if msg[1] == value[1] or msg[1] == value[2] then
            level = value[3]
            area = tonumber(msg[2]) or 1
            act = tonumber(msg[3]) or (course_is_main_course(level_to_course[level]) and 1 or 0)
            if msg[4] and string.sub(msg[4], 1, 2) == "0x" then
                node = tonumber(string.sub(msg[4], 3, #msg[4]), 16) or 10
            else
                node = tonumber(msg[4]) or 10
            end
            break
        end
    end
    warp_to_warpnode(level, area, act, node)
    return true
end

hook_chat_command('warp', "Usage is: /warp <course abbreviation/number> [area] [star]", on_warp_command)