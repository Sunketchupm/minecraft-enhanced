Vtx block_boxcustom_000_displaylist_mesh_layer_1_mesh_mesh_layer_1_vtx_cull[8] = {
	{{{-100, -100, 100}, 0, {0, 0}, {0x00, 0x00, 0x00, 0x00}}},
	{{{-100, 100, 100}, 0, {0, 0}, {0x00, 0x00, 0x00, 0x00}}},
	{{{-100, 100, -100}, 0, {0, 0}, {0x00, 0x00, 0x00, 0x00}}},
	{{{-100, -100, -100}, 0, {0, 0}, {0x00, 0x00, 0x00, 0x00}}},
	{{{100, -100, 100}, 0, {0, 0}, {0x00, 0x00, 0x00, 0x00}}},
	{{{100, 100, 100}, 0, {0, 0}, {0x00, 0x00, 0x00, 0x00}}},
	{{{100, 100, -100}, 0, {0, 0}, {0x00, 0x00, 0x00, 0x00}}},
	{{{100, -100, -100}, 0, {0, 0}, {0x00, 0x00, 0x00, 0x00}}},
};

Vtx block_boxcustom_000_displaylist_mesh_layer_1_mesh_mesh_layer_1_vtx_0[24] = {
	{{{100, 100, -100}, 0, {974, -16}, {0x49, 0x49, 0xB7, 0xFF}}},
	{{{-100, 100, -100}, 0, {-16, -16}, {0xB7, 0x49, 0xB7, 0xFF}}},
	{{{-100, 100, 100}, 0, {-16, 1996}, {0xB7, 0x49, 0x49, 0xFF}}},
	{{{100, 100, 100}, 0, {974, 1996}, {0x49, 0x49, 0x49, 0xFF}}},
	{{{-100, -100, -100}, 0, {974, 1996}, {0xB7, 0xB7, 0xB7, 0xFF}}},
	{{{-100, 100, -100}, 0, {974, -16}, {0xB7, 0x49, 0xB7, 0xFF}}},
	{{{100, 100, -100}, 0, {-16, -16}, {0x49, 0x49, 0xB7, 0xFF}}},
	{{{100, -100, -100}, 0, {-16, 1996}, {0x49, 0xB7, 0xB7, 0xFF}}},
	{{{-100, -100, 100}, 0, {974, 1996}, {0xB7, 0xB7, 0x49, 0xFF}}},
	{{{-100, 100, 100}, 0, {974, -16}, {0xB7, 0x49, 0x49, 0xFF}}},
	{{{-100, 100, -100}, 0, {-16, -16}, {0xB7, 0x49, 0xB7, 0xFF}}},
	{{{-100, -100, -100}, 0, {-16, 1996}, {0xB7, 0xB7, 0xB7, 0xFF}}},
	{{{100, -100, 100}, 0, {974, -16}, {0x49, 0xB7, 0x49, 0xFF}}},
	{{{-100, -100, 100}, 0, {-16, -16}, {0xB7, 0xB7, 0x49, 0xFF}}},
	{{{-100, -100, -100}, 0, {-16, 1996}, {0xB7, 0xB7, 0xB7, 0xFF}}},
	{{{100, -100, -100}, 0, {974, 1996}, {0x49, 0xB7, 0xB7, 0xFF}}},
	{{{100, -100, -100}, 0, {974, 1996}, {0x49, 0xB7, 0xB7, 0xFF}}},
	{{{100, 100, -100}, 0, {974, -16}, {0x49, 0x49, 0xB7, 0xFF}}},
	{{{100, 100, 100}, 0, {-40, -52}, {0x49, 0x49, 0x49, 0xFF}}},
	{{{100, -100, 100}, 0, {-40, 1992}, {0x49, 0xB7, 0x49, 0xFF}}},
	{{{100, -100, 100}, 0, {974, 1996}, {0x49, 0xB7, 0x49, 0xFF}}},
	{{{-100, 100, 100}, 0, {-16, -16}, {0xB7, 0x49, 0x49, 0xFF}}},
	{{{-100, -100, 100}, 0, {-16, 1996}, {0xB7, 0xB7, 0x49, 0xFF}}},
	{{{100, 100, 100}, 0, {974, -16}, {0x49, 0x49, 0x49, 0xFF}}},
};

Gfx block_boxcustom_000_displaylist_mesh_layer_1_mesh_mesh_layer_1_tri_0[] = {
	gsSPVertex(block_boxcustom_000_displaylist_mesh_layer_1_mesh_mesh_layer_1_vtx_0 + 0, 24, 0),
	gsSP2Triangles(0, 1, 2, 0, 0, 2, 3, 0),
	gsSP2Triangles(4, 5, 6, 0, 4, 6, 7, 0),
	gsSP2Triangles(8, 9, 10, 0, 8, 10, 11, 0),
	gsSP2Triangles(12, 13, 14, 0, 12, 14, 15, 0),
	gsSP2Triangles(16, 17, 18, 0, 16, 18, 19, 0),
	gsSP2Triangles(20, 21, 22, 0, 20, 23, 21, 0),
	gsSPEndDisplayList(),
};


Gfx mat_block_f3dlite_material_001[] = {
	gsDPPipeSync(),
	gsDPSetCombineLERP(0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, PRIMITIVE, 0, 0, 0, ENVIRONMENT),
	gsDPSetAlphaDither(G_AD_NOISE),
	gsSPTexture(65535, 65535, 0, 0, 1),
	gsDPSetPrimColor(0, 0, 255, 10, 0, 255),
	gsSPEndDisplayList(),
};

Gfx mat_revert_block_f3dlite_material_001[] = {
	gsDPPipeSync(),
	gsDPSetAlphaDither(G_AD_DISABLE),
	gsSPEndDisplayList(),
};

Gfx block_boxcustom_000_displaylist_mesh_layer_1_mesh_mesh_layer_1[] = {
	gsSPClearGeometryMode(G_LIGHTING),
	gsSPVertex(block_boxcustom_000_displaylist_mesh_layer_1_mesh_mesh_layer_1_vtx_cull + 0, 8, 0),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPCullDisplayList(0, 7),
	gsSPDisplayList(mat_block_f3dlite_material_001),
	gsSPDisplayList(block_boxcustom_000_displaylist_mesh_layer_1_mesh_mesh_layer_1_tri_0),
	gsSPDisplayList(mat_revert_block_f3dlite_material_001),
	gsDPPipeSync(),
	gsSPSetGeometryMode(G_LIGHTING),
	gsSPClearGeometryMode(G_TEXTURE_GEN),
	gsDPSetCombineLERP(0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT, 0, 0, 0, SHADE, 0, 0, 0, ENVIRONMENT),
	gsSPTexture(65535, 65535, 0, 0, 0),
	gsDPSetEnvColor(255, 255, 255, 255),
	gsDPSetAlphaCompare(G_AC_NONE),
	gsSPEndDisplayList(),
};

