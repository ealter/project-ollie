//
//  Skeleton.cpp
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/4/12.
//  Copyright (c) 2012 hi ku llc. All rights reserved.
//

#include <stdlib.h>
#include <stdio.h>
#include <fstream>
#include "Skeleton.h"
#include "Box2D.h"
#include "GameConstants.h"

using namespace std;

Skeleton::Skeleton(b2World* world)
{
    this->angle = 0.0;
    this->root = NULL;
    this->world = world;
}

Skeleton::~Skeleton()
{
    this->boneDumpTree(this->root, 0);
    this->boneFreeTree(this->root);
}

Bone* Skeleton::boneAddChild(Bone *root, string name, float x, float y, float angle, float length, float width, float jx, float jy, float jaMax, float jaMin)
{
    Bone *t = new Bone;
    
    /* Set data */
    t->x             = x;
    t->y             = y;
    t->a             = angle;
    t->l             = length;
    t->w             = width;
    t->name          = name;
    t->jointAngleMax = jaMax;
    t->jointAngleMin = jaMin;
    t->jx            = jx;
    t->jy            = jy;
    
    return boneAddChild(root, t);
}

Bone* Skeleton::boneAddChild(Bone *root, Bone *child)
{
    if (!root) { /* If there is no root, create a new */
        root         = child;
        root->parent = NULL;
        this->root   = root;
    } else if (root->children.size() < MAX_CHCOUNT)  {/* If there is space for another child */
        child->parent = root;
        root->children.push_back(child); /* Set the pointer */
        root = child; /* Change the root */
    } else /* Can't add a child */
        return NULL;
    
    /* Tie to box2d */
    b2BodyDef bd;
    b2PolygonShape box;
    b2FixtureDef fixtureDef;
    b2RevoluteJointDef jointDef;
    
    /* Body definition */
    bd.type = b2_dynamicBody;
    bd.gravityScale = 1.;
    bd.linearDamping = .1f;
    bd.angularDamping = .1f;
    
    box.SetAsBox(root->l/PTM_RATIO/2.f,root->w/PTM_RATIO/2.);
    fixtureDef.shape = &box;
    fixtureDef.density = 1.f;
    fixtureDef.friction = 8.f;
    fixtureDef.restitution = 0.1f;
    fixtureDef.filter.categoryBits = CATEGORY_BONES;
    fixtureDef.filter.maskBits = MASK_BONES;
    bd.position.Set(root->x/PTM_RATIO, root->y/PTM_RATIO);
    b2Body *boneShape = world->CreateBody(&bd);
    boneShape->CreateFixture(&fixtureDef);
    
    root->box2DBody = boneShape;
    root->box2DBody->SetUserData(root);
    
    boneShape->SetTransform(boneShape->GetPosition(), root->a);
    
    /* Joint definition */
    if(root->parent) {
        jointDef.enableLimit = true;
        jointDef.upperAngle  = root->jointAngleMax;
        jointDef.lowerAngle  = root->jointAngleMin;
        jointDef.Initialize(root->box2DBody, root->parent->box2DBody, b2Vec2(root->jx/PTM_RATIO,root->jy/PTM_RATIO));
        //jointDef.referenceAngle = root->box2DBody->GetAngle() - root->parent->box2DBody->GetAngle();
        world->CreateJoint(&jointDef);
        //DebugLog("The angle between these two bodies are: %4.4f", RAD2DEG(j->GetJointAngle()));
    }
    
    boneDict[root->name] = root;
    
    return root;
}

void Skeleton::boneDumpTree(Bone *root, int level)
{
    if (!root)
        return;
    
    for (int i = 0; i < level; i++)
        printf("  "); /* We print to signal the level of this bone. */
    
    string pname = "none";
    if(root->parent)
        pname = root->parent->name;
    
    printf("Name:%s X: %4.4f Y: %4.4f JX: %4.4f JY: %4.4f Ang: %4.4f %s \n",root->name.c_str(), root->x + absolutePosition.x, root->y + absolutePosition.y, root->jx, root->jy, root->a, pname.c_str());
    
    /* Recursively call this on children */
    for (int i = 0; i < root->children.size(); i++)
        boneDumpTree(root->children.at(i), level + 1);
}

