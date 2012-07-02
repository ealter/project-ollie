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

//Turn off to disable rectangles from being constructed independently of other geometry so they must intersect to be built
#define INDEPENDENT_RECTANGLES 0

// Size of each cell in the spatial grid
#define cellWidth 32
#define cellHeight 32

//Maximum distance for a segment on a circle
#define maxCircleSeg 4

// Define the smallest float difference that could matter
#define plankFloat 0.001f

//2 pi
#define TAU (M_PI*2)

//Finds if the winding of 3 points is counterclockwise
#define ccw(x1, y1, x2, y2, x3, y3) (((x2) - (x1))*((y3) - (y1)) - ((y2) - (y1))*((x3) - (x1)))

#ifdef DEBUG
#define PRINT_DEBUGGING_STATEMENTS
#define KEEP_TOUCH_INPUT
#define USE_EXPENSIVE_ASSERTS
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
    spatialGrid = new vector<PointEdge*>*[gridWidth];
    for (int x = 0; x < gridWidth; x++)
        spatialGrid[x] = new vector<PointEdge*>[gridHeight];

}

ShapeField::~ShapeField()
{
    //Delete every point
    int numPoints = peSet.size();
    for (int i = 0; i < numPoints; i++)
        delete peSet[i];

    //Delete the grid
    for (int x = 0; x < gridWidth; x++)
        delete[] spatialGrid[x];
    delete[] spatialGrid;
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

    //Bound by the world size so we cannot possibly get spatial grid errors
    if (x <= r) x = r + 1;
    if (y <= r) y = r + 1;
    if (x >= width-r) x = width-r-1;
    if (y >= height-r) y = height-r-1;

    //Use this as the r when creating new points so going over circles won't ever expand the curve into the float trig error spots
    float rMarginal = r - .01;

    //Get all potential PointEdges that we could be affecting in a bounding box
    vector<PointEdge*> nearPEs = pointsNear(x-r, y-r, x+r, y+r);

    //Classify each of the points of every near PointEdge as inside, on edge, or outside
    float rsq = r*r;
    unsigned numNearPEs = nearPEs.size();
    for (unsigned i = 0; i < numNearPEs; i++)
    {
        PointEdge* pe = nearPEs[i];
        //Find square of the distance to the point
        float dx = pe->x - x;
        float dy = pe->y - y;
        float dsq = dx*dx + dy*dy;
        if (dsq <= rsq)// + plankFloat)
            pe->tmpMark = inside;
        else// if (dsq > rsq + plankFloat)
            pe->tmpMark = outside;
    }

    //Find intersections, create points, link them, create enterence or exit
    vector<CircleIntersection> entrences;
    vector<CircleIntersection> exits;
    for (unsigned i = 0; i < nearPEs.size(); i++)
    {
        PointEdge* pe = nearPEs[i];
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
                        peSet.push_back(inP);
                        peSet.push_back(outP);

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
                if (dtesq < plankFloat) distanceToEdge = 0;
                else distanceToEdge = sqrtf(dtesq);
                float inX = -unitX * distanceToEdge + xClosest;
                float inY = -unitY * distanceToEdge + yClosest;
                //Make point
                PointEdge* inP = new PointEdge(inX, inY, NULL, pe);
                //Rerout pe to new point
                pe->next = inP;
                //Add this back
                addToSpatialGrid(pe);
                //Add to point set
                peSet.push_back(inP);
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
                if (dtesq < plankFloat) distanceToEdge = 0;
                else distanceToEdge = sqrtf(dtesq);
                float outX = unitX * distanceToEdge + xClosest;
                float outY = unitY * distanceToEdge + yClosest;
                printq("I-O intersection out: %f, %f, \n", outX, outY);
                //Make point
                PointEdge* outP = new PointEdge(outX, outY, npe, NULL);
                //Rerout pe to new point
                npe->prev = outP;
                //Add this to the grid and PointEdge set
                addToSpatialGrid(outP);
                peSet.push_back(outP);
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

    //Check that all of the points are real and in view, like we didn't delete anything or put it in a strange place
    unsigned numPoints = peSet.size();
    for(unsigned i = 0; i < numPoints; i++)
    {
        PointEdge* pe = peSet[i];
        //Check that it exists and isn't null somehow
        assert(pe);
        //See if the location is in a strange place
#ifdef USE_EXPENSIVE_ASSERTS
        if (pe->x < 0 || pe->x > width || pe->y < 0 || pe->y > height)
        {
            printq("Strange point edge coordinates %f, %f", pe->x, pe->y);
            assert(false);
        }
#endif
    }

    //If this isn't true, something fucked up. Abort mission, refund investors, etc.
    printq("in: %lu, out: %lu\n", entrences.size(), exits.size());
    assert(entrences.size() == exits.size());

    //Figure out the maximum theta for the given radius and maxCircleSeg
    float maxTheta = 2*asinf(maxCircleSeg/(r*2));

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
            peSet.push_back(first);
            PointEdge* prev = first;
            for (int i = 1; i < numSegs; i++)
            {
                angle += dtheta;
                float px = x + rMarginal*cosf(angle);
                float py = y + rMarginal*sinf(angle);
                PointEdge* pe = new PointEdge(px, py, NULL, prev);
                peSet.push_back(pe);
                prev->next = pe;
                addToSpatialGrid(prev);
                prev = pe;
            }
            prev->next = first;
            first->prev = prev;
            addToSpatialGrid(prev);
        }
        else if (edgeOutside && !add)
        {
            printq("Adding new hole loop");
            //Inside and subtracting, add a new hole
            int numSegs = (int)(TAU/maxTheta) + 1;
            float dtheta = -TAU/numSegs;

            //Build a counter clockwise circle (increasing theta)
            float angle = 0;
            PointEdge* first = new PointEdge(x + rMarginal, y, NULL, NULL);
            peSet.push_back(first);
            PointEdge* prev = first;
            for (int i = 1; i < numSegs; i++)
            {
                angle += dtheta;
                float px = x + rMarginal*cosf(angle);
                float py = y + rMarginal*sinf(angle);
                PointEdge* pe = new PointEdge(px, py, NULL, prev);
                peSet.push_back(pe);
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


            //If the enterence and exit are at a really close theta, then we just want to merge these points,
            if (fabs(dTheta) < .01)
            {
                printq("Merging close enterence and exit\n");
                //Bypass the "in" PointEdge
                in.intersection->tmpMark = inside;
                in.intersection->next = NULL;
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
                    peSet.push_back(pe);

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
    for (unsigned i = 0; i < nearPEs.size(); i++)
    {
        PointEdge* pe = nearPEs[i];
        if (pe->tmpMark == inside)
            removeFromSpatialGrid(pe);
    }
    //Delete inside points which are now only irrelevantly linked to themselves
    for (unsigned i = 0; i < peSet.size(); i++)
    {
        PointEdge* pe = peSet[i];/*
        //Check if we can bypass the point
        if (pe->tmpMark != inside && pe->getLenSq() < plankFloat)
        {
            printq("Bypassing point in clip circle\n");
            removeFromSpatialGrid(pe);
            removeFromSpatialGrid(pe->prev);
            pe->tmpMark = inside;
            pe->next->prev = pe->prev;
            pe->prev->next = pe->next;
            addToSpatialGrid(pe->prev);
        }*/
        if (pe->tmpMark == inside)
        {
            //Remove from the set of all points
            peSet[i] = peSet.back();
            peSet.pop_back();
            i--;
            delete pe;
        }
    }

    //Check the consistancy of the linked list structures
    numPoints = peSet.size();
    for(unsigned i = 0; i < numPoints; i++)
    {
        PointEdge* pe = peSet[i];
        //Check that it exists and isn't null somehow
        assert(pe);
        //See if the location is in a strange place
#ifdef USE_EXPENSIVE_ASSERTS
        if (pe->x <= 1 || pe->x > width || pe->y <= 1 || pe->y > height) {
            printq("Strange point edge coordinates %f, %f", pe->x, pe->y);
            assert(false);
        }
#endif
        //Check that it has a next and previous
        assert(pe->next);
        assert(pe->prev);
        //Check that linked nodes link back correctly
        if(pe->next->prev != pe) {
          assert(pe->next->prev);
          assert(0);
        }
        if(pe->prev->next != pe) {
          assert(pe->prev->next);
          assert(0);
        }/*
        if ((fabs(pe->x - pe->next->x) < FLT_EPSILON && fabs(pe->y - pe->next->y) < FLT_EPSILON))
        {
            printq("pe %p npe %p center %f, %f\n, p: \n%f, %f\n%f, %f\n", pe, pe->next, x, y, pe->x, pe->y, pe->next->x, pe->next->y);
            assert(false);
        }*/
    }

    
#ifdef USE_EXPENSIVE_ASSERTS
    //Check the spatial grid to make sure everything exists
    for (int i = 0; i < gridWidth; i++)
        for (int j = 0; j < gridHeight; j++)
            for (int k = 0; k < spatialGrid[i][j].size(); k++)
            {
                PointEdge* pe = spatialGrid[i][j][k];
                assert(pe);
                assert(pe->x);
                assert(pe->next);
                assert(pe->next->x);
            }
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
    printq("intersection T: in range\n");
    return true;
}

//Returns true when the point (x, y) is right of the segment from (x1, y1) to (x2, y2), false if it is left or on the segment
bool rightOf(float x1, float y1, float x2, float y2, float x, float y)
{
    //CCW winding of (x1, y1) to (x, y) to (x2, y2) implies that the point is right
    return ccw(x1, y1, x, y, x2, y2) >= 0;
}

PolyIntersection ShapeField::makePolyIntersectionOut(float x, float y, float t, float peT, PointEdge* npe)
{
    //assert(peT < 1-FLT_EPSILON);
    PolyIntersection p;
    p.intersection = new PointEdge(x, y, npe, NULL);
    p.t = t;
    npe->prev = p.intersection;
    addToSpatialGrid(p.intersection);
    peSet.push_back(p.intersection);
    return p;
}

PolyIntersection ShapeField::makePolyIntersectionIn(float x, float y, float t, float peT, PointEdge* pe)
{
    //assert(peT > FLT_EPSILON);
    removeFromSpatialGrid(pe);
    PolyIntersection p;
    p.intersection = new PointEdge(x, y, NULL, pe);
    p.t = t;
    pe->next = p.intersection;
    addToSpatialGrid(pe);
    return p;
}

//Requires 4 x and 4 y for points in a counterclockwise rotation
void ShapeField::clipConvexQuad(bool add, float* x, float* y)
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

    //Find a bounding box to get near points
    float minX = min(min(x[0], x[1]), min(x[2], x[3]));
    float minY = min(min(y[0], y[1]), min(y[2], y[3]));
    float maxX = max(max(x[0], x[1]), max(x[2], x[3]));
    float maxY = max(max(y[0], y[1]), max(y[2], y[3]));

    //Get all of the near points
    vector<PointEdge*> nearPEs = pointsNear(minX, minY, maxX, maxY);
    printq("RECT near points count: %lu\n", nearPEs.size());
    //Mark inside or outside
    for (int i = 0; i < nearPEs.size(); i++)
    {
        PointEdge* pe = nearPEs[i];

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

        //Check inside (unmarked so far)
        else if (pe->tmpMark == outside) pe->tmpMark = inside;
    }

    //Create intersections
    vector<PolyIntersection> Ains = vector<PolyIntersection>();
    vector<PolyIntersection> Bins = vector<PolyIntersection>();
    vector<PolyIntersection> Cins = vector<PolyIntersection>();
    vector<PolyIntersection> Dins = vector<PolyIntersection>();
    vector<PolyIntersection> Aouts = vector<PolyIntersection>();
    vector<PolyIntersection> Bouts = vector<PolyIntersection>();
    vector<PolyIntersection> Couts = vector<PolyIntersection>();
    vector<PolyIntersection> Douts = vector<PolyIntersection>();

    for (int i = 0; i < nearPEs.size(); i++)
    {
        PointEdge* pe = nearPEs[i];
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

            //Check inside (unmarked so far)
            assert (npe->tmpMark != outside);
        }

        //Check if we are inside
        if (pe->tmpMark == inside)
        {
            //Check that npe is not inside
            if (!(npe->tmpMark & inside))
            {
                printq("RECT I-O intersection out, outside side: %d\n", npe->tmpMark);
                //There is an I-O intersection out, lets find the line that it is on
                //Find the intersection and where it is on the segments
                float Xint;
                float Yint;
                float t;
                float peT;
                if      (npe->tmpMark & rightA && intersects(x[0], y[0], x[1], y[1], pe->x, pe->y, npe->x, npe->y, &Xint, &Yint, &t, &peT) )
                    Aouts.push_back(makePolyIntersectionOut(Xint, Yint, t, peT, npe));
                else if (npe->tmpMark & rightB && intersects(x[1], y[1], x[2], y[2], pe->x, pe->y, npe->x, npe->y, &Xint, &Yint, &t, &peT))
                    Bouts.push_back(makePolyIntersectionOut(Xint, Yint, t, peT, npe));
                else if (npe->tmpMark & rightC && intersects(x[2], y[2], x[3], y[3], pe->x, pe->y, npe->x, npe->y, &Xint, &Yint, &t, &peT))
                    Couts.push_back(makePolyIntersectionOut(Xint, Yint, t, peT, npe));
                else if (npe->tmpMark & rightD && intersects(x[3], y[3], x[0], y[0], pe->x, pe->y, npe->x, npe->y, &Xint, &Yint, &t, &peT))
                    Douts.push_back(makePolyIntersectionOut(Xint, Yint, t, peT, npe));
                else assert(false);  //Intersection not found
            }
        }
        else    //PE somewhere outside
        {
            if (npe->tmpMark == inside)
            {
                printq("RECT O-I intersection in, outside side: %d\n", pe->tmpMark);
                //NPE inside, O-I intersection in
                float Xint;
                float Yint;
                float t;
                float peT;
                if      (pe->tmpMark & rightA && intersects(x[0], y[0], x[1], y[1], pe->x, pe->y, npe->x, npe->y, &Xint, &Yint, &t, &peT))
                    Ains.push_back(makePolyIntersectionIn(Xint, Yint, t, peT, pe));
                else if (pe->tmpMark & rightB && intersects(x[1], y[1], x[2], y[2], pe->x, pe->y, npe->x, npe->y, &Xint, &Yint, &t, &peT))
                    Bins.push_back(makePolyIntersectionIn(Xint, Yint, t, peT, pe));
                else if (pe->tmpMark & rightC && intersects(x[2], y[2], x[3], y[3], pe->x, pe->y, npe->x, npe->y, &Xint, &Yint, &t, &peT))
                    Cins.push_back(makePolyIntersectionIn(Xint, Yint, t, peT, pe));
                else if (pe->tmpMark & rightD && intersects(x[3], y[3], x[0], y[0], pe->x, pe->y, npe->x, npe->y, &Xint, &Yint, &t, &peT))
                    Dins.push_back(makePolyIntersectionIn(Xint, Yint, t, peT, pe));
                else assert(false);  //Intersection not found
            }


            //Both outside, check if the npe is not on the same side of the quad
            else if (pe->tmpMark != npe->tmpMark)
            {
                //Potential O-O intersection

                //In intersection only possible on edges which PE is on the right side of
                float XintIn;
                float YintIn;
                float tIn;
                float peTIn;
                vector<PolyIntersection>* segIns = NULL;
                
                if      (pe->tmpMark & rightA && intersects(x[0], y[0], x[1], y[1], pe->x, pe->y, npe->x, npe->y, &XintIn, &YintIn, &tIn, &peTIn))
                    segIns = &Ains;
                else if (pe->tmpMark & rightB && intersects(x[1], y[1], x[2], y[2], pe->x, pe->y, npe->x, npe->y, &XintIn, &YintIn, &tIn, &peTIn))
                    segIns = &Bins;
                else if (pe->tmpMark & rightC && intersects(x[2], y[2], x[3], y[3], pe->x, pe->y, npe->x, npe->y, &XintIn, &YintIn, &tIn, &peTIn))
                    segIns = &Cins;
                else if (pe->tmpMark & rightD && intersects(x[3], y[3], x[0], y[0], pe->x, pe->y, npe->x, npe->y, &XintIn, &YintIn, &tIn, &peTIn))
                    segIns = &Dins;
                else continue;  //Intersection not found
                
                printq("RECT O-O intersection in and out, outside sides: %d, %d\n", pe->tmpMark, npe->tmpMark);
                
                float XintOut;
                float YintOut;
                float tOut;
                float peTOut;
                
                //In intersection was found, try to find an out intersection now
                if      (npe->tmpMark & rightA && intersects(x[0], y[0], x[1], y[1], pe->x, pe->y, npe->x, npe->y, &XintOut, &YintOut, &tOut, &peTOut))
                    Aouts.push_back(makePolyIntersectionOut(XintOut, YintOut, tOut, peTOut, npe));
                else if (npe->tmpMark & rightB && intersects(x[1], y[1], x[2], y[2], pe->x, pe->y, npe->x, npe->y, &XintOut, &YintOut, &tOut, &peTOut))
                    Bouts.push_back(makePolyIntersectionOut(XintOut, YintOut, tOut, peTOut, npe));
                else if (npe->tmpMark & rightC && intersects(x[2], y[2], x[3], y[3], pe->x, pe->y, npe->x, npe->y, &XintOut, &YintOut, &tOut, &peTOut))
                    Couts.push_back(makePolyIntersectionOut(XintOut, YintOut, tOut, peTOut, npe));
                else if (npe->tmpMark & rightD && intersects(x[3], y[3], x[0], y[0], pe->x, pe->y, npe->x, npe->y, &XintOut, &YintOut, &tOut, &peTOut))
                    Douts.push_back(makePolyIntersectionOut(XintOut, YintOut, tOut, peTOut, npe));
                else continue;    //Nevermind don't intersect or whatever
                
                //Add in intersection because an out intersection was found too
                segIns->push_back(makePolyIntersectionIn(XintIn, YintIn, tIn, peTIn, pe));
            }
        }


    }

    //Make sure we have the same number of ins as outs because otherwise something went wrong
    int ins = Ains.size() + Bins.size() + Cins.size() + Dins.size();
    int outs = Aouts.size() + Bouts.size() + Couts.size() + Douts.size();
    printq("RECT ins: %d, outs: %d\n", ins, outs);
    assert(ins == outs);

    if (ins == 0 && INDEPENDENT_RECTANGLES)
    {
        //There are no intersections, figure out what where the fuck we are
        bool aOutside = isOutside((x[0]+x[2])/2, (y[0]+y[2])/2);
        if (add && aOutside)
        {
            printq("adding independent rectangle loop\n");
            //assert(false);  //As of now this functionality is useless so reaching this point is a bug... erase the assert if you want to add rectangle loops
            //We are adding and outside, simply build the rectangle
            PointEdge* A = new PointEdge(x[0], y[0], NULL, NULL);
            PointEdge* B = new PointEdge(x[1], y[1], NULL, A);
            PointEdge* C = new PointEdge(x[2], y[2], NULL, B);
            PointEdge* D = new PointEdge(x[3], y[3], NULL, C);

            A->prev = D;

            A->next = B;
            B->next = C;
            C->next = D;
            D->next = A;

            addToSpatialGrid(A);
            addToSpatialGrid(B);
            addToSpatialGrid(C);
            addToSpatialGrid(D);

            peSet.push_back(A);
            peSet.push_back(B);
            peSet.push_back(C);
            peSet.push_back(D);
        }
        else if (!add && !aOutside)
        {
            printq("adding independent rectangle hole\n");
            assert(false);  //As of now this functionality is useless so reaching this point is a bug... erase the assert if you want to add rectangle loops
            //We are subtracting and inside, simply build a rectangle hole
            PointEdge* A = new PointEdge(x[0], y[0], NULL, NULL);
            PointEdge* B = new PointEdge(x[1], y[1], A, NULL);
            PointEdge* C = new PointEdge(x[2], y[2], B, NULL);
            PointEdge* D = new PointEdge(x[3], y[3], C, NULL);

            A->next = D;

            A->prev= B;
            B->prev = C;
            C->prev = D;
            D->prev = A;

            addToSpatialGrid(A);
            addToSpatialGrid(B);
            addToSpatialGrid(C);
            addToSpatialGrid(D);

            peSet.push_back(A);
            peSet.push_back(B);
            peSet.push_back(C);
            peSet.push_back(D);
        }
    }
    else if (ins > 0)
    {
        //There are intersections
        //Loop through the enterences and connect them to the exits in the counterclockwise direction
        vector<PolyIntersection>* ins [] = {&Ains, &Bins, &Cins, &Dins};
        vector<PolyIntersection>* outs [] = {&Aouts, &Bouts, &Couts, &Douts};
        //Find the starting index, the first segment that has an in
        int start = 0;
        while (ins[start]->empty()) start++;
        for (int n = start; n < start + 4; n++)
        {
            int i = n % 4;
            while (!ins[i]->empty())
            {
                //Find the lowest t in intersection
                PolyIntersection* in = &ins[i]->at(0);
                int inIndex = 0;
                for (int j = 1; j < ins[i]->size(); j++)
                {
                    if (ins[i]->at(j).t < in->t)
                    {
                        in = &ins[i]->at(j);
                        inIndex = j;
                    }
                }

                //Find the next out intersection
                PolyIntersection* out = NULL;
                int outSeg = i-1;
                int outIndex;
                bool wrapped = false;
                while (out == NULL)
                {
                    outSeg = (outSeg + 1) %4;
                    //Check outSeg for the next out
                    for (int j = 0; j < outs[outSeg]->size(); j++)
                    {
                        PolyIntersection* outTemp = &outs[outSeg]->at(j);
                        if (wrapped || outTemp->t >= in->t)
                            if (!out || (outTemp->t < out->t))
                            {
                                out = outTemp;
                                outIndex = j;
                            }
                    }
                    wrapped = true;
                }
                printq("in seg:%d t:%f extending to out seg:%d t:%f\n", i, in->t, outSeg, out->t);
                //Lets see if we need to merge
                float dx = out->intersection->x - in->intersection->x;
                float dy = out->intersection->y - in->intersection->y;/*
                if(fabs(out->t - in->t) < plankFloat || (dx*dx+dy*dy < plankFloat && outSeg == ((i+1)%4)))
                {
                    //Bypass the in intersection and delete it
                    printq("RECT bypass\n");
                    removeFromSpatialGrid(in->intersection->prev);
                    in->intersection->prev->next = out->intersection;
                    out->intersection->prev = in->intersection->prev;
                    addToSpatialGrid(in->intersection->prev);
                    in->intersection->tmpMark = inside;
                }
                else*/
                {
                    //Connect the in to the out
                    PointEdge* prev = in->intersection;
                    bool wrapped = false;
                    for (int cseg = i; cseg != outSeg || (!wrapped && in->t > out->t);)
                    {
                        int nextSeg = (cseg + 1)%4;
                        //Create the corner point
                        //Make a corner if the neither the in nor out intersection is close enough to be one
                        if (!(outSeg == nextSeg && out->t < plankFloat)  &&
                            !(cseg == i && in->t  > 1-plankFloat))
                        {
                            PointEdge* corner = new PointEdge(x[nextSeg], y[nextSeg], NULL, prev);
                            prev->next = corner;
                            addToSpatialGrid(prev);
                            peSet.push_back(prev);
                            prev = corner;
                        }
                        cseg = nextSeg;
                        wrapped = true;
                    }
                    //Connect last constructed PE to the exit
                    out->intersection->prev = prev;
                    prev->next = out->intersection;
                    addToSpatialGrid(prev);
                    peSet.push_back(prev);
                }

                //Remove that in intersection
                ins[i]->at(inIndex) = ins[i]->back();
                ins[i]->pop_back();

                //Remove that out intersection
                outs[outSeg]->at(outIndex) = outs[outSeg]->back();
                outs[outSeg]->pop_back();
            }
        }
    }

    //Clean up, remove all the inside point edges from the grid
    for (unsigned i = 0; i < nearPEs.size(); i++)
    {
        PointEdge* pe = nearPEs[i];
        if (pe->tmpMark == inside)
            removeFromSpatialGrid(pe);
    }
    //Delete inside points which are now only irrelevantly linked to themselves
    for (unsigned i = 0; i < peSet.size(); i++)
    {
        PointEdge* pe = peSet[i];/*
        //Check if we can bypass the point
        if (pe->tmpMark != inside && pe->getLenSq() < 4*FLT_EPSILON)
        {
            removeFromSpatialGrid(pe);
            removeFromSpatialGrid(pe->prev);
            pe->tmpMark = inside;
            pe->next->prev = pe->prev;
            pe->prev->next = pe->next;
            addToSpatialGrid(pe->prev);
        }*/
        if (pe->tmpMark == inside)
        {
            //Remove from the set of all points
            peSet[i] = peSet.back();
            peSet.pop_back();
            i--;
            delete pe;
        }
        else pe->tmpMark = outside;
    }

    //Check the consistancy of the linked list structures
    int numPoints = peSet.size();
    for(unsigned i = 0; i < numPoints; i++)
    {
        PointEdge* pe = peSet[i];
        //Check that it exists and isn't null somehow
        assert(pe);        //Check that it has a next and previous
        assert(pe->next);
        assert(pe->prev);
        //Check that linked nodes link back correctly
        assert(pe->next->prev);
        assert(pe->next->prev == pe);
        assert(pe->prev->next);
        assert(pe->prev->next == pe);
#ifdef USE_EXPENSIVE_ASSERTS
        //See if the location is in a strange place
        if (pe->x <= 1 || pe->x > width || pe->y <= 1 || pe->y > height)
        {
            printq("Strange point edge coordinates %f, %f", pe->x, pe->y);
            assert(false);
        }/*
        //Check that the next point is far enough away that PE has a valid edge
        if ((fabs(pe->x - pe->next->x) < FLT_EPSILON && fabs(pe->y - pe->next->y) < FLT_EPSILON))
        {
            printq("pe %p npe %p p: \n%f, %f\n%f, %f\n", pe, pe->next, pe->x, pe->y, pe->next->x, pe->next->y);
            assert(false);
        }*/
#endif
        
    }
    
#ifdef USE_EXPENSIVE_ASSERTS
    //Check the spatial grid to make sure everything exists
    for (int i = 0; i < gridWidth; i++)
        for (int j = 0; j < gridHeight; j++)
            for (int k = 0; k < spatialGrid[i][j].size(); k++)
            {
                PointEdge* pe = spatialGrid[i][j][k];
                assert(pe);
                assert(pe->x);
                assert(pe->next);
                assert(pe->next->x);
            }
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
    for (unsigned i = 0; i < peSet.size(); i++)
        delete peSet[i];

    //Clear the point set
    peSet.clear();

    //Clear the spatial grid vectors
    for (int i = 0; i < gridWidth; i++)
        for(int j = 0; j < gridHeight; j++)
            spatialGrid[i][j].clear();

}


//Returns true if the point (px, py) is outside or on an edge whose outside normal is (0, -1)
//Precondition: no point edges are coincident with the given segment
bool ShapeField::isOutside(float px, float py)
{
    //Hold the current cell that we are in
    int cellX = px/cellWidth;
    int cellY = py/cellHeight;

    float yDistance = -1.0f;    //Negative implies that no intersections have been found yet
    bool isOutside;
    for (; cellY < gridHeight; cellY++)
    {
        vector<PointEdge*>* cell = &(spatialGrid[cellX][cellY]);
        for (unsigned i = 0; i < cell->size(); i++)
        {
            PointEdge* pe = cell->at(i);
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
                    if ((yDistance < 0 || tmpYdistance < yDistance) && tmpYdistance >= 0)
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
                    if ((yDistance < 0 || tmpYdistance < yDistance) && tmpYdistance >= 0)
                    {
                        //Closest intersection thus far, implies inside
                        isOutside = false;
                        yDistance = tmpYdistance;
                    }
                }
            }
        }
        if (yDistance >= 0) return isOutside;
    }
    return true;
}

