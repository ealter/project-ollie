//
//  Skeleton.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/4/12.
//  Copyright (c) 2012 hi ku llc. All rights reserved.
//

#ifndef ProjectOllie_Skeleton_h
#define ProjectOllie_Skeleton_h

#include <string>
#include <vector>
#include <queue>

#define MAX_CHCOUNT				8  //max amount of children for bone
#define MAX_KFCOUNT				60 //max amount of key frames per bone per animation

class b2Body;
class b2World;

using std::string;

struct KeyFrame{
    float angle, time, x, y;
};

struct Bone{
    
    string name;
    float     x, // x coordinate of center
              y, // y coordinate of center
              a, // angle (in radians)
              l, // length (in meters)
              w, // width (in meters)
           offA, // offset angle (for interpolation)
             jx, // joint x coordinate
             jy, // joint y coordinate
  jointAngleMax, // joint angle maximum limit
  jointAngleMin; // joint angle minimum limit
        
    std::vector<Bone*>    children;
    Bone*                 parent;
    std::queue<KeyFrame*> animation;

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
    
    /* Free the tree of bones, for use with destructor */
    Bone* boneFreeTree(Bone* root);
    
public:
    
    //constructors with box2dworld
    Skeleton(b2World* world);
    ~Skeleton();
    
    /* Can get information about a bone from a string of its name */
    Bone* findBoneByName(Bone* root, string name);
    
    /* Add a bone as a child of another bone, or as a child of nil (therefore the root) */
    Bone* boneAddChild(Bone *root, string name, float x, float y, float angle, float length, float width, float jx, float jy, float jaMax, float jaMin);
    
    Bone* boneAddChild(Bone *root, Bone* child);
    
    /* Prints out tree from given bone */
    void  boneDumpTree(Bone* root, int level);
    
    /* Animates, returns whether or not it is still animating */
    bool animating(Bone* root, float time);
    
    /* Setters and getters for root of tree */
    void setRoot(Bone* bone);
    
    /* Searches for specific name. Have to use string comparisons...maybe need better data structure */
    Bone* getBoneByName(Bone* root, string name);
    
    /* Fetches root for traverals */
    Bone* getRoot();
};

#endif
