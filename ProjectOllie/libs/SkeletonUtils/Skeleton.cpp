//
//  Skeleton.cpp
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/4/12.
//  Copyright (c) 2012 hi ku llc. All rights reserved.
//

#include <iostream>
#include <stdlib.h>
#include <stdio.h>
#include <fstream>
#include "Skeleton.h"
#include "Box2D.h"
#include "GameConstants.h"

Skeleton::Skeleton(b2World* world)
{
    this->root = NULL;
    this->world = world;
}

Skeleton::~Skeleton()
{
    this->boneDumpTree(this->root, 0);
    this->boneFreeTree(this->root);
}

Bone* Skeleton::boneAddChild(Bone *root, string name, float x, float y, float angle, float length, float width, float jx, float jy, float jaMax, float jaMin, Animation* anim)
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
    t->animation     = anim;
    
    return boneAddChild(root, t);
    
}

Bone* Skeleton::boneAddChild(Bone *root, Bone *child){
    if (!root) /* If there is no root, create a new */
	{
		root         = child;
        root->parent = NULL;
        this->root   = root;
	}
	else if (root->children.size() < MAX_CHCOUNT) /* If there is space for another child */
	{
		child->parent = root;
		root->children.push_back(child); /* Set the pointer */
		root = child; /* Change the root */
	}
	else /* Can't add a child */
		return NULL;
    
    /* Tie to box2d */
    b2BodyDef bd;
    b2PolygonShape box;
    b2FixtureDef fixtureDef;
    b2RevoluteJointDef jointDef;
    
    /* Body definition */
    bd.type = b2_dynamicBody;
    bd.gravityScale = 0;
    box.SetAsBox(root->l/PTM_RATIO/2.f,root->w/PTM_RATIO);
    fixtureDef.shape = &box;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.4f;
    fixtureDef.restitution = 0.1f;
    fixtureDef.filter.categoryBits = CATEGORY_BONES;
    fixtureDef.filter.maskBits = MASK_BONES;
    bd.position.Set(root->x/PTM_RATIO, root->y/PTM_RATIO);
    b2Body *boneShape = world->CreateBody(&bd);
    boneShape->CreateFixture(&fixtureDef);
    root->box2DBody = boneShape;
    
    boneShape->SetTransform(boneShape->GetPosition(), root->a);
    
    
    /* Joint definition */
    if(root->parent)
    {
        jointDef.enableLimit = true;
        jointDef.upperAngle  = root->jointAngleMax;
        jointDef.lowerAngle  = root->jointAngleMin;
        jointDef.Initialize(root->box2DBody, root->parent->box2DBody, b2Vec2(root->jx/PTM_RATIO,root->jy/PTM_RATIO));
       // jointDef.referenceAngle = abs(root->a - root->parent->a);
        b2RevoluteJoint* j = (b2RevoluteJoint*)world->CreateJoint(&jointDef);
        DebugLog("The angle between these two bodies are: %4.4f", j->GetJointAngle());
    }
    
    
	return root;

}

void Skeleton::boneDumpTree(Bone *root, int level)
{
	if (!root)
		return;
    
	for (int i = 0; i < level; i++)
		printf("#"); /* We print # to signal the level of this bone. */
    
    string pname = "none";
    if(root->parent)
        pname = root->parent->name;
    
	printf("Name:%s X: %4.4f Y: %4.4f JX: %4.4f JY: %4.4f Ang: %4.4f %s \n",root->name.c_str(), root->x, root->y, root->jx, root->jy, root->a, pname.c_str());
    
	/* Now print animation info */
	/*for (int i = 0; i < root->keyFrameCount; i++)
		printf(" %4.4f %4.4f", root->animation->keyframes[i].time, root->animation->keyframes[i].angle);
	printf("\n");*/
    
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
    
	delete(root);
    
	return NULL;
}

bool Skeleton::animating(Bone *root, float time)
{
    
    bool others = false;
    
	float adiff,
    tdiff;
    
	/* Check for keyframes */
	for (int i = 0; i < root->animation->keyFrames.size(); i++)
		if (root->animation->keyFrames[i].time == time)
		{
			/* Find the index for the interpolation */
			if (i != root->animation->keyFrames.size() - 1)
			{
				tdiff = root->animation->keyFrames.at(i + 1).time - root->animation->keyFrames.at(i).time;
				adiff = root->animation->keyFrames.at(i + 1).angle - root->animation->keyFrames.at(i).angle;
                
				root->offA = adiff / tdiff;
			}
			else
			{
				root->offA = 0;
			}
		}
		else if (root->animation->keyFrames.at(i).time > time)
			others = true;
	
	/* Change animation */
	root->a += root->offA;
    
	/* Call on other bones */
	for (int i = 0; i < root->children.size(); i++)
		if (animating(root->children.at(i), time))
			others = true;
    
	return others;
}

void Skeleton::setRoot(Bone *bone)
{
    root = bone;
}

Bone* Skeleton::getRoot()
{
    return root;
}