Bone* Skeleton::boneFreeTree(Bone *root)
{    
    if (!root)
        return NULL;
    
    for (int i = 0; i < root->children.size(); i++)
        boneFreeTree(root->children[i]);
    
    boneDict[root->name] = NULL;
    
    delete(root);
    
    return NULL;
}

void Skeleton::addAnimationFrame(string animationName, string boneName, KeyFrame *frame)
{
    //pushes the frame back for that particular bone
    Animation* animation = animations[animationName][boneName];
    if(animation) {
        animation->frames.push_back(frame);
    } else {
        animation = new Animation;
        animation->frames.push_back(frame);
        animations[animationName][boneName] = animation;
    }
}

void Skeleton::deleteAnimation(string animationName)
{

    std::map<string, Animation*> animation = animations[animationName];
    std::map<string, Animation*>::iterator it;
    for(it = animation.begin(); it != animation.end(); it++)
    {
        it->second->frames.clear();
    }
}

void Skeleton::runAnimation(string animationName, bool flipped)
{
    setActive(root, true);
    map<string, Animation*>::iterator iter;
    for (iter = animations[animationName].begin(); iter != animations[animationName].end(); iter++) {
        
        /* if flipped, it should adjust the symmetric limb */
        string name = iter->first;
        string initial_name;
        char prefix = iter->first.at(0);
        if(flipped)
        {
            initial_name = name;
            
            if(prefix == 'r')
                name = 'l'+name.substr(1);
            else if (prefix == 'l')
                name = 'r'+name.substr(1);
        }
        // When reversed, alternate bones    
        Bone* bone = this->getBoneByName(name);
        Bone* alternate = this->getBoneByName(initial_name);
        if(bone) {
            if(iter->second) {
                // queue<KeyFrame*> newAnimation;
                
                /* Get the last frame of the previous animation */
                KeyFrame* last;
                float extraTime = 0;
                if(!bone->animation.empty())
                {
                    last = bone->animation.back();
                    extraTime    = last->time;
                }
                
                /* Iterate through new animation queue and push it to the back of current animation queue */
                for(int i = 0; i < iter->second->frames.size(); i++) {
                    
                    /* Create a deep copy to adjust time of frame */
                    KeyFrame* deep = new KeyFrame;
                    KeyFrame* shallow = iter->second->frames.at(i);
                    
                    deep->x           = shallow->x;
                    deep->y           = shallow->y;
                    deep->angle       = shallow->angle;
                    deep->time        = shallow->time + extraTime;
                    
                    if(flipped)
                    {
                        if(alternate)
                        {
                            int tempz    = bone->z;
                            bone->z      = alternate->z;
                            alternate->z = tempz;
                        }
                        deep->x      = -deep->x;
                        deep->angle  = M_PI - deep->angle; 
                    }
                    
                    /* Push it to back of animation queue */
                    bone->animation.push(deep);
                }
                //swap(bone->animation,newAnimation);
            }
        }
    }
}

void Skeleton::clearAnimationQueue(Bone* root)
{
    queue<KeyFrame*> cleanQueue;
    swap(root->animation, cleanQueue);
    for(int i = 0; i < root->children.size(); i++)
        clearAnimationQueue(root->children.at(i));
    
}

bool Skeleton::animating(Bone *root, float time)
{
    bool anim = true;
    KeyFrame* key = root->animation.front();
    /* Check for current keyframe */
    if (!root->animation.empty()) {
        anim = true;
        while (key->time <= time) {
            /*Transform according to skeleton's angle */
            root->a = key->angle+this->angle;
            root->x = key->x*cos(this->angle) - key->y*sin(this->angle);
            root->y = key->x*sin(this->angle) + key->y*cos(this->angle);
            /* Change animation */
            delete key;
            root->animation.pop();
            if(root->animation.empty())break;
            key = root->animation.front();
        }
        //DebugLog("The angle here is: %f",RAD2DEG(this->angle));
        root->box2DBody->SetLinearVelocity(b2Vec2(0,0));
    }
    else {
        // stop animating
        anim = false;
        
        // new position is avg left and right leg position
        Bone* ll = getBoneByName("ll_leg");
        Bone* rl = getBoneByName("rl_leg");

        if(ll && rl) {
            float xpos = ll->box2DBody->GetPosition().x + rl->box2DBody->GetPosition().x;
            xpos      /= 2;
            float ypos = ll->box2DBody->GetPosition().y + rl->box2DBody->GetPosition().y;
            ypos      /= 2;
            
            absolutePosition = b2Vec2(xpos,ypos);
        }
    }
    
    /* Call on other bones */
    for (int i = 0; i < root->children.size(); i++)
        if(animating(root->children.at(i), time))
            anim = true;
    
    return anim;
}

