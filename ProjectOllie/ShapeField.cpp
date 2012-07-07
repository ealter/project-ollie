//
//  ShapeField.cpp
//  ProjectOllie
//
//  Created by Steve Gregory on 6/9/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//

#include <iostream>
#include <stdio.h>
#include "ShapeField.h"
#include "PointEdge.h"
#include <math.h>
#include <float.h>
#include <assert.h>
#include <map>

// Size of each cell in the spatial grid
#define cellWidth 32
#define cellHeight 32

//Maximum distance for a segment on a circle
#define maxCircleSegTheta .1

// Define the smallest float difference that could matter
#define plankFloat 0.001f

//Constant we 
#define radiusMargin .01

//2 pi
#define TAU (M_PI*2)

//Finds if the winding of 3 points is counterclockwise
#define ccw(x1, y1, x2, y2, x3, y3) (((x2) - (x1))*((y3) - (y1)) - ((y2) - (y1))*((x3) - (x1)))

#ifdef DEBUG
//#define PRINT_DEBUGGING_STATEMENTS
#define KEEP_TOUCH_INPUT
//#define USE_EXPENSIVE_ASSERTS
#endif

#ifdef PRINT_DEBUGGING_STATEMENTS
#define printq(s, ...) printf(s, ##__VA_ARGS__)
#else
#define printq(s, ...)
#endif

using namespace std;

#ifdef KEEP_TOUCH_INPUT
struct ShapeField_input {
    bool isCircle;
    bool add;
    union {
        struct {
            float r, x, y;
        } circleInput;
        struct {
            float x[4];
            float y[4];
        } rectInput;
    } input;
};

static vector<ShapeField_input> shapefieldInput;

void printTouchInput()
{
    ShapeField_input input = shapefieldInput.back();
    const char *add = input.add ? "add" : "remove";
    if(input.isCircle) {
      printq("circle %s %f %f %f\n", add, input.input.circleInput.r, input.input.circleInput.x, input.input.circleInput.y);
    } else {
      float *xs = input.input.rectInput.x;
      float *ys = input.input.rectInput.y;
      printq("rect %s %f %f %f %f %f %f %f %f\n", add, xs[0], xs[1], xs[2], xs[3], ys[0], ys[1], ys[2], ys[3]);
    }
}
#endif /* KEEP_TOUCH_INPUT */

ShapeField::ShapeField(float width, float height)
:width(width), height(height), gridWidth(width/cellWidth + 1), gridHeight(height/cellHeight + 1)
{
    //Setup empty spatial grid
    spatialGrid = new PeSet*[gridWidth];
    for (int x = 0; x < gridWidth; x++)
        spatialGrid[x] = new PeSet[gridHeight];

}

ShapeField::~ShapeField()
{
    //Delete every point
    for (PeSet::iterator i = peSet.begin(); i != peSet.end(); i++)
        delete *i;

    //Delete the grid
    for (int x = 0; x < gridWidth; x++)
        delete[] spatialGrid[x];
    delete[] spatialGrid;
}

ShapeField::ShapeField(const void *data, size_t numBytes) {
    //TODO: implement this
    ShapeField(1024, 768);
}

void *ShapeField::pickleDataStructure(int &dataLength) {
    //TODO: implement this
    dataLength = 0;
    return NULL;
}


float ShapeField::getRinside(float r)
{
    return (r - radiusMargin)*cosf(maxCircleSegTheta/2) - radiusMargin;
}

