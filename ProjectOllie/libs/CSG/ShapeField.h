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
#include <set>

class PointEdge;

struct CircleIntersection
{
    float angle;                //In radians
    PointEdge* intersection;    //PointEdge in the shape field at the intersection
};

typedef std::set<PointEdge*> PeSet;

// Represents a field of true and false values in a quickly clippable vector format
class ShapeField
{
public:
    PeSet peSet;
    std::set<void*> removed;
    PeSet added;
    
    ShapeField(float meterWidth, float meterHeight);
    ~ShapeField();
    
    void clipCircle(bool add, float r, float x, float y);
    void clipConvexQuadBridge(bool add, float* x, float* y);
    void clear();
    void checkConsistency();
    float getRinside(float r);  //Calculates a radius length that will certainly be inside a clipped circle of radius r
    
    //Useful for pickling the data structure
    ShapeField(const void *data, size_t numBytes);
    void *pickleDataStructure(int &dataLength);
private:
    std::set<PointEdge*> **spatialGrid;
    float width;
    float height;
    int gridWidth;
    int gridHeight;
    
    PointEdge* closestPointEdge(float x, float y);
    void removeFromSpatialGrid(PointEdge* pe);
    void addToSpatialGrid(PointEdge* pe);
    PeSet pointsNear(float minX, float minY, float maxX, float maxY);
    void closestPointOnLine(float px, float py, float x1, float y1, float x2, float y2, float* cx, float *cy);
    bool isOutside(float px, float py);
    bool linesClose(PointEdge* a1, PointEdge* a2,  PointEdge* b1, PointEdge*b2);
};

#endif
