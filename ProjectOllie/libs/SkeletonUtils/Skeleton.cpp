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

#define RAD2DEG(a) (((a) * 180.0) / M_PI)
#define DEG2RAD(a) (((a) / 180.0) * M_PI)


Skeleton::Skeleton(b2World* world, string path)
{
    this->root   = loadBoneStructure(path);
    this->world  = world;
}

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
    Bone *t;
	int i;
    
	if (!root) /* If there is no root, create a new */
	{
		if (!(root = (Bone *)malloc(sizeof(Bone))))
			return NULL; // all is lost
        
		root->parent = NULL;
	}
	else if (root->childCount < MAX_CHCOUNT) /* If there is space for another child */
	{
		if (!(t = (Bone *)malloc(sizeof(Bone))))
			return NULL; // Let's just give up now
        
		t->parent = root;
		root->children[root->childCount] = t; /* Set the pointer */
		root->childCount++; /* Increment the childCounter */
		root = t; /* Change the root */
	}
	else /* Can't add a child */
		return NULL;
    
	/* Set data */
	root->x             = x;
	root->y             = y;
	root->a             = angle;
	root->l             = length;
    root->w             = width;
	root->childCount    = 0;
    root->name          = name;
    root->jointAngleMax = jaMax;
    root->jointAngleMin = jaMin;
    root->jx            = jx;
    root->jy            = jy;
    root->animation     = anim;
    
    /* Tie to box2d */
    b2BodyDef bd;
    b2PolygonShape box;
    b2FixtureDef fixtureDef;
    b2RevoluteJointDef jointDef;
    
    /* Body definition */
    bd.type = b2_dynamicBody;
    box.SetAsBox(length/PTM_RATIO,width/PTM_RATIO);
    fixtureDef.shape = &box;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.4f;
    fixtureDef.restitution = 0.1f;
    bd.position.Set(x/PTM_RATIO, y/PTM_RATIO);
    b2Body *boneShape = world->CreateBody(&bd);
    boneShape->CreateFixture(&fixtureDef);
    root->box2DBody = boneShape;
    
    /* Joint definition */
    if(root->parent)
    {
        jointDef.enableLimit = true;
        jointDef.upperAngle  = root->jointAngleMax;
        jointDef.upperAngle  = root->jointAngleMin;
        jointDef.Initialize(root->box2DBody, root->parent->box2DBody, b2Vec2(jx,jy));
        world->CreateJoint(&jointDef);
    }
    
	for (i = 0; i < MAX_CHCOUNT; i++)
		root->children[i] = NULL;
    
	return root;
}

void Skeleton::boneDumpTree(Bone *root, int level)
{
	if (!root)
		return;
    
	for (int i = 0; i < level; i++)
		printf("#"); /* We print # to signal the level of this bone. */
    
	printf(" %4.4f %4.4f %4.4f %4.4f %s", root->x, root->y, root->a, root->l, root->name.c_str());
    
	/* Now print animation info */
	for (int i = 0; i < root->keyFrameCount; i++)
		printf(" %4.4f %4.4f", root->animation->keyframes[i].time, root->animation->keyframes[i].angle);
	printf("\n");
    
	/* Recursively call this on children */
	for (int i = 0; i < root->childCount; i++)
		boneDumpTree(root->children[i], level + 1);
}

Bone* Skeleton::boneFreeTree(Bone *root)
{    
	if (!root)
		return NULL;
    
	for (int i = 0; i < root->childCount; i++)
		boneFreeTree(root->children[i]);
    
	free(root);
    
	return NULL;
}

Bone* Skeleton::loadBoneStructure(string path)
{
    
    return NULL;
}

bool Skeleton::animating(Bone *root, float time)
{
    
    bool others = false;
    
	float adiff,
    tdiff;
    
	/* Check for keyframes */
	for (int i = 0; i < root->keyFrameCount; i++)
		if (root->animation->keyframes[i].time == time)
		{
			/* Find the index for the interpolation */
			if (i != root->keyFrameCount - 1)
			{
				tdiff = root->animation->keyframes[i + 1].time - root->animation->keyframes[i].time;
				adiff = root->animation->keyframes[i + 1].angle - root->animation->keyframes[i].angle;
                
				root->offA = adiff / tdiff;
			}
			else
			{
				root->offA = 0;
			}
		}
		else if (root->animation->keyframes[i].time > time)
			others = true;
	
	/* Change animation */
	root->a += root->offA;
    
	/* Call on other bones */
	for (int i = 0; i < root->childCount; i++)
		if (animating(root->children[i], time))
			others = true;
    
	return others;
}