void ShapeField::clipCircle(bool add, float r, float x, float y)
{
#ifdef KEEP_TOUCH_INPUT
    ShapeField_input input;
    input.isCircle = true;
    input.add      = add;
    input.input.circleInput.r = r;
    input.input.circleInput.x = x;
    input.input.circleInput.y = y;
    shapefieldInput.push_back(input);
    printTouchInput();
#endif

    //Use this as the r when creating new points so going over circles won't ever expand the curve into the float trig error spots
    float rMarginal = r - radiusMargin;

    //Get all potential PointEdges that we could be affecting in a bounding box
    PeSet nearPEs = pointsNear(x-r, y-r, x+r, y+r);

    //Classify each of the points of every near PointEdge as inside or outside
    float rsq = r*r;
    for (PeSet::iterator i = nearPEs.begin(); i != nearPEs.end(); i++)
    {
        PointEdge* pe = *i;
        assert(pe->tmpMark == outside);
        //Find square of the distance to the point
        float dx = pe->x - x;
        float dy = pe->y - y;
        float dsq = dx*dx + dy*dy;
        if (dsq <= rsq)
            pe->tmpMark = inside;
    }

    //Find intersections, create points, link them, create enterence or exit
    vector<CircleIntersection> entrences;
    vector<CircleIntersection> exits;
    for (PeSet::iterator i = nearPEs.begin(); i != nearPEs.end(); i++)
    {
        PointEdge* pe = *i;
        PointEdge* npe = pe->next;
        if (pe->tmpMark == outside)
        {
            if (npe->tmpMark == outside)
            {
                //Both outside, we only care about this pe if it intersects in the middle
                //Get unit vector in the direction of the pe
                float pedx = npe->x - pe->x;
                float pedy = npe->y - pe->y;
                float peLen = sqrtf(pedx*pedx + pedy*pedy);
                float unitX = pedx/peLen;
                float unitY = pedy/peLen;
                //Project the vector from pe to the circle center onto the unit vector
                float dxPtoC = x - pe->x;
                float dyPtoC = y - pe->y;
                float diffDotUnitPe = unitX*dxPtoC + unitY*dyPtoC;
                //This point must be on the PE edge, so the dot product must be >0 and <peLen
                if (diffDotUnitPe > 0 && diffDotUnitPe < peLen)
                {
                    //Closest point is neither endpoint... intersection still possible
                    float xClosest = pe->x + unitX * diffDotUnitPe;
                    float yClosest = pe->y + unitY * diffDotUnitPe;
                    //Check if the closest point on the line to the citcle center is inside the radius
                    float dx = x - xClosest;
                    float dy = y - yClosest;
                    float lenToCenterSq = dx*dx + dy*dy;
                    if (lenToCenterSq < rsq)
                    {
                        printq("O-O intersection\n");
                        //Line crosses inside the circle, cut it and make intersections
                        removeFromSpatialGrid(pe);

                        //Calculate intersection points
                        float distanceToEdge = sqrtf(rsq - lenToCenterSq);
                        float inX = -unitX * distanceToEdge + xClosest;
                        float inY = -unitY * distanceToEdge + yClosest;
                        float outX = unitX * distanceToEdge + xClosest;
                        float outY = unitY * distanceToEdge + yClosest;

                        //Create points
                        PointEdge* inP = new PointEdge(inX, inY, NULL, pe);
                        PointEdge* outP = new PointEdge(outX, outY, npe, NULL);

                        //Add new points to the PointEdge set
                        peSet.insert(inP);
                        peSet.insert(outP);

                        //Reroute pe to inP and npe after outP
                        pe->next = inP;
                        npe->prev = outP;

                        //Add new pe and outP to spatial grid
                        addToSpatialGrid(pe);
                        addToSpatialGrid(outP);

                        //In intersection
                        CircleIntersection in;
                        in.intersection = inP;
                        in.angle = atan2f(inY - y, inX - x);
                        if(isnan(in.angle))
                        {
                            printq("circle center: %f, %f,  intersection: %f, %f", x, y, inX, inY);
                        }
                        entrences.push_back(in);

                        //Out intersection
                        CircleIntersection out;
                        out.intersection = outP;
                        out.angle = atan2f(outY - y, outX - x);
                        if(isnan(out.angle))
                        {
                            printq("circle center: %f, %f,  intersection: %f, %f", x, y, outX, outY);
                        }
                        exits.push_back(out);
                    }
                }
            }
            else if (npe->tmpMark == inside)
            {
                printq("O-I intersection in\n");
                //P outside, np inside: enterence intersection in the middle somewhere
                removeFromSpatialGrid(pe);
                //Get unit vector in the direction of the pe
                float pedx = npe->x - pe->x;
                float pedy = npe->y - pe->y;
                float peLen = sqrtf(pedx*pedx + pedy*pedy);
                float unitX = pedx/peLen;
                float unitY = pedy/peLen;
                //Project the vector from pe to the circle center onto the unit vector
                float dxPtoC = x - pe->x;
                float dyPtoC = y - pe->y;
                float diffDotUnitPe = unitX*dxPtoC + unitY*dyPtoC;
                float xClosest = pe->x + unitX * diffDotUnitPe;
                float yClosest = pe->y + unitY * diffDotUnitPe;
                //Check if the closest point on the line to the citcle center is inside the radius
                float dx = x - xClosest;
                float dy = y - yClosest;
                //Calculate enterence x, y
                float dtesq = rsq - dx*dx - dy*dy;
                float distanceToEdge;
                assert (dtesq >= 0);
                distanceToEdge = sqrtf(dtesq);
                float inX = -unitX * distanceToEdge + xClosest;
                float inY = -unitY * distanceToEdge + yClosest;
                //Make point
                PointEdge* inP = new PointEdge(inX, inY, NULL, pe);
                //Rerout pe to new point
                pe->next = inP;
                //Add this back
                addToSpatialGrid(pe);
                //Add to point set
                peSet.insert(inP);
                //Create intersection
                CircleIntersection in;
                in.intersection = inP;
                in.angle= atan2f(inY - y, inX - x);
                if(isnan(in.angle))
                {
                    printq("circle center: %f, %f,  intersection: %f, %f", x, y, inX, inY);
                    printq("pe: %f, %f\nnpe: %f, %f\nped: %f, %f\npeLen: %f", pe->x, pe->y, npe->x, npe->y, pedx, pedy, peLen);
                    printq("ped unit: %f, %f", unitX, unitY);
                    printq("p to c: %f, %f", dxPtoC, dyPtoC);
                    printq("dot: %f\nClosest: %f, %f", diffDotUnitPe, xClosest, yClosest);
                    printq("dx dy: %f, %f", dx, dy);
                    printq("distance to edge: %f\nin: %f, %f", distanceToEdge, inX, inY);
                    assert(false);
                }
                entrences.push_back(in);
            }
            //Next mark on edge is handled when the next PointEdge is evaluated
        }
        else if (pe->tmpMark == inside)
        {
            if (npe->tmpMark == outside)
            {
                //P inside, np outside: exit intersection in the middle somewhere
                removeFromSpatialGrid(pe);
                //Get unit vector in the direction of the pe
                float pedx = npe->x - pe->x;
                float pedy = npe->y - pe->y;
                float peLen = sqrtf(pedx*pedx + pedy*pedy);
                float unitX = pedx/peLen;
                float unitY = pedy/peLen;
                //Project the vector from pe to the circle center onto the unit vector
                float dxPtoC = x - pe->x;
                float dyPtoC = y - pe->y;
                float diffDotUnitPe = unitX*dxPtoC + unitY*dyPtoC;
                float xClosest = pe->x + unitX * diffDotUnitPe;
                float yClosest = pe->y + unitY * diffDotUnitPe;
                float dx = x - xClosest;
                float dy = y - yClosest;
                //Calculate exit x, y
                float dtesq = rsq - dx*dx - dy*dy;
                float distanceToEdge;
                assert(dtesq >= 0);
                distanceToEdge = sqrtf(dtesq);
                float outX = unitX * distanceToEdge + xClosest;
                float outY = unitY * distanceToEdge + yClosest;
                printq("I-O intersection out: %f, %f, \n", outX, outY);
                //Make point
                PointEdge* outP = new PointEdge(outX, outY, npe, NULL);
                //Rerout pe to new point
                npe->prev = outP;
                //Add this to the grid and PointEdge set
                addToSpatialGrid(outP);
                peSet.insert(outP);
                //Create intersection
                CircleIntersection out;
                out.intersection = outP;
                out.angle= atan2f(outY - y, outX - x);
                if(isnan(out.angle))
                {
                    printq("circle center: %f, %f,  intersection: %f, %f", x, y, outX, outY);
                    printq("pe: %f, %f\nnpe: %f, %f\nped: %f, %f\npeLen: %f", pe->x, pe->y, npe->x, npe->y, pedx, pedy, peLen);
                    printq("ped unit: %f, %f", unitX, unitY);
                    printq("p to c: %f, %f", dxPtoC, dyPtoC);
                    printq("dot: %f\nClosest: %f, %f", diffDotUnitPe, xClosest, yClosest);
                    printq("dx dy: %f, %f", dx, dy);
                    printq("distance to edge: %f\nin: %f, %f", distanceToEdge, outX, outY);
                    assert(false);
                }
                exits.push_back(out);
            }
            //Otherwise this point will be deleted at the end (but we still need it for a little bit)
        }
        else assert(false);
    }

    //If this isn't true, something fucked up. Abort mission, refund investors, etc.
    printq("in: %lu, out: %lu\n", entrences.size(), exits.size());
    assert(entrences.size() == exits.size());

    //Figure out the maximum theta for the given radius and maxCircleSeg
    float maxTheta = maxCircleSegTheta;

    //If nothing intersects, we have no geometry to adjust, perhaps we will make some new independant shapes
    if (entrences.empty())
    {
        //Figure out if the circle edge is outside
        bool edgeOutside = isOutside(x, y);
        //assert(outside);
        if (edgeOutside && add)
        {
            printq("adding new loop\n");
            //The circle edge is outside and we are adding, so we must create a new loop
            int numSegs = (int)(TAU/maxTheta) + 1;
            float dtheta = TAU/numSegs;

            //Build a counter clockwise circle (increasing theta)
            float angle = 0;
            PointEdge* first = new PointEdge(x + rMarginal, y, NULL, NULL);
            peSet.insert(first);
            PointEdge* prev = first;
            for (int i = 1; i < numSegs; i++)
            {
                angle += dtheta;
                float px = x + rMarginal*cosf(angle);
                float py = y + rMarginal*sinf(angle);
                PointEdge* pe = new PointEdge(px, py, NULL, prev);
                peSet.insert(pe);
                prev->next = pe;
                addToSpatialGrid(prev);
                prev = pe;
            }
            prev->next = first;
            first->prev = prev;
            addToSpatialGrid(prev);
        }
        else if (!edgeOutside && !add)
        {
            printq("Adding new hole loop");
            //Inside and subtracting, add a new hole
            int numSegs = (int)(TAU/maxTheta) + 1;
            float dtheta = -TAU/numSegs;

            //Build a counter clockwise circle (increasing theta)
            float angle = 0;
            PointEdge* first = new PointEdge(x + rMarginal, y, NULL, NULL);
            peSet.insert(first);
            PointEdge* prev = first;
            for (int i = 1; i < numSegs; i++)
            {
                angle += dtheta;
                float px = x + rMarginal*cosf(angle);
                float py = y + rMarginal*sinf(angle);
                PointEdge* pe = new PointEdge(px, py, NULL, prev);
                peSet.insert(pe);
                prev->next = pe;
                addToSpatialGrid(prev);
                prev = pe;
            }
            prev->next = first;
            first->prev = prev;
            addToSpatialGrid(prev);
        }
    }
    else    //Entrences and exits not empty, adjust intersecting geometry accordingly
    {
        //For each enterence, extend to the next exit
        for (unsigned i = 0; i < entrences.size(); i++)
        {
            CircleIntersection in = entrences[i];

            //Find the subsequent exit in the +ccw direction
            CircleIntersection out;
            int outI;
            float dTheta;
            if (add)
            {
                dTheta = 1000.0f;   //Bigger than 2pi
                for (unsigned j = 0; j < exits.size(); j++)
                {
                    CircleIntersection tmpOut = exits[j];

                    //Get the +ccw change in the angle from the enterence to this exit
                    float tmpDtheta = tmpOut.angle - in.angle;
                    if (tmpDtheta < 0) tmpDtheta += TAU;

                    //If it's smaller than the last one, it's closer
                    if (tmpDtheta < dTheta)
                    {
                        outI = j;
                        dTheta = tmpDtheta;
                        out = tmpOut;
                    }
                }
            }
            else
            {
                dTheta = -1000.0f;  //Less then -2pi
                for (unsigned j = 0; j < exits.size(); j++)
                {
                    CircleIntersection tmpOut = exits[j];
                    printq("r %f\n", r);
                    //Get the +ccw change in the angle from the enterence to this exit
                    float tmpDtheta = tmpOut.angle - in.angle;
                    if (tmpDtheta > 0) tmpDtheta -= TAU;

                    //If it's smaller than the last one, it's closer
                    if (tmpDtheta > dTheta)
                    {
                        outI = j;
                        dTheta = tmpDtheta;
                        out = tmpOut;
                    }
                }
            }
                        
            //If the enterence and exit are at a really close theta, then we just want to merge these points
            if (fabs(dTheta) < FLT_EPSILON)
            {
                printf("Merging close enterence and exit\n");
                //Bypass the "in" PointEdge
                peSet.erase(in.intersection);
                removeFromSpatialGrid(in.intersection->prev);
                in.intersection->prev->next = out.intersection;
                out.intersection->prev = in.intersection->prev;
                addToSpatialGrid(in.intersection->prev);
            }
            else
            {
                //Find the minimum number of segments we need to satisfy the maximum seg length requirement
                int numSegs = (fabs(dTheta)/maxTheta) + 1;   //Ceil of dtheta/maxTheta
                //Find the angle that each of these segments needs
                float segTheta = dTheta/numSegs;
                printq("building %d new edges with dtheta %f\n", numSegs, segTheta);
                if(dTheta > 10)
                {
                    printq("dtheta: %f\n", dTheta);
                    printq("maxTheta: %f\n", maxTheta);
                    printq("in angle: %f\n", in.angle);
                    printq("out angle: %f\n", out.angle);
                    assert(false);
                }
                //Extend entrence to exit along the circle edge in +theta
                PointEdge* prev = in.intersection;
                float angle = in.angle + segTheta;
                for (int j = 1; j < numSegs; j++)
                {
                    //Make a new point at this theta
                    float px = x + rMarginal*cosf(angle);
                    float py = y + rMarginal*sinf(angle);
                    PointEdge* pe = new PointEdge(px, py, NULL, prev);
                    peSet.insert(pe);

                    //Make the prev point edge connect to this one
                    prev->next = pe;

                    //Now that the last PE has its edge defined, add it to our collections
                    addToSpatialGrid(prev);

                    //Set these for the next iteration
                    prev = pe;
                    angle += segTheta;
                }
                //Connect the last segment to the exit
                prev->next = out.intersection;
                out.intersection->prev = prev;
                //Add the last point to the spatial grid
                addToSpatialGrid(prev);
            }
            //Remove that exit because it is no longer needed
            exits[outI] = exits.back();
            exits.pop_back();
        }
    }

    //Remove all of the circumvented PointEdges from the spatial grid
    for (PeSet::iterator i = nearPEs.begin(); i != nearPEs.end(); i++)
    {
        PointEdge* pe = *i;
        if (pe->tmpMark == inside)
        {
            removeFromSpatialGrid(pe);
            peSet.erase(pe);
        }
    }
    for (PeSet::iterator i = nearPEs.begin(); i != nearPEs.end(); i++)
        if ((*i)->tmpMark == inside) delete *i;
    
    
    //Make sure that the middle is inside if we're adding or outside if we're subtracting
    assert(isOutside(x, y) != add);
    
#ifdef USE_EXPENSIVE_ASSERTS
    //Check that everything makes sense in the ways we can validate
    checkConsistency();
#endif

}

