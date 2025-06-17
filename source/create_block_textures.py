import os

INITIAL_DIR = "."
BIN_DIR = os.path.join(INITIAL_DIR, "bin")
LEVELS_DIR = os.path.join(INITIAL_DIR, "levels")

texture_names: list[str] = []
ignore_files = (
    "title_screen_bg.c",
    "debug_level_select.c",
    "bbh_skybox.c",
    "bitdw_skybox.c",
    "bitfs_skybox.c",
    "bits_skybox.c",
    "ccm_skybox.c",
    "cloud_floor_skybox.c",
    "clouds_skybox.c",
    "effect.c",
    "ssl_skybox.c",
    "water_skybox.c",
    "wdw_skybox.c",
)

ignore_texure_names = (
    "texture_font_char_jp_long_vowel",
    "texture_font_char_eu_colon",
    "texture_font_char_EU_slash",
    "texture_font_char_us_A",
    "texture_font_char_us_B",
    "texture_font_char_us_C",
    "texture_font_char_us_D",
    "texture_font_char_us_E",
    "texture_font_char_us_F",
    "texture_font_char_us_G",
    "texture_font_char_us_H",
    "texture_font_char_us_I",
    "texture_font_char_us_J",
    "texture_font_char_us_K",
    "texture_font_char_us_L",
    "texture_font_char_us_M",
    "texture_font_char_us_N",
    "texture_font_char_us_O",
    "texture_font_char_us_P",
    "texture_font_char_us_Q",
    "texture_font_char_us_R",
    "texture_font_char_us_S",
    "texture_font_char_us_T",
    "texture_font_char_us_U",
    "texture_font_char_us_V",
    "texture_font_char_us_W",
    "texture_font_char_us_X",
    "texture_font_char_us_Y",
    "texture_font_char_us_Z",
)

if os.path.exists(BIN_DIR):
	files = os.scandir(BIN_DIR)
	for file in files:
		if file.is_file() and file.name not in ignore_files:
			with open(file.path, "r") as lines:
				for line in lines:
					if line.strip().startswith("ROM_ASSET_LOAD_TEXTURE"):
						name = line.split(",")[0].split("(")[1]
						if not any(name in n for n in ignore_texure_names):
							texture_names.append(name)
	print("Got textures in bin")
else:
	print("Bin does not exist")

if os.path.exists(LEVELS_DIR):
	for root, dirs, files in os.walk(LEVELS_DIR):
		for file in files:
			if file == "texture.inc.c":
				with open(os.path.join(root, file), "r") as lines:
					for line in lines:
						if line.strip().startswith("ROM_ASSET_LOAD_TEXTURE"):
							name = line.split(",")[0].split("(")[1]
							if not any(name in n for n in ignore_texure_names):
								texture_names.append(name)
	print("Got textures in levels")
else:
	print("Levels does not exist")

color_set: list[list[str]] = []
with open(os.path.join(INITIAL_DIR, "colors.txt"), "r") as file:
	for line in file:
		color_set.append(line.replace(" ", "").replace("\n", "").split(","))

