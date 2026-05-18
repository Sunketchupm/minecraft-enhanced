#include "src/game/envfx_snow.h"

const GeoLayout Cube_6_sides_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_ALPHA, Cube_6_sides_Cube_6_sides_mesh_layer_4_with_revert),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
