Gfx barrier_barrier_ci4_aligner[] = {gsSPEndDisplayList()};
u8 barrier_barrier_ci4[] = {
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	0x00, 0x01, 0x11, 0x11, 0x11, 0x11, 0x11, 0x10, 
	0x00, 0x00, 0x11, 0x11, 0x11, 0x11, 0x11, 0x10, 
	0x01, 0x00, 0x01, 0x11, 0x11, 0x11, 0x11, 0x10, 
	0x01, 0x10, 0x00, 0x11, 0x11, 0x11, 0x11, 0x10, 
	0x01, 0x11, 0x00, 0x01, 0x11, 0x11, 0x11, 0x10, 
	0x01, 0x11, 0x10, 0x00, 0x11, 0x11, 0x11, 0x10, 
	0x01, 0x11, 0x11, 0x00, 0x01, 0x11, 0x11, 0x10, 
	0x01, 0x11, 0x11, 0x10, 0x00, 0x11, 0x11, 0x10, 
	0x01, 0x11, 0x11, 0x11, 0x00, 0x01, 0x11, 0x10, 
	0x01, 0x11, 0x11, 0x11, 0x10, 0x00, 0x11, 0x10, 
	0x01, 0x11, 0x11, 0x11, 0x11, 0x00, 0x01, 0x10, 
	0x01, 0x11, 0x11, 0x11, 0x11, 0x10, 0x00, 0x10, 
	0x01, 0x11, 0x11, 0x11, 0x11, 0x11, 0x00, 0x00, 
	0x01, 0x11, 0x11, 0x11, 0x11, 0x11, 0x10, 0x00, 
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 
	
};

Gfx barrier_barrier_pal_rgba16_aligner[] = {gsSPEndDisplayList()};
u8 barrier_barrier_pal_rgba16[] = {
	0xf8, 0x01, 0x00, 0x00, 
};

Vtx barrier_Cube_mesh_layer_4_vtx_0[24] = {
	{{ {-100, -100, 100}, 0, {-16, 496}, {255, 255, 255, 255} }},
	{{ {-100, 100, 100}, 0, {496, 496}, {255, 255, 255, 255} }},
	{{ {-100, 100, -100}, 0, {496, -16}, {255, 255, 255, 255} }},
	{{ {-100, -100, -100}, 0, {-16, -16}, {255, 255, 255, 255} }},
	{{ {-100, -100, -100}, 0, {-16, 496}, {255, 255, 255, 255} }},
	{{ {-100, 100, -100}, 0, {496, 496}, {255, 255, 255, 255} }},
	{{ {100, 100, -100}, 0, {496, -16}, {255, 255, 255, 255} }},
	{{ {100, -100, -100}, 0, {-16, -16}, {255, 255, 255, 255} }},
	{{ {100, -100, -100}, 0, {-16, 496}, {255, 255, 255, 255} }},
	{{ {100, 100, -100}, 0, {496, 496}, {255, 255, 255, 255} }},
	{{ {100, 100, 100}, 0, {496, -16}, {255, 255, 255, 255} }},
	{{ {100, -100, 100}, 0, {-16, -16}, {255, 255, 255, 255} }},
	{{ {100, -100, 100}, 0, {-16, 496}, {255, 255, 255, 255} }},
	{{ {100, 100, 100}, 0, {496, 496}, {255, 255, 255, 255} }},
	{{ {-100, 100, 100}, 0, {496, -16}, {255, 255, 255, 255} }},
	{{ {-100, -100, 100}, 0, {-16, -16}, {255, 255, 255, 255} }},
	{{ {-100, -100, -100}, 0, {-16, 496}, {255, 255, 255, 255} }},
	{{ {100, -100, -100}, 0, {496, 496}, {255, 255, 255, 255} }},
	{{ {100, -100, 100}, 0, {496, -16}, {255, 255, 255, 255} }},
	{{ {-100, -100, 100}, 0, {-16, -16}, {255, 255, 255, 255} }},
	{{ {100, 100, -100}, 0, {-16, 496}, {255, 255, 255, 255} }},
	{{ {-100, 100, -100}, 0, {496, 496}, {255, 255, 255, 255} }},
	{{ {-100, 100, 100}, 0, {496, -16}, {255, 255, 255, 255} }},
	{{ {100, 100, 100}, 0, {-16, -16}, {255, 255, 255, 255} }},
};

Gfx barrier_Cube_mesh_layer_4_tri_0[] = {
	gsSPVertex(barrier_Cube_mesh_layer_4_vtx_0 + 0, 16, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(0, 2, 3, 0),
	gsSP1Triangle(4, 5, 6, 0),
	gsSP1Triangle(4, 6, 7, 0),
	gsSP1Triangle(8, 9, 10, 0),
	gsSP1Triangle(8, 10, 11, 0),
	gsSP1Triangle(12, 13, 14, 0),
	gsSP1Triangle(12, 14, 15, 0),
	gsSPVertex(barrier_Cube_mesh_layer_4_vtx_0 + 16, 8, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(0, 2, 3, 0),
	gsSP1Triangle(4, 5, 6, 0),
	gsSP1Triangle(4, 6, 7, 0),
	gsSPEndDisplayList(),
};


Gfx mat_barrier_f3dlite_material_001[] = {
	gsSPClearGeometryMode(G_LIGHTING),
	gsDPPipeSync(),
	gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0),
	gsDPSetAlphaDither(G_AD_NOISE),
	gsDPSetTextureLUT(G_TT_RGBA16),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, barrier_barrier_pal_rgba16),
	gsDPSetTile(0, 0, 0, 256, 5, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadTLUTCmd(5, 1),
	gsDPSetTextureImage(G_IM_FMT_CI, G_IM_SIZ_16b, 1, barrier_barrier_ci4),
	gsDPSetTile(G_IM_FMT_CI, G_IM_SIZ_16b, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(7, 0, 0, 63, 2048),
	gsDPSetTile(G_IM_FMT_CI, G_IM_SIZ_4b, 1, 0, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 4, 0, G_TX_WRAP | G_TX_NOMIRROR, 4, 0),
	gsDPSetTileSize(0, 0, 0, 60, 60),
	gsSPEndDisplayList(),
};

Gfx mat_revert_barrier_f3dlite_material_001[] = {
	gsSPSetGeometryMode(G_LIGHTING),
	gsDPPipeSync(),
	gsDPSetAlphaDither(G_AD_DISABLE),
	gsDPSetTextureLUT(G_TT_NONE),
	gsSPEndDisplayList(),
};

Gfx barrier_Cube_mesh_layer_4[] = {
	gsSPDisplayList(mat_barrier_f3dlite_material_001),
	gsSPDisplayList(barrier_Cube_mesh_layer_4_tri_0),
	gsSPDisplayList(mat_revert_barrier_f3dlite_material_001),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

