// 0x0700E958 - 0x0701104C
const Collision bob_seg7_collision_level[] = {
    COL_INIT(),
    COL_VERTEX_INIT(9),
    COL_VERTEX(0, -30000, 0), // 0
    COL_VERTEX(-32768, -30000, 0), // 1
    COL_VERTEX(0, -30000, 32767), // 2
    COL_VERTEX(32767, -30000, 0), // 3
    COL_VERTEX(0, -30000, -32768), // 4
    COL_VERTEX(-32768, -30000, -32768), // 5
    COL_VERTEX(32767, -30000, 32767), // 6
    COL_VERTEX(32767, -30000, -32768), // 7
    COL_VERTEX(-32768, -30000, 32767), // 8
    COL_TRI_INIT(SURFACE_DEFAULT, 8),
    COL_TRI(0, 1, 8),
    COL_TRI(0, 8, 2),
    COL_TRI(0, 2, 6),
    COL_TRI(0, 6, 3),
    COL_TRI(0, 3, 7),
    COL_TRI(0, 7, 4),
    COL_TRI(0, 4, 5),
    COL_TRI(0, 5, 1),
    COL_END(),
};
