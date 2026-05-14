#include "src/game/envfx_snow.h"

const GeoLayout Icosphere_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, Icosphere_Icosphere_mesh_layer_1_with_revert),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