with open(os.path.join(INITIAL_DIR, "!TEXTURES.txt"), "w") as file:
    for name in texture_names:
        file.write(f"    g(\"{name}\"),\n")
    for colors in color_set:
        file.write("    {" + f"r = {colors[0]}, g = {colors[1]}, b = {colors[2]}, a = 255" + "},\n")

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
			GEO_SWITCH_CASE(' + str((len(texture_names) + len(color_set)) * 2 + 2) + ', geo_switch_anim_state),\n\
			GEO_OPEN_NODE(),\n\
				GEO_NODE_START(),\n\
				GEO_OPEN_NODE(),\n\
					GEO_ANIMATED_PART(LAYER_ALPHA, 0, 276, 0, ' + str(texture_names[0]) + '_mat),\n\
				GEO_CLOSE_NODE(),\n'
)
    for name in texture_names:
        file.write(f"				GEO_DISPLAY_LIST(LAYER_ALPHA, {name}_mat),\n")
    for colors in color_set:
        file.write(f"				GEO_DISPLAY_LIST(LAYER_ALPHA, color_{colors[0]}{colors[1]}{colors[2]}_mat),\n")
    file.write(f"                           // Transparent start: {str(len(texture_names) + len(color_set))}\n")
    for name in texture_names:
        file.write(f"				GEO_DISPLAY_LIST(LAYER_TRANSPARENT, {name}_mat),\n")
    for colors in color_set:
        file.write(f"				GEO_DISPLAY_LIST(LAYER_TRANSPARENT, color_{colors[0]}{colors[1]}{colors[2]}_mat),\n")

    file.write(
'                GEO_DISPLAY_LIST(LAYER_ALPHA, barrier_Cube_mesh_layer_4),\n\
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

    for colors in color_set:
        file.write(
'\n\
Gfx color_' + colors[0] + colors[1] + colors[2] + '_mat[] = {\n\
	gsSPSetGeometryMode(G_TEXTURE_GEN),\n\
	gsSPClearGeometryMode(G_SHADE | G_LIGHTING),\n\
	gsDPPipeSync(),\n\
	gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),\n\
	gsDPSetAlphaDither(G_AD_NOISE),\n\
	gsSPTexture(65535, 65535, 0, 0, 1),\n\
	gsDPSetPrimColor(0, 0, ' + colors[0] + ',' + colors[1] + ',' + colors[2] + ', 255),\n\
	gsSPDisplayList(mce_block_tris),\n\
	gsSPClearGeometryMode(G_TEXTURE_GEN),\n\
	gsSPSetGeometryMode(G_SHADE | G_LIGHTING),\n\
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
};\n\
')
    file.write(
'\n\
Gfx barrier_barrier_ci4_aligner[] = {gsSPEndDisplayList()};\n\
u8 barrier_barrier_ci4[] = {\n\
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, \n\
	0x00, 0x01, 0x11, 0x11, 0x11, 0x11, 0x11, 0x10, \n\
	0x00, 0x00, 0x11, 0x11, 0x11, 0x11, 0x11, 0x10, \n\
	0x01, 0x00, 0x01, 0x11, 0x11, 0x11, 0x11, 0x10, \n\
	0x01, 0x10, 0x00, 0x11, 0x11, 0x11, 0x11, 0x10, \n\
	0x01, 0x11, 0x00, 0x01, 0x11, 0x11, 0x11, 0x10, \n\
	0x01, 0x11, 0x10, 0x00, 0x11, 0x11, 0x11, 0x10, \n\
	0x01, 0x11, 0x11, 0x00, 0x01, 0x11, 0x11, 0x10, \n\
	0x01, 0x11, 0x11, 0x10, 0x00, 0x11, 0x11, 0x10, \n\
	0x01, 0x11, 0x11, 0x11, 0x00, 0x01, 0x11, 0x10, \n\
	0x01, 0x11, 0x11, 0x11, 0x10, 0x00, 0x11, 0x10, \n\
	0x01, 0x11, 0x11, 0x11, 0x11, 0x00, 0x01, 0x10, \n\
	0x01, 0x11, 0x11, 0x11, 0x11, 0x10, 0x00, 0x10, \n\
	0x01, 0x11, 0x11, 0x11, 0x11, 0x11, 0x00, 0x00, \n\
	0x01, 0x11, 0x11, 0x11, 0x11, 0x11, 0x10, 0x00, \n\
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, \n\
	\n\
};\n\
\n\
Gfx barrier_barrier_pal_rgba16_aligner[] = {gsSPEndDisplayList()};\n\
u8 barrier_barrier_pal_rgba16[] = {\n\
	0xf8, 0x01, 0x00, 0x00, \n\
};\n\
\n\
Vtx barrier_Cube_mesh_layer_4_vtx_0[24] = {\n\
	{{ {-100, -100, 100}, 0, {-16, 496}, {255, 255, 255, 255} }},\n\
	{{ {-100, 100, 100}, 0, {496, 496}, {255, 255, 255, 255} }},\n\
	{{ {-100, 100, -100}, 0, {496, -16}, {255, 255, 255, 255} }},\n\
	{{ {-100, -100, -100}, 0, {-16, -16}, {255, 255, 255, 255} }},\n\
	{{ {-100, -100, -100}, 0, {-16, 496}, {255, 255, 255, 255} }},\n\
	{{ {-100, 100, -100}, 0, {496, 496}, {255, 255, 255, 255} }},\n\
	{{ {100, 100, -100}, 0, {496, -16}, {255, 255, 255, 255} }},\n\
	{{ {100, -100, -100}, 0, {-16, -16}, {255, 255, 255, 255} }},\n\
	{{ {100, -100, -100}, 0, {-16, 496}, {255, 255, 255, 255} }},\n\
	{{ {100, 100, -100}, 0, {496, 496}, {255, 255, 255, 255} }},\n\
	{{ {100, 100, 100}, 0, {496, -16}, {255, 255, 255, 255} }},\n\
	{{ {100, -100, 100}, 0, {-16, -16}, {255, 255, 255, 255} }},\n\
	{{ {100, -100, 100}, 0, {-16, 496}, {255, 255, 255, 255} }},\n\
	{{ {100, 100, 100}, 0, {496, 496}, {255, 255, 255, 255} }},\n\
	{{ {-100, 100, 100}, 0, {496, -16}, {255, 255, 255, 255} }},\n\
	{{ {-100, -100, 100}, 0, {-16, -16}, {255, 255, 255, 255} }},\n\
	{{ {-100, -100, -100}, 0, {-16, 496}, {255, 255, 255, 255} }},\n\
	{{ {100, -100, -100}, 0, {496, 496}, {255, 255, 255, 255} }},\n\
	{{ {100, -100, 100}, 0, {496, -16}, {255, 255, 255, 255} }},\n\
	{{ {-100, -100, 100}, 0, {-16, -16}, {255, 255, 255, 255} }},\n\
	{{ {100, 100, -100}, 0, {-16, 496}, {255, 255, 255, 255} }},\n\
	{{ {-100, 100, -100}, 0, {496, 496}, {255, 255, 255, 255} }},\n\
	{{ {-100, 100, 100}, 0, {496, -16}, {255, 255, 255, 255} }},\n\
	{{ {100, 100, 100}, 0, {-16, -16}, {255, 255, 255, 255} }},\n\
};\n\
\n\
Gfx barrier_Cube_mesh_layer_4_tri_0[] = {\n\
	gsSPVertex(barrier_Cube_mesh_layer_4_vtx_0 + 0, 16, 0),\n\
	gsSP1Triangle(0, 1, 2, 0),\n\
	gsSP1Triangle(0, 2, 3, 0),\n\
	gsSP1Triangle(4, 5, 6, 0),\n\
	gsSP1Triangle(4, 6, 7, 0),\n\
	gsSP1Triangle(8, 9, 10, 0),\n\
	gsSP1Triangle(8, 10, 11, 0),\n\
	gsSP1Triangle(12, 13, 14, 0),\n\
	gsSP1Triangle(12, 14, 15, 0),\n\
	gsSPVertex(barrier_Cube_mesh_layer_4_vtx_0 + 16, 8, 0),\n\
	gsSP1Triangle(0, 1, 2, 0),\n\
	gsSP1Triangle(0, 2, 3, 0),\n\
	gsSP1Triangle(4, 5, 6, 0),\n\
	gsSP1Triangle(4, 6, 7, 0),\n\
	gsSPEndDisplayList(),\n\
};\n\
\n\
Gfx mat_barrier_f3dlite_material_001[] = {\n\
	gsSPClearGeometryMode(G_LIGHTING),\n\
	gsDPPipeSync(),\n\
	gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0),\n\
	gsDPSetAlphaDither(G_AD_NOISE),\n\
	gsDPSetTextureLUT(G_TT_RGBA16),\n\
	gsSPTexture(65535, 65535, 0, 0, 1),\n\
	gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, barrier_barrier_pal_rgba16),\n\
	gsDPSetTile(0, 0, 0, 256, 5, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),\n\
	gsDPLoadTLUTCmd(5, 1),\n\
	gsDPSetTextureImage(G_IM_FMT_CI, G_IM_SIZ_16b, 1, barrier_barrier_ci4),\n\
	gsDPSetTile(G_IM_FMT_CI, G_IM_SIZ_16b, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),\n\
	gsDPLoadBlock(7, 0, 0, 63, 2048),\n\
	gsDPSetTile(G_IM_FMT_CI, G_IM_SIZ_4b, 1, 0, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 4, 0, G_TX_WRAP | G_TX_NOMIRROR, 4, 0),\n\
	gsDPSetTileSize(0, 0, 0, 60, 60),\n\
	gsSPEndDisplayList(),\n\
};\n\
\n\
Gfx mat_revert_barrier_f3dlite_material_001[] = {\n\
	gsSPSetGeometryMode(G_LIGHTING),\n\
	gsDPPipeSync(),\n\
	gsDPSetAlphaDither(G_AD_DISABLE),\n\
	gsDPSetTextureLUT(G_TT_NONE),\n\
	gsSPEndDisplayList(),\n\
};\n\
\n\
Gfx barrier_Cube_mesh_layer_4[] = {\n\
	gsSPDisplayList(mat_barrier_f3dlite_material_001),\n\
	gsSPDisplayList(barrier_Cube_mesh_layer_4_tri_0),\n\
	gsSPDisplayList(mat_revert_barrier_f3dlite_material_001),\n\
	gsDPPipeSync(),\n\
	gsSPSetGeometryMode(G_LIGHTING),\n\
	gsSPClearGeometryMode(G_TEXTURE_GEN),\n\
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),\n\
	gsSPTexture(65535, 65535, 0, 0, 0),\n\
	gsDPSetEnvColor(255, 255, 255, 255),\n\
	gsDPSetAlphaCompare(G_AC_NONE),\n\
	gsSPEndDisplayList(),\n\
};')