// 0x08025008
static const Vtx exclamation_box_outline_seg8_vertex_08025008[] = {
    {{{   -101,     101,     101}, 0, {   990,    990}, {0xff, 0xff, 0xff, 0xff}}},
    {{{    101,     101,     101}, 0, {   990,      0}, {0xff, 0xff, 0xff, 0xff}}},
    {{{    101,     101,    -101}, 0, {     0,      0}, {0xff, 0xff, 0xff, 0xff}}},
    {{{   -101,     101,    -101}, 0, {     0,    990}, {0xff, 0xff, 0xff, 0xff}}},
    {{{    101,    -101,     101}, 0, {   990,    990}, {0xff, 0xff, 0xff, 0xff}}},
    {{{   -101,     101,     101}, 0, {     0,      0}, {0xff, 0xff, 0xff, 0xff}}},
    {{{   -101,    -101,     101}, 0, {     0,    990}, {0xff, 0xff, 0xff, 0xff}}},
    {{{    101,    -101,    -101}, 0, {   990,    990}, {0xff, 0xff, 0xff, 0xff}}},
    {{{    101,     101,    -101}, 0, {   990,      0}, {0xff, 0xff, 0xff, 0xff}}},
    {{{    101,     101,     101}, 0, {     0,      0}, {0xff, 0xff, 0xff, 0xff}}},
    {{{    101,    -101,     101}, 0, {     0,    990}, {0xff, 0xff, 0xff, 0xff}}},
    {{{   -101,    -101,    -101}, 0, {     0,    990}, {0xff, 0xff, 0xff, 0xff}}},
    {{{    101,    -101,    -101}, 0, {     0,      0}, {0xff, 0xff, 0xff, 0xff}}},
    {{{   -101,     101,    -101}, 0, {   990,    990}, {0xff, 0xff, 0xff, 0xff}}},
};

// 0x080250E8
static const Vtx exclamation_box_outline_seg8_vertex_080250E8[] = {
    {{{   -101,     -101,     101}, 0, {   990,    990}, {0xff, 0xff, 0xff, 0xff}}},
    {{{   -101,      101,     101}, 0, {   990,      0}, {0xff, 0xff, 0xff, 0xff}}},
    {{{   -101,      101,    -101}, 0, {     0,      0}, {0xff, 0xff, 0xff, 0xff}}},
    {{{   -101,     -101,    -101}, 0, {     0,    990}, {0xff, 0xff, 0xff, 0xff}}},
    {{{   -101,     -101,     101}, 0, {     0,    990}, {0xff, 0xff, 0xff, 0xff}}},
    {{{   -101,     -101,    -101}, 0, {   990,    990}, {0xff, 0xff, 0xff, 0xff}}},
    {{{    101,     -101,    -101}, 0, {   996,      0}, {0xff, 0xff, 0xff, 0xff}}},
    {{{    101,     -101,     101}, 0, {   -26,      0}, {0xff, 0xff, 0xff, 0xff}}},
};

// 0x08025168
ALIGNED8 static const Texture exclamation_box_outline_seg8_texture_08025168[] = {
#include "actors/mce_outline/exclamation_box_outline.rgba16.inc.c"
};

// 0x08025968 - 0x080259F8
const Gfx exclamation_box_outline_seg8_dl_08025968[] = {
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, exclamation_box_outline_seg8_texture_08025168),
    gsDPLoadSync(),
    gsDPLoadBlock(G_TX_LOADTILE, 0, 0, 32 * 32 - 1, CALC_DXT(32, G_IM_SIZ_16b_BYTES)),
    gsSPVertex(exclamation_box_outline_seg8_vertex_08025008, 14, 0),
    gsSP2Triangles( 0,  1,  2, 0x0,  0,  2,  3, 0x0),
    gsSP2Triangles( 4,  1,  5, 0x0,  4,  5,  6, 0x0),
    gsSP2Triangles( 7,  8,  9, 0x0,  7,  9, 10, 0x0),
    gsSP2Triangles(11,  8, 12, 0x0, 11, 13,  8, 0x0),
    gsSPVertex(exclamation_box_outline_seg8_vertex_080250E8, 8, 0),
    gsSP2Triangles( 0,  1,  2, 0x0,  0,  2,  3, 0x0),
    gsSP2Triangles( 4,  5,  6, 0x0,  4,  6,  7, 0x0),
    gsSPEndDisplayList(),
};

// 0x080259F8 - 0x08025A68
const Gfx exclamation_box_outline_seg8_dl_080259F8[] = {
    gsDPPipeSync(),
    gsDPSetCombineMode(G_CC_DECALRGBA, G_CC_DECALRGBA),
    gsSPClearGeometryMode(G_LIGHTING | G_CULL_BACK),
    gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 0, 0, G_TX_LOADTILE, 0, G_TX_WRAP | G_TX_NOMIRROR, G_TX_NOMASK, G_TX_NOLOD, G_TX_WRAP | G_TX_NOMIRROR, G_TX_NOMASK, G_TX_NOLOD),
    gsSPTexture(0xFFFF, 0xFFFF, 0, G_TX_RENDERTILE, G_ON),
    gsDPTileSync(),
    gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 8, 0, G_TX_RENDERTILE, 0, G_TX_CLAMP, 5, G_TX_NOLOD, G_TX_CLAMP, 5, G_TX_NOLOD),
    gsDPSetTileSize(0, 0, 0, (32 - 1) << G_TEXTURE_IMAGE_FRAC, (32 - 1) << G_TEXTURE_IMAGE_FRAC),
    gsSPDisplayList(exclamation_box_outline_seg8_dl_08025968),
    gsSPTexture(0xFFFF, 0xFFFF, 0, G_TX_RENDERTILE, G_OFF),
    gsDPPipeSync(),
    gsDPSetCombineMode(G_CC_SHADE, G_CC_SHADE),
    gsSPSetGeometryMode(G_LIGHTING | G_CULL_BACK),
    gsSPEndDisplayList(),
};