//Returns true if line seg A from (x1, y1) to (x2, y2) intersects line seg B from (x3, y3) to (x4, y4) and
//puts intersection in (Xint, Yint) and the parametric t (from 0 to 1) along line A
bool intersects(float x1,float y1,float x2,float y2,float x3,float y3,float x4,float y4, float* Xint, float* Yint, float* tA, float* tB)
{
    float mua,mub;

    float adx = x2-x1;
    float ady = y2-y1;
    float bdx = x4-x3;
    float bdy = y4-y3;
    float badx = x1-x3;
    float bady = y1-y3;

    float denom  = bdy * adx - bdx * ady;
    float numera = bdx * bady - bdy * badx;
    float numerb = adx * bady - ady * badx;

    /* Are the lines coincident? */
    if (fabs(numera) < FLT_EPSILON && fabs(numerb) < FLT_EPSILON && fabs(denom) < FLT_EPSILON) {
        //If each point on seg B is on an opposite side of the normal of seg A (from pt 1) then use pt 1
        float p1dp3 = -(badx*adx + bady*ady);
        float p4p1dx = x4 - x1;
        float p4p1dy = y4 - y1;
        float p1dp4 = p4p1dx*adx + p4p1dy*ady;
        if ((p1dp3 > 0) != (p1dp4 > 0))
        {
            *Xint = x1;
            *Yint = y1;
            *tA = 0;
            float db = sqrtf(bdx*bdx + bdy*bdy);
            float d31 = sqrtf(badx*badx + bady*bady);
            *tB = d31/db;
            printq("intersection T: colinear on ray\n");
            return true;
        }
        printq("intersection F: colinear before ray\n");
        //Otherwise it's an intersection that should be accounted for later
        return false;
    }

    /* Are the line parallel */
    if (fabs(denom) < FLT_EPSILON) {
        //*Xint = 0;
        //*Yint = 0;
        printq("intersection F: parallel segments\n");
        return false;
    }

    /* Is the intersection along the the segments */
    mua = numera / denom;
    mub = numerb / denom;
    if (mua < 0 || mua > 1 || mub < 0 || mub > 1) {
        //*Xint = 0;
        //*Yint = 0;
        printq("intersection F: off ends mua %.20f, mub %.20f\n", mua, mub);
        return false;
    }
    *Xint = x1 + mua * (x2 - x1);
    *Yint = y1 + mua * (y2 - y1);
    *tA = mua;
    *tB = mub;
    printq("intersection T: in rangemua %.20f, mub %.20f\n", mua, mub);
    return true;
}

