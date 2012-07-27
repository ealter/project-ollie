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

//BLENDER TO PIXEL RATIO
#define BTP_RATIO 7.0

using namespace std;

@interface Interactor()
{
    float radius;
    b2Body* box;
    b2Body* wheel;
    b2World* _world;
}

-(void)createPhysicsBodiesAt:(CGPoint)position;

@end

@implementation Interactor

@synthesize state           = _state;
@synthesize interactingBody = _interactingBody;

-(id)initAsBoxAt:(CGPoint)location inWorld:(b2World *)world{
    if((self = [super init])){
        radius = .01*BTP_RATIO;
        _world = world;
        [self createPhysicsBodiesAt:ccp(200,200)];
        self.state = kInteractorStateInactive;
    }
    return self;
}

-(id)initAsCircleAt:(CGPoint)location inWorld:(b2World *)world{
    if((self = [super init])){
        radius =  .01*BTP_RATIO;
        _world = world;
        [self createPhysicsBodiesAt:ccp(200,200)];
        self.state = kInteractorStateActive;
    }
    return self;
}

-(CGPoint)getLinearVelocity{
    b2Vec2 vel = self.interactingBody->GetLinearVelocity();
    return ccp(vel.x,vel.y);
}

-(void)setLinearVelocity:(CGPoint)lv{
    self.interactingBody->SetLinearVelocity(b2Vec2(lv.x,lv.y));
}

-(float)getAngularVelocity{
    return self.interactingBody->GetAngularVelocity();
}

-(void)setAngularVelocity:(float)av{
    self.interactingBody->SetAngularVelocity(av);
}

-(CGPoint)getAbsolutePosition{
    
    CGPoint positionInPixels = ccpMult([self getPosition],PTM_RATIO);
    return ccp(positionInPixels.x,positionInPixels.y - radius*PTM_RATIO);
}

-(CGPoint)getPosition{
    b2Vec2 position = self.interactingBody->GetPosition();
    return ccp(position.x,position.y);
}

-(void)setPosition:(CGPoint)position{
    self.interactingBody->SetTransform(b2Vec2(position.x,position.y), self.interactingBody->GetAngle());
}

-(void)setState:(InteractorState)state{
    _state = state;
    if(state == kInteractorStateActive)
    {
        _interactingBody = wheel;
        box->SetActive(NO);
        wheel->SetActive(YES);
    }
    else if (state == kInteractorStateInactive)
    {
        _interactingBody = box;
        box->SetActive(YES);
        wheel->SetActive(NO);
    }
    else if (state == kInteractorStateRagdoll)
    {
        _interactingBody = wheel;
        wheel->SetActive(YES);
        box->SetActive(NO);
    }
}

-(void)applyLinearImpulse:(CGPoint)impulse{
    self.interactingBody->ApplyLinearImpulse(b2Vec2(impulse.x,impulse.y), self.interactingBody->GetPosition());
}

-(void)setPositionInSkeleton:(Skeleton *)_skeleton{
    Bone* root      = _skeleton->getRoot();
    Bone* torso     = _skeleton->getBoneByName(root, "Torso");
    Bone* left_leg  = _skeleton->getBoneByName(root, "ll_leg");
    Bone* right_leg = _skeleton->getBoneByName(root, "rl_leg");
    b2Vec2 highest_left  = _skeleton->highestContact(left_leg, b2Vec2(-100,-100)); 
    b2Vec2 highest_right = _skeleton->highestContact(right_leg,b2Vec2(-100,-100));
    float totalLowest    = _skeleton->lowestY(root, 100);
    float lowestY        = max(totalLowest+radius,self.interactingBody->GetPosition().y);
    [self setAngularVelocity:0];
    self.interactingBody->SetTransform(b2Vec2(torso->box2DBody->GetPosition().x,lowestY), self.interactingBody->GetAngle());
}

