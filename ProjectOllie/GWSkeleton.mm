//
//  GWSkeleton.m
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 7/10/12.
//  Copyright 2012 hi ku llc. All rights reserved.
//

#import "GWSkeleton.h"
#import "Skeleton.h"
#import "GameConstants.h"
#import "cocos2d.h"
#import "Box2D.h"
#import "NSString+SBJSON.h"

//BLENDER TO METER RATIO
#define BTM_RATIO 7.0

using namespace std;

static inline CGPoint dictionaryToCGPoint(NSDictionary *dict) {
    CGPoint p;
    p.x = [(NSNumber*)[dict objectForKey:@"x"] floatValue];
    p.y = [(NSNumber*)[dict objectForKey:@"y"] floatValue];
    return p;
}

@interface GWSkeleton(){
    float timeElapsed;
    CGPoint absoluteLocation; 
    b2Body* _interactor;
    b2World* _world;
}
//Master function for loading file information for skeleton (.skel) files
-(void)buildSkeletonFromFile:(NSString*)fileName;

//Recursive helper function for building tree of bones
-(void)assembleSkeleton:(NSArray*)currentBoneArray parentBone:(Bone*)parent;

//Master function for loading file information for animation (.anim) files
-(void)buildAnimationFromFile:(NSString*)fileName;

//Helper function for attaching animations to bones
-(void)assembleAnimation:(NSArray*)frames;

//Create body that interacts with world when not in ragdoll mode
-(void)buildInteractor;

@end

@implementation GWSkeleton

-(id)initFromFile:(NSString*)fileName box2dWorld:(b2World *)world{
    if((self = [super init])){
        timeElapsed = 0;
        absoluteLocation = ccp(200.0,200.0);
        _skeleton   = new Skeleton(world);
        _world      = world;
        
        NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"skel"];
        DebugLog(@"The filepath for filename %@ is %@", fileName, filePath);
        [self buildSkeletonFromFile:filePath];
        
        //if the above worked...
        if(_skeleton->getRoot()) {
            filePath           = [[NSBundle mainBundle] pathForResource:fileName ofType:@"anim"];
            [self buildAnimationFromFile:filePath];
        } else {
            CCLOG(@"ERROR BUILDING SKELETONS. ABANDON ALL HOPE!");
        }
    }
    return self;
}

-(void)buildSkeletonFromFile:(NSString*)fileName{
    /* Load the data and check for error */
    NSError* error = nil;
    DebugLog(@"The file is %@", fileName);
    NSData* skelData = [NSData dataWithContentsOfFile:fileName options:kNilOptions error:&error];
    if(error) {
        DebugLog(@"Error reading character file (%@): %@", [self class], error);
    }
    NSArray *skeletonArray = [[[NSString alloc] initWithData:skelData encoding:NSUTF8StringEncoding] JSONValue];
    if(!skeletonArray) {
        DebugLog(@"Error creating array from file (%@)", fileName);
    }
    
    [self assembleSkeleton:skeletonArray parentBone:nil];
    _skeleton->setPosition(_skeleton->getRoot(), absoluteLocation.x, absoluteLocation.y);
    [self buildInteractor];
}

/* recursively assembles the bone tree imported from blender*/
-(void)assembleSkeleton:(NSArray *)currentBoneArray parentBone:(Bone *)parent{
    float jointAngleMax = DEG2RAD(45.0);
    float jointAngleMin = -DEG2RAD(30.0);
    
    for (NSDictionary* currentBone in currentBoneArray) {
        Bone* bone          = new Bone;
        
        CGPoint headLoc     = dictionaryToCGPoint([currentBone objectForKey:@"head"]);
        CGPoint tailLoc     = dictionaryToCGPoint([currentBone objectForKey:@"tail"]);
        
        //transform to screen coordinates
        headLoc             = ccpMult(headLoc,BTM_RATIO);
        tailLoc             = ccpMult(tailLoc,BTM_RATIO);
        CGPoint averageLoc  = ccpMult(ccpAdd(tailLoc,headLoc),.5f);
        
        //assign values to bone
        bone->x             = averageLoc.x;
        bone->y             = averageLoc.y;
        bone->jointAngleMax = jointAngleMax;
        bone->jointAngleMin = jointAngleMin;
        bone->jx            = headLoc.x;
        bone->jy            = headLoc.y;
        bone->name          = string([[currentBone objectForKey:@"name"] UTF8String]);
        bone->l             = [(NSNumber*)[currentBone objectForKey:@"length"] floatValue]*BTM_RATIO;
        bone->a             = [(NSNumber*)[currentBone objectForKey:@"angle"]  floatValue];
        bone->w             = [(NSNumber*)[currentBone objectForKey:@"width"]  floatValue]*BTM_RATIO;
        
        _skeleton->boneAddChild(parent, bone);
        
        NSArray* children   = [currentBone objectForKey:@"children"];
        [self assembleSkeleton:children parentBone:bone];
    }
}