//Returns true when the point (x, y) is right of the segment from (x1, y1) to (x2, y2), false if it is left or on the segment
bool rightOf(float x1, float y1, float x2, float y2, float x, float y)
{
    //CCW winding of (x1, y1) to (x, y) to (x2, y2) implies that the point is right
    return ccw(x1, y1, x, y, x2, y2) >= 0;
}

//Requires 4 x and 4 y for points in a counterclockwise rotation
//All four points must be inside if adding, outside if subtracting, by a margin significantly greater than possible intersection error
//Edges 0-1 (A) and 2-3 (C) can have intersections, as they "bridge"
//Edges 1-2 (B) and 3-0 (D) cannot have intersections, as they are completely inside or outside
void ShapeField::clipConvexQuadBridge(bool add, float* x, float* y)
{
#ifdef KEEP_TOUCH_INPUT
    ShapeField_input input;
    input.isCircle = false;
    input.add = add;
    for(int i=0; i<4; i++) {
        input.input.rectInput.x[i] = x[i];
        input.input.rectInput.y[i] = y[i];
    }
    shapefieldInput.push_back(input);
    printTouchInput();
#endif

    //Make sure the points are counterclockwise
    assert(ccw(x[0], y[0], x[1], y[1], x[2], y[2]) > FLT_EPSILON);
    assert(ccw(x[1], y[1], x[2], y[2], x[3], y[3]) > FLT_EPSILON);
    assert(ccw(x[2], y[2], x[3], y[3], x[0], y[0]) > FLT_EPSILON);
    //Check that all four points are inside if adding and outside if subtracting
    assert(isOutside(x[0], y[0]) != add);
    assert(isOutside(x[1], y[1]) != add);
    assert(isOutside(x[2], y[2]) != add);
    assert(isOutside(x[3], y[3]) != add);

    //Find a bounding box to get near points
    float minX = min(min(x[0], x[1]), min(x[2], x[3]));
    float minY = min(min(y[0], y[1]), min(y[2], y[3]));
    float maxX = max(max(x[0], x[1]), max(x[2], x[3]));
    float maxY = max(max(y[0], y[1]), max(y[2], y[3]));

    //Get all of the near points
    PeSet nearPEs = pointsNear(minX, minY, maxX, maxY);
    printq("RECT near points count: %lu\n", nearPEs.size());
    //Mark inside or outside
    for (PeSet::iterator i = nearPEs.begin(); i != nearPEs.end(); i++)
    {
        PointEdge* pe = *i;
        assert(pe->tmpMark == outside);

        //Check Right of A
        if (rightOf(x[0], y[0], x[1], y[1], pe->x, pe->y))
            pe->tmpMark = rightA;
        //Check right of C
        else if (rightOf(x[2], y[2], x[3], y[3], pe->x, pe->y))
            pe->tmpMark = rightC;

        //Check right of B
        if (rightOf(x[1], y[1], x[2], y[2], pe->x, pe->y))
            pe->tmpMark |= rightB;
        //Check right of d
        else if (rightOf(x[3], y[3], x[0], y[0], pe->x, pe->y))
            pe->tmpMark |= rightD;

        //Check inside (unmarked so far, left of all segments)
        else if (pe->tmpMark == outside) pe->tmpMark = inside;
    }

    //Store intersections in a fast data structure sorted by the parametric t where the intersection is on the segment
    map<float, PointEdge*> SegIns;
    map<float, PointEdge*> SegOuts;
    
    //Track the marked PE's that are outside of near PE's so we can reset them to outside at the end
    PeSet markedNotNear;
    
    //Do A first
    int rightMark = rightA;
	
    //For both seg A and B, find intersecting PE's and create connecting paths and remember what to connect at the end 
    vector<PointEdge*> perA = vector<PointEdge*>();     //Hold PE to rerout from
    vector<PointEdge*> perB = vector<PointEdge*>();     //Hold NPE to rerout to
    for (int s = 0; s < 2; s++)
    {
        //Get the current segment points for seg A or B
        int segi = 2*s;
        float x1 = x[segi];
        float y1 = y[segi];
        float x2 = x[segi +1];
        float y2 = y[segi +1];
        
        //Find all intersections
        for (PeSet::iterator i = nearPEs.begin(); i != nearPEs.end(); i++)
        {
            PointEdge* pe = *i;
            PointEdge* npe = pe->next;
            
            //Make sure the next point is marked as a specific outside (in case it was off the nearPEs)
            if (npe->tmpMark == outside)
            {
                //Check Right of A
                if (rightOf(x[0], y[0], x[1], y[1], npe->x, npe->y))
                    npe->tmpMark = rightA;
                //Check right of C
                else if (rightOf(x[2], y[2], x[3], y[3], npe->x, npe->y))
                    npe->tmpMark = rightC;
                
                //Check right of B
                if (rightOf(x[1], y[1], x[2], y[2], npe->x, npe->y))
                    npe->tmpMark |= rightB;
                //Check right of D
                else if (rightOf(x[3], y[3], x[0], y[0], npe->x, npe->y))
                    npe->tmpMark |= rightD;
                
                //Make sure it wasn't left of everything (which would mean it was inside but not near)
                assert (npe->tmpMark != outside);
                
                markedNotNear.insert(npe);
            }
            
            //Bitwise flag comparing super-shortcut implying no intersection possible because both points are
            //either on the right of the same clipping segment or both on the left of every clipping segment
            if (pe->tmpMark & npe->tmpMark) continue;
            
            float Xint, Yint, tA, peT;
            
            //Check for IN intersection
            if (pe->tmpMark & rightMark)            //PE is right 
            {
                if (!(npe->tmpMark & rightMark))    //NPE is not right
                    //PE right and NPE left, possible IN intersection
                    if (intersects(x1, y1, x2, y2, pe->x, pe->y, npe->x, npe->y, &Xint, &Yint, &tA, &peT))
                    {
                        //Create IN intersection at Xint, Yint
                        PointEdge* intersection = new PointEdge(Xint, Yint, NULL, pe);
                        SegIns.insert(pair<float, PointEdge*>(tA, intersection));
                        peSet.insert(intersection);
                        
                        //Remember to eventually reroute the PE to this intersection
                        perA.push_back(pe);
                        perB.push_back(intersection);
                    }
            }
            
            //PE left check for OUT intersection
            else if (npe->tmpMark & rightMark)
            {
                //PE left and NPE right, possible OUT intersection
                if (intersects(x1, y1, x2, y2, pe->x, pe->y, npe->x, npe->y, &Xint, &Yint, &tA, &peT))
                {
                    //OUT intersection at Xint, Yint and at parametric tA along the clipping segment
                    PointEdge* intersection = new PointEdge(Xint, Yint, npe, NULL);
                    SegOuts.insert(pair<float, PointEdge*>(tA, intersection));
                    peSet.insert(intersection);
                    
                    //Remember to eventually reroute the exit to the NPE
                    perA.push_back(intersection);
                    perB.push_back(npe);
                }
            }
        }
        
        //Get the iterators
        map<float, PointEdge*>::iterator insIterator = SegIns.begin();
        map<float, PointEdge*>::iterator outsIterator = SegOuts.begin();
        
        //Since endpoints must be either both inside or both outside, we must have an equal number of ins and outs
        printq("RECT SEG ins %d outs %d\n", SegIns.size(), SegOuts.size());
        if (SegIns.size() != SegOuts.size())
        {
            //This should not happen, but can in rare float error cases
#ifdef USE_EXPENSIVE_ASSERTS
            printq("Unequal ins and outs, mathematically unsolvable, skipping");
#endif
            //In production, clear the ins and outs from the grid and skip to the cleanup
            for (;insIterator != SegIns.end(); insIterator++)
                peSet.erase(insIterator->second);
            for (;outsIterator != SegOuts.end(); outsIterator++)
                peSet.erase(outsIterator->second);
            
            //Yea don't connect anything
            perA.clear();
            perB.clear();
            
            //Skip the next segment if we didn't do it yet
            s = 3;
        }
        
        //Construct new edges by connecting every IN to the corrosponding next OUT on this segment
        for (; insIterator != SegIns.end(); insIterator++, outsIterator++)
        {
            //Check that nothing like crossed over in a bad way
            assert((insIterator->first <= outsIterator->first) == add);
            //Just set the thing to the whatever and you know
            PointEdge* in = insIterator->second;
            PointEdge* out = outsIterator->second;
            in->next = out;
            out->prev = in;
            addToSpatialGrid(in);
        }
        
        //Clean up from this segment 
        SegIns.clear();
        SegOuts.clear();
        
        //Use C for the second iteration
        rightMark = rightC;
        
    }   /* Find all interections */
    
    /* Reroute existing geometry to constructed geometry */
    for (int i = 0; i < perA.size(); i++)
    {
        //Connect A to B
        PointEdge* A = perA[i];
        PointEdge* B = perB[i];
        removeFromSpatialGrid(A);   //Remove if it was in the grid since we're rerouting
        A->next = B;
        B->prev = A;
        addToSpatialGrid(A);
    }
    
    /* Clear old geomtry */
    for (PeSet::iterator i = nearPEs.begin(); i != nearPEs.end(); i++)
    {
        PointEdge* pe = *i;
        if (pe->tmpMark == inside)
        {
            removeFromSpatialGrid(pe);
            peSet.erase(pe);
        }
        else pe->tmpMark = outside;
    }
    for (PeSet::iterator i = nearPEs.begin(); i != nearPEs.end(); i++)
        if ((*i)->tmpMark == inside) delete *i;
    //Reset marked PE's that were not near 
    for (PeSet::iterator i = markedNotNear.begin(); i != markedNotNear.end(); i++)
        (*i)->tmpMark = outside;
    
#ifdef USE_EXPENSIVE_ASSERTS
    checkConsistency();
#endif
}

