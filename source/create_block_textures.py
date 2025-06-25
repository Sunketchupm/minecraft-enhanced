import os
import math

INITIAL_DIR = "."
BUILTIN_TEXTURES_FILE = os.path.join("dynos_mgr_builtin_tex.cpp")

if not os.path.exists(BUILTIN_TEXTURES_FILE):
    print("dynos_mgr_builtin_tex.cpp could not be found")
    exit()

texture_names: list[str] = []

include_folders = (
    "textures",
    "levels",
)

exclude_subfolders = (
    "textures/effect",
    "textures/segment2", # Segment2 gets special handling
    "textures/custom_font",
    "textures/skybox_tiles",
)

override_include_texture_names = (
    "amp_seg8_texture_08000F18",
    "amp_seg8_texture_08001B18",
    "blue_coin_switch_seg8_texture_08000418",
    "blue_fish_seg3_texture_0301B5E0",
    "book_seg5_texture_05002570",
    "bowser_seg6_texture_0601F438",
    "bowser_seg6_texture_06022438",
    "bowser_seg6_texture_06023C38",
    "bowser_seg6_texture_06028438",
    "bowser_seg6_texture_06028C38",
    "breakable_box_seg8_texture_08011A90",
    "breakable_box_seg8_texture_08012290",
    "bub_seg6_texture_0600EAA8",
    "bub_seg6_texture_0600F2A8",
    "bub_seg6_texture_060102A8",
    "bubble_seg4_texture_0401CD60",
    "bubble_seg4_texture_0401D560",
    "cannon_barrel_seg8_texture_080058A8",
    "cannon_base_seg8_texture_080049B8",
    "cannon_lid_seg8_texture_08004058",
    "chain_ball_seg6_texture_06020AE8",
    "chair_seg5_texture_05003060",
    "chair_seg5_texture_05003860",
    "chair_seg5_texture_05004060",
    "chair_seg5_texture_05004460",
    "checkerboard_platform_seg8_texture_0800C840",
    "checkerboard_platform_seg8_texture_0800CC40",
    "door_seg3_texture_03009D10",
    "door_seg3_texture_0300AD10",
    "door_seg3_texture_0300BD10",
    "door_seg3_texture_0300CD10",
    "door_seg3_texture_0300D510",
    "door_seg3_texture_0300E510",
    "door_seg3_texture_0300ED10",
    "door_seg3_texture_0300FD10",
    "door_seg3_texture_03010510",
    "door_seg3_texture_03011510",
    "door_seg3_texture_03011D10",
    "door_seg3_texture_03012510",
    "door_seg3_texture_03012D10",
    "exclamation_box_seg8_texture_08012E28",
    "exclamation_box_seg8_texture_08013628",
    "exclamation_box_seg8_texture_08014628",
    "exclamation_box_seg8_texture_08014E28",
    "exclamation_box_seg8_texture_08015E28",
    "exclamation_box_seg8_texture_08016628",
    "exclamation_box_seg8_texture_08017628",
    "exclamation_box_seg8_texture_08017E28",
    "exclamation_box_outline_seg8_texture_08025168",
    "exclamation_box_outline_seg8_texture_08025A80",
    "flyguy_seg8_texture_0800E088",
    "flyguy_seg8_texture_0800F088",
    "goomba_seg8_texture_08019530",
    "goomba_seg8_texture_08019D30",
    "goomba_seg8_texture_0801A530",
    "haunted_cage_seg5_texture_0500C288",
    "haunted_cage_seg5_texture_0500CA88",
    "haunted_cage_seg5_texture_0500D288",
    "haunted_cage_seg5_texture_0500D688",
    "haunted_cage_seg5_texture_0500DA88",
    "heart_seg8_texture_0800D7E0",
    "heave_ho_seg5_texture_0500E9C8",
    "heave_ho_seg5_texture_0500F1C8",
    "heave_ho_seg5_texture_0500F9C8",
    "heave_ho_seg5_texture_050109C8",
    "koopa_seg6_texture_06002648",
    "koopa_seg6_texture_06002E48",
    "koopa_seg6_texture_06003648",
    "koopa_seg6_texture_06003E48",
    "lakitu_seg6_texture_06000000",
    "lakitu_seg6_texture_06002800",
    "metal_box_seg8_texture_08023998",
    "mushroom_1up_seg3_texture_03029628",
    "piranha_plant_seg6_texture_060123F8",
    "poundable_pole_seg6_texture_06001050",
    "texture_power_meter_full",
    "texture_power_meter_seven_segments",
    "texture_power_meter_six_segments",
    "texture_power_meter_five_segments",
    "texture_power_meter_four_segments",
    "texture_power_meter_three_segments",
    "texture_power_meter_two_segments",
    "texture_power_meter_one_segments",
    "purple_switch_seg8_texture_0800C128",
    "sparkles_seg4_texture_04027490",
    "sparkles_seg4_texture_04027C90",
    "sparkles_seg4_texture_04028490",
    "sparkles_seg4_texture_04028C90",
    "sparkles_seg4_texture_04029490",
    "sparkles_seg4_texture_04029C90",
    "springboard_seg5_texture_05000018",
    "springboard_seg5_texture_05000818",
    "star_seg3_texture_0302A6F0",
    "thwomp_seg5_texture_05009900",
    "thwomp_seg5_texture_0500A900",
    "toad_seg6_texture_06005920",
    "toad_seg6_texture_06006120",
    "treasure_chest_seg6_texture_06013FA8",
    "treasure_chest_seg6_texture_060147A8",
    "treasure_chest_seg6_texture_06014FA8",
    "treasure_chest_seg6_texture_060157A8",
    "ukiki_seg5_texture_0500A3C0",
    "warp_pipe_seg3_texture_03007E40",
    "warp_pipe_seg3_texture_03009168",
    "water_bubble_seg5_texture_0500FE80",
    "water_ring_seg6_texture_06012380",
    "whomp_seg6_texture_0601C360",
    "whomp_seg6_texture_0601D360",
    "whomp_seg6_texture_0601EB60",
    "wooden_signpost_seg3_texture_0302C9C8",
    "wooden_signpost_seg3_texture_0302D1C8",
)

