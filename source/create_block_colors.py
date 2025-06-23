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

with open("geo.inc.c", "w") as file:
    file.write("\
const GeoLayout mce_color_block_geo[] = {\n\
	GEO_NODE_START(),\n\
	GEO_OPEN_NODE(),\n\
		GEO_ANIMATED_PART(LAYER_ALPHA, 0, 0, 0, NULL),\n\
		GEO_OPEN_NODE(),\n\
			GEO_ASM(30, geo_update_layer_transparency),\n\
			GEO_SWITCH_CASE(" + str((len(color_sets) * 2) + 1) + ", geo_switch_anim_state),\n\
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
			GEO_CLOSE_NODE(),\n\
		GEO_CLOSE_NODE(),\n\
	GEO_CLOSE_NODE(),\n\
	GEO_END(),\n\
};\
")
    
with open("model.inc.c", "w") as file:
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