bool ShapeField::linesClose(PointEdge* a1, PointEdge* a2,  PointEdge* b1, PointEdge*b2)
{
    //Find a bounds
    int aMinX = a1->x, aMaxX = a2->x;
    if (a1->x > a2->x)
    {
        aMinX = a2->x;
        aMaxX = a1->x;
    }
    int aMinY = a1->y, aMaxY = a2->y;
    if (a1->y > a2->y)
    {
        aMinY = a2->y;
        aMaxY = a1->y;
    }

    //Find b bounds
    int bMinX = b1->x, bMaxX = b2->x;
    if (b1->x > b2->x)
    {
        bMinX = b2->x;
        bMaxX = b1->x;
    }
    int bMinY = b1->y, bMaxY = b2->y;
    if (b1->y > b2->y)
    {
        bMinY = b2->y;
        bMaxY = b1->y;
    }

    return aMaxX >= bMinX && bMaxX >= aMinX
        && aMaxY >= bMinY && bMaxY >= aMinY;
}

void ShapeField::clear()
{
    //Free everything in the point set
    for (PeSet::iterator i = peSet.begin(); i != peSet.end(); i++)
        delete *i;

    //Clear the point set
    peSet.clear();

    //Clear the spatial grid vectors
    for (int i = 0; i < gridWidth; i++)
        for(int j = 0; j < gridHeight; j++)
            spatialGrid[i][j].clear();

}