override_exclude_texture_names = (
    "generic_0900B000",
)

segment_2_textures = (
	"texture_hud_char_0",
    "texture_hud_char_1",
    "texture_hud_char_2",
    "texture_hud_char_3",
    "texture_hud_char_4",
    "texture_hud_char_5",
    "texture_hud_char_6",
    "texture_hud_char_7",
    "texture_hud_char_8",
    "texture_hud_char_9",
    "texture_hud_char_A",
    "texture_hud_char_B",
    "texture_hud_char_C",
    "texture_hud_char_D",
    "texture_hud_char_E",
    "texture_hud_char_F",
    "texture_hud_char_G",
    "texture_hud_char_H",
    "texture_hud_char_I",
    "texture_hud_char_J",
    "texture_hud_char_K",
    "texture_hud_char_L",
    "texture_hud_char_M",
    "texture_hud_char_N",
    "texture_hud_char_O",
    "texture_hud_char_P",
    "texture_hud_char_Q",
    "texture_hud_char_R",
    "texture_hud_char_S",
    "texture_hud_char_T",
    "texture_hud_char_U",
    "texture_hud_char_V",
    "texture_hud_char_W",
    "texture_hud_char_X",
    "texture_hud_char_Y",
    "texture_hud_char_Z",
    "texture_hud_char_apostrophe",
    "texture_hud_char_double_quote",
    "texture_hud_char_exclamation",
    "texture_hud_char_hashtag",
    "texture_hud_char_question",
    "texture_hud_char_ampersand",
    "texture_hud_char_percent",
    "texture_hud_char_slash",
    "texture_hud_char_multiply",
    "texture_hud_char_coin",
    "texture_hud_char_mario_head",
    "texture_hud_char_luigi_head",
    "texture_hud_char_toad_head",
    "texture_hud_char_waluigi_head",
    "texture_hud_char_wario_head",
    "texture_hud_char_star",
    "texture_hud_char_period",
    "texture_hud_char_key",
    "texture_hud_char_comma",
    "texture_hud_char_dash",
    "texture_hud_char_divide",
    "texture_hud_char_period",
    "texture_hud_char_plus",
    "texture_credits_char_3",
    "texture_credits_char_4",
    "texture_credits_char_6",
    "texture_credits_char_A",
    "texture_credits_char_B",
    "texture_credits_char_C",
    "texture_credits_char_D",
    "texture_credits_char_E",
    "texture_credits_char_F",
    "texture_credits_char_G",
    "texture_credits_char_H",
    "texture_credits_char_I",
    "texture_credits_char_J",
    "texture_credits_char_K",
    "texture_credits_char_L",
    "texture_credits_char_M",
    "texture_credits_char_N",
    "texture_credits_char_O",
    "texture_credits_char_P",
    "texture_credits_char_Q",
    "texture_credits_char_R",
    "texture_credits_char_S",
    "texture_credits_char_T",
    "texture_credits_char_U",
    "texture_credits_char_V",
    "texture_credits_char_W",
    "texture_credits_char_X",
    "texture_credits_char_Y",
    "texture_credits_char_Z",
    "texture_credits_char_period",
    "texture_hud_char_camera",
    "texture_hud_char_lakitu",
    "texture_hud_char_no_camera",
    "texture_hud_char_arrow_up",
    "texture_hud_char_arrow_down",
    "texture_shadow_quarter_circle",
    "texture_shadow_quarter_square",
    "texture_shadow_spike_ext",
    "texture_transition_star_half",
    "texture_transition_circle_half",
    "texture_transition_mario",
    "texture_transition_bowser_half",
    "texture_waterbox_water",
    "texture_waterbox_jrb_water",
    "texture_waterbox_unknown_water",
    "texture_waterbox_mist",
    "texture_waterbox_lava",
    "texture_ia8_up_arrow",
)

