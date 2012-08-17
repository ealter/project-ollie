#ifndef ProjectOllie_GameContants_h
#define ProjectOllie_GameContants_h

#define PTM_RATIO 256               //Pixels to meters at a zoom level of 1 (camera at z0)

#define FPS 60

#define VERSION 0.01

//Width and height of the world in meters
#define WORLD_WIDTH 10
#define WORLD_HEIGHT 6
#define WORLD_WIDTH_PX  (WORLD_WIDTH  * PTM_RATIO)
#define WORLD_HEIGHT_PX (WORLD_HEIGHT * PTM_RATIO)

//For things that must go to the edges of all possible screens
#define MIN_VIEWABLE_X (-WORLD_WIDTH  *PTM_RATIO/2)
#define MAX_VIEWABLE_X ( WORLD_WIDTH  *PTM_RATIO/2*3)
#define MIN_VIEWABLE_Y (-WORLD_HEIGHT *PTM_RATIO/2)
#define MAX_VIEWABLE_Y (WORLD_HEIGHT  *PTM_RATIO/2*3)

#define MAX_WIDTH_PX  (MAX_VIEWABLE_X - MIN_VIEWABLE_X)
#define MAX_HEIGHT_PX (MAX_VIEWABLE_Y - MIN_VIEWABLE_Y)

#define CATEGORY_BONES       0x0001 // 0000000000000001 in binary
#define CATEGORY_TERRAIN     0x0002 // 0000000000000010 in binary
#define CATEGORY_PROJECTILES 0x0004 // 0000000000000100 in binary
#define CATEGORY_INTERACTOR  0x0008 // 0000000000001000 in binary
#define CATEGORY_PELLETS     0x0010 // 0000000000010000 in binary
#define CATEGORY_OUTERBONES  0x0020 // 0000000000100000 in binary

#define MASK_BONES   (CATEGORY_TERRAIN | CATEGORY_PROJECTILES | CATEGORY_PELLETS)                          // Collides with terrain and projectiles 
#define MASK_TERRAIN (CATEGORY_BONES | CATEGORY_PROJECTILES | CATEGORY_INTERACTOR | CATEGORY_PELLETS)    // Collides with bones and projectiles
#define MASK_PROJECTILES  -1                                                            // Collides with everything
#define MASK_PELLETS (CATEGORY_TERRAIN | CATEGORY_BONES)                                // Collides with Tucker's crotchal region
#define MASK_INTERACTOR CATEGORY_TERRAIN                                                // Collides with terrain only

#define RAD2DEG(a) (((a) * 180.0) / M_PI)
#define DEG2RAD(a) (((a) / 180.0) * M_PI)

#endif