//Returns true if the point (px, py) is outside or on an edge whose outside normal is (0, -1)
//Precondition: no point edges are coincident with the given point
bool ShapeField::isOutside(float px, float py)
{
    //Hold the current cell that we are in
    int cellX = (int)(px/cellWidth);
    int cellY = (int)(py/cellHeight);

    float yDistance = -1.0f;    //Negative implies that no intersections have been found yet
    bool isOutside;
    for (; cellY < gridHeight; cellY++)
    {
        PeSet* cell = &(spatialGrid[cellX][cellY]);
        for (PeSet::iterator i = cell->begin(); i != cell->end(); i++)
        {
            PointEdge* pe = *i;
            PointEdge* npe = pe->next;
            if (pe->tmpMark != inside)
            {

                bool peLeft = pe->x < px;
                bool npeLeft = npe->x < px;
                if (peLeft && !npeLeft)
                {
                    //P is left of normal, Np right
                    //Find actual intersection
                    float m = (npe->y - pe->y)/(npe->x - pe->x);
                    float tmpYdistance = pe->y + (px - pe->x) * m - py;
                    if (tmpYdistance > height-py || tmpYdistance < -py)
                    {
                        printq("Strange tmp y distance... %f\n", tmpYdistance);
                        assert(false);
                    }
                    if ((yDistance < 0 || tmpYdistance < yDistance) && tmpYdistance > 0)
                    {
                        //Closest intersection thus far, implies outside
                        isOutside = true;
                        yDistance = tmpYdistance;
                    }
                }
                else if (!peLeft && npeLeft)
                {
                    //P is right of normal, Np left
                    //Find actual intersection
                    float m = (npe->y - pe->y)/(npe->x - pe->x);
                    float tmpYdistance = pe->y + (px - pe->x) * m - py;
                    if (tmpYdistance > height-py || tmpYdistance < -py)
                    {
                        printq("Strange tmp y distance... %f\n", tmpYdistance);
                        assert(false);
                    }
                    if ((yDistance < 0 || tmpYdistance < yDistance) && tmpYdistance > 0)
                    {
                        //Closest intersection thus far, implies inside
                        isOutside = false;
                        yDistance = tmpYdistance;
                    }
                }
            }
            else 
                printq("isOutside: skipped evaluating inside pe\n");
        }
        if (yDistance > 0 && py + yDistance < (cellY+1)*cellHeight)
        {
            printq("isOutside found telling edge %d, at ydistance %f\n", isOutside, yDistance);
            return isOutside;
        }
    }
    printq("isOutside: uninterupted path in +y off grid\n");
    return true;
}

