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
#include <assert.h>

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
#endif

#ifdef PRINT_DEBUGGING_STATEMENTS
#define printq(s, ...) printf(s, ##__VA_ARGS__)
#else
#define printq(s, ...)
#endif

using namespace std;

struct circleIntersection
{
    float angle;                //In radians
    PointEdge* intersection;    //PointEdge in the shape field at the intersection
};

struct polyIntersection
{
    PointEdge* intersection;    //PointEdge in the shape field at the intersection
    PointEdge* clipPE;          //The intersecting clipping edge
};

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
       /* else 
            pe->tmpMark = onEdge;*/
    }
    
    //All inside points will be circumvented and some edge points. Remember which edge points
    vector<PointEdge*> circumventedEdgePE;
    
    //Find intersections, create points, link them, create enterence or exit
    vector<circleIntersection> entrences;
    vector<circleIntersection> exits;
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
                        circleIntersection in;
                        in.intersection = inP;
                        in.angle = atan2f(inY - y, inX - x);
                        if(isnan(in.angle))
                        {
                            printf("circle center: %f, %f,  intersection: %f, %f", x, y, inX, inY);
                        }
                        entrences.push_back(in);
                        
                        //Out intersection
                        circleIntersection out;
                        out.intersection = outP;
                        out.angle = atan2f(outY - y, outX - x);
                        if(isnan(out.angle))
                        {
                            printf("circle center: %f, %f,  intersection: %f, %f", x, y, outX, outY);
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
                float distanceToEdge = sqrtf(rsq - dx*dx - dy*dy);
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
                circleIntersection in;
                in.intersection = inP;
                in.angle= atan2f(inY - y, inX - x);
                if(isnan(in.angle))
                {
                    printf("circle center: %f, %f,  intersection: %f, %f", x, y, inX, inY);
                    printf("pe: %f, %f\nnpe: %f, %f\nped: %f, %f\npeLen: %f", pe->x, pe->y, npe->x, npe->y, pedx, pedy, peLen);
                    printf("ped unit: %f, %f", unitX, unitY);
                    printf("p to c: %f, %f", dxPtoC, dyPtoC);
                    printf("dot: %f\nClosest: %f, %f", diffDotUnitPe, xClosest, yClosest);
                    printf("dx dy: %f, %f", dx, dy);
                    printf("distance to edge: %f\nin: %f, %f", distanceToEdge, inX, inY);
                    assert(false);
                }
                entrences.push_back(in);
            }
            //Next mark on edge is handled when the next PointEdge is evaluated
        }
        else if (pe->tmpMark == onEdge)
        {
            assert(false);
            if (npe->tmpMark == outside)
            {
                //This on edge, next outside, determine if we came from inside or outside
                if (pe->prev->tmpMark != outside)
                {
                    printq("I-Edge-O intersection out\n");
                    //Set this pe as exit intersection
                    circleIntersection out;
                    out.intersection = pe;
                    out.angle = atan2f(pe->y - y, pe->x - x);
                    exits.push_back(out);
                }
                else 
                    //P essentially inside and should be deleted later since it will be bypassed
                    circumventedEdgePE.push_back(pe);
            }
            else
            {
                //P on edge, np either inside or on edge, determine if we came from outside
                if (pe->prev->tmpMark == outside)
                {
                    printq("O-Edge-I intersection in\n");
                    //Set this pe as an enterence intersection
                    removeFromSpatialGrid(pe);
                    circleIntersection in;
                    in.intersection = pe;
                    in.angle = atan2f(pe->y - y, pe->x - x);
                    entrences.push_back(in);
                }
                else
                    //P essentially inside and should be deleted later since it will be bypassed
                    circumventedEdgePE.push_back(pe);
            }
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
                float distanceToEdge = sqrtf(rsq - dx*dx - dy*dy);
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
                circleIntersection out;
                out.intersection = outP;
                out.angle= atan2f(outY - y, outX - x);
                if(isnan(out.angle))
                {
                    printf("circle center: %f, %f,  intersection: %f, %f", x, y, outX, outY);
                    printf("pe: %f, %f\nnpe: %f, %f\nped: %f, %f\npeLen: %f", pe->x, pe->y, npe->x, npe->y, pedx, pedy, peLen);
                    printf("ped unit: %f, %f", unitX, unitY);
                    printf("p to c: %f, %f", dxPtoC, dyPtoC);
                    printf("dot: %f\nClosest: %f, %f", diffDotUnitPe, xClosest, yClosest);
                    printf("dx dy: %f, %f", dx, dy);
                    printf("distance to edge: %f\nin: %f, %f", distanceToEdge, outX, outY);
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
        if (pe->x < 0 || pe->x > width || pe->y < 0 || pe->y > height)
        {
            printq("Strange point edge coordinates %f, %f", pe->x, pe->y);
            assert(false);
        }
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
        bool outside = isOutside(x, y);
        //assert(outside);
        if (outside && add)
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
                float px = x + rMarginal*cosf(angle);
                float py = y + rMarginal*sinf(angle);
                PointEdge* pe = new PointEdge(px, py, NULL, prev);
                peSet.push_back(pe);
                prev->next = pe;
                addToSpatialGrid(prev);
                prev = pe;
                angle += dtheta;
            }
            prev->next = first;
            first->prev = prev;
            addToSpatialGrid(prev);
        }
        else if (!outside && !add)
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
                float px = x + rMarginal*cosf(angle);
                float py = y + rMarginal*sinf(angle);
                PointEdge* pe = new PointEdge(px, py, NULL, prev);
                peSet.push_back(pe);
                prev->next = pe;
                addToSpatialGrid(prev);
                prev = pe;
                angle += dtheta;
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
            circleIntersection in = entrences[i];
            
            //Find the subsequent exit in the +ccw direction
            circleIntersection out;
            int outI;
            float dTheta;
            if (add)
            {
                dTheta = 1000.0f;   //Bigger than 2pi
                for (unsigned j = 0; j < exits.size(); j++)
                {
                    circleIntersection tmpOut = exits[j];
                    
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
                    circleIntersection tmpOut = exits[j];
                    printf("r %f\n", r);
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
                in.intersection->tmpMark = onEdge;
                in.intersection->next = NULL;
                removeFromSpatialGrid(in.intersection->prev);
                in.intersection->prev->next = out.intersection;
                out.intersection->prev = in.intersection->prev;
                addToSpatialGrid(in.intersection->prev);
                circumventedEdgePE.push_back(in.intersection);
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
                    printf("dtheta: %f\n", dTheta);
                    printf("maxTheta: %f\n", maxTheta);
                    printf("in angle: %f\n", in.angle);
                    printf("out angle: %f\n", out.angle);
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
    for (unsigned i = 0; i < peSet.size(); i++)
    {	
        PointEdge* pe = peSet[i];
        if (pe->tmpMark == inside)
            removeFromSpatialGrid(pe);
        else if (pe->tmpMark == onEdge)
        {
            //Check if it was circumvented
            bool circumvented = false;
            for (unsigned j = 0; j < circumventedEdgePE.size(); j++)
                if (pe == circumventedEdgePE[j])
                {
                    //Found it. We did circumvent it and therefore it should be removed
                    removeFromSpatialGrid(pe);
                    //Lets also mark it as inside to delete it more quickly in the delete loop
                    pe->tmpMark = inside;
                    circumvented = true;
                    break;
                }
            if (!circumvented) pe->tmpMark = outside;   //Reset this
        }
    }
    //Delete inside points which are now only irrelevantly linked to themselves
    for (unsigned i = 0; i < peSet.size(); i++)
    {
        PointEdge* pe = peSet[i];
        if (pe->tmpMark == inside)
        {
            //Remove from the set of all points
            peSet[i] = peSet.back();
            peSet.pop_back();
            i--;
            //delete pe;
        }
    }
    
    fflush(stdout);
    //Check the consistancy of the linked list structures
    numPoints = peSet.size();
    for(unsigned i = 0; i < numPoints; i++)
    {
        PointEdge* pe = peSet[i];
        //Check that it exists and isn't null somehow
        assert(pe);
        //See if the location is in a strange place
        if (pe->x <= 1 || pe->x > width || pe->y <= 1 || pe->y > height)
        {
            printq("Strange point edge coordinates %f, %f", pe->x, pe->y);
            assert(false);
        }
        //Check that it has a next and previous
        assert(pe->next);
        assert(pe->prev);
        //Check that linked nodes link back correctly
        assert(pe->next->prev);
        assert(pe->next->prev == pe);	
        assert(pe->prev->next);
        assert(pe->prev->next == pe);
    }
    
}

//Clips a convex polygon
void ShapeField::clipConvexPolygon(bool add, PointEdge* head)
{
    //Find the min and max x and y to make a bounding box
    float minX = head->x;
    float minY = head->y;
    float maxX = head->x;
    float maxY = head->y;
    PointEdge* pe = head->next;
    while (pe != head) {
        if (pe->x < minX) minX = pe->x;
        if (pe->y < minY) minY = pe->y;
        if (pe->x > maxX) maxX = pe->x;
        if (pe->y > maxY) maxY = pe->y;
    }
    
    //Get all of the near points with these bounds
    vector<PointEdge*> nearPEs = pointsNear(minX, minY, maxX, maxY);
    
    //Mark all points
    for (int i = 0; i < nearPEs.size(); i++)
    {
        PointEdge* pe;
        
    }
    pe = head;
    do
    {
        PointEdge* npe = pe->next;
        //It's inside unless it's on the right of something
        
        
        pe = npe;
    } while(pe != head);
    
    //Find intersections, create exits and entrences
    
    //Connect intersections along clipping path
    
    //Clean up
    
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
            if (pe->tmpMark == outside)
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
    if (!pe->next) return;
    
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




