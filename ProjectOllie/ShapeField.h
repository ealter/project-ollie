//
//  ShapeField.h
//  ProjectOllie
//
//  Created by Steve Gregory on 6/9/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//

#ifndef ProjectOllie_ShapeField_h
#define ProjectOllie_ShapeField_h

#include <vector>
#include "PointEdge.h"

using namespace std;

// Divisions of the spatial grid
#define spatialGridWidth 32
#define spatialGridHeight 32

//Maximum distance for a segment on a circle
#define maxCircleSeg = 4

// Represents a field of true and false values in a quickly clippable vector format
class ShapeField
{
public:
    vector<PointEdge*>  peSet;
    
    ShapeField(float meterWidth, float meterHeight);
    ~ShapeField();
    
    void clipCircle(bool add, float r, float x, float y);
    void clipThickLine(bool add, float x1, float y1, float x2, float y2, float r);
private:
    vector<PointEdge*> **spatialGrid;
    float width;
    float height;
    float cellWidth;
    float cellHeight;
    
    PointEdge* closestPointEdge(float x, float y);
    void removeFromSpatialGrid(PointEdge* pe);
    void addToSpatialGrid(PointEdge* pe);
    vector<PointEdge*> pointsNear(float minX, float minY, float maxX, float maxY);
    void closestPointOnLine(float px, float py, float x1, float y1, float x2, float y2, float* cx, float *cy);
    bool isOutside(float px, float py);
};

#endif
