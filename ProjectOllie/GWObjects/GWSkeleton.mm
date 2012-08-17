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
#define BTM_RATIO .12* PTM_RATIO
#define MIN_ANGLE -M_PI/5.0
#define MAX_ANGLE M_PI/5.0
#define INTERACTOR_FLAT_RADIUS .0004*PTM_RATIO;

using namespace std;

@interface Interactor()
{
    b2Body* box;
    b2Body* wheel;
    b2Body* comp;
    b2World* _world;
    float box_radius;
    float wheel_radius;
    float interactor_radius;
}

-(void)createPhysicsBodiesAt:(CGPoint)position;

@end

@implementation Interactor

@synthesize state           = _state;
@synthesize interactingBody = _interactingBody;

-(id)initAsBoxAt:(CGPoint)location inWorld:(b2World *)world{
    if((self = [super init])){
        
        _world            = world;
        wheel_radius      = INTERACTOR_FLAT_RADIUS;
        box_radius        = .2 * wheel_radius;
        interactor_radius = box_radius;
        
        [self createPhysicsBodiesAt:ccp(200,200)];
        self.state = kInteractorStateInactive;
    }
    return self;
}

-(id)initAsCircleAt:(CGPoint)location inWorld:(b2World *)world{
    if((self = [super init])){

        _world            = world;
        wheel_radius      = INTERACTOR_FLAT_RADIUS;
        box_radius        = .2 * wheel_radius;
        interactor_radius = wheel_radius;
        
        [self createPhysicsBodiesAt:ccp(200,200)];
        self.state = kInteractorStateActive;
    }
    return self;
}

-(float)getRadius{
    return interactor_radius;
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
    return ccp(positionInPixels.x,positionInPixels.y - [self getRadius]*PTM_RATIO);
}

-(CGPoint)getPosition{
    b2Vec2 position = self.interactingBody->GetPosition();
    return ccp(position.x,position.y);
}

-(void)setPosition:(CGPoint)position{
    self.interactingBody->SetTransform(b2Vec2(position.x,position.y), self.interactingBody->GetAngle());
}

-(b2Body*)getBox{
    return box;
}

-(b2Body*)getWheel{
    return wheel;
}

-(void)setState:(InteractorState)state{
    _state = state;
    if(state == kInteractorStateActive)
    {
        _interactingBody  = wheel;
        interactor_radius = wheel_radius;
    }
    else if (state == kInteractorStateInactive)
    {
        _interactingBody  = box;
        interactor_radius = box_radius;
    }
    else if (state == kInteractorStateRagdoll)
    {
        _interactingBody  = wheel;
        interactor_radius = wheel_radius;
    }
}

-(void)applyLinearImpulse:(CGPoint)impulse{
    self.interactingBody->ApplyLinearImpulse(b2Vec2(impulse.x,impulse.y), self.interactingBody->GetPosition());
}

-(void)setPositionInSkeleton:(Skeleton *)_skeleton{
    Bone* left_leg  = _skeleton->getBoneByName("ll_leg");
    Bone* right_leg = _skeleton->getBoneByName("rl_leg");
    //b2Vec2 highest_left  = _skeleton->highestContact(left_leg, b2Vec2(-100,-100)); 
    //b2Vec2 highest_right = _skeleton->highestContact(right_leg,b2Vec2(-100,-100));
    //float totalLowest    = _skeleton->lowestY(root, 100);
    //float lowestY        = max(totalLowest+radius,self.interactingBody->GetPosition().y);
    [self setAngularVelocity:0];
    b2Vec2 averageLeg    = left_leg->box2DBody->GetPosition() + right_leg->box2DBody->GetPosition();
    averageLeg.x /= 2.;
    averageLeg.y /= 2.;
    self.interactingBody->SetTransform(averageLeg, self.interactingBody->GetAngle());
}