//Returns all of the points inside and near a bounding box
vector<PointEdge*> ShapeField::pointsNear(float minX, float minY, float maxX, float maxY)
{
    return peSet;
    
    //Find the corrosponding grid spaces that we are affecting
    unsigned int minCellX = ((unsigned)minX)/cellWidth;
    unsigned int minCellY = ((unsigned)minY)/cellHeight;
    unsigned int maxCellX = ((unsigned)maxX+1)/cellWidth;
    unsigned int maxCellY = ((unsigned)maxY+1)/cellHeight;

    vector<PointEdge*> nearPEs;
    for (unsigned i = minCellX; i <= maxCellX; i++)
        for (unsigned j = minCellY; j <= maxCellY; j++)
            for (unsigned k = 0; k < spatialGrid[i][j].size(); k++)
            {
                bool cont = false;
                unsigned numNearPEs = nearPEs.size();
                for (unsigned l = 0; l < numNearPEs; l++)
                    if (nearPEs[l] == spatialGrid[i][j][k])
                    {
                        cont = true;
                        break;
                    }
                if (!cont) nearPEs.push_back(spatialGrid[i][j][k]);
            }

    return nearPEs;
}

void ShapeField::removeFromSpatialGrid(PointEdge* pe)
{
    assert(pe->next);

    //Create a slightly generous bounding box
    unsigned int minX = min(pe->x, pe->next->x) - plankFloat;
    unsigned int minY = min(pe->y, pe->next->y) - plankFloat;
    unsigned int maxX = max(pe->x, pe->next->x) + plankFloat + 1;
    unsigned int maxY = max(pe->y, pe->next->y) + plankFloat + 1;

    unsigned int minCellX = minX/cellWidth;
    unsigned int minCellY = minY/cellHeight;
    unsigned int maxCellX = maxX/cellWidth;
    unsigned int maxCellY = maxY/cellHeight;

    //Remove from all of these cells
    for (unsigned i = minCellX; i <= maxCellX; i++)
        for (unsigned j = minCellY; j <= maxCellY; j++)
            for (unsigned k = 0; k < spatialGrid[i][j].size(); k++)
                if (spatialGrid[i][j][k] == pe)
                {
                    //Quick removal from unordered vector
                    spatialGrid[i][j][k] = spatialGrid[i][j].back();
                    spatialGrid[i][j].pop_back();
                    break;
                }

}

void ShapeField::addToSpatialGrid(PointEdge* pe)
{
    assert(pe->next);

    //Create a slightly generous bounding box
    unsigned int minX = min(pe->x, pe->next->x) - plankFloat;
    unsigned int minY = min(pe->y, pe->next->y) - plankFloat;
    unsigned int maxX = max(pe->x, pe->next->x) + plankFloat + 1;
    unsigned int maxY = max(pe->y, pe->next->y) + plankFloat + 1;

    unsigned int minCellX = minX/cellWidth;
    unsigned int minCellY = minY/cellHeight;
    unsigned int maxCellX = maxX/cellWidth;
    unsigned int maxCellY = maxY/cellHeight;

    //Add to all of these cells
    for (unsigned i = minCellX; i <= maxCellX; i++)
        for (unsigned j = minCellY; j <= maxCellY; j++)
            spatialGrid[i][j].push_back(pe);
}




