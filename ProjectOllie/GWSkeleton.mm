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
-(void)assembleSkeleton:(NSArray*)currentBoneArray parentBone:(Bone*)parent;
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
    
    [self assembleSkeleton:skeletonArray parentBone:nil];
}

-(void)assembleSkeleton:(NSArray *)currentBoneArray parentBone:(Bone *)parent{
    
    CGPoint absoluteLocation = ccp(100.0,200.0);
    float jointAngleMax = DEG2RAD(180.0);
    float jointAngleMin = -DEG2RAD(90.0);
    CGPoint headLoc;
    CGPoint tailLoc;
    CGPoint averageLoc;
    
    for (NSDictionary* currentBone in currentBoneArray) {
        //make new bone
        Bone* bone                 = new Bone;
        
        //perform type conversions
        NSDictionary* headDict     = [currentBone objectForKey:@"head"];
        headLoc.x                  = [(NSNumber*)[headDict objectForKey:@"x"] floatValue];
        headLoc.y                  = [(NSNumber*)[headDict objectForKey:@"y"] floatValue];
        NSDictionary* tailDict     = [currentBone objectForKey:@"tail"];
        tailLoc.x                  = [(NSNumber*)[tailDict objectForKey:@"x"] floatValue];
        tailLoc.y                  = [(NSNumber*)[tailDict objectForKey:@"y"] floatValue];
        
        //transform to screen coordinates
        headLoc                    = ccpMult(headLoc,BTM_RATIO);
        tailLoc                    = ccpMult(tailLoc,BTM_RATIO);
        tailLoc                    = ccpAdd(tailLoc,absoluteLocation);
        headLoc                    = ccpAdd(headLoc,absoluteLocation);
        averageLoc                 = ccpMult(ccpAdd(tailLoc,headLoc),.5f);
        
        //assign values to bone
        bone->x                    = averageLoc.x;
        bone->y                    = averageLoc.y;
        bone->jointAngleMax        = jointAngleMax;
        bone->jointAngleMin        = jointAngleMin;
        bone->jx                   = headLoc.x;
        bone->jy                   = headLoc.y;
        bone->name                 = [[currentBone objectForKey:@"name"] UTF8String];
        bone->l                    = [(NSNumber*)[currentBone objectForKey:@"length"] floatValue]*BTM_RATIO;
        bone->a                    = [(NSNumber*)[currentBone objectForKey:@"angle"]  floatValue];
        bone->w                    = 2.0;
        
        _skeleton->boneAddChild(parent, bone);
        
        NSArray* children          = [currentBone objectForKey:@"children"];
        [self assembleSkeleton:children parentBone:bone];
        
    }
}

-(Bone*)getBoneByName:(NSString*)bName{
    
    return nil;
}
-(Skeleton*)getSkeleton{
    return _skeleton;
}

@end