-(void)createPhysicsBodiesAt:(CGPoint)position{
    
    /* Tie to box2d */
    b2BodyDef bd;
    b2FixtureDef fixtureDefWheel;
    b2FixtureDef fixtureDefBox;
    
    /* Body definition */
    bd.type = b2_dynamicBody;
    bd.gravityScale = 1.;
    bd.linearDamping = .1f;
    bd.angularDamping = .1f;
    
    b2CircleShape wheelShape;
    wheelShape.m_radius = radius;
    fixtureDefWheel.shape = &wheelShape;

    b2PolygonShape  boxShape;
    boxShape.SetAsBox(radius, radius);
    fixtureDefBox.shape = &boxShape;
    
    fixtureDefBox.density = 1.f;
    fixtureDefBox.friction = 10.f;
    fixtureDefBox.restitution = 0.1f;
    fixtureDefBox.filter.categoryBits = CATEGORY_BONES;
    fixtureDefBox.filter.maskBits = MASK_BONES;
    
    fixtureDefWheel.density = 1.f;
    fixtureDefWheel.friction = 10.f;
    fixtureDefWheel.restitution = 0.1f;
    fixtureDefWheel.filter.categoryBits = CATEGORY_BONES;
    fixtureDefWheel.filter.maskBits = MASK_BONES;
    
    bd.position.Set(position.x/PTM_RATIO, position.y/PTM_RATIO);
    wheel = _world->CreateBody(&bd);
    box   = _world->CreateBody(&bd);
    
    wheel->CreateFixture(&fixtureDefWheel);
    box->CreateFixture(&fixtureDefBox);
    
}

-(void)update{
    if(self.state == kInteractorStateActive)
    {
        box->SetTransform(wheel->GetPosition(), box->GetAngle());
        box->SetLinearVelocity(wheel->GetLinearVelocity());
    }
    else if (self.state == kInteractorStateInactive)
    {
        wheel->SetTransform(box->GetPosition(), wheel->GetAngle());
        wheel->SetLinearVelocity(box->GetLinearVelocity());
    }
    else if(self.state == kInteractorStateRagdoll)
    {
        box->SetTransform(wheel->GetPosition(), box->GetAngle());
        box->SetLinearVelocity(wheel->GetLinearVelocity());
    }
        
}

@end

static inline CGPoint dictionaryToCGPoint(NSDictionary *dict) {
    CGPoint p;
    p.x = [(NSNumber*)[dict objectForKey:@"x"] floatValue];
    p.y = [(NSNumber*)[dict objectForKey:@"y"] floatValue];
    return p;
}

@interface GWSkeleton(){
    float timeElapsed;
    CGPoint absoluteLocation; 
    float destinationAngle;
    b2Fixture* _shape;
    b2World* _world;
}
//Master function for loading file information for skeleton (.skel) files
-(void)buildSkeleton;

//Recursive helper function for building tree of bones
-(void)assembleSkeleton:(NSArray*)currentBoneArray parentBone:(Bone*)parent;

//Master function for loading file information for animation (.anim) files
-(void)buildAnimationFromFile:(NSString*)filePath animationName:(NSString*)animationName;

//Helper function for attaching animations to bones
-(void)assembleAnimation:(NSArray*)frames animationName:(NSString*)animName;

//Adjusts skeleton's angle to ground body
-(void)orientToGround;

@end

@implementation GWSkeleton

@synthesize animating  = _animating;
@synthesize interactor = _interactor;

-(id)initFromFile:(NSString*)fileName box2dWorld:(b2World *)world{
    if((self = [super init])){
        timeElapsed      = 0;
        absoluteLocation = ccp(200.0,200.0);
        _skeleton        = new Skeleton(world);
        _world           = world;
        skeletonName     = fileName;
        destinationAngle = 0;
        [self buildSkeleton];
        self.animating   = false;
        self.interactor  = [[Interactor alloc]initAsBoxAt:absoluteLocation inWorld:world];
    }
    return self;
}

-(Bone*)getBoneByName:(NSString*)bName{
    string name = string([bName UTF8String]);
    return _skeleton->getBoneByName(_skeleton->getRoot(), name);
}