ignore_segments = False
with open(BUILTIN_TEXTURES_FILE, "r") as file:
    for line in file:
        stripped_line = line.strip()
        if stripped_line.startswith("#ifndef VERSION_JP") or stripped_line.startswith("#ifndef VERSION_EU"):
            ignore_segments = False
        elif not ignore_segments and line.strip().startswith("#else"):
            ignore_segments = True
        elif ignore_segments and line.strip().startswith("#endif"):
            ignore_segments = False

        if stripped_line.startswith("#if defined(VERSION_JP)") or stripped_line.startswith("#elif defined(VERSION_EU)") or stripped_line.startswith("#if defined(VERSION_JP)") or stripped_line.startswith("#ifdef VERSION_EU"):
            ignore_segments = True
        elif ignore_segments and line.strip().startswith("#else"):
            ignore_segments = False

        if not ignore_segments and stripped_line.startswith("define_builtin_tex") and not stripped_line.startswith("define_builtin_tex_"):
            # name, path, width, height, bitsize
            params = line[line.find("("):-2].replace("(", "").replace(")", "").replace(" ", "").split(",")
            is_power_of_2 = math.log2(int(params[2])).is_integer() and math.log2(int(params[3])).is_integer() and math.log2(int(params[4])).is_integer()
            containing_folder = params[1].split("/")[0][1:]
            is_in_containing_folder = any(containing_folder in folder for folder in include_folders)
            is_excluded_subfolder = False
            for folder in exclude_subfolders:
                is_excluded_subfolder = line.find(folder) != -1
                if is_excluded_subfolder:
                    break
            is_override_in = True#any(params[0] in name for name in override_include_texture_names)
            is_override_out = any(params[0] in name for name in override_exclude_texture_names)
            if is_power_of_2 and ((is_in_containing_folder and not is_excluded_subfolder and not is_override_out) or is_override_in):
                texture_names.append(params[0])
    print("Got texture names")

with open(os.path.join(INITIAL_DIR, "!TEXTURES.txt"), "w") as file:
    for name in texture_names:
        file.write(f"    g(\"{name}\"),\n")
    for name in segment_2_textures:
        file.write(f"    g(\"{name}\"),\n")

