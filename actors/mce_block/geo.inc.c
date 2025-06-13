#include "src/game/envfx_snow.h"

const GeoLayout mce_block_Bone_001_opt1[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_ANIMATED_PART(LAYER_OPAQUE, 0, 259, 0, mce_block_Bone_002_mesh_layer_7_mat_override_f3dlite_material_0),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout mce_block_Bone_001_opt2[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_ANIMATED_PART(LAYER_OPAQUE, 0, 259, 0, mce_block_Bone_002_mesh_layer_7_mat_override_f3dlite_material_001_1),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout mce_block_Bone_001_opt3[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_ANIMATED_PART(LAYER_OPAQUE, 0, 259, 0, mce_block_Bone_002_mesh_layer_7_mat_override_f3dlite_material_002_2),
	GEO_CLOSE_NODE(),
	GEO_RETURN(),
};
const GeoLayout mce_block_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_SWITCH_CASE(4, geo_switch_anim_state),
		GEO_OPEN_NODE(),
			GEO_NODE_START(),
			GEO_OPEN_NODE(),
				GEO_ANIMATED_PART(LAYER_OPAQUE, 0, 259, 0, mce_block_Bone_002_mesh_layer_7),
			GEO_CLOSE_NODE(),
			GEO_BRANCH(1, mce_block_Bone_001_opt1),
			GEO_BRANCH(1, mce_block_Bone_001_opt2),
			GEO_BRANCH(1, mce_block_Bone_001_opt3),
		GEO_CLOSE_NODE(),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
