const GeoLayout mce_block_geo[] = {
    GEO_SCALE(0, 0x8000),
    GEO_OPEN_NODE(),
        GEO_SWITCH_CASE(8, geo_switch_mce_block),
        GEO_OPEN_NODE(),
            // Solid
            GEO_NODE_START()
            GEO_OPEN_NODE(),
                GEO_ASM(0, geo_update_mce_block),
                GEO_DISPLAY_LIST(LAYER_ALPHA, mce_texture_block_dl),
            GEO_CLOSE_NODE(),
            // Transparent
            GEO_NODE_START()
            GEO_OPEN_NODE(),
                GEO_ASM(1, geo_update_mce_block),
                GEO_DISPLAY_LIST(LAYER_TRANSPARENT, mce_texture_block_dl),
            GEO_CLOSE_NODE()
        GEO_CLOSE_NODE(),
    GEO_CLOSE_NODE(),
    GEO_END(),
};