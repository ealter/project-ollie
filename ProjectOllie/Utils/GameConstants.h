#ifndef ProjectOllie_GameContants_h
#define ProjectOllie_GameContants_h

#define PTM_RATIO 32
#define FPS 60

#define CATEGORY_BONES       0x0001 // 0000000000000001 in binary
#define CATEGORY_TERRAIN     0x0002 // 0000000000000010 in binary
#define CATEGORY_PROJECTILES 0x0004 // 0000000000000100 in binary

#define MASK_BONES  (CATEGORY_TERRAIN | CATEGORY_PROJECTILES) // or ~CATEGORY_PLAYER
#define MASK_TERRAIN (CATEGORY_BONES | CATEGORY_PROJECTILES) // or ~CATEGORY_MONSTER
#define MASK_PROJECTILES  -1

#define RAD2DEG(a) (((a) * 180.0) / M_PI)
#define DEG2RAD(a) (((a) / 180.0) * M_PI)

#endif
