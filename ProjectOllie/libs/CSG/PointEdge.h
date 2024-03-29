//
//  PointEdge.h
//  ProjectOllie
//
//  Created by Steve Gregory on 6/9/12.
//  Copyright (c) 2012 hi ku. All rights reserved.
//

#ifndef ProjectOllie_PointEdge_h
#define ProjectOllie_PointEdge_h

#define outside 0
#define rightA 1
#define rightB 2
#define rightC 4
#define rightD 8
#define inside 16

 
// Represents the point x, y and the edge up to the next point
class PointEdge
{
public:
    float x, y;                  //Where the edge starts, included in this edge
    PointEdge*      next;        //The next point edge - this object represents every point up to the next one
    PointEdge*      prev;        //Link to the previous point 
    void*           userData;    //Super flexible way of letting the user bind the points to something
    unsigned        tmpMark;     //For labeling the point; useful in clipping algorithms
    PointEdge(float x, float y, PointEdge* next, PointEdge* prev)
        :x(x), y(y), next(next), prev(prev)
    {
        tmpMark = outside;   //Always starts outside
    }
    
    float getLenSq()
    {
        float dx = next->x - x;
        float dy = next->y - y;
        return dx*dx + dy*dy;
    }
};



#endif
