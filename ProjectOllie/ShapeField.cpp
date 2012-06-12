//
//  ShapeField.cpp
//  ProjectOllie
//
//  Created by Steve Gregory on 6/9/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//

#include <iostream>
#include "ShapeField.h"
#include <math.h>
#include <assert.h>

// Define the smallest float difference that could matter
#define plankFloat 0.00001f

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
:width(width), height(height), cellWidth(width/spatialGridWidth), cellHeight(height/spatialGridHeight)
{
    //Setup empty spatial grid
    for (int x = 0; x < spatialGridWidth; x++)
        spatialGrid[x] = new vector<PointEdge*>[spatialGridHeight];
    
}

ShapeField::~ShapeField()
{
    //Delete every point
    for (int i = 0; i < peSet.size(); i++)
        delete peSet[i];
    
    //Delete the grid
    for (int x = 0; x < spatialGridWidth; x++)
        delete[] spatialGrid[x];
    delete[] spatialGrid;
}

void ShapeField::clipCircle(bool add, float r, float x, float y)
{
    
    //Create bounding box for affected area
    unsigned int minX = (unsigned int)(x - r - plankFloat);
    unsigned int minY = (unsigned int)(y - r - plankFloat);
    unsigned int maxX = (unsigned int)(x + r + 1.0f + plankFloat);
    unsigned int maxY = (unsigned int)(y + r + 1.0f + plankFloat);
    
    //Find the corrosponding grid spaces that we are affecting
    unsigned int minCellX = minX/spatialGridWidth;
    unsigned int minCellY = minY/spatialGridHeight;
    unsigned int maxCellX = maxX/spatialGridWidth;
    unsigned int maxCellY = maxY/spatialGridHeight;
    
    //Loop through and collect all potential PointEdges that we could be affecting
    vector<PointEdge*> nearPEs;
    for (int i = minCellX; i <= maxCellX; i++)
        for (int j = minCellY; j <= maxCellY; j++)
            for (int k = 0; k < spatialGrid[i][j].size(); k++)
            {
                bool cont = false;
                for (int l = 0; l < nearPEs.size(); l++)
                    if (nearPEs[l] == spatialGrid[i][j][k])
                    {
                        cont = true;
                        break;
                    }
                if (!cont) nearPEs.push_back(spatialGrid[i][j][k]);
            }
    
    //Classify each of the points of every near PointEdge as inside, on edge, or outside
    float rsq = r*r;
    for (int i = 0; i < nearPEs.size(); i++)
    {
        PointEdge* pe = nearPEs[i];
        //Find square of the distance to the point
        float dx = pe->x - x;
        float dy = pe->y - y;
        float dsq = dx*dx + dy*dy;
        if (dsq < rsq - plankFloat)
            pe->tmpMark = inside;
        else if (dsq > rsq + plankFloat)
            pe->tmpMark = outside;
        else 
            pe->tmpMark = onEdge;
    }
    
    //Find intersections, create points, link them, create enterence or exit
    vector<circleIntersection> entrences;
    vector<circleIntersection> exits;
    for (int i = 0; i < nearPEs.size(); i++)
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
                float xClosest = pe->x + unitX * diffDotUnitPe;
                float yClosest = pe->y + unitY * diffDotUnitPe;
                //Check if the closest point on the line to the citcle center is inside the radius
                float dx = x - xClosest;
                float dy = y - yClosest;
                float lenToCenterSq = dx*dx + dy*dy;
                if (lenToCenterSq < rsq - plankFloat)
                {
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
                    outP->prev = outP;
                    
                    //Add new pe and outP to spatial grid
                    addToSpatialGrid(pe);
                    addToSpatialGrid(outP);
                    
                    //In intersection
                    circleIntersection in;
                    in.intersection = inP;
                    in.angle = atan2f(inX, inY);
                    entrences.push_back(in);
                    
                    //Out intersection
                    circleIntersection out;
                    out.intersection = outP;
                    out.angle = atan2f(outX, outY);
                    exits.push_back(out);
                }
            }
            else if (npe->tmpMark == inside)
            {
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
                in.angle= atan2f(inX, inY);
                entrences.push_back(in);
            }
            //Next mark on edge is handled when the next PointEdge is evaluated
        }
        else if (pe->tmpMark == onEdge)
        {
            if (npe->tmpMark == outside)
            {
                //This on edge, next outside, determine if we came from inside or outside
                if (npe->prev->tmpMark != outside)
                {
                    //Set this pe as exit intersection
                    removeFromSpatialGrid(pe);
                    circleIntersection out;
                    out.intersection = pe;
                    out.angle = atan2f(pe->y - y, pe->x - x);
                    exits.push_back(out);
                }
                else 
                {
                    //It's essentially inside and should be deleted later since it will be bypassed
                    pe->tmpMark = inside;
                }
            }
            else
            {
                //This point on edge, next inside or on edge
                //Set this pe as an enterence intersection
                removeFromSpatialGrid(pe);
                circleIntersection in;
                in.intersection = pe;
                in.angle = atan2f(pe->y - y, pe->x - x);
                entrences.push_back(in);
            }
        }
        else //(pe->tmpMark == inside)
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
                //Make point
                PointEdge* outP = new PointEdge(outX, outY, npe, NULL);
                //Rerout pe to new point
                pe->next = outP;
                //Add this to the grid and PointEdge set
                addToSpatialGrid(outP);
                peSet.push_back(outP);
                //Create intersection
                circleIntersection out;
                out.intersection = outP;
                out.angle= atan2f(outX, outY);
                entrences.push_back(out);
            }
            //Otherwise this point will be deleted at the end (but we still need it for a little bit)
        }
    }
    
    //If this isn't true, something fucked up. Abort mission, refund investors, etc.
    assert(entrences.size() == exits.size());
    
    //Figure out the maximum theta for the given radius and maxCircleSeg
    float maxTheta = 2*asinf(maxCircleSeg/(r*2));
    
    //If nothing intersects, we have no geometry to adjust, perhaps we will make some new independant shapes
    if (entrences.empty())
    {
        //Figure out if the circle edge is outside
        bool outside = isOutside(x, y - plankFloat);
        
        if (outside && add)
        {
            //The circle edge is outside and we are adding, so we must create a new loop
            int numSegs = (int)(twoPi/maxTheta) + 1;
            float dtheta = twoPi/numSegs;
            
            //Build a counter clockwise circle (increasing theta)
            float angle = 0;
            PointEdge* first = new PointEdge(x + r, y, NULL, NULL);
            peSet.push_back(first);
            PointEdge* prev = first;
            for (int i = 1; i < numSegs; i++)
            {
                float px = r*cosf(angle);
                float py = r*sinf(angle);
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
            //Inside and subtracting, add a new hole
            int numSegs = (int)(twoPi/maxTheta) + 1;
            float dtheta = -twoPi/numSegs;
            
            //Build a counter clockwise circle (increasing theta)
            float angle = 0;
            PointEdge* first = new PointEdge(x + r, y, NULL, NULL);
            peSet.push_back(first);
            PointEdge* prev = first;
            for (int i = 1; i < numSegs; i++)
            {
                float px = r*cosf(angle);
                float py = r*sinf(angle);
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
        for (int i = 0; i < entrences.size(); i++)
        {
            //Extend the current entrence to the next exit
            circleIntersection in = entrences[i];
            //Find the subsequent exit in the +ccw direction
            circleIntersection out;
            int outI;
            float dTheta = 10.0f;   //Bigger than 2pi
            for (int j = 0; j < exits.size(); j++)
            {
                circleIntersection tmpOut = exits[i];
                
                //Get the +ccw change in the angle from the enterence to this exit
                float tmpDtheta = tmpOut.angle - in.angle;
                if (tmpDtheta < 0) tmpDtheta = twoPi + tmpDtheta;
                assert(tmpDtheta != 0);
                
                //If it's smaller than the last one, it's closer
                if (tmpDtheta < dTheta)
                {
                    outI = i;
                    dTheta = tmpDtheta;
                    out = tmpOut;
                }
            }
            
            //Find the minimum number of segments we need to satisfy the maximum seg length requirement
            int numSegs = (int)(dTheta/maxTheta + 1);   //Ceil of dtheta/maxTheta
            //Find the angle that each of these segments needs
            float segTheta = dTheta/numSegs;
            
            //Extend entrence to exit along the circle edge in +theta
            PointEdge* prev = in.intersection;
            float angle = in.angle + segTheta;
            for (int j = 1; j < numSegs; j++)
            {
                //Make a new point at this theta
                float x = r*cosf(angle);
                float y = r*sinf(angle);
                PointEdge* pe = new PointEdge(x, y, NULL, prev);
                
                //Make the prev point edge connect to this one
                prev->next = pe;
                
                //Now that the last PE has its edge defined, add it to our collections
                addToSpatialGrid(prev);
                peSet.push_back(pe);
                
                //Set these for the next iteration
                prev = pe;
                angle += segTheta;
            }
            //Connect the last segment to the exit
            prev->next = out.intersection;
            //Add it to the collections
            addToSpatialGrid(prev);
            peSet.push_back(prev);
            
            //Remove that exit because it is no longer needed
            exits[i] = exits.back();
            exits.pop_back();
        }
    }
    
    //Remark all of the OnEdge points as outside, resetting the default for the next clip
    //and remove all points marked inside because nothing except other inside ones point to them
    for (int i = 0; i < nearPEs.size(); i++)
    {
        PointEdge* pe = nearPEs[i];
        if (pe->tmpMark == onEdge) pe->tmpMark = outside;
        else if (pe->tmpMark == inside)
        {
            removeFromSpatialGrid(pe);
            //Fast deletion for unordered vector
            nearPEs[i] = nearPEs.back();
            nearPEs.pop_back();
            i--;
            delete pe;
        }
    }
    
}

void ShapeField::clipThickLine(bool add, float x1, float y1, float x2, float y2, float r)
{
    
}

//Returns true if the point (px, py) is outside or on an edge whose outside normal is (0, -1)
//Precondition: no point edges are coincident with the given segment
bool ShapeField::isOutside(float px, float py)
{
    //Hold the current cell that we are in
    int cellX = (int)(px/cellWidth);
    int cellY = (int)(py/cellHeight);
    
    float yDistance = -1.0f;    //Negative implies that no intersections have been found yet
    bool isOutside;
    for (; cellY >= 0; cellY--)
    {
        vector<PointEdge*>* cell = &(spatialGrid[cellX][cellY]);
        for (int i = 0; i < cell->size(); i++)
        {
            PointEdge* pe = (*cell)[i];
            PointEdge* npe = pe->next;
            bool peLeft = pe->x < px;
            bool npeLeft = npe->x < px;
            if (peLeft && !npeLeft)
            {
                //P is right of normal
                //Find actual intersection
                float m = (npe->y - pe->y)/(npe->x - pe->x);
                float tmpYdistance = pe->y + (px - pe->x) * m - py;
                if ((yDistance < 0 || tmpYdistance < yDistance) && tmpYdistance > 0)
                {
                    //Closest intersection thus far, implies outside
                    isOutside = true;
                    yDistance = tmpYdistance;
                }
            }
            else if (!peLeft && npeLeft)
            {
                //P is left of normal
                //Find actual intersection
                float m = (npe->y - pe->y)/(npe->x - pe->x);
                float tmpYdistance = pe->y + (px - pe->x) * m - py;
                if ((yDistance < 0 || tmpYdistance < yDistance) && tmpYdistance > 0)
                {
                    //Closest intersection thus far, implies inside
                    isOutside = false;
                    yDistance = tmpYdistance;
                }
            }
        }
        //Reset flags
        for (int i = 0; i < cell->size(); i++)
            (*cell)[i]->tmpMark = outside;
        if (yDistance >= 0) return isOutside;
    }
    return true;
}

//Returns all of the points inside and near a bounding box
vector<PointEdge*> ShapeField::pointsNear(float minX, float minY, float maxX, float maxY)
{
    
}

void ShapeField::removeFromSpatialGrid(PointEdge* pe)
{
    //Create a slightly generous bounding box
    unsigned int minX = (unsigned int)(min(pe->x, pe->next->x) - plankFloat);
    unsigned int minY = (unsigned int)(min(pe->y, pe->next->y) - plankFloat);
    unsigned int maxX = (unsigned int)(max(pe->x, pe->next->x) + plankFloat + 1.0f);
    unsigned int maxY = (unsigned int)(max(pe->x, pe->next->y) + plankFloat + 1.0f);
    
    unsigned int minCellX = minX/spatialGridWidth;
    unsigned int minCellY = minY/spatialGridHeight;
    unsigned int maxCellX = maxX/spatialGridWidth;
    unsigned int maxCellY = maxY/spatialGridHeight;
    
    //Remove from all of these cells
    for (int i = minCellX; i <= maxCellX; i++)
        for (int j = minCellY; j <= maxCellY; j++)
            for (int k = 0; k < spatialGrid[i][j].size(); k++)
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
    //Create a slightly generous bounding box
    unsigned int minX = (unsigned int)(min(pe->x, pe->next->x) - plankFloat);
    unsigned int minY = (unsigned int)(min(pe->y, pe->next->y) - plankFloat);
    unsigned int maxX = (unsigned int)(max(pe->x, pe->next->x) + plankFloat + 1.0f);
    unsigned int maxY = (unsigned int)(max(pe->x, pe->next->y) + plankFloat + 1.0f);
    
    unsigned int minCellX = minX/spatialGridWidth;
    unsigned int minCellY = minY/spatialGridHeight;
    unsigned int maxCellX = maxX/spatialGridWidth;
    unsigned int maxCellY = maxY/spatialGridHeight;
    
    //Add to all of these cells
    for (int i = minCellX; i <= maxCellX; i++)
        for (int j = minCellY; j <= maxCellY; j++)
            spatialGrid[i][j].push_back(pe);
}