-(void)buildAnimationFromFile:(NSString *)fileName{
    
    NSError* error = nil;
    NSData* animData = [NSData dataWithContentsOfFile:fileName options:kNilOptions error:&error];
    if(error) {
        DebugLog(@"Error reading animation file (%@): %@", [self class], error);
    }
    NSArray *animArray = [[[NSString alloc] initWithData:animData encoding:NSUTF8StringEncoding] JSONValue];
    if(error) {
        DebugLog(@"Error creating array from file (%@): %@", [self class], error);
    }
    [self assembleAnimation:animArray];

}

-(void)assembleAnimation:(NSArray *)frames{
    
    CGPoint headLoc;
    CGPoint tailLoc;
    CGPoint averageLoc;
    for (NSDictionary* frame in frames) {
        
        //get universal frame data
        float time     = [(NSNumber*)[frame objectForKey:@"time"] floatValue];
        //float frameCount     = [(NSNumber*)[frame objectForKey:@"framecount"] floatValue];
        NSArray* bones = [frame objectForKey:@"bones"];
        
        for (NSDictionary* bone in bones) {
            
            //get bone specific values
            KeyFrame* key   = new KeyFrame;
            string name = [(NSString*)[bone objectForKey:@"name"] UTF8String];
            float angle = [(NSNumber*)[bone objectForKey:@"angle"] floatValue];
            NSDictionary* headDict = [bone objectForKey:@"head"];
            headLoc.x              = [(NSNumber*)[headDict objectForKey:@"x"] floatValue];
            headLoc.y              = [(NSNumber*)[headDict objectForKey:@"y"] floatValue];
            NSDictionary* tailDict = [bone objectForKey:@"tail"];
            tailLoc.x              = [(NSNumber*)[tailDict objectForKey:@"x"] floatValue];
            tailLoc.y              = [(NSNumber*)[tailDict objectForKey:@"y"] floatValue];
            
            //transform to screen coordinates
            headLoc                = ccpMult(headLoc,BTM_RATIO);
            tailLoc                = ccpMult(tailLoc,BTM_RATIO);
            averageLoc             = ccpMult(ccpAdd(tailLoc,headLoc),.5f);
            
            //assign bone specific values
            key->angle = angle;
            key->time  = time;
            key->x     = averageLoc.x;
            key->y     = averageLoc.y;
            
            //adds the animation frame to the given animation name
            _skeleton->addAnimationFrame("animation", name, key);
        }
    }
}

-(Bone*)getBoneByName:(NSString*)bName{
    string name = string([bName UTF8String]);
    return _skeleton->getBoneByName(_skeleton->getRoot(), name);
}

-(Skeleton*)getSkeleton{
    return _skeleton;
}

-(void)loadAnimation:(string)animationName{
    timeElapsed = 0;
    _skeleton->loadAnimation(animationName);
}

-(void)buildInteractor{
    
    /* Tie to box2d */
    b2BodyDef bd;
    b2CircleShape wheel;
    b2FixtureDef fixtureDef;
    b2RevoluteJointDef jointDef;
    
    /* Body definition */
    bd.type = b2_dynamicBody;
    bd.gravityScale = 1.;
    bd.linearDamping = .1f;
    bd.angularDamping = .1f;
    
    wheel.m_radius = .05;
    fixtureDef.shape = &wheel;
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 1.f;
    fixtureDef.restitution = 0.1f;
    fixtureDef.filter.categoryBits = CATEGORY_BONES;
    fixtureDef.filter.maskBits = MASK_BONES;
    bd.position.Set(absoluteLocation.x/PTM_RATIO, absoluteLocation.y/PTM_RATIO);
    b2Body *boneShape = _world->CreateBody(&bd);
    boneShape->CreateFixture(&fixtureDef);
    
    _interactor = boneShape;
    _interactor->SetTransform(b2Vec2(absoluteLocation.x/PTM_RATIO, absoluteLocation.y/PTM_RATIO),0);
}

-(void)update:(float)dt{
    
    absoluteLocation = ccp(_interactor->GetPosition().x*PTM_RATIO, _interactor->GetPosition().y*PTM_RATIO);
    if(_skeleton->animating(_skeleton->getRoot(), timeElapsed))
    {
        timeElapsed += dt;
        _skeleton->setPosition(_skeleton->getRoot(), absoluteLocation.x, absoluteLocation.y);
    }
    else{
        timeElapsed = 0;
        _skeleton->update();
        _interactor->SetTransform(_skeleton->getRoot()->box2DBody->GetPosition(), _interactor->GetAngle());
    }
    

}

@end
