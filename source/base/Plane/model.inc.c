Lights1 Plane_f3dlite_material_001_lights = gdSPDefLights1(
	0x7F, 0x7F, 0x7F,
	0xFF, 0xFF, 0xFF, 0x49, 0x49, 0x49);

Vtx Plane_Plane_mesh_layer_1_vtx_0[4] = {
	{{ {-200, 0, 200}, 0, {-16, 1008}, {0, 127, 0, 255} }},
	{{ {200, 0, 200}, 0, {1008, 1008}, {0, 127, 0, 255} }},
	{{ {200, 0, -200}, 0, {1008, -16}, {0, 127, 0, 255} }},
	{{ {-200, 0, -200}, 0, {-16, -16}, {0, 127, 0, 255} }},
};

Gfx Plane_Plane_mesh_layer_1_tri_0[] = {
	gsSPVertex(Plane_Plane_mesh_layer_1_vtx_0 + 0, 4, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(0, 2, 3, 0),
	gsSPEndDisplayList(),
};


Gfx mat_Plane_f3dlite_material_001[] = {
	gsSPSetGeometryMode(G_SHADE | G_LIGHTING | G_SHADING_SMOOTH | G_CULL_BACK | G_ZBUFFER),
	gsSPSetLights1(Plane_f3dlite_material_001_lights),
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

Gfx mat_revert_Plane_f3dlite_material_001[] = {
	gsSPClearGeometryMode(G_SHADE | G_LIGHTING | G_SHADING_SMOOTH | G_CULL_BACK | G_ZBUFFER),
	gsDPPipeSync(),
	gsDPSetAlphaDither(G_AD_DISABLE),
	gsDPSetTextureConvert(G_TC_CONV),
	gsDPSetTextureFilter(G_TF_POINT),
	gsDPSetTexturePersp(G_TP_NONE),
	gsDPPipelineMode(G_PM_NPRIMITIVE),
	gsSPEndDisplayList(),
};

Gfx Plane_Plane_mesh_layer_1_with_revert[] = {
	gsSPDisplayList(mat_Plane_f3dlite_material_001),
	gsSPDisplayList(Plane_Plane_mesh_layer_1_tri_0),
	gsSPDisplayList(mat_revert_Plane_f3dlite_material_001),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

