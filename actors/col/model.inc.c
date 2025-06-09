// Color Box

static const Lights1 block_lights_shaded = gdSPDefLights1(
    0xff, 0xff, 0xff,
    0xff, 0xff, 0xff, 0xff, 0xff, 0xff
);

// [RED]
ALIGNED8 const Texture red_box[] = {
#include "actors/col/red.inc.c"
};

// [ORANGE]
ALIGNED8 const Texture orange_box[] = {
#include "actors/col/orange.inc.c"
};

// [YELLOW]
ALIGNED8 const Texture yellow_box[] = {
#include "actors/col/yellow.inc.c"
};

// [GREEN]
ALIGNED8 const Texture green_box[] = {
#include "actors/col/green.inc.c"
};

// [LIME]
ALIGNED8 const Texture lime_box[] = {
#include "actors/col/lime.inc.c"
};

// [CYAN]
ALIGNED8 const Texture cyan_box[] = {
#include "actors/col/cyan.inc.c"
};

// [TEAL]
ALIGNED8 const Texture teal_box[] = {
#include "actors/col/teal.inc.c"
};

// [BLUE]
ALIGNED8 const Texture blue_box[] = {
#include "actors/col/blue.inc.c"
};

// [PURPLE]
ALIGNED8 const Texture purple_box[] = {
#include "actors/col/purple.inc.c"
};

// [MAGENTA]
ALIGNED8 const Texture magenta_box[] = {
#include "actors/col/magenta.inc.c"
};

// [PINK]
ALIGNED8 const Texture pink_box[] = {
#include "actors/col/pink.inc.c"
};

// [BROWN]
ALIGNED8 const Texture brown_box[] = {
#include "actors/col/brown.inc.c"
};

// [SKIN]
ALIGNED8 const Texture skin_box[] = {
#include "actors/col/skin.inc.c"
};

// [BLACK]
ALIGNED8 const Texture black_box[] = {
#include "actors/col/black.inc.c"
};

// [GREY]
ALIGNED8 const Texture grey_box[] = {
#include "actors/col/grey.inc.c"
};

// [WHITE]
ALIGNED8 const Texture white_box[] = {
#include "actors/col/white.inc.c"
};

// 0x08024998
static const Vtx metal_box_seg8_vertex_08024998[] = {
    {{{   100,    100,   -100}, 0, {   990,      0}, {0x00, 0x7f, 0x00, 0x5a}}},
    {{{  -100,    100,   -100}, 0, {     0,      0}, {0x00, 0x7f, 0x00, 0x5a}}},
    {{{  -100,    100,    100}, 0, {     0,   2012}, {0x00, 0x7f, 0x00, 0x5a}}},
    {{{   100,    100,    100}, 0, {   990,   2012}, {0x00, 0x7f, 0x00, 0x5a}}},
    {{{  -100,   -100,   -100}, 0, {   990,   2012}, {0x00, 0x00, 0x81, 0x5a}}},
    {{{  -100,    100,   -100}, 0, {   990,      0}, {0x00, 0x00, 0x81, 0x5a}}},
    {{{   100,    100,   -100}, 0, {     0,      0}, {0x00, 0x00, 0x81, 0x5a}}},
    {{{   100,   -100,   -100}, 0, {     0,   2012}, {0x00, 0x00, 0x81, 0x5a}}},
    {{{  -100,   -100,    100}, 0, {   990,   2012}, {0x81, 0x00, 0x00, 0x5a}}},
    {{{  -100,    100,    100}, 0, {   990,      0}, {0x81, 0x00, 0x00, 0x5a}}},
    {{{  -100,    100,   -100}, 0, {     0,      0}, {0x81, 0x00, 0x00, 0x5a}}},
    {{{  -100,   -100,   -100}, 0, {     0,   2012}, {0x81, 0x00, 0x00, 0x5a}}},
    {{{   100,   -100,    100}, 0, {   990,      0}, {0x00, 0x81, 0x00, 0x5a}}},
    {{{  -100,   -100,    100}, 0, {     0,      0}, {0x00, 0x81, 0x00, 0x5a}}},
    {{{  -100,   -100,   -100}, 0, {     0,   2012}, {0x00, 0x81, 0x00, 0x5a}}},
    {{{   100,   -100,   -100}, 0, {   990,   2012}, {0x00, 0x81, 0x00, 0x5a}}},
};