void Skeleton::setRoot(Bone *bone)
{
    root = bone;
}

Bone* Skeleton::getRoot()
{
    return root;
}

Bone* Skeleton::getBoneByName(string name)
{
    return boneDict[name];
}

void Skeleton::setPosition(Bone* root, float x, float y)
{
    absolutePosition = b2Vec2(x/PTM_RATIO,y/PTM_RATIO);
    adjustTreePosition(this->root);
}

void Skeleton::setLinearVelocity(Bone *root, b2Vec2 velocity)
{
    root->box2DBody->SetLinearVelocity(velocity);
    for(int i = 0; i < root->children.size(); i++)
        setLinearVelocity(root->children.at(i),velocity);
}

void Skeleton::adjustTreePosition(Bone* root)
{
    root->box2DBody->SetTransform(b2Vec2(root->x/PTM_RATIO,root->y/PTM_RATIO) + absolutePosition, root->a);
    for(int i = 0; i < root->children.size(); i++)
        adjustTreePosition(root->children.at(i));
}

void Skeleton::setAngle(float a){
    this->angle = a;
}

float Skeleton::getAngle(){
    return this->angle;
}

float Skeleton::lowestY(Bone* root, float currentLowest)
{
    //set up values for dot product
    float x_extent    = root->w/2./PTM_RATIO;
    float y_extent    = root->l/2./PTM_RATIO;
    float bodyAngle   = root->box2DBody->GetAngle();
    b2Vec2 localXaxis = b2Vec2(cos(bodyAngle),sin(bodyAngle));
    b2Vec2 localYaxis = b2Vec2(-localXaxis.y, localXaxis.x);
    
    //use dot products to get radius towards bottom
    float radius = abs(localXaxis.y) * x_extent + abs(localYaxis.y) * y_extent;
    float minY = root->box2DBody->GetPosition().y - radius;
    
    //recursively check against all the children
    currentLowest = min(currentLowest,minY);
    for(int i = 0; i < root->children.size(); i++)
    {
        currentLowest = min(currentLowest, lowestY(root->children.at(i),currentLowest));
    }
    
    return currentLowest;
}

b2Vec2 Skeleton::highestContact(Bone *root, b2Vec2 currentHighest){
    
    b2Body* body = root->box2DBody;
    for (b2ContactEdge* ce = body->GetContactList(); ce; ce = ce->next)
    {
        b2Contact* c = ce->contact;
        b2WorldManifold manifold;
        c->GetWorldManifold(&manifold);
        b2Vec2 contactPoint = manifold.points[0];
        
        if(contactPoint.y > currentHighest.y) currentHighest = contactPoint;
    }
    
    for(int i = 0; i < root->children.size(); i++)
    {
        b2Vec2 potential = highestContact(root->children.at(i), currentHighest);
        if(potential.y > currentHighest.y)
            currentHighest = potential;
    }
    return currentHighest;
}

void Skeleton::setActive(Bone *root, bool active)
{
    b2Body* body = root->box2DBody;
    body->SetAwake(active);
    body->SetActive(active);
    
    for(int i = 0; i<root->children.size();i++)
        setActive(root->children.at(i),active);
}

std::map<string, std::map<string,Animation*> > Skeleton::getAnimationMap()
{
    return animations;
}

float Skeleton::getX(){
    return absolutePosition.x;
}
float Skeleton::getY(){
    return absolutePosition.y;
}

void Skeleton::setUserData(Bone *root, void *userData)
{
    root->box2DBody->SetUserData(userData);
    for (int i = 0; i < root->children.size(); i++) {
        setUserData(root->children.at(i), userData);
    }
}

void Skeleton::update()
{

}