//Returns all of the points inside and near a bounding box
PeSet ShapeField::pointsNear(float minX, float minY, float maxX, float maxY)
{

    //Find the corrosponding grid spaces that we are affecting
    unsigned int minCellX = ((unsigned)minX)/cellWidth;
    unsigned int minCellY = ((unsigned)minY)/cellHeight;
    unsigned int maxCellX = ((unsigned)maxX+1)/cellWidth;
    unsigned int maxCellY = ((unsigned)maxY+1)/cellHeight;

    PeSet nearPEs;
//    nearPEs.insert(peSet.begin(), peSet.end());

    for (unsigned i = minCellX; i <= maxCellX; i++)
        for (unsigned j = minCellY; j <= maxCellY; j++)
            nearPEs.insert(spatialGrid[i][j].begin(), spatialGrid[i][j].end());

    return nearPEs;
}

void getGridCells(PointEdge* pe, unsigned &minCellX, unsigned &minCellY, unsigned &maxCellX, unsigned &maxCellY)
{
    
    unsigned int minX = (unsigned)(min(pe->x, pe->next->x) - .6);
    unsigned int minY = (unsigned)(min(pe->y, pe->next->y) - .6);
    unsigned int maxX = (unsigned)(max(pe->x, pe->next->x) + 1.1);
    unsigned int maxY = (unsigned)(max(pe->y, pe->next->y) + 1.1);
    
    minCellX = minX/cellWidth;
    minCellY = minY/cellHeight;
    maxCellX = maxX/cellWidth;
    maxCellY = maxY/cellHeight;
}

