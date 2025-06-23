
Vtx mce_color_block_mesh[14] = {
	{{ {-100, -100, 100}, 0, {368, 1008}, {255, 255, 255, 255} }},
	{{ {-100, 100, 100}, 0, {624, 1008}, {255, 255, 255, 255} }},
	{{ {-100, 100, -100}, 0, {624, 752}, {255, 255, 255, 255} }},
	{{ {-100, -100, -100}, 0, {368, 752}, {255, 255, 255, 255} }},
	{{ {100, 100, -100}, 0, {624, 496}, {255, 255, 255, 255} }},
	{{ {100, -100, -100}, 0, {368, 496}, {255, 255, 255, 255} }},
	{{ {100, 100, 100}, 0, {624, 240}, {255, 255, 255, 255} }},
	{{ {-100, 100, 100}, 0, {880, 240}, {255, 255, 255, 255} }},
	{{ {-100, 100, -100}, 0, {880, 496}, {255, 255, 255, 255} }},
	{{ {100, -100, 100}, 0, {368, 240}, {255, 255, 255, 255} }},
	{{ {-100, 100, 100}, 0, {624, -16}, {255, 255, 255, 255} }},
	{{ {-100, -100, 100}, 0, {368, -16}, {255, 255, 255, 255} }},
	{{ {-100, -100, -100}, 0, {112, 496}, {255, 255, 255, 255} }},
	{{ {-100, -100, 100}, 0, {112, 240}, {255, 255, 255, 255} }},
};

Gfx mce_color_block_tris[] = {
	gsSPVertex(mce_color_block_mesh + 0, 14, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(0, 2, 3, 0),
	gsSP1Triangle(3, 2, 4, 0),
	gsSP1Triangle(3, 4, 5, 0),
	gsSP1Triangle(5, 4, 6, 0),
	gsSP1Triangle(4, 7, 6, 0),
	gsSP1Triangle(4, 8, 7, 0),
	gsSP1Triangle(5, 6, 9, 0),
	gsSP1Triangle(9, 6, 10, 0),
	gsSP1Triangle(9, 10, 11, 0),
	gsSP1Triangle(12, 5, 9, 0),
	gsSP1Triangle(12, 9, 13, 0),
	gsSPEndDisplayList(),
};

Gfx mce_color_block_general[] = {
	gsSPDisplayList(mce_color_block_tris),
	gsSPSetGeometryMode(G_SHADE | G_LIGHTING),
	gsDPPipeSync(),
	gsDPSetAlphaDither(G_AD_DISABLE),
	gsSPEndDisplayList(),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};


Gfx mce_color_block_000[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 0, 0, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_101010[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 10, 10, 10, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_202020[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 20, 20, 20, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_292929[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 29, 29, 29, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_393939[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 39, 39, 39, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_494949[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 49, 49, 49, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_595959[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 59, 59, 59, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_696969[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 69, 69, 69, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_787878[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 78, 78, 78, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_888888[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 88, 88, 88, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_989898[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 98, 98, 98, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_108108108[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 108, 108, 108, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_117117117[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 117, 117, 117, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_128128128[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 128, 128, 128, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_137137137[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 137, 137, 137, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_147147147[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 147, 147, 147, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_157157157[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 157, 157, 157, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_167167167[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 167, 167, 167, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_177177177[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 177, 177, 177, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_186186186[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 186, 186, 186, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_196196196[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 196, 196, 196, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_206206206[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 206, 206, 206, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_216216216[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 216, 216, 216, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_226226226[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 226, 226, 226, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_235235235[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 235, 235, 235, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_245245245[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 245, 245, 245, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_255255255[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 255, 255, 255, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_5100[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 51, 0, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_10200[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 102, 0, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_15300[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 153, 0, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_20400[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 204, 0, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_25500[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 255, 0, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_2555151[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 255, 51, 51, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_255102102[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 255, 102, 102, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_255153153[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 255, 153, 153, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_255204204[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 255, 204, 204, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_51250[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 51, 25, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_102510[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 102, 51, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_153760[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 153, 76, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_2061030[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 206, 103, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_2551280[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 255, 128, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_25515351[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 255, 153, 51, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_255178102[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 255, 178, 102, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_255204153[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 255, 204, 153, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_255229204[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 255, 229, 204, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_51400[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 51, 40, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_102810[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 102, 81, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_1531220[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 153, 122, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_2041630[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 204, 163, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_2552120[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 255, 212, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_25521451[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 255, 214, 51, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_255224102[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 255, 224, 102, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_255234153[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 255, 234, 153, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_255244204[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 255, 244, 204, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_0380[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 0, 38, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_0760[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 0, 76, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_01140[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 0, 114, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_01530[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 0, 153, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_01920[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 0, 192, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_4020440[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 40, 204, 40, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_8621686[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 86, 216, 86, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_137229137[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 137, 229, 137, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_193242193[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 193, 242, 193, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_01351[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 0, 13, 51, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_027102[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 0, 27, 102, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_040153[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 0, 40, 153, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_054204[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 0, 54, 204, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_064255[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 0, 64, 255, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_50105255[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 50, 105, 255, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_102142255[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 102, 142, 255, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_153180255[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 153, 180, 255, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_204217255[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 204, 217, 255, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_18051[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 18, 0, 51, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_370102[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 37, 0, 102, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_560153[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 56, 0, 153, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_740204[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 74, 0, 204, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_960255[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 96, 0, 255, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_12550255[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 125, 50, 255, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_158102255[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 158, 102, 255, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_190153255[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 190, 153, 255, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_222204255[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 222, 204, 255, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_2590[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 25, 9, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_51190[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 51, 19, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_76290[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 76, 29, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_102390[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 102, 39, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_127480[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 127, 48, 0, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_1537530[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 153, 75, 30, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_17811071[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 178, 110, 71, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_204152122[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 204, 152, 122, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_229200183[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 229, 200, 183, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_0025[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 0, 0, 25, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_0053[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 0, 0, 53, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_0079[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 0, 0, 79, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_00107[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 0, 0, 107, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_00135[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 0, 0, 135, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_3131158[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 31, 31, 158, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_7272181[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 72, 72, 181, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_122122204[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 122, 122, 204, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_179179224[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 179, 179, 224, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_45132[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 4, 51, 32, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_910264[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 9, 102, 64, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_1315397[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 13, 153, 97, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_18204129[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 18, 204, 129, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_21255165[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 21, 255, 165, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_68255180[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 68, 255, 180, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_114255198[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 114, 255, 198, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_168255220[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 168, 255, 220, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};

Gfx mce_color_block_209255236[] = {
    gsSPClearGeometryMode(G_SHADE | G_LIGHTING),
    gsDPPipeSync(),
    gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
    gsDPSetAlphaDither(G_AD_NOISE),
    gsSPTexture(65535, 65535, 0, 0, 1),
    gsDPSetPrimColor(0, 0, 209, 255, 236, 255),
    gsSPDisplayList(mce_color_block_general),
    gsSPEndDisplayList(),
};
