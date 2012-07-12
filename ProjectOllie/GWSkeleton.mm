//
//  GWSkeleton.m
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/10/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "GWSkeleton.h"


//BLENDER TO METER RATIO
#define BTM_RATIO 10.0

using namespace std;

@interface GWSkeleton(){
    
}
-(void)buildSkeletonFromFile:(NSString*)fileName;
-(void)assembleSkeleton:(NSDictionary*)currentBone;
@end

@implementation GWSkeleton

-(id)initFromFile:(NSString*)fileName box2dWorld:(b2World *)world{
    if((self = [super init])){
        
        _skeleton = new Skeleton(world);
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"skel"]; 
        [self buildSkeletonFromFile:filePath];
    }
    return self;
}

-(void)buildSkeletonFromFile:(NSString*)fileName{
    
    CGPoint absoluteLocation = ccp(100.0,200.0);
    float jointAngleMax = DEG2RAD(180.0);
    float jointAngleMin = 0.0;
    CGPoint headLoc;
    CGPoint tailLoc;
    CGPoint averageLoc;
    
    /* Load the data and check for error */
    NSError* error = nil;
    NSData* skelData = [NSData dataWithContentsOfFile:fileName options:kNilOptions error:&error];
    if(error) {
        DebugLog(@"Error reading character file (%@): %@", [self class], error);
    }
    NSArray* skeletonArray = [NSJSONSerialization JSONObjectWithData:skelData options:kNilOptions error:&error];
    if(error) {
        DebugLog(@"Error creating dictionary from file (%@): %@", [self class], error);
    }
    
    
    // Must be done for every bone until proper tree is sent
    Bone* head = new Bone;
    NSDictionary* currentBone  = [skeletonArray objectAtIndex:0];
    head->l                    = [(NSNumber*)[currentBone objectForKey:@"length"] floatValue]*BTM_RATIO;
    head->a                    = [(NSNumber*)[currentBone objectForKey:@"angle"]  floatValue];
    head->w                    = 1.0 * BTM_RATIO;
    NSDictionary* headDict     = [currentBone objectForKey:@"head"];
    headLoc.x                  = [(NSNumber*)[headDict objectForKey:@"x"] floatValue];
    headLoc.y                  = [(NSNumber*)[headDict objectForKey:@"y"] floatValue];
    NSDictionary* tailDict     = [currentBone objectForKey:@"tail"];
    tailLoc.x                  = [(NSNumber*)[tailDict objectForKey:@"x"] floatValue];
    tailLoc.y                  = [(NSNumber*)[tailDict objectForKey:@"y"] floatValue];
    
    tailLoc                    = ccpAdd(tailLoc,absoluteLocation);
    headLoc                    = ccpAdd(headLoc,absoluteLocation);
    averageLoc                 = ccpMult(ccpAdd(tailLoc,headLoc),.5f);
    head->x                    = averageLoc.x;
    head->y                    = averageLoc.y;
    head->jointAngleMax        = jointAngleMax;
    head->jointAngleMin        = jointAngleMin;
    head->jx                   = headLoc.x;
    head->jy                   = headLoc.y;
    head->name                 = "head";
    _skeleton->boneAddChild(0, head);
    _skeleton->setRoot(head);
}
-(Bone*)getBoneByName:(NSString*)bName{
    
    return nil;
}
-(Skeleton*)getSkeleton{
    return _skeleton;
}

@end
