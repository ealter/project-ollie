#ifndef ProjectOllie_GameContants_h
#define ProjectOllie_GameContants_h

#define PTM_RATIO 32    //Pixels to meters at a zoom level of 1

#define FPS 60

//Width and height of the world in meters
#define WORLD_WIDTH 10
#define WORLD_HEIGHT 5

//For things that must go to the edges of all possible screens
#define MIN_VIEWABLE_X (-WORLD_WIDTH*PTM_RATIO/2)
#define MAX_VIEWABLE_X (WORLD_WIDTH*PTM_RATIO*3/2)
#define MIN_VIEWABLE_Y (-WORLD_HEIGHT*PTM_RATIO/2)
#define MAX_VIEWABLE_Y (WORLD_HEIGHT*PTM_RATIO*3/2)

#define MAX_WIDTH_PX (MAX_VIEWABLE_X - MIN_VIEWABLE_X)
#define MAX_HEIGHT_PX (MAX_VIEWABLE_Y - MIN_VIEWABLE_Y)

#define CATEGORY_BONES       0x0001 // 0000000000000001 in binary
#define CATEGORY_TERRAIN     0x0002 // 0000000000000010 in binary
#define CATEGORY_PROJECTILES 0x0004 // 0000000000000100 in binary

#define MASK_BONES  (CATEGORY_TERRAIN | CATEGORY_PROJECTILES) // Collides with terrain and projectiles 
#define MASK_TERRAIN (CATEGORY_BONES | CATEGORY_PROJECTILES)  // Collides with bones and projectiles
#define MASK_PROJECTILES  -1                                  // Collides with everything

#define RAD2DEG(a) (((a) * 180.0) / M_PI)
#define DEG2RAD(a) (((a) / 180.0) * M_PI)

#endif
