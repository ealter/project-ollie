//
//  Skeleton.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/4/12.
//  Copyright (c) 2012 hi ku llc. All rights reserved.
//

#ifndef ProjectOllie_Skeleton_h
#define ProjectOllie_Skeleton_h

#include "Box2D.h"
#include "GameConstants.h"
#include <vector>
#include <queue>
#include <map>
#include <string>

#define MAX_CHCOUNT				8  //max amount of children for bone
#define MAX_KFCOUNT				60 //max amount of key frames per bone per animation


/**
 * TODO WITH SKELETON 
 **
 - ADD MARKER THAT ACTS AS POSITION INSTEAD (SOURCE OF MOTION)
 - ANIMATE WITH TWEENING
 */

using namespace std;
class b2Body;
class b2World;

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
        
    vector<Bone*>     children;
    Bone*             parent;
    queue<KeyFrame*>  animation;

    //every bone is a body with a joint
    //the joint is where it attaches to it's parent
    b2Body*          box2DBody;
    
};

struct Animation{
    vector<KeyFrame*> frames;
};

// Holds a collection of Bone trees
class Skeleton
{
private:
    //private variables
    
    //root of skeletal tree. The head of the body in this case
    Bone* root;
    //Box2D world to put the skeleton in
    b2World* world;	
    //Map of animations we loaded from file. Will have string keys
    map<string, map<string,Animation*> > animations;
    
    /* Free the tree of bones, for use with destructor */
    Bone* boneFreeTree(Bone* root);
    
    /* Absolute position of the skeleton in a b2World. Needed because all we have are bones */
    b2Vec2 absolutePosition;
    
    /* helper to adjust position all the way through the skeleton */
    void adjustTreePosition(Bone* root);
    
public:
    
    //constructors with box2dworld
    Skeleton(b2World* world);
    ~Skeleton();
    
    /* Add a bone as a child of another bone, or as a child of nil (therefore the root) */
    Bone* boneAddChild(Bone *root, string name, float x, float y, float angle, float length, float width, float jx, float jy, float jaMax, float jaMin);
    
    /* Helper for adding bones */
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
    
    /* Adds this animation frame to the map */
    void addAnimationFrame(string animationName, string boneName, KeyFrame* frame);
    
    /* Loads this animation to the skeleton */
    void loadAnimation(string animationName);
    
    /* sets absolute position. Arguments are pixels */
    void setPosition(Bone* root, float x, float y);
    
    float getX();
    float getY();
    
    /* update values changing over time */
    void update();
};

#endif
