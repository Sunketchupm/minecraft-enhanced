#include "src/game/envfx_snow.h"

const GeoLayout cube_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_TRANSPARENT_DECAL, cube_cube_mesh_layer_6_with_revert),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