-(void)createPhysicsBodiesAt:(CGPoint)position{
    
    /* Tie to box2d */
    b2BodyDef bd;
    b2FixtureDef fixtureDefWheel;
    b2FixtureDef fixtureDefBox;
    b2FixtureDef fixtureDefWheelComp;
    
    /* Body definition */
    bd.type = b2_dynamicBody;
    bd.gravityScale = 1.;
    bd.linearDamping = .1f;
    bd.angularDamping = .1f;
    
    b2CircleShape wheelShape;
    wheelShape.m_radius = wheel_radius;
    fixtureDefWheel.shape = &wheelShape;

    b2PolygonShape  boxShape;
    boxShape.SetAsBox(box_radius*2.5f,box_radius);
    fixtureDefBox.shape = &boxShape;

    b2PolygonShape wheelComp;
    wheelComp.SetAsBox(wheel_radius, wheel_radius*1.5f);
    fixtureDefWheelComp.shape = &wheelComp;
    
    //The box data
    fixtureDefBox.density = 5.f;
    fixtureDefBox.friction = 10.f;
    fixtureDefBox.restitution = 0.1f;
    fixtureDefBox.filter.categoryBits = CATEGORY_INTERACTOR;
    fixtureDefBox.filter.maskBits = MASK_INTERACTOR;
    
    //The wheel data
    fixtureDefWheel.density = 1.f;
    fixtureDefWheel.friction = 10.f;
    fixtureDefWheel.restitution = 0.1f;
    fixtureDefWheel.filter.categoryBits = CATEGORY_INTERACTOR;
    fixtureDefWheel.filter.maskBits = MASK_INTERACTOR;
    
    //comp data
    fixtureDefWheelComp.density = .11f;
    fixtureDefWheelComp.friction = 0.f;
    fixtureDefWheelComp.restitution = .1f;
    fixtureDefWheelComp.filter.categoryBits = CATEGORY_INTERACTOR;
    fixtureDefWheelComp.filter.maskBits = MASK_INTERACTOR;
    
    bd.position.Set(position.x/PTM_RATIO, position.y/PTM_RATIO);
    wheel = _world->CreateBody(&bd);
    box   = _world->CreateBody(&bd);
    bd.position.Set(position.x/PTM_RATIO, position.y/PTM_RATIO + .15);
    bd.fixedRotation = YES;
    comp  = _world->CreateBody(&bd);
    
    wheel->CreateFixture(&fixtureDefWheel);
    comp->CreateFixture(&fixtureDefWheelComp);
    b2RevoluteJointDef jointDef;
    
    jointDef.enableLimit = false;
    jointDef.Initialize(comp, wheel, wheel->GetPosition());
    _world->CreateJoint(&jointDef);

    
    box->CreateFixture(&fixtureDefBox);
    
}

-(void)update{
    if(self.state == kInteractorStateActive)
    {
        box->SetTransform(wheel->GetPosition()-b2Vec2(0,wheel_radius-box_radius), [self calculateNormalAngle]);
        box->SetLinearVelocity(wheel->GetLinearVelocity());
    }
    else if (self.state == kInteractorStateInactive)
    {
        box->SetAwake(YES);
        wheel->SetTransform(box->GetPosition(), wheel->GetAngle());
        wheel->SetLinearVelocity(box->GetLinearVelocity());
    }
    else if(self.state == kInteractorStateRagdoll)
    {
        wheel->SetAngularVelocity(0);
        box->SetTransform(wheel->GetPosition()-b2Vec2(0,wheel_radius-box_radius), [self calculateNormalAngle]);
        box->SetLinearVelocity(wheel->GetLinearVelocity());
    }
}

-(float)calculateNormalAngle{
    
    for (b2ContactEdge* ce = self.interactingBody->GetContactList(); ce; ce = ce->next)
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
            float potentialDestination = angle - M_PI/2.0;
            return min(max(potentialDestination,MIN_ANGLE),MAX_ANGLE);
        }
        
    }
    return 0;

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
    
    //to check resting state
    float restingCounter;
    float restingUpdates;
    float rollingAvgSpeed;
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

//Creates linear animation tween for starting animations
-(void)tweenBonesToAnimation:(string)name forBone:(Bone*)root withDuration:(float)duration;

//Creates single frame for animating to aim position
-(void)createFrameAnimation:(string)name forBone:(Bone*)root atFrame:(int)frameNum;

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
        
        // check resting state
        restingCounter   = 0;
        restingUpdates   = 0;
        rollingAvgSpeed  = 0;

    }
    return self;
}

-(Bone*)getBoneByName:(NSString*)bName{
    string name = string([bName UTF8String]);
    return _skeleton->getBoneByName(name);
}

-(void)runAnimation:(NSString*)animationName flipped:(bool)flipped{
    string name = [animationName UTF8String];
    _skeleton->runAnimation(name,flipped);
}

-(void)runAnimation:(NSString*)animationName WithTweenTime:(float)duration flipped:(bool)flipped
{
    string name = [animationName UTF8String];
    if(duration > 0)
    {
        _skeleton->deleteAnimation("tween");
        [self tweenBonesToAnimation:name forBone:_skeleton->getRoot() withDuration:duration];
        _skeleton->runAnimation("tween", NO);
    }
    _skeleton->runAnimation(name, flipped);
}

-(void)runFrame:(int)frameNum ofAnimation:(NSString *)animName flipped:(bool)flipped{
    string name = [animName UTF8String];
    [self clearAnimation];
    _skeleton->deleteAnimation("frame_position");
    [self createFrameAnimation:name forBone:_skeleton->getRoot() atFrame:frameNum];
    _skeleton->runAnimation("frame_position", flipped);
}

