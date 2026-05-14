const GeoLayout mce_block_geo[] = {
    GEO_SCALE(0, 0x8000),
    GEO_OPEN_NODE(),
        GEO_SWITCH_CASE(8, geo_switch_mce_block),
        GEO_OPEN_NODE(),
            // Shaded solid texture
            GEO_NODE_START()
            GEO_OPEN_NODE(),
                GEO_ASM(0, geo_update_mce_block),
                GEO_DISPLAY_LIST(LAYER_ALPHA, mce_texture_block_dl),
            GEO_CLOSE_NODE(),
            // Shaded transparent texture
            GEO_NODE_START()
            GEO_OPEN_NODE(),
                GEO_ASM(1, geo_update_mce_block),
                GEO_DISPLAY_LIST(LAYER_TRANSPARENT, mce_texture_block_dl),
            GEO_CLOSE_NODE()
            // Unshaded solid texture
            GEO_NODE_START()
            GEO_OPEN_NODE(),
                GEO_ASM(2, geo_update_mce_block),
                GEO_DISPLAY_LIST(LAYER_ALPHA, mce_texture_block_dl),
            GEO_CLOSE_NODE()
            // Unshaded transparent texture
            GEO_NODE_START()
            GEO_OPEN_NODE(),
                GEO_ASM(3, geo_update_mce_block),
                GEO_DISPLAY_LIST(LAYER_TRANSPARENT, mce_texture_block_dl),
            GEO_CLOSE_NODE()
            // Shaded solid color
            GEO_NODE_START()
            GEO_OPEN_NODE(),
                GEO_ASM(4, geo_update_mce_block),
                GEO_DISPLAY_LIST(LAYER_ALPHA, mce_texture_block_dl),
            GEO_CLOSE_NODE(),
            // Shaded transparent color
            GEO_NODE_START()
            GEO_OPEN_NODE(),
                GEO_ASM(5, geo_update_mce_block),
                GEO_DISPLAY_LIST(LAYER_TRANSPARENT, mce_texture_block_dl),
            GEO_CLOSE_NODE()
            // Unshaded solid color
            GEO_NODE_START()
            GEO_OPEN_NODE(),
                GEO_ASM(6, geo_update_mce_block),
                GEO_DISPLAY_LIST(LAYER_ALPHA, mce_texture_block_dl),
            GEO_CLOSE_NODE()
            // Unshaded transparent color
            GEO_NODE_START()
            GEO_OPEN_NODE(),
                GEO_ASM(7, geo_update_mce_block),
                GEO_DISPLAY_LIST(LAYER_TRANSPARENT, mce_texture_block_dl),
            GEO_CLOSE_NODE()
        GEO_CLOSE_NODE(),
    GEO_CLOSE_NODE(),
    GEO_END(),
};