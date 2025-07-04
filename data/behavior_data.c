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
    BEGIN(OBJ_LIST_UNIMPORTANT),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    BEGIN_LOOP(),
        CALL_NATIVE(bhv_mock_item_loop),
    END_LOOP(),
};

const BehaviorScript bhvArrow[] = {
    BEGIN(OBJ_LIST_UNIMPORTANT),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    BEGIN_LOOP(),
        CALL_NATIVE(bhv_arrow_loop),
    END_LOOP(),
};

/////////////////////////////////////////////////////////////////////////////////////////

const BehaviorScript bhvMceBlock[] = {
    BEGIN(OBJ_LIST_SURFACE),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    //LOAD_COLLISION_DATA(mce_block_col_default),
    SET_FLOAT(oCollisionDistance, 500),
    //SET_HOME(),
    CALL_NATIVE(bhv_mce_block_init),
    BEGIN_LOOP(),
        CALL_NATIVE(bhv_mce_block_loop),
        CALL_NATIVE(load_object_collision_model),
    END_LOOP(),
};

const BehaviorScript bhvMceStar[] = {
    BEGIN(OBJ_LIST_LEVEL),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    CALL_NATIVE(bhv_mce_star_init),
    BEGIN_LOOP(),
        CALL_NATIVE(bhv_mce_star_loop),
        ADD_INT(oFaceAngleYaw, 0x800),
    END_LOOP(),
};

const BehaviorScript bhvMceCoin[] = {
    BEGIN(OBJ_LIST_LEVEL),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    BILLBOARD(),
    CALL_NATIVE(bhv_mce_coin_init),
    //SET_OBJ_PHYSICS(/*Wall hitbox radius*/ 30, /*Gravity*/ -400, /*Bounciness*/ -70, /*Drag strength*/ 1000, /*Friction*/ 1000, /*Buoyancy*/ 200, /*Unused*/ 0, 0),
    BEGIN_LOOP(),
        CALL_NATIVE(bhv_mce_coin_loop),
        ADD_INT(oAnimState, 1),
    END_LOOP(),
};

const BehaviorScript bhvMceExclamationBox[] = {
    BEGIN(OBJ_LIST_SURFACE),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    LOAD_COLLISION_DATA(exclamation_box_outline_seg8_collision_08025F78),
    SET_FLOAT(oCollisionDistance, 300),
    SET_HOME(),
    CALL_NATIVE(bhv_mce_exclamation_box_init),
    BEGIN_LOOP(),
        CALL_NATIVE(bhv_mce_exclamation_box_loop),
    END_LOOP(),
};

const BehaviorScript bhvMceTree[] = {
    BEGIN(OBJ_LIST_POLELIKE),
    ID(id_bhvNewId),
    OR_INT(oFlags, OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE),
    SET_INT(oInteractType, INTERACT_POLE),
    SET_HITBOX(/*Radius*/ 80, /*Height*/ 500),
    SET_INT(oIntangibleTimer, 0),
    BILLBOARD(),
    BEGIN_LOOP(),
        CALL_NATIVE(bhv_pole_base_loop),
    END_LOOP(),
};

/////////////////////////////////////////////////////////////////////////////////////////