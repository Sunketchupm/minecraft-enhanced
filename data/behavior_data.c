const BehaviorScript bhvOutline[] = {
    BEGIN(OBJ_LIST_DEFAULT),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    CALL_NATIVE(bhv_outline_init),
    BEGIN_LOOP(),
        CALL_NATIVE(bhv_outline_loop),
    END_LOOP(),
};

const BehaviorScript bhvMockItem[] = {
    BEGIN(OBJ_LIST_DEFAULT),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    BEGIN_LOOP(),
        CALL_NATIVE(bhv_mock_item_loop),
    END_LOOP(),
};

const BehaviorScript bhvMinecraftBox[] = {
    BEGIN(OBJ_LIST_SURFACE),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    LOAD_COLLISION_DATA(custom_box_collision_default),
    SET_FLOAT(oCollisionDistance, 500),
    SET_HOME(),
    BEGIN_LOOP(),
        CALL_NATIVE(load_object_collision_model),
    END_LOOP(),
};