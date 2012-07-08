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
#include "GameConstants.h"


#define MAX_CHCOUNT				8  //max amount of children for bone
#define MAX_KFCOUNT				60 //max amount of key frames per bone per animation

using namespace std;

struct KeyFrame{
    float angle, time;
};

struct Animation{
    KeyFrame keyframes[MAX_KFCOUNT];
};

struct Bone{
    
    string name;
    float     x, // x coordinate
              y, // y coordinate
              a, // angle (in radians)
              l, // length (in meters)
              w, // width (in meters)
           offA, // offset angle (for interpolation)
             jx, // joint x coordinate
             jy, // joint y coordinate
  jointAngleMax, // joint angle maximum limit
  jointAngleMin; // joint angle minimum limit
        

    
    int              childCount;
    int              keyFrameCount;
    Bone*            children[MAX_CHCOUNT];
    Bone*            parent;
    Animation*       animation;

    //every bone is a body with a joint
    //the joint is where it attaches to it's parent
    b2Body*          box2DBody;
    
};

// Holds a collection of Bone trees
class Skeleton
{
private:
    //private variables
    Bone* root;
    b2World* world;	
    
    //private functions
    
    /* Add a bone as a child of another bone, or as a child of nil (therefore the root) */
    Bone* boneAddChild(Bone *root, string name, float x, float y, float angle, float length, float width, float jx, float jy, float jaMax, float jaMin, Animation* anim);
    
    /* Free the tree of bones, for use with destructor */
    Bone* boneFreeTree(Bone* root);
    
public:
    
    //constructors with box2dworld
    Skeleton(b2World* world, string path);
    Skeleton(b2World* world);
    ~Skeleton();
    
    /* Can get information about a bone from a string of its name */
    Bone* findBoneByName(Bone* root, string name);
    
    /* Prints out tree from given bone */
    void  boneDumpTree(Bone* root, int level);
    
    /* Animates, returns whether or not it is still animating */
    bool animating(Bone* root, float time);
    
    /* Load a structure of bones from a file, returns pointer to root */
    Bone* loadBoneStructure(string path);
    
    
};



#endif
