import os

if not os.path.exists("colors.txt"):
    print("Could not find colors.txt")
    exit()

color_sets = []
with open("colors.txt", "r") as file:
    for line in file:
        if line.startswith("("):
            color_sets.append(line.replace("(", "").replace(")", "").replace(" ", "").replace("\n", "").split(","))

with open("color_icons.txt", "w") as file:
    for colors in color_sets:
        file.write("    {" + f"r = {colors[0]}, g = {colors[1]}, b = {colors[2]}, a = 255" + "},\n")

with open("!COLORS_GEO.txt", "w") as file:
    file.write("\
const GeoLayout mce_color_block_geo[] = {\n\
	GEO_NODE_START(),\n\
	GEO_OPEN_NODE(),\n\
		GEO_ANIMATED_PART(LAYER_ALPHA, 0, 0, 0, NULL),\n\
		GEO_OPEN_NODE(),\n\
			GEO_ASM(30, geo_update_layer_transparency),\n\
			GEO_SWITCH_CASE(" + str((len(color_sets) * 2) + 2) + ", geo_switch_anim_state),\n\
			GEO_OPEN_NODE(),\n\
				GEO_NODE_START(),\n\
				GEO_OPEN_NODE(),\n")
    file.write(f"                    GEO_ANIMATED_PART(LAYER_ALPHA, 0, 276, 0, mce_color_block_{color_sets[0][0]}{color_sets[0][1]}{color_sets[0][2]}),\n")
    file.write("                GEO_CLOSE_NODE(),\n")
    file.write(f"            // Transparent start: {str(len(color_sets))}\n")
    for colors in color_sets:
        file.write(f"                GEO_DISPLAY_LIST(LAYER_ALPHA, mce_color_block_{colors[0]}{colors[1]}{colors[2]}),\n")
    for colors in color_sets:
        file.write(f"                GEO_DISPLAY_LIST(LAYER_TRANSPARENT, mce_color_block_{colors[0]}{colors[1]}{colors[2]}),\n")
    file.write("\
			    GEO_DISPLAY_LIST(LAYER_ALPHA, barrier_Cube_mesh_layer_4),\n\
			GEO_CLOSE_NODE(),\n\
		GEO_CLOSE_NODE(),\n\
	GEO_CLOSE_NODE(),\n\
	GEO_END(),\n\
};\
")
    
with open("!COLORS_MODEL.txt", "w") as file:
    file.write("\n\
Vtx mce_color_block_mesh[14] = {\n\
	{{ {-100, -100, 100}, 0, {368, 1008}, {255, 255, 255, 255} }},\n\
	{{ {-100, 100, 100}, 0, {624, 1008}, {255, 255, 255, 255} }},\n\
	{{ {-100, 100, -100}, 0, {624, 752}, {255, 255, 255, 255} }},\n\
	{{ {-100, -100, -100}, 0, {368, 752}, {255, 255, 255, 255} }},\n\
	{{ {100, 100, -100}, 0, {624, 496}, {255, 255, 255, 255} }},\n\
	{{ {100, -100, -100}, 0, {368, 496}, {255, 255, 255, 255} }},\n\
	{{ {100, 100, 100}, 0, {624, 240}, {255, 255, 255, 255} }},\n\
	{{ {-100, 100, 100}, 0, {880, 240}, {255, 255, 255, 255} }},\n\
	{{ {-100, 100, -100}, 0, {880, 496}, {255, 255, 255, 255} }},\n\
	{{ {100, -100, 100}, 0, {368, 240}, {255, 255, 255, 255} }},\n\
	{{ {-100, 100, 100}, 0, {624, -16}, {255, 255, 255, 255} }},\n\
	{{ {-100, -100, 100}, 0, {368, -16}, {255, 255, 255, 255} }},\n\
	{{ {-100, -100, -100}, 0, {112, 496}, {255, 255, 255, 255} }},\n\
	{{ {-100, -100, 100}, 0, {112, 240}, {255, 255, 255, 255} }},\n\
};\n\
\n\
Gfx mce_color_block_tris[] = {\n\
	gsSPVertex(mce_color_block_mesh + 0, 14, 0),\n\
	gsSP1Triangle(0, 1, 2, 0),\n\
	gsSP1Triangle(0, 2, 3, 0),\n\
	gsSP1Triangle(3, 2, 4, 0),\n\
	gsSP1Triangle(3, 4, 5, 0),\n\
	gsSP1Triangle(5, 4, 6, 0),\n\
	gsSP1Triangle(4, 7, 6, 0),\n\
	gsSP1Triangle(4, 8, 7, 0),\n\
	gsSP1Triangle(5, 6, 9, 0),\n\
	gsSP1Triangle(9, 6, 10, 0),\n\
	gsSP1Triangle(9, 10, 11, 0),\n\
	gsSP1Triangle(12, 5, 9, 0),\n\
	gsSP1Triangle(12, 9, 13, 0),\n\
	gsSPEndDisplayList(),\n\
};\n\
\n\
Gfx mce_color_block_general[] = {\n\
	gsSPDisplayList(mce_color_block_tris),\n\
	gsSPSetGeometryMode(G_SHADE | G_LIGHTING),\n\
	gsDPPipeSync(),\n\
	gsDPSetAlphaDither(G_AD_DISABLE),\n\
	gsSPEndDisplayList(),\n\
	gsDPPipeSync(),\n\
	gsSPSetGeometryMode(G_LIGHTING),\n\
	gsSPClearGeometryMode(G_TEXTURE_GEN),\n\
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),\n\
	gsSPTexture(65535, 65535, 0, 0, 0),\n\
	gsDPSetEnvColor(255, 255, 255, 255),\n\
	gsDPSetAlphaCompare(G_AC_NONE),\n\
	gsSPEndDisplayList(),\n\
};\n\
\n\
")
    for colors in color_sets:
        file.write("\n\
Gfx mce_color_block_" + colors[0] + colors[1] + colors[2] + "[] = {\n\
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),\n\
    gsDPPipeSync(),\n\
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),\n\
    gsDPSetAlphaDither(G_AD_NOISE),\n\
    gsSPTexture(65535, 65535, 0, 0, 1),\n\
    gsDPSetPrimColor(0, 0, " + colors[0] + ", " + colors[1] + ", " + colors[2] + ", 255),\n\
    gsSPDisplayList(mce_color_block_general),\n\
    gsSPEndDisplayList(),\n\
};\n\
")
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