void ShapeField::removeFromSpatialGrid(PointEdge* pe)
{
    assert(pe->next);

    //Create a slightly generous bounding box
    unsigned int minCellX, minCellY, maxCellX, maxCellY;
    getGridCells(pe,  minCellX, minCellY, maxCellX, maxCellY);
    
    //Remove from all of these cells
    for (unsigned i = minCellX; i <= maxCellX; i++)
        for (unsigned j = minCellY; j <= maxCellY; j++)
            spatialGrid[i][j].erase(pe);

}

void ShapeField::addToSpatialGrid(PointEdge* pe)
{
    assert(pe->next);
    
    //Create a slightly generous bounding box
    unsigned int minCellX, minCellY, maxCellX, maxCellY;
    getGridCells(pe,  minCellX, minCellY, maxCellX, maxCellY);
    
    //Add to all of these cells
    for (unsigned i = minCellX; i <= maxCellX; i++)
        for (unsigned j = minCellY; j <= maxCellY; j++)
            spatialGrid[i][j].insert(pe);
}

void ShapeField::checkConsistency()
{
    //Check the consistancy of the linked list structures
    for(PeSet::iterator i = peSet.begin(); i != peSet.end(); i++)
    {
        PointEdge* pe = *i;
        //Check that it exists and isn't null somehow
        assert(pe);
        //See if the location is in a strange place
        if (pe->x <= 1 || pe->x > width || pe->y <= 1 || pe->y > height) {
            printq("Strange point edge coordinates %f, %f", pe->x, pe->y);
            assert(false);
        }
        //Check that it has a next and previous
        assert(pe->next);
        assert(pe->prev);
        assert(peSet.find(pe->next) != peSet.end());
        assert(peSet.find(pe->prev) != peSet.end());
        //Check that linked nodes link back correctly
        if(pe->next->prev != pe) {
            assert(pe->next->prev);
            assert(0);
        }
        if(pe->prev->next != pe) {
            assert(pe->prev->next);
            assert(0);
        }
        assert(pe->next != pe); //No self looping points
        assert(pe->prev != pe);
        assert(pe->next->next != pe);   //No self looping lines
        assert(pe->prev->prev != pe);
        
        //Check that this PE is correctly in the spatial grid
        unsigned int minCellX, minCellY, maxCellX, maxCellY;
        getGridCells(pe,  minCellX, minCellY, maxCellX, maxCellY);
        
        //Remove from all of these cells
        for (unsigned i = minCellX; i <= maxCellX; i++)
            for (unsigned j = minCellY; j <= maxCellY; j++)
            {
                PeSet* cell = &spatialGrid[i][j];
                assert(cell->find(pe) != cell->end());
            }
        /*
         if ((fabs(pe->x - pe->next->x) < FLT_EPSILON && fabs(pe->y - pe->next->y) < FLT_EPSILON))
         {
         printq("pe %p npe %p center %f, %f\n, p: \n%f, %f\n%f, %f\n", pe, pe->next, x, y, pe->x, pe->y, pe->next->x, pe->next->y);
         assert(false);
         }*/
    }
    
    //Check the spatial grid to make sure everything exists
    for (int i = 0; i < gridWidth; i++)
        for (int j = 0; j < gridHeight; j++)
            for (PeSet::iterator k = spatialGrid[i][j].begin(); k != spatialGrid[i][j].end(); k++)
            {
                PointEdge* pe = *k;
                assert(pe);
                assert(pe->x);
                assert(pe->next);
                assert(pe->next->x);
                assert(peSet.find(pe) != peSet.end());   //Contained in the total set
            }
}


