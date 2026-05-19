#include "src/game/envfx_snow.h"

const GeoLayout pyramid_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_ALPHA, pyramid_pyramid_mesh_layer_4_with_revert),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
