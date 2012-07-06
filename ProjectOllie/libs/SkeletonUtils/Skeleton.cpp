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
    this->root   = loadStructure(path);
    this->head   = this->root;
    this->uTorso = this->root->children[0];
    this->lTorso = this->uTorso->children[0];
    this->luArm  = this->uTorso->children[1];
    this->ruArm  = this->uTorso->children[2];
    this->llArm  = this->luArm->children[0];
    this->rlArm  = this->ruArm->children[0];
    this->luLeg  = this->lTorso->children[0];
    this->ruLeg  = this->lTorso->children[1];
    this->llLeg  = this->luLeg->children[0];
    this->rlLeg  = this->ruLeg->children[0];
    
    this->world = world;
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

Bone* Skeleton::boneAddChild(Bone *root, string name, float x, float y, float a, float length, float width)
{
    Bone *t;
	int i;
    
	if (!root) /* If there is no root, create a new */
	{
		if (!(root = (Bone *)malloc(sizeof(Bone))))
			return NULL; // BIG PROBLEMS, all is lost
        
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
	root->x = x;
	root->y = y;
	root->a = a;
	root->l = length;
    root->w = width;
	root->childCount = 0;
    root->name = name;
    
    // tie to box2d
    b2BodyDef bd;
    b2PolygonShape box;
    b2FixtureDef fixtureDef;
    
    bd.type = b2_dynamicBody;
    box.SetAsBox(length/32,width/32);
    fixtureDef.shape = &box;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.4f;
    fixtureDef.restitution = 0.1f;
    bd.position.Set(x/32, y/32);
    b2Body *boneShape = this->world->CreateBody(&bd);
    boneShape->CreateFixture(&fixtureDef);
    
    root->box2DBody = boneShape;
    
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
		printf(" %4.4f %4.4f", root->keyframes[i].time, root->keyframes[i].angle);
	printf("\n");
    
	/* Recursively call this on my childs */
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

Bone* Skeleton::loadStructure(string path)
{
    Bone *root,
    *temp;
    
    FILE *file;
    
    float x,
    y,
    angle,
    length,
    width;
    
    int unusedChildrenCount,
    depth,
    actualLevel;
    
    float time;
    
    char name[20],
    depthStr[20],
    animBuf[1024],
    buffer[1024],
    *ptr,
    *token;
    
    KeyFrame *k;
    
    if (!(file = fopen(path.c_str(), "r")))
    {
        fprintf(stderr, "Can't open file %s for reading\n", path.c_str());
        return NULL;
    }
    
    root = NULL;
    temp = NULL;
    actualLevel = 0;
    
    while (!feof(file))
    {
        memset(animBuf, 0, 1024);
        fgets(buffer, 1024, file);
        sscanf(buffer, "%s %f %f %f %f %f %d %s %[^\n]", depthStr, &x, &y, &angle, &length, &width, &unusedChildrenCount, name, animBuf);
        
        /* Avoid empty strings */
        if (strlen(buffer) < 3)
            continue;
        
        /* Calculate the depth */
        depth = strlen(depthStr) - 1;
        if (depth < 0 || depth > MAX_CHCOUNT)
        {
            fprintf(stderr, "Wrong bone depth (%s)\n", depthStr);
            return NULL;
        }
        
        for (; actualLevel > depth; actualLevel--)
            temp = temp->parent;
        
        if (!root && !depth)
        {
            root = boneAddChild(NULL, name, x, y, angle, length, width);
            temp = root;
        }
        else
            temp = boneAddChild(temp, name, x, y, angle, length, width);
        
        /* Now check for animation data */
        if (strlen(animBuf) > 3)
        {
            ptr = animBuf;
            while ((token = strtok(ptr, " ")))
            {
                ptr = NULL;
                sscanf(token, "%d", &time);
                
                token = strtok(ptr, " ");
                sscanf(token, "%f", &angle);
                
                token = strtok(ptr, " ");
                sscanf(token, "%f", &length);
                
                printf("Read %f %f %f\n", time, angle, length);
                
                if (temp->keyFrameCount >= MAX_KFCOUNT)
                {
                    fprintf(stderr, "Can't add more keyframes\n");
                    continue;
                }
                
                k = &(temp->keyframes[temp->keyFrameCount]);
                
                k->time = time;
                k->angle = angle;
                
                temp->keyFrameCount++;
            }
        }
        
        actualLevel++;
    }
    
    return root;
}

bool Skeleton::animating(Bone *root, float time){
    
    bool others = false;
    
	float adiff,
    tdiff;
    
	/* Check for keyframes */
	for (int i = 0; i < root->keyFrameCount; i++)
		if (root->keyframes[i].time == time)
		{
			/* Find the index for the interpolation */
			if (i != root->keyFrameCount - 1)
			{
				tdiff = root->keyframes[i + 1].time - root->keyframes[i].time;
				adiff = root->keyframes[i + 1].angle - root->keyframes[i].angle;
                
				root->offA = adiff / tdiff;
			}
			else
			{
				root->offA = 0;
			}
		}
		else if (root->keyframes[i].time > time)
			others = true;
	
	/* Change animation */
	root->a += root->offA;
    
	/* Call on other bones */
	for (int i = 0; i < root->childCount; i++)
		if (animating(root->children[i], time))
			others = true;
    
	return others;
}