// 0x08024A98
static const Vtx metal_box_seg8_vertex_08024A98[] = {
    {{{   100,   -100,    100}, 0, {   990,   2012}, {0x00, 0x00, 0x7f, 0x5a}}},
    {{{  -100,    100,    100}, 0, {     0,      0}, {0x00, 0x00, 0x7f, 0x5a}}},
    {{{  -100,   -100,    100}, 0, {     0,   2012}, {0x00, 0x00, 0x7f, 0x5a}}},
    {{{   100,    100,    100}, 0, {   990,      0}, {0x00, 0x00, 0x7f, 0x5a}}},
    {{{   100,   -100,   -100}, 0, {   990,   2012}, {0x7f, 0x00, 0x00, 0x5a}}},
    {{{   100,    100,   -100}, 0, {   990,      0}, {0x7f, 0x00, 0x00, 0x5a}}},
    {{{   100,    100,    100}, 0, {   -24,    -36}, {0x7f, 0x00, 0x00, 0x5a}}},
    {{{   100,   -100,    100}, 0, {   -24,   2008}, {0x7f, 0x00, 0x00, 0x5a}}},
};

// 0x08024B18 - 0x08024BB8
const Gfx block_dl_shaded[] = {
    gsDPLoadSync(),
    gsDPLoadBlock(G_TX_LOADTILE, 0, 0, 32 * 64 - 1, CALC_DXT(32, G_IM_SIZ_16b_BYTES)),
    gsSPLight(&block_lights_shaded.l, 1),
    gsSPLight(&block_lights_shaded.a, 2),
    gsSPVertex(metal_box_seg8_vertex_08024998, 16, 0),
    gsSP2Triangles( 0,  1,  2, 0x0,  0,  2,  3, 0x0),
    gsSP2Triangles( 4,  5,  6, 0x0,  4,  6,  7, 0x0),
    gsSP2Triangles( 8,  9, 10, 0x0,  8, 10, 11, 0x0),
    gsSP2Triangles(12, 13, 14, 0x0, 12, 14, 15, 0x0),
    gsSPVertex(metal_box_seg8_vertex_08024A98, 8, 0),
    gsSP2Triangles( 0,  1,  2, 0x0,  0,  3,  1, 0x0),
    gsSP2Triangles( 4,  5,  6, 0x0,  4,  6,  7, 0x0),
    gsSPEndDisplayList(),
};

// [GLOBAL]
const Gfx global_box_dl_shaded[] = {
    gsDPPipeSync(),
    gsDPSetCombineMode(G_CC_MODULATERGB, G_CC_MODULATERGB),
    gsSPClearGeometryMode(G_SHADING_SMOOTH),
    gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 0, 0, G_TX_LOADTILE, 0, G_TX_WRAP | G_TX_NOMIRROR, G_TX_NOMASK, G_TX_NOLOD, G_TX_WRAP | G_TX_NOMIRROR, G_TX_NOMASK, G_TX_NOLOD),
    gsSPTexture(0xFFFF, 0xFFFF, 0, G_TX_RENDERTILE, G_ON),
    gsDPTileSync(),
    gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 8, 0, G_TX_RENDERTILE, 0, G_TX_WRAP | G_TX_NOMIRROR, 6, G_TX_NOLOD, G_TX_WRAP | G_TX_NOMIRROR, 5, G_TX_NOLOD),
    gsDPSetTileSize(0, 0, 0, (32 - 1) << G_TEXTURE_IMAGE_FRAC, (64 - 1) << G_TEXTURE_IMAGE_FRAC),
    gsSPDisplayList(block_dl_shaded),
    gsSPTexture(0xFFFF, 0xFFFF, 0, G_TX_RENDERTILE, G_OFF),
    gsDPPipeSync(),
    gsDPSetCombineMode(G_CC_SHADE, G_CC_SHADE),
    gsSPSetGeometryMode(G_SHADING_SMOOTH),
    gsSPEndDisplayList(),
};

// [RED]
const Gfx red_box_dl_shaded[] = {
    gsDPPipeSync(),
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, red_box),
    gsSPDisplayList(global_box_dl_shaded)
    gsSPEndDisplayList(),
};

// [ORANGE]
const Gfx orange_box_dl_shaded[] = {
    gsDPPipeSync(),
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, orange_box),
    gsSPDisplayList(global_box_dl_shaded)
    gsSPEndDisplayList(),
};

// [YELLOW]
const Gfx yellow_box_dl_shaded[] = {
    gsDPPipeSync(),
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, yellow_box),
    gsSPDisplayList(global_box_dl_shaded)
    gsSPEndDisplayList(),
};

// [GREEN]
const Gfx green_box_dl_shaded[] = {
    gsDPPipeSync(),
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, green_box),
    gsSPDisplayList(global_box_dl_shaded)
    gsSPEndDisplayList(),
};

// [LIME]
const Gfx lime_box_dl_shaded[] = {
    gsDPPipeSync(),
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, lime_box),
    gsSPDisplayList(global_box_dl_shaded)
    gsSPEndDisplayList(),
};

