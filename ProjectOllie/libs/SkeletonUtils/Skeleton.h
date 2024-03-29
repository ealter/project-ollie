//
//  Skeleton.h
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/4/12.
//  Copyright (c) 2012 hi ku llc. All rights reserved.
//

#ifndef ProjectOllie_Skeleton_h
#define ProjectOllie_Skeleton_h

#include <vector>
#include <queue>
#include <map>
#include <string>
#include "b2Math.h"

#define MAX_CHCOUNT 8  //max amount of children for bone
#define MAX_KFCOUNT 60 //max amount of key frames per bone per animation

/**
 * TODO WITH SKELETON 
 **
 - ADD MARKER THAT ACTS AS POSITION INSTEAD (SOURCE OF MOTION)
 - ANIMATE WITH TWEENING
 */

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
              z, // the bone's z value
  jointAngleMax, // joint angle maximum limit
  jointAngleMin; // joint angle minimum limit
        
    std::vector<Bone*>    children;
    Bone*                 parent;
    std::queue<KeyFrame*> animation;

    //every bone is a body with a joint
    //the joint is where it attaches to it's parent
    b2Body*          box2DBody;
    
};

struct Animation{
    std::vector<KeyFrame*> frames;
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
    std::map<string, std::map<string,Animation*> > animations;
    
    /* Free the tree of bones, for use with destructor */
    Bone* boneFreeTree(Bone* root);
    
    /* Absolute position of the skeleton in a b2World. Needed because all we have are bones */
    b2Vec2 absolutePosition;
    
    /* helper to adjust position all the way through the skeleton */
    void adjustTreePosition(Bone* root, float dt);
    
    /* set position absolutely instead of suggesting */
    void setTreePosition(Bone* root);
    
    /* Keeps track of angle of entire skeleton (essentially torso angle)*/
    float angle;
    
    /* Fast look up of bones by name */
    std::map<string,Bone*> boneDict;
    
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
    Bone* getBoneByName(string name);
    
    /* Fetches root for traverals */
    Bone* getRoot();
    
    /* Adds this animation frame to the map */
    void addAnimationFrame(string animationName, string boneName, KeyFrame* frame);
    
    /* Removes animation from anim dictionary */
    void deleteAnimation(string animationName);
    
    /* Loads this animation to the skeleton */
    void runAnimation(string animationName, bool flipped);
    
    /* sets absolute position. Arguments are pixels */
    void setPosition(Bone* root, float x, float y);
    
    /* Adjust position w/o setting transform */
    void adjustPosition(Bone* root, float x, float y, float dt);
    
    /* sets absolute angle. Argument in radians. For use in animation */
    void setAngle(float a);
    
    /* sets linear velocity of each bone recursively */
    void setLinearVelocity(Bone* root, b2Vec2 velocity);
    
    /* recursive function to find lowest y coordinate, give arbitrarily high number to start */
    float lowestY(Bone* root, float currentLowest);
    
    /* recursive function to find the highest point of contact from a given root */
    b2Vec2 highestContact(Bone* root, b2Vec2 currentHighest);
    
    /* clears out the animation queue */
    void clearAnimationQueue(Bone* root);
    
    /* Sets whether or not the bones are active */
    void setActive(Bone* root, bool active);
    
    float getX();
    float getY();
    float getAngle();
    
    /* Returns the map of animations */
    std::map<string, std::map<string,Animation*> > getAnimationMap();
    
    void setUserData(Bone* root, void* userData);
    
    /* update values changing over time */
    void update();
};

#endif