-(void)runAnimation:(NSString*)animationName flipped:(bool)flipped{
    string name = [animationName UTF8String];
    _skeleton->runAnimation(name,flipped);
}

-(void)clearAnimation{
    _skeleton->clearAnimationQueue(_skeleton->getRoot());
}

-(void)loadAnimations:(NSArray *)animationNames{
    
    NSString* filePath;
    for (NSString* animationName in animationNames) {
        
        NSString* pathForResource = [NSString stringWithFormat:@"%@%@%@",skeletonName,@"_",animationName];
        filePath           = [[NSBundle mainBundle] pathForResource:pathForResource ofType:@"anim"];
        [self buildAnimationFromFile:filePath animationName:animationName];
    }
}

-(void)update:(float)dt{
    [self.interactor update];
    absoluteLocation = [self.interactor getAbsolutePosition];
    if((self.animating = _skeleton->animating(_skeleton->getRoot(), timeElapsed)))
    {   
        timeElapsed += dt;
        _skeleton->setPosition(_skeleton->getRoot(), absoluteLocation.x, absoluteLocation.y);
        [self orientToGround];
    }
    else{
        if(timeElapsed!=0)
        {
            timeElapsed = 0;
        }
        _skeleton->update();
    }
}

-(void)applyLinearImpulse:(CGPoint)impulse
{
    [self.interactor applyLinearImpulse:impulse];
}

-(void)setVelocity:(CGPoint)vel{
    [self.interactor setLinearVelocity:vel];
}

-(CGPoint)getVelocity{
    
    b2Vec2 velocity = _skeleton->getRoot()->box2DBody->GetLinearVelocity();
    CGPoint toRet   = ccp(velocity.x,velocity.y);
    if(self.animating)
        toRet = [self.interactor getLinearVelocity];
    
    return toRet;
}

/*****************************
 ***** PRIVATE FUNCTIONS *****
 *****************************/

-(void)buildSkeleton{
    /* Load the data and check for error */
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:skeletonName ofType:@"skel"];
    
    NSError* error = nil;
    DebugLog(@"The file is %@", skeletonName);
    NSData* skelData = [NSData dataWithContentsOfFile:filePath options:kNilOptions error:&error];
    if(error) {
        DebugLog(@"Error reading character file (%@): %@", [self class], error);
    }
    NSArray *skeletonArray = [[[NSString alloc] initWithData:skelData encoding:NSUTF8StringEncoding] JSONValue];
    if(!skeletonArray) {
        DebugLog(@"Error creating array from file (%@)", skeletonName);
    }
    
    [self assembleSkeleton:skeletonArray parentBone:nil];
    _skeleton->setPosition(_skeleton->getRoot(), absoluteLocation.x, absoluteLocation.y);
}

/* recursively assembles the bone tree imported from blender*/
-(void)assembleSkeleton:(NSArray *)currentBoneArray parentBone:(Bone *)parent{
    float jointAngleMax =  DEG2RAD(45.0);
    float jointAngleMin = -DEG2RAD(30.0);
    
    for (NSDictionary* currentBone in currentBoneArray) {
        Bone* bone          = new Bone;
        
        CGPoint headLoc     = dictionaryToCGPoint([currentBone objectForKey:@"head"]);
        CGPoint tailLoc     = dictionaryToCGPoint([currentBone objectForKey:@"tail"]);
        
        //transform to screen coordinates
        headLoc             = ccpMult(headLoc,BTP_RATIO);
        tailLoc             = ccpMult(tailLoc,BTP_RATIO);
        CGPoint averageLoc  = ccpMult(ccpAdd(tailLoc,headLoc),.5f);
        
        //assign values to bone
        bone->x             = averageLoc.x;
        bone->y             = averageLoc.y;
        bone->jointAngleMax = jointAngleMax;
        bone->jointAngleMin = jointAngleMin;
        bone->jx            = headLoc.x;
        bone->jy            = headLoc.y;
        bone->name          = string([[currentBone objectForKey:@"name"] UTF8String]);
        bone->l             = [(NSNumber*)[currentBone objectForKey:@"length"] floatValue]*BTP_RATIO;
        bone->a             = [(NSNumber*)[currentBone objectForKey:@"angle"]  floatValue];
        bone->w             = [(NSNumber*)[currentBone objectForKey:@"width"]  floatValue]*BTP_RATIO;
        
        _skeleton->boneAddChild(parent, bone);
        
        NSArray* children   = [currentBone objectForKey:@"children"];
        [self assembleSkeleton:children parentBone:bone];
    }
}