// [CYAN]
const Gfx cyan_box_dl_shaded[] = {
    gsDPPipeSync(),
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, cyan_box),
    gsSPDisplayList(global_box_dl_shaded)
    gsSPEndDisplayList(),
};

// [TEAL]
const Gfx teal_box_dl_shaded[] = {
    gsDPPipeSync(),
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, teal_box),
    gsSPDisplayList(global_box_dl_shaded)
    gsSPEndDisplayList(),
};

// [BLUE]
const Gfx blue_box_dl_shaded[] = {
    gsDPPipeSync(),
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, blue_box),
    gsSPDisplayList(global_box_dl_shaded)
    gsSPEndDisplayList(),
};

// [PURPLE]
const Gfx purple_box_dl_shaded[] = {
    gsDPPipeSync(),
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, purple_box),
    gsSPDisplayList(global_box_dl_shaded)
    gsSPEndDisplayList(),
};

// [MAGENTA]
const Gfx magenta_box_dl_shaded[] = {
    gsDPPipeSync(),
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, magenta_box),
    gsSPDisplayList(global_box_dl_shaded)
    gsSPEndDisplayList(),
};

// [PINK]
const Gfx pink_box_dl_shaded[] = {
    gsDPPipeSync(),
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, pink_box),
    gsSPDisplayList(global_box_dl_shaded)
    gsSPEndDisplayList(),
};

// [BROWN]
const Gfx brown_box_dl_shaded[] = {
    gsDPPipeSync(),
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, brown_box),
    gsSPDisplayList(global_box_dl_shaded)
    gsSPEndDisplayList(),
};

// [SKIN]
const Gfx skin_box_dl_shaded[] = {
    gsDPPipeSync(),
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, skin_box),
    gsSPDisplayList(global_box_dl_shaded)
    gsSPEndDisplayList(),
};

// [BLACK]
const Gfx black_box_dl_shaded[] = {
    gsDPPipeSync(),
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, black_box),
    gsSPDisplayList(global_box_dl_shaded)
    gsSPEndDisplayList(),
};

// [GREY]
const Gfx grey_box_dl_shaded[] = {
    gsDPPipeSync(),
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, grey_box),
    gsSPDisplayList(global_box_dl_shaded)
    gsSPEndDisplayList(),
};

// [WHITE]
const Gfx white_box_dl_shaded[] = {
    gsDPPipeSync(),
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, white_box),
    gsSPDisplayList(global_box_dl_shaded)
    gsSPEndDisplayList(),
};

// 0x08023980
static const Lights1 metal_box_transparent_seg8_lights_08023980 = gdSPDefLights1(
    0x7f, 0x7f, 0x7f,
    0xff, 0xff, 0xff, 0x28, 0x28, 0x28
);

// 0x08024998
static const Vtx metal_box_transparent_seg8_vertex_08024998[] = {
    {{{   100,    100,   -100}, 0, {   990,      0}, {0x00, 0x7f, 0x00, 0x5A}}},
    {{{  -100,    100,   -100}, 0, {     0,      0}, {0x00, 0x7f, 0x00, 0x5A}}},
    {{{  -100,    100,    100}, 0, {     0,   2012}, {0x00, 0x7f, 0x00, 0x5A}}},
    {{{   100,    100,    100}, 0, {   990,   2012}, {0x00, 0x7f, 0x00, 0x5A}}},
    {{{  -100,   -100,   -100}, 0, {   990,   2012}, {0x00, 0x00, 0x81, 0x5A}}},
    {{{  -100,    100,   -100}, 0, {   990,      0}, {0x00, 0x00, 0x81, 0x5A}}},
    {{{   100,    100,   -100}, 0, {     0,      0}, {0x00, 0x00, 0x81, 0x5A}}},
    {{{   100,   -100,   -100}, 0, {     0,   2012}, {0x00, 0x00, 0x81, 0x5A}}},
    {{{  -100,   -100,    100}, 0, {   990,   2012}, {0x81, 0x00, 0x00, 0x5A}}},
    {{{  -100,    100,    100}, 0, {   990,      0}, {0x81, 0x00, 0x00, 0x5A}}},
    {{{  -100,    100,   -100}, 0, {     0,      0}, {0x81, 0x00, 0x00, 0x5A}}},
    {{{  -100,   -100,   -100}, 0, {     0,   2012}, {0x81, 0x00, 0x00, 0x5A}}},
    {{{   100,   -100,    100}, 0, {   990,      0}, {0x00, 0x81, 0x00, 0x5A}}},
    {{{  -100,   -100,    100}, 0, {     0,      0}, {0x00, 0x81, 0x00, 0x5A}}},
    {{{  -100,   -100,   -100}, 0, {     0,   2012}, {0x00, 0x81, 0x00, 0x5A}}},
    {{{   100,   -100,   -100}, 0, {   990,   2012}, {0x00, 0x81, 0x00, 0x5A}}},
};

