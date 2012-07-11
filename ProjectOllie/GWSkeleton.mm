//
//  GWSkeleton.m
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/10/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "GWSkeleton.h"


using namespace std;

@interface GWSkeleton(){
    
}
-(void)buildSkeletonFromFile:(NSString*)fileName;

@end

@implementation GWSkeleton

-(id)initFromFile:(NSString*)fileName box2dWorld:(b2World *)world{
    if((self = [super init])){
        
        _skeleton = new Skeleton(world);
        [self buildSkeletonFromFile:fileName];
    }
    return self;
}

-(void)buildSkeletonFromFile:(NSString*)fileName{
    
    float jointAngleMax = DEG2RAD(180.0);
    float jointAngleMin = 0.0;
    CGPoint headLoc;
    CGPoint tailLoc;
    CGPoint averageLoc;
    
    /* Load the data and check for error */
    NSError* error = nil;
    NSData* skelData = [NSData dataWithContentsOfFile:fileName options:kNilOptions error:&error];
    if(error) {
        DebugLog(@"Error when communicating with server (%@): %@", [self class], error);
    }
    NSDictionary* skeletonDictionary = [NSJSONSerialization JSONObjectWithData:skelData options:kNilOptions error:&error];
    
    
    // Must be done for every bone until proper tree is sent
    Bone* head = new Bone;
    NSDictionary* currentBone  = [skeletonDictionary objectForKey:@"head"];
    head->l                    = [(NSNumber*)[currentBone objectForKey:@"length"] floatValue];
    head->a                    = [(NSNumber*)[currentBone objectForKey:@"angle"]  floatValue];
    head->w                    = 3.f;
    NSDictionary* headDict     = [currentBone objectForKey:@"head"];
    headLoc.x                  = [(NSNumber*)[headDict objectForKey:@"x"] floatValue];
    headLoc.y                  = [(NSNumber*)[headDict objectForKey:@"y"] floatValue];
    NSDictionary* tailDict     = [currentBone objectForKey:@"tail"];
    tailLoc.x                  = [(NSNumber*)[tailDict objectForKey:@"x"] floatValue];
    tailLoc.y                  = [(NSNumber*)[tailDict objectForKey:@"y"] floatValue];
    averageLoc                 = ccpMult(ccpAdd(tailLoc,headLoc),.5f);
    head->x                    = averageLoc.x;
    head->y                    = averageLoc.y;
    head->jointAngleMax        = jointAngleMax;
    head->jointAngleMin        = jointAngleMin;
    head->jx                   = headLoc.x;
    head->jy                   = headLoc.y;
    
    _skeleton->setRoot(head);
    
    
    
}
-(Bone*)getBoneByName:(NSString*)bName{
    
    return nil;
}
-(Skeleton*)getSkeleton{
    return _skeleton;
}

@end
