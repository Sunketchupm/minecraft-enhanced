#include "src/game/envfx_snow.h"

const GeoLayout stair_4_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_ALPHA, stair_4_stair_4_mesh_layer_4_with_revert),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