// 0x08024A98
static const Vtx metal_box_transparent_seg8_vertex_08024A98[] = {
    {{{   100,   -100,    100}, 0, {   990,   2012}, {0x00, 0x00, 0x7f, 0x5A}}},
    {{{  -100,    100,    100}, 0, {     0,      0}, {0x00, 0x00, 0x7f, 0x5A}}},
    {{{  -100,   -100,    100}, 0, {     0,   2012}, {0x00, 0x00, 0x7f, 0x5A}}},
    {{{   100,    100,    100}, 0, {   990,      0}, {0x00, 0x00, 0x7f, 0x5A}}},
    {{{   100,   -100,   -100}, 0, {   990,   2012}, {0x7f, 0x00, 0x00, 0x5A}}},
    {{{   100,    100,   -100}, 0, {   990,      0}, {0x7f, 0x00, 0x00, 0x5A}}},
    {{{   100,    100,    100}, 0, {   -24,    -36}, {0x7f, 0x00, 0x00, 0x5A}}},
    {{{   100,   -100,    100}, 0, {   -24,   2008}, {0x7f, 0x00, 0x00, 0x5A}}},
};

const Gfx metal_box_transparent_seg8_dl_08024B18[] = {
    gsDPLoadSync(),
    gsDPLoadBlock(G_TX_LOADTILE, 0, 0, 32 * 64 - 1, CALC_DXT(32, G_IM_SIZ_16b_BYTES)),
    gsSPLight(&metal_box_transparent_seg8_lights_08023980.l, 1),
    gsSPLight(&metal_box_transparent_seg8_lights_08023980.a, 2),
    gsSPVertex(metal_box_transparent_seg8_vertex_08024998, 16, 0),
    gsSP2Triangles( 0,  1,  2, 0x0,  0,  2,  3, 0x0),
    gsSP2Triangles( 4,  5,  6, 0x0,  4,  6,  7, 0x0),
    gsSP2Triangles( 8,  9, 10, 0x0,  8, 10, 11, 0x0),
    gsSP2Triangles(12, 13, 14, 0x0, 12, 14, 15, 0x0),
    gsSPVertex(metal_box_transparent_seg8_vertex_08024A98, 8, 0),
    gsSP2Triangles( 0,  1,  2, 0x0,  0,  3,  1, 0x0),
    gsSP2Triangles( 4,  5,  6, 0x0,  4,  6,  7, 0x0),
    gsSPEndDisplayList(),
};

// [GLOBAL]
const Gfx transparent_box_main_dl[] = {
    gsDPPipeSync(),
    gsDPSetCombineMode(G_CC_MODULATERGB, G_CC_MODULATERGB),
    gsSPClearGeometryMode(G_SHADING_SMOOTH),
    gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 0, 0, G_TX_LOADTILE, 0, G_TX_WRAP | G_TX_NOMIRROR, G_TX_NOMASK, G_TX_NOLOD, G_TX_WRAP | G_TX_NOMIRROR, G_TX_NOMASK, G_TX_NOLOD),
    gsSPTexture(0xFFFF, 0xFFFF, 0, G_TX_RENDERTILE, G_ON),
    gsDPTileSync(),
    gsDPSetTile(G_IM_FMT_RGBA, G_IM_SIZ_16b, 8, 0, G_TX_RENDERTILE, 0, G_TX_WRAP | G_TX_NOMIRROR, 6, G_TX_NOLOD, G_TX_WRAP | G_TX_NOMIRROR, 5, G_TX_NOLOD),
    gsDPSetTileSize(0, 0, 0, (32 - 1) << G_TEXTURE_IMAGE_FRAC, (64 - 1) << G_TEXTURE_IMAGE_FRAC),
    gsSPDisplayList(metal_box_transparent_seg8_dl_08024B18),
    gsSPTexture(0xFFFF, 0xFFFF, 0, G_TX_RENDERTILE, G_OFF),
    gsDPPipeSync(),
    gsDPSetCombineMode(G_CC_SHADE, G_CC_SHADE),
    gsSPSetGeometryMode(G_SHADING_SMOOTH),
    gsSPEndDisplayList(),
};

const Gfx transparent_box_dl_no_shading[] = {
    gsDPPipeSync(),
    gsDPSetTextureImage(G_IM_FMT_RGBA, G_IM_SIZ_16b, 1, black_box),
    gsSPDisplayList(transparent_box_main_dl),
    gsSPEndDisplayList(),
};