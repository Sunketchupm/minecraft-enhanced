Lights1 mce_block_f3dlite_material_lights = gdSPDefLights1(
	0x7F, 0x7F, 0x7F,
	0xFF, 0xFF, 0xFF, 0x49, 0x49, 0x49);

Lights1 mce_block_f3dlite_material_001_lights = gdSPDefLights1(
	0x32, 0x4D, 0x7F,
	0x6C, 0x9E, 0xFF, 0x49, 0x49, 0x49);

Lights1 mce_block_f3dlite_material_002_lights = gdSPDefLights1(
	0x7F, 0x3C, 0x10,
	0xFF, 0x7E, 0x2C, 0x49, 0x49, 0x49);

Vtx mce_block_Bone_002_mesh_layer_7_vtx_0[24] = {
	{{ {-100, -359, 100}, 0, {368, 1008}, {129, 0, 0, 255} }},
	{{ {-100, -159, 100}, 0, {624, 1008}, {129, 0, 0, 255} }},
	{{ {-100, -159, -100}, 0, {624, 752}, {129, 0, 0, 255} }},
	{{ {-100, -359, -100}, 0, {368, 752}, {129, 0, 0, 255} }},
	{{ {100, -359, 100}, 0, {368, 240}, {0, 0, 127, 255} }},
	{{ {-100, -159, 100}, 0, {624, -16}, {0, 0, 127, 255} }},
	{{ {-100, -359, 100}, 0, {368, -16}, {0, 0, 127, 255} }},
	{{ {100, -159, 100}, 0, {624, 240}, {0, 0, 127, 255} }},
	{{ {-100, -359, -100}, 0, {112, 496}, {0, 129, 0, 255} }},
	{{ {100, -359, 100}, 0, {368, 240}, {0, 129, 0, 255} }},
	{{ {-100, -359, 100}, 0, {112, 240}, {0, 129, 0, 255} }},
	{{ {100, -359, -100}, 0, {368, 496}, {0, 129, 0, 255} }},
	{{ {100, -159, -100}, 0, {624, 496}, {0, 127, 0, 255} }},
	{{ {-100, -159, -100}, 0, {880, 496}, {0, 127, 0, 255} }},
	{{ {-100, -159, 100}, 0, {880, 240}, {0, 127, 0, 255} }},
	{{ {100, -159, 100}, 0, {624, 240}, {0, 127, 0, 255} }},
	{{ {-100, -359, -100}, 0, {368, 752}, {0, 0, 129, 255} }},
	{{ {-100, -159, -100}, 0, {624, 752}, {0, 0, 129, 255} }},
	{{ {100, -159, -100}, 0, {624, 496}, {0, 0, 129, 255} }},
	{{ {100, -359, -100}, 0, {368, 496}, {0, 0, 129, 255} }},
	{{ {100, -359, -100}, 0, {368, 496}, {127, 0, 0, 255} }},
	{{ {100, -159, 100}, 0, {624, 240}, {127, 0, 0, 255} }},
	{{ {100, -359, 100}, 0, {368, 240}, {127, 0, 0, 255} }},
	{{ {100, -159, -100}, 0, {624, 496}, {127, 0, 0, 255} }},
};

Gfx mce_block_Bone_002_mesh_layer_7_tri_0[] = {
	gsSPVertex(mce_block_Bone_002_mesh_layer_7_vtx_0 + 0, 16, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(0, 2, 3, 0),
	gsSP1Triangle(4, 5, 6, 0),
	gsSP1Triangle(4, 7, 5, 0),
	gsSP1Triangle(8, 9, 10, 0),
	gsSP1Triangle(8, 11, 9, 0),
	gsSP1Triangle(12, 13, 14, 0),
	gsSP1Triangle(12, 14, 15, 0),
	gsSPVertex(mce_block_Bone_002_mesh_layer_7_vtx_0 + 16, 8, 0),
	gsSP1Triangle(0, 1, 2, 0),
	gsSP1Triangle(0, 2, 3, 0),
	gsSP1Triangle(4, 5, 6, 0),
	gsSP1Triangle(4, 7, 5, 0),
	gsSPEndDisplayList(),
};


Gfx mat_mce_block_f3dlite_material[] = {
	gsSPSetLights1(mce_block_f3dlite_material_lights),
	gsDPPipeSync(),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsDPSetAlphaDither(G_AD_NOISE),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsSPEndDisplayList(),
};

Gfx mat_revert_mce_block_f3dlite_material[] = {
	gsDPPipeSync(),
	gsDPSetAlphaDither(G_AD_DISABLE),
	gsSPEndDisplayList(),
};

Gfx mat_mce_block_f3dlite_material_001[] = {
	gsSPSetLights1(mce_block_f3dlite_material_001_lights),
	gsDPPipeSync(),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsDPSetAlphaDither(G_AD_NOISE),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsSPEndDisplayList(),
};

Gfx mat_revert_mce_block_f3dlite_material_001[] = {
	gsDPPipeSync(),
	gsDPSetAlphaDither(G_AD_DISABLE),
	gsSPEndDisplayList(),
};

Gfx mat_mce_block_f3dlite_material_002[] = {
	gsSPSetLights1(mce_block_f3dlite_material_002_lights),
	gsDPPipeSync(),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsDPSetAlphaDither(G_AD_NOISE),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsSPEndDisplayList(),
};

Gfx mat_revert_mce_block_f3dlite_material_002[] = {
	gsDPPipeSync(),
	gsDPSetAlphaDither(G_AD_DISABLE),
	gsSPEndDisplayList(),
};

Gfx mce_block_Bone_002_mesh_layer_7[] = {
	gsSPDisplayList(mat_mce_block_f3dlite_material),
	gsSPDisplayList(mce_block_Bone_002_mesh_layer_7_tri_0),
	gsSPDisplayList(mat_revert_mce_block_f3dlite_material),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

Gfx mce_block_Bone_002_mesh_layer_7_mat_override_f3dlite_material_0[] = {
	gsSPDisplayList(mat_mce_block_f3dlite_material),
	gsSPDisplayList(mce_block_Bone_002_mesh_layer_7_tri_0),
	gsSPDisplayList(mat_revert_mce_block_f3dlite_material),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

Gfx mce_block_Bone_002_mesh_layer_7_mat_override_f3dlite_material_001_1[] = {
	gsSPDisplayList(mat_mce_block_f3dlite_material_001),
	gsSPDisplayList(mce_block_Bone_002_mesh_layer_7_tri_0),
	gsSPDisplayList(mat_revert_mce_block_f3dlite_material_001),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

Gfx mce_block_Bone_002_mesh_layer_7_mat_override_f3dlite_material_002_2[] = {
	gsSPDisplayList(mat_mce_block_f3dlite_material_002),
	gsSPDisplayList(mce_block_Bone_002_mesh_layer_7_tri_0),
	gsSPDisplayList(mat_revert_mce_block_f3dlite_material_002),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

