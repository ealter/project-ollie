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

class PointEdge;

struct CircleIntersection
{
    float angle;                //In radians
    PointEdge* intersection;    //PointEdge in the shape field at the intersection
};

struct PolyIntersection
{
    float t;                    //Distance parameter along the clip PE that this intersections is
    PointEdge* intersection;    //PointEdge in the shape field at the intersection
};

// Represents a field of true and false values in a quickly clippable vector format
class ShapeField
{
public:
    std::vector<PointEdge*> peSet;
    
    ShapeField(float meterWidth, float meterHeight);
    ~ShapeField();
    
    void clipCircle(bool add, float r, float x, float y);
    void clipConvexQuad(bool add, float* x, float* y);
    void clipConvexPolygon(bool add, PointEdge* head);
    void clear();
    
    //Useful for pickling the data structure
    ShapeField(const void *data, size_t numBytes);
    void *pickleDataStructure(int &dataLength);
private:
    std::vector<PointEdge*> **spatialGrid;
    float width;
    float height;
    int gridWidth;
    int gridHeight;
    
    PointEdge* closestPointEdge(float x, float y);
    void removeFromSpatialGrid(PointEdge* pe);
    void addToSpatialGrid(PointEdge* pe);
    std::vector<PointEdge*> pointsNear(float minX, float minY, float maxX, float maxY);
    void closestPointOnLine(float px, float py, float x1, float y1, float x2, float y2, float* cx, float *cy);
    bool isOutside(float px, float py);
    bool linesClose(PointEdge* a1, PointEdge* a2,  PointEdge* b1, PointEdge*b2);
    PolyIntersection makePolyIntersectionOut(float x, float y, float t, float peT, PointEdge* npe);
    PolyIntersection makePolyIntersectionIn(float x, float y, float t, float peT, PointEdge* pe);
};

#endif
