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

-(id)initFromFile:(NSString*)fileName{
    if((self = [super init])){
        [self buildSkeletonFromFile:fileName];
    }
    return self;
}

-(void)buildSkeletonFromFile:(NSString*)fileName{
    
    /* Load the data and check for error */
    NSError* error = nil;
    NSData* skelData = [NSData dataWithContentsOfFile:fileName options:kNilOptions error:&error];
    if(error) {
        DebugLog(@"Error when communicating with server (%@): %@", [self class], error);
    }
    NSArray* skeletonDictionary = [NSJSONSerialization JSONObjectWithData:skelData options:kNilOptions error:&error];
    
    
}
-(Bone*)getBoneByName:(NSString*)bName{
    
    return nil;
}
-(Skeleton*)getSkeleton{
    return _skeleton;
}

@end