with open(os.path.join(INITIAL_DIR, "!GEO.txt"), "w") as file:
    file.write(

'#include "src/game/envfx_snow.h"\n\
\n\
const GeoLayout mce_block_geo[] = {\n\
	GEO_NODE_START(),\n\
	GEO_OPEN_NODE(),\n\
		GEO_ANIMATED_PART(LAYER_ALPHA, 0, 0, 0, NULL),\n\
		GEO_OPEN_NODE(),\n\
			GEO_ASM(30, geo_update_layer_transparency),\n\
			GEO_SWITCH_CASE(' + str(((len(texture_names) + len(segment_2_textures)) * 2) + 1) + ', geo_switch_anim_state),\n\
			GEO_OPEN_NODE(),\n\
				GEO_NODE_START(),\n\
				GEO_OPEN_NODE(),\n\
					GEO_ANIMATED_PART(LAYER_ALPHA, 0, 276, 0, ' + str(texture_names[0]) + '_mat),\n\
				GEO_CLOSE_NODE(),\n'
)
    file.write(f"            // Transparent start: {str(len(texture_names) + len(segment_2_textures))}\n")
    for name in texture_names:
        file.write(f"				GEO_DISPLAY_LIST(LAYER_ALPHA, {name}_mat),\n")
    for name in segment_2_textures:
        file.write(f"				GEO_DISPLAY_LIST(LAYER_ALPHA, {name}_mat),\n")
    for name in texture_names:
        file.write(f"				GEO_DISPLAY_LIST(LAYER_TRANSPARENT, {name}_mat),\n")
    for name in segment_2_textures:
        file.write(f"				GEO_DISPLAY_LIST(LAYER_TRANSPARENT, {name}_mat),\n")

    file.write('\
			GEO_CLOSE_NODE(),\n\
		GEO_CLOSE_NODE(),\n\
	GEO_CLOSE_NODE(),\n\
	GEO_END(),\n\
};')
    