-(void)buildAnimationFromFile:(NSString *)filePath animationName:(NSString *)animationName{
    
    NSError* error = nil;
    NSData* animData = [NSData dataWithContentsOfFile:filePath options:kNilOptions error:&error];
    if(error) {
        DebugLog(@"Error reading animation file (%@): %@", [self class], error);
    }
    NSArray *animArray = [[[NSString alloc] initWithData:animData encoding:NSUTF8StringEncoding] JSONValue];
    if(error) {
        DebugLog(@"Error creating array from file (%@): %@", [self class], error);
    }
    [self assembleAnimation:animArray animationName:animationName];

}

-(void)assembleAnimation:(NSArray *)frames animationName:(NSString*)animName{
    
    string animationName = [animName UTF8String];
    for (NSDictionary* frame in frames) {
        
        //get universal frame data
        float time     = [(NSNumber*)[frame objectForKey:@"time"] floatValue];
        NSArray* bones = [frame objectForKey:@"bones"];
        
        for (NSDictionary* bone in bones) {
            
            //get bone specific values
            KeyFrame* key   = new KeyFrame;
            string name = [(NSString*)[bone objectForKey:@"name"] UTF8String];
            float angle = [(NSNumber*)[bone objectForKey:@"angle"] floatValue];
            CGPoint headLoc = dictionaryToCGPoint([bone objectForKey:@"head"]);
            CGPoint tailLoc = dictionaryToCGPoint([bone objectForKey:@"tail"]);
            
            //transform to screen coordinates
            headLoc                = ccpMult(headLoc,BTP_RATIO);
            tailLoc                = ccpMult(tailLoc,BTP_RATIO);
            CGPoint averageLoc     = ccpMult(ccpAdd(tailLoc,headLoc),.5f);
            
            //assign bone specific values
            key->angle      = angle;
            key->time       = time;
            key->x          = averageLoc.x;
            key->y          = averageLoc.y;

            //adds the animation frame to the given animation name
            _skeleton->addAnimationFrame(animationName, name, key);
        }
    }
}

-(bool)calculateNormalAngle{

    for (b2ContactEdge* ce = self.interactor.interactingBody->GetContactList(); ce; ce = ce->next)
    {
        b2Contact* c = ce->contact;
        b2WorldManifold manifold;
        c->GetWorldManifold(&manifold);
        if(c->IsTouching())
        {
            CGPoint normal = ccp(manifold.normal.x, manifold.normal.y);
            normal = ccpNormalize(normal);
            //DebugLog(@"The contact normal has an x: %f and a y: %f",normal.x,normal.y);
            float angle = atan2(normal.y,normal.x);
            //DebugLog(@"The contact normal has an angle of: %f",RAD2DEG(angle));
            destinationAngle = angle - M_PI/2.0;
            return YES;
        }

    }
    return NO;
}

-(void)orientToGround{
    float angle = _skeleton->getAngle();
    [self calculateNormalAngle];
    if(angle > destinationAngle)
        angle -= (angle - destinationAngle)*.15f;
    else if(angle < destinationAngle)
        angle += (destinationAngle - angle)*.15f;
    _skeleton->setAngle(angle);
}

-(void)setInteractorPositionInRagdoll{
    [self.interactor setPositionInSkeleton:_skeleton];
}

@end
