//
//  Skeleton.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/4/12.
//  Copyright (c) 2012 hi ku llc. All rights reserved.
//

#ifndef ProjectOllie_Skeleton_h
#define ProjectOllie_Skeleton_h

#include "string.h"
#include "Box2D.h"
//#include "GameConstants.h"


#define MAX_CHCOUNT				8  //max amount of children for bone
#define MAX_KFCOUNT				30 //max amount of key frames per bone per animation

using namespace std;

struct KeyFrame{
    float angle, time;
};

struct Animation{
  
    KeyFrame keyframes[MAX_KFCOUNT];
    
};

struct Bone{
    
    string name;
    float x, // x coordinate
          y, // y coordinate
          a, // angle (in radians)
          l, // length (in meters)
          w, // width (in meters)
       offA; // offset angle (for interpolation)

    
    int        childCount;
    int        keyFrameCount;
    Bone*      children[MAX_CHCOUNT];
    Bone*      parent;
    KeyFrame  keyframes[MAX_KFCOUNT];

    b2Body* box2DBody;
    
};

// Holds a collection of Bone trees
class Skeleton
{
private:
    Bone* root;
    Bone* loadStructure(string path);
    Bone* boneFreeTree(Bone* root);
	b2World* world;	
    
public:
    
    
    /* THE FORMAT FOR SKELETAL STRUCTURE IS TOP TO BOTTOM, LEFT TO RIGHT */
    
    // HEAD   = ROOT
    // UTORSO = HEAD.CHILDREN[0]
    // LTORSO = UTORSO.CHILDREN[0]
    // LUARM  = UTORSO.CHILDREN[1]
    // RUARM  = UTORSO.CHILDREN[2]
    // LLARM  = LUARM.CHILDREN[0]
    // RLARM  = RUARM.CHILDREN[0]
    // LULEG  = LTORSO.CHILDREN[0]
    // RULEG  = LTORSO.CHILDREN[1]
    // LLLEG  = LULEG.CHILDREN[0]
    // RLLEG  = RULEG.CHILDREN[0]
    
    Bone* head;
    
    Bone* uTorso;
    Bone* lTorso;
    
    Bone* luArm;
    Bone* llArm;
    
    Bone* ruArm;
    Bone* rlArm;
    
    Bone* luLeg;
    Bone* llLeg;
    
    Bone* ruLeg;
    Bone* rlLeg;
    
    Skeleton(b2World* world, string path);
    Skeleton(b2World* world);
    ~Skeleton();
    
    Bone* boneAddChild(Bone* root, string name, float x, float y, float a, float length, float width);
    Bone* findBoneByName(Bone* root, string name);
    void  boneDumpTree(Bone* root, int level);
    bool animating(Bone* root, float time);
    void generateBox2DBodies();
    
};



#endif