with open(os.path.join(INITIAL_DIR, "!MODEL.txt"), "w") as file:
    file.write(
'\n\
Lights1 mce_block_f3dlite_material_lights = gdSPDefLights1(\n\
	0x7F, 0x7F, 0x7F,\n\
	0xFF, 0xFF, 0xFF, 0x49, 0x49, 0x49);\n\
\n\
Vtx mce_block_verticies[24] = {\n\
	{{ {-100, -100, 100}, 0, {-16, 1008}, {129, 0, 0, 255} }},\n\
	{{ {-100, 100, 100}, 0, {1008, 1008}, {129, 0, 0, 255} }},\n\
	{{ {-100, 100, -100}, 0, {1008, -16}, {129, 0, 0, 255} }},\n\
	{{ {-100, -100, -100}, 0, {-16, -16}, {129, 0, 0, 255} }},\n\
	{{ {100, -100, 100}, 0, {-16, 1008}, {0, 0, 127, 255} }},\n\
	{{ {-100, 100, 100}, 0, {1008, -16}, {0, 0, 127, 255} }},\n\
	{{ {-100, -100, 100}, 0, {-16, -16}, {0, 0, 127, 255} }},\n\
	{{ {100, 100, 100}, 0, {1008, 1008}, {0, 0, 127, 255} }},\n\
	{{ {-100, -100, -100}, 0, {-16, 1008}, {0, 129, 0, 255} }},\n\
	{{ {100, -100, 100}, 0, {1008, -16}, {0, 129, 0, 255} }},\n\
	{{ {-100, -100, 100}, 0, {-16, -16}, {0, 129, 0, 255} }},\n\
	{{ {100, -100, -100}, 0, {1008, 1008}, {0, 129, 0, 255} }},\n\
	{{ {100, 100, -100}, 0, {-16, 1008}, {0, 127, 0, 255} }},\n\
	{{ {-100, 100, -100}, 0, {1008, 1008}, {0, 127, 0, 255} }},\n\
	{{ {-100, 100, 100}, 0, {1008, -16}, {0, 127, 0, 255} }},\n\
	{{ {100, 100, 100}, 0, {-16, -16}, {0, 127, 0, 255} }},\n\
	{{ {-100, -100, -100}, 0, {-16, 1008}, {0, 0, 129, 255} }},\n\
	{{ {-100, 100, -100}, 0, {1008, 1008}, {0, 0, 129, 255} }},\n\
	{{ {100, 100, -100}, 0, {1008, -16}, {0, 0, 129, 255} }},\n\
	{{ {100, -100, -100}, 0, {-16, -16}, {0, 0, 129, 255} }},\n\
	{{ {100, -100, -100}, 0, {-16, 1008}, {127, 0, 0, 255} }},\n\
	{{ {100, 100, 100}, 0, {1008, -16}, {127, 0, 0, 255} }},\n\
	{{ {100, -100, 100}, 0, {-16, -16}, {127, 0, 0, 255} }},\n\
	{{ {100, 100, -100}, 0, {1008, 1008}, {127, 0, 0, 255} }},\n\
};\n\
\n\
Gfx mce_block_tris[] = {\n\
	gsSPVertex(mce_block_verticies + 0, 16, 0),\n\
	gsSP1Triangle(0, 1, 2, 0),\n\
	gsSP1Triangle(0, 2, 3, 0),\n\
	gsSP1Triangle(4, 5, 6, 0),\n\
	gsSP1Triangle(4, 7, 5, 0),\n\
	gsSP1Triangle(8, 9, 10, 0),\n\
	gsSP1Triangle(8, 11, 9, 0),\n\
	gsSP1Triangle(12, 13, 14, 0),\n\
	gsSP1Triangle(12, 14, 15, 0),\n\
	gsSPVertex(mce_block_verticies + 16, 8, 0),\n\
	gsSP1Triangle(0, 1, 2, 0),\n\
	gsSP1Triangle(0, 2, 3, 0),\n\
	gsSP1Triangle(4, 5, 6, 0),\n\
	gsSP1Triangle(4, 7, 5, 0),\n\
	gsSPEndDisplayList(),\n\
}; \n'
)
    for name in texture_names:
        file.write(
'\n\
Gfx ' + name +'_mat[] = {\n\
    gsSPSetLights1(mce_block_f3dlite_material_lights),\n\
    gsDPPipeSync(),\n\
    gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0),\n\
    gsDPSetAlphaDither(G_AD_NOISE),\n\
    gsSPTexture(65535, 65535, 0, 0, 1),\n\
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, ' + name +'),\n\
    gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),\n\
    gsDPLoadBlock(7, 0, 0, 1023, 256),\n\
    gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 8, 0, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 5, 0, G_TX_WRAP | G_TX_NOMIRROR, 5, 0),\n\
    gsDPSetTileSize(0, 0, 0, 124, 124),\n\
    gsSPDisplayList(mce_block_tris),\n\
    gsDPPipeSync(),\n\
    gsDPSetAlphaDither(G_AD_DISABLE),\n\
    gsDPPipeSync(),\n\
    gsSPSetGeometryMode(G_LIGHTING),\n\
    gsSPClearGeometryMode(G_TEXTURE_GEN),\n\
    gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),\n\
    gsSPTexture(65535, 65535, 0, 0, 0),\n\
    gsDPSetEnvColor(255, 255, 255, 255),\n\
    gsDPSetAlphaCompare(G_AC_NONE),\n\
    gsSPEndDisplayList(),\n\
};\n')
		
    for name in segment_2_textures:
        file.write(
'\n\
Gfx ' + name +'_mat[] = {\n\
    gsSPSetLights1(mce_block_f3dlite_material_lights),\n\
    gsDPPipeSync(),\n\
    gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0),\n\
    gsDPSetAlphaDither(G_AD_NOISE),\n\
    gsSPTexture(65535, 65535, 0, 0, 1),\n\
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 1, ' + name +'),\n\
    gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b_LOAD_BLOCK, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),\n\
    gsDPLoadBlock(7, 0, 0, 1023, 256),\n\
    gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 8, 0, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 5, 0, G_TX_WRAP | G_TX_NOMIRROR, 5, 0),\n\
    gsDPSetTileSize(0, 0, 0, 124, 124),\n\
    gsSPDisplayList(mce_block_tris),\n\
    gsDPPipeSync(),\n\
    gsDPSetAlphaDither(G_AD_DISABLE),\n\
    gsDPPipeSync(),\n\
    gsSPSetGeometryMode(G_LIGHTING),\n\
    gsSPClearGeometryMode(G_TEXTURE_GEN),\n\
    gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),\n\
    gsSPTexture(65535, 65535, 0, 0, 0),\n\
    gsDPSetEnvColor(255, 255, 255, 255),\n\
    gsDPSetAlphaCompare(G_AC_NONE),\n\
    gsSPEndDisplayList(),\n\
};\n')