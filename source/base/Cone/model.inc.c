Lights1 Cone_f3dlite_material_001_lights = gdSPDefLights1(
	0x7F, 0x7F, 0x7F,
	0xFF, 0xFF, 0xFF, 0x49, 0x49, 0x49);

Vtx Cone_Cone_mesh_layer_1_vtx_0[16] = {
	{{ {-200, -200, -200}, 0, {-16, 1008}, {0, 57, 142, 255} }},
	{{ {0, 200, 0}, 0, {1008, 1008}, {0, 57, 142, 255} }},
	{{ {200, -200, -200}, 0, {1008, -16}, {0, 57, 142, 255} }},
	{{ {200, -200, -200}, 0, {-16, 1008}, {114, 57, 0, 255} }},
	{{ {0, 200, 0}, 0, {1008, 1008}, {114, 57, 0, 255} }},
	{{ {200, -200, 200}, 0, {1008, -16}, {114, 57, 0, 255} }},
	{{ {200, -200, 200}, 0, {-16, 1008}, {0, 57, 114, 255} }},
	{{ {0, 200, 0}, 0, {1008, 1008}, {0, 57, 114, 255} }},
	{{ {-200, -200, 200}, 0, {1008, -16}, {0, 57, 114, 255} }},
	{{ {-200, -200, 200}, 0, {-16, 1008}, {142, 57, 0, 255} }},
	{{ {0, 200, 0}, 0, {1008, 1008}, {142, 57, 0, 255} }},
	{{ {-200, -200, -200}, 0, {1008, -16}, {142, 57, 0, 255} }},
	{{ {-200, -200, -200}, 0, {-16, 1008}, {0, 129, 0, 255} }},
	{{ {200, -200, -200}, 0, {1008, 1008}, {0, 129, 0, 255} }},
	{{ {200, -200, 200}, 0, {1008, -16}, {0, 129, 0, 255} }},
	{{ {-200, -200, 200}, 0, {-16, -16}, {0, 129, 0, 255} }},
};

Gfx Cone_Cone_mesh_layer_1_tri_0[] = {
	gsSPVertex(Cone_Cone_mesh_layer_1_vtx_0 + 0, 16, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(3, 4, 5, 0),
	gsSP1Triangle(6, 7, 8, 0),
	gsSP1Triangle(9, 10, 11, 0),
	gsSP1Triangle(12, 13, 14, 0),
	gsSP1Triangle(12, 14, 15, 0),
	gsSPEndDisplayList(),
};


Gfx mat_Cone_f3dlite_material_001[] = {
	gsSPSetGeometryMode(G_LIGHTING | G_SHADE | G_SHADING_SMOOTH | G_ZBUFFER | G_CULL_BACK),
	gsSPSetLights1(Cone_f3dlite_material_001_lights),
	gsDPPipeSync(),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsDPSetAlphaDither(G_AD_NOISE),
	gsDPSetTextureConvert(G_TC_FILT),
	gsDPSetTextureFilter(G_TF_BILERP),
	gsDPSetTexturePersp(G_TP_PERSP),
	gsDPPipelineMode(G_PM_1PRIMITIVE),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsSPEndDisplayList(),
};

Gfx mat_revert_Cone_f3dlite_material_001[] = {
	gsSPClearGeometryMode(G_LIGHTING | G_SHADE | G_SHADING_SMOOTH | G_ZBUFFER | G_CULL_BACK),
	gsDPPipeSync(),
	gsDPSetAlphaDither(G_AD_DISABLE),
	gsDPSetTextureConvert(G_TC_CONV),
	gsDPSetTextureFilter(G_TF_POINT),
	gsDPSetTexturePersp(G_TP_NONE),
	gsDPPipelineMode(G_PM_NPRIMITIVE),
	gsSPEndDisplayList(),
};

Gfx Cone_Cone_mesh_layer_1_with_revert[] = {
	gsSPDisplayList(mat_Cone_f3dlite_material_001),
	gsSPDisplayList(Cone_Cone_mesh_layer_1_tri_0),
	gsSPDisplayList(mat_revert_Cone_f3dlite_material_001),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

