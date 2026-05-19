Lights1 pyramid_2_cube_mat_1_lights = gdSPDefLights1(
	0x7F, 0x7F, 0x7F,
	0xFF, 0xFF, 0xFF, 0x49, 0x49, 0x49);

Gfx pyramid_2_Abutton_ci4_aligner[] = {gsSPEndDisplayList()};
u8 pyramid_2_Abutton_ci4[] = {
	0x00, 0x00, 0x01, 0x11, 0x11, 0x10, 0x00, 0x00, 
	0x00, 0x01, 0x23, 0x33, 0x33, 0x32, 0x10, 0x00, 
	0x00, 0x23, 0x33, 0x33, 0x33, 0x33, 0x32, 0x00, 
	0x01, 0x33, 0x33, 0x34, 0x43, 0x33, 0x33, 0x10, 
	0x02, 0x33, 0x33, 0x44, 0x44, 0x33, 0x33, 0x20, 
	0x13, 0x33, 0x34, 0x43, 0x34, 0x43, 0x33, 0x31, 
	0x13, 0x33, 0x34, 0x43, 0x34, 0x43, 0x33, 0x31, 
	0x13, 0x33, 0x34, 0x44, 0x44, 0x43, 0x33, 0x31, 
	0x13, 0x33, 0x44, 0x44, 0x44, 0x44, 0x33, 0x31, 
	0x13, 0x33, 0x44, 0x43, 0x34, 0x44, 0x33, 0x31, 
	0x13, 0x33, 0x44, 0x33, 0x33, 0x44, 0x33, 0x31, 
	0x02, 0x33, 0x44, 0x33, 0x33, 0x44, 0x33, 0x20, 
	0x01, 0x33, 0x33, 0x33, 0x33, 0x33, 0x33, 0x10, 
	0x00, 0x23, 0x33, 0x33, 0x33, 0x33, 0x32, 0x00, 
	0x00, 0x01, 0x23, 0x33, 0x33, 0x32, 0x10, 0x00, 
	0x00, 0x00, 0x01, 0x11, 0x11, 0x10, 0x00, 0x00, 
	
};

Gfx pyramid_2_Abutton_pal_rgba16_aligner[] = {gsSPEndDisplayList()};
u8 pyramid_2_Abutton_pal_rgba16[] = {
	0x00, 0x00, 0x42, 0x3f, 0x4a, 0x7f, 0x63, 0x3f, 
	0x31, 0x8d, 
};

Vtx pyramid_2_pyramid_2_mesh_layer_4_vtx_0[16] = {
	{{ {-100, -100, -100}, 0, {-16, 377}, {0, 57, 142, 255} }},
	{{ {0, 100, 0}, 0, {240, -135}, {0, 57, 142, 255} }},
	{{ {100, -100, -100}, 0, {496, 377}, {0, 57, 142, 255} }},
	{{ {100, -100, -100}, 0, {496, 377}, {114, 57, 0, 255} }},
	{{ {0, 100, 0}, 0, {240, -135}, {114, 57, 0, 255} }},
	{{ {100, -100, 100}, 0, {-16, 377}, {114, 57, 0, 255} }},
	{{ {100, -100, 100}, 0, {496, 377}, {0, 57, 114, 255} }},
	{{ {0, 100, 0}, 0, {240, -135}, {0, 57, 114, 255} }},
	{{ {-100, -100, 100}, 0, {-16, 377}, {0, 57, 114, 255} }},
	{{ {-100, -100, 100}, 0, {-16, 377}, {142, 57, 0, 255} }},
	{{ {0, 100, 0}, 0, {240, -135}, {142, 57, 0, 255} }},
	{{ {-100, -100, -100}, 0, {496, 377}, {142, 57, 0, 255} }},
	{{ {-100, -100, -100}, 0, {-16, -16}, {0, 129, 0, 255} }},
	{{ {100, -100, -100}, 0, {496, -16}, {0, 129, 0, 255} }},
	{{ {100, -100, 100}, 0, {496, 496}, {0, 129, 0, 255} }},
	{{ {-100, -100, 100}, 0, {-16, 496}, {0, 129, 0, 255} }},
};

Gfx pyramid_2_pyramid_2_mesh_layer_4_tri_0[] = {
	gsSPVertex(pyramid_2_pyramid_2_mesh_layer_4_vtx_0 + 0, 16, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(3, 4, 5, 0),
	gsSP1Triangle(6, 7, 8, 0),
	gsSP1Triangle(9, 10, 11, 0),
	gsSP1Triangle(12, 13, 14, 0),
	gsSP1Triangle(12, 14, 15, 0),
	gsSPEndDisplayList(),
};


Gfx mat_pyramid_2_cube_mat_1[] = {
	gsSPSetGeometryMode(G_LIGHTING | G_ZBUFFER | G_SHADING_SMOOTH | G_SHADE),
	gsSPSetLights1(pyramid_2_cube_mat_1_lights),
	gsDPPipeSync(),
	gsDPSetCombineLERP(TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0, TEXEL0, 0, SHADE, 0, TEXEL0, 0, ENVIRONMENT, 0),
	gsDPSetAlphaDither(G_AD_NOISE),
	gsDPSetTextureConvert(G_TC_FILT),
	gsDPSetTextureFilter(G_TF_BILERP),
	gsDPSetTextureLUT(G_TT_RGBA16),
	gsDPSetTexturePersp(G_TP_PERSP),
	gsDPPipelineMode(G_PM_1PRIMITIVE),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, pyramid_2_Abutton_pal_rgba16),
	gsDPSetTile(0, 0, 0, 256, 5, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadTLUTCmd(5, 4),
	gsDPSetTextureImage(G_IM_FMT_CI, G_IM_SIZ_16b, 1, pyramid_2_Abutton_ci4),
	gsDPSetTile(G_IM_FMT_CI, G_IM_SIZ_16b, 0, 0, 7, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 0, 0),
	gsDPLoadBlock(7, 0, 0, 63, 2048),
	gsDPSetTile(G_IM_FMT_CI, G_IM_SIZ_4b, 1, 0, 0, 0, G_TX_WRAP | G_TX_NOMIRROR, 4, 0, G_TX_WRAP | G_TX_NOMIRROR, 4, 0),
	gsDPSetTileSize(0, 0, 0, 60, 60),
	gsSPEndDisplayList(),
};

Gfx mat_revert_pyramid_2_cube_mat_1[] = {
	gsSPClearGeometryMode(G_LIGHTING | G_ZBUFFER | G_SHADING_SMOOTH | G_SHADE),
	gsDPPipeSync(),
	gsDPSetAlphaDither(G_AD_DISABLE),
	gsDPSetTextureConvert(G_TC_CONV),
	gsDPSetTextureFilter(G_TF_POINT),
	gsDPSetTextureLUT(G_TT_NONE),
	gsDPSetTexturePersp(G_TP_NONE),
	gsDPPipelineMode(G_PM_NPRIMITIVE),
	gsSPEndDisplayList(),
};

Gfx pyramid_2_pyramid_2_mesh_layer_4_with_revert[] = {
	gsSPDisplayList(mat_pyramid_2_cube_mat_1),
	gsSPDisplayList(pyramid_2_pyramid_2_mesh_layer_4_tri_0),
	gsSPDisplayList(mat_revert_pyramid_2_cube_mat_1),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