-(void)clearAnimation{
    timeElapsed = 0;
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
    if(self.animating = (_skeleton->animating(_skeleton->getRoot(), timeElapsed)))
    {   
        timeElapsed += dt;
        [self orientToGround];
    }
    else
    {
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
    if(self.interactor.state != kInteractorStateRagdoll)
        [self.interactor setLinearVelocity:vel];
    else 
        _skeleton->setLinearVelocity(_skeleton->getRoot(), b2Vec2(vel.x,vel.y));
}

-(CGPoint)getVelocity{
    
    CGPoint toRet = CGPointZero;
    if(self.interactor.state != kInteractorStateRagdoll)
        toRet = [self.interactor getLinearVelocity];
    else 
    {
        b2Vec2 vel = _skeleton->getRoot()->box2DBody->GetLinearVelocity();
        toRet      = ccp(vel.x,vel.y); 
    }
    
    return toRet;
}

-(float)getAngle{
    return destinationAngle;
}

-(void)tieSkeletonToInteractor:(float)dt{
    //_skeleton->setPosition(_skeleton->getRoot(), absoluteLocation.x, absoluteLocation.y);
    _skeleton->adjustPosition(_skeleton->getRoot(),absoluteLocation.x,absoluteLocation.y, dt);
}

-(void)setActive:(bool)active{
    _skeleton->setActive(_skeleton->getRoot(), active);
}

-(bool)resting:(float)dt{
    
    if(self.interactor.state == kInteractorStateRagdoll)
    {
        restingCounter  += dt;
        restingUpdates  ++;
        rollingAvgSpeed += ccpLength([self getVelocity]);
        
        if(restingCounter >= 1)
        {
            float avg = rollingAvgSpeed/restingUpdates;
            restingCounter  = 0;
            restingUpdates  = 0;
            rollingAvgSpeed = 0;
            if(avg <= .06)
                return true;

        }
    }
    return false;
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
        bone->z             = [(NSNumber*)[currentBone objectForKey:@"z"] intValue];
        
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
            headLoc                = ccpMult(headLoc,BTM_RATIO);
            tailLoc                = ccpMult(tailLoc,BTM_RATIO);
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

-(void)tweenBonesToAnimation:(string)name forBone:(Bone *)root withDuration:(float)duration
{
    std::map<string, std::map<string,Animation*> > animations = _skeleton->getAnimationMap();
    Animation* animation = animations[name][root->name];
    if(animation)
    {
        KeyFrame* initialFrame = animation->frames[0];
        float destinationX     = initialFrame->x;
        float destinationY     = initialFrame->y;
        float destinationA     = initialFrame->angle;
        
        float currentX         = root->box2DBody->GetPosition().x*PTM_RATIO - _skeleton->getX()*PTM_RATIO;
        float currentY         = root->box2DBody->GetPosition().y*PTM_RATIO - _skeleton->getY()*PTM_RATIO;
        float currentA         = root->box2DBody->GetAngle();
        float numFrames        = duration*FPS;
        float diffA            = (destinationA - currentA);
        
        while(abs(diffA) > M_PI)
        {
            if(diffA > 0)
                diffA = M_PI * 2. - diffA;
            else
                diffA = M_PI * 2. + diffA;
        }
        
        float tweenX           = (destinationX - currentX)/numFrames;
        float tweenY           = (destinationY - currentY)/numFrames;
        float tweenA           = diffA/numFrames;
        
        for(int i = 0; i < (int)numFrames; i++)
        {
            KeyFrame* tweenFrame = new KeyFrame;
            tweenFrame->x        = currentX + tweenX*(i+1);
            tweenFrame->y        = currentY + tweenY*(i+1);
            tweenFrame->angle    = currentA + tweenA*(i+1);
            tweenFrame->time     = duration/numFrames * (float)i;
            _skeleton->addAnimationFrame("tween", root->name, tweenFrame);
        }

        //For every bone!
        for(int i = 0; i < root->children.size(); i++)
            [self tweenBonesToAnimation:name forBone:root->children.at(i) withDuration:duration];
    }
}

-(void)createFrameAnimation:(string)name forBone:(Bone *)root atFrame:(int)frameNum{
    std::map<string, std::map<string,Animation*> > animations = _skeleton->getAnimationMap();
    Animation* animation = animations[name][root->name];
    if(animation)
    {
        frameNum = min(frameNum,animation->frames.size()-1);
        KeyFrame* target_frame = animation->frames[frameNum];
        KeyFrame* angle_frame  = new KeyFrame;
        angle_frame->x     = target_frame->x;
        angle_frame->y     = target_frame->y;
        angle_frame->angle = target_frame->angle;
        angle_frame->time  = 0;
        _skeleton->addAnimationFrame("frame_position", root->name, angle_frame);
        
        //For every bone!
        for(int i = 0; i < root->children.size(); i++)
            [self createFrameAnimation:name forBone:root->children.at(i) atFrame:frameNum];
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
            float potentialDestination = angle - M_PI/2.0;
            destinationAngle =  min(max(potentialDestination,MIN_ANGLE),MAX_ANGLE);
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

-(void)setOwner:(id)owner{
    // set user data for collisions
    _skeleton->setUserData(_skeleton->getRoot(), (__bridge void*)owner);
}

@end
