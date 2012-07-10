//
//  ActionLayer.m
//  ProjectOllie
//
//  Created by Sam Zeckendorf on 6/1/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import "ActionLayer.h"
#import "AppDelegate.h"
#import "PhysicsSprite.h"
#import "Background.h"
#import "MaskedSprite.h"
#import "RippleEffect.h"
#import "GameConstants.h"

#define kTagPoly 10
#define kTagBox 20

enum {
	kTagParentNode = 1,
};

@interface ActionLayer()
{

}
-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) addNewStaticBodyAtPosition:(CGPoint)p;
-(void) handleOneFingerMotion:(NSSet *)touches;
-(void) handleTwoFingerMotion:(NSSet *)touches;


@end

@implementation ActionLayer

@synthesize camera           = _camera;


+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];
    
    // 'layer' is an autorelease object.
    ActionLayer *layer = [ActionLayer node];

    // add layer as a child to scene
    [scene addChild: layer];

    // return the scene
    return scene;
}

-(id) init
{
    if( (self=[super init])) {

        self.contentSize = CGSizeMake(self.contentSize.width,self.contentSize.height);
        //set up screen parameters
        self.anchorPoint = ccp(0,0);
        [self setIgnoreAnchorPointForPosition:YES];
        
        //keep track of camera motion
        self.camera = [[GWCamera alloc] initWithSubject:self worldDimensions:self.contentSize];

        // enable events
        self.isTouchEnabled = YES;
        self.isAccelerometerEnabled = NO;

        // init physics
        [self initPhysics];
        
        //Set up sprite
#if 1
        // Use batch node. Faster
        CCSpriteBatchNode *parent = [CCSpriteBatchNode batchNodeWithFile:@"blocks.png" capacity:100];
        spriteTexture_ = [parent texture];
#else
        // doesn't use batch node. Slower
        spriteTexture_ = [[CCTextureCache sharedTextureCache] addImage:@"blocks.png"];
        CCNode *parent = [CCNode node];
#endif
        [self addChild:parent z:0 tag:kTagParentNode];
        
        [self addNewStaticBodyAtPosition:ccp(self.contentSize.width/2, self.contentSize.height/2)];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap screen" fontName:@"Marker Felt" fontSize:32];
        [self addChild:label z:0];
        [label setColor:ccc3(0,0,255)];
        label.position = ccp( self.contentSize.width/2, self.contentSize.height-50);
        
        [self scheduleUpdate];

        
        
    }
    return self;
}


-(void) dealloc
{
    delete world;
    world = NULL;

    delete m_debugDraw;
    m_debugDraw = NULL;
}	

-(void) initPhysics
{

    b2Vec2 gravity;
    gravity.Set(0.0f, -10.0f);
    world = new b2World(gravity);


    // Do we want to let bodies sleep?
    world->SetAllowSleeping(true);

    world->SetContinuousPhysics(true);

    m_debugDraw = new GLESDebugDraw( PTM_RATIO );
    world->SetDebugDraw(m_debugDraw);

    uint32 flags = 0;
    flags += b2Draw::e_shapeBit;
    //		flags += b2Draw::e_jointBit;
    //		flags += b2Draw::e_aabbBit;
    //		flags += b2Draw::e_pairBit;
    //		flags += b2Draw::e_centerOfMassBit;
    m_debugDraw->SetFlags(flags);		


    // Define the ground body.
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0); // bottom-left corner

    // Call the body factory which allocates memory for the ground body
    // from a pool and creates the ground box shape (also from a pool).
    // The body is also added to the world.
    b2Body* groundBody = world->CreateBody(&groundBodyDef);
    
    // Define the shape for our static body.
    b2ChainShape dynamicBox;
    b2Vec2 vs[4];
    vs[0].Set(0,0);
    vs[1].Set(self.contentSize.width/PTM_RATIO,0);
    vs[2].Set(self.contentSize.width/PTM_RATIO,self.contentSize.height/PTM_RATIO);
    vs[3].Set(0,self.contentSize.height/PTM_RATIO);
    dynamicBox.CreateLoop(vs, 4);
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicBox;	
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    groundBody->CreateFixture(&fixtureDef);
}

-(void) draw
{
    //
    // IMPORTANT:
    // This is only for debug purposes
    // It is recommend to disable it
    //
    [super draw];
    
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );

    kmGLPushMatrix();

    world->DrawDebugData();	

    kmGLPopMatrix();
}

-(void) addNewStaticBodyAtPosition:(CGPoint)p
{
    CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
#if 0
    CCNode *parent = [self getChildByTag:kTagParentNode];

    //We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
    //just randomly picking one of the images
    int idx = (CCRANDOM_0_1() > .5 ? 0:1);
    int idy = (CCRANDOM_0_1() > .5 ? 0:1);
#endif
   // PhysicsSprite *sprite = [PhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(16 * idx,16 * idy,16,16)];					
	
    /**
     * With the debug drawing features we have, bodies draw themselves.
     */
    
    // [parent addChild:sprite];
    // Will eventually make this a piece of terrain

    // sprite.position = ccp( p.x, p.y); //cocos2d point

    // Define the static body.
    // Set up a 1m squared box in the physics world
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    b2Body *body = world->CreateBody(&bodyDef);

    // Define another box shape for our static body.
    //b2PolygonShape staticBox;
    //dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
    b2ChainShape dynamicBox;
    b2Vec2 vs[4];
    vs[0].Set(1.7f,0);
    vs[1].Set(0,1.7f);
    vs[2].Set(0,0);
    vs[3].Set(.24f,.24f);
    dynamicBox.CreateLoop(vs, 4);
    
    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicBox;	
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    body->CreateFixture(&fixtureDef);

}

-(void) addNewSpriteAtPosition:(CGPoint)p
{
    CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
    CCNode *parent = [self getChildByTag:kTagParentNode];
    
    //We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
    //just randomly picking one of the images
    int idx = (CCRANDOM_0_1() > .5 ? 0:1);
    int idy = (CCRANDOM_0_1() > .5 ? 0:1);
   
    PhysicsSprite *sprite = [PhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(32 * idx,32 * idy,32,32)];

    sprite.position = ccp( p.x, p.y); //cocos2d point
    
    // Define the dynamic body.
    //Set up a 1m squared box in the physics world
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    b2Body *body = world->CreateBody(&bodyDef);
    
    // Define another box shape for our dynamic body.
    b2PolygonShape dynamicBox;
    dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box

    // Define the dynamic body fixture.
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &dynamicBox;	
    fixtureDef.density = 1.0f;
    fixtureDef.friction = 0.3f;
    body->CreateFixture(&fixtureDef);
   
    [sprite setPhysicsBody:body];
    [parent addChild:sprite];
   
    [self.camera followNode:sprite];
}

-(void) update: (ccTime) dt
{
    //It is recommended that a fixed time step is used with Box2D for stability
    //of the simulation, however, we are using a variable time step here.
    //You need to make an informed choice, the following URL is useful
    //http://gafferongames.com/game-physics/fix-your-timestep/
   
    PhysicsSprite* lastChild = [[self getChildByTag:kTagParentNode].children lastObject];
    if(lastChild != nil)
    {
        if(![lastChild physicsBody]->IsAwake() && self.camera.target != nil)
        {   
            [self.camera revert];
        }
    }
    
    int32 velocityIterations = 8;
    int32 positionIterations = 1;

    // Instruct the world to perform a single step of simulation. It is
    // generally best to keep the time step and iterations fixed.

    world->Step(dt, velocityIterations, positionIterations);
    
    /**
     * User-made objects that also require updates
     */
    
	[self.camera update:dt];
    //[self updateParallax];

}


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.camera touchesBegan:[event allTouches]];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.camera touchesEnded:touches];

    //Add a new body/atlas sprite at the touched location
    CGPoint location;
    for( UITouch *touch in touches ) {
        location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];
        
        //RippleEffect* ripple = [[RippleEffect alloc] initWithSubject:self.parent atOrigin:location];
        //[self.parent.parent addChild: ripple];
        
        location = [self convertToNodeSpace:location];
        
    }
    
    /* add box */
    CGRect bounds = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    if([touches count] == 3)
        if(CGRectContainsPoint(bounds, location))
        {
            [self addNewSpriteAtPosition: location];
            [self.camera addIntensity:10.f]; 
        }
    
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
   [self.camera touchesMoved:[event allTouches]];
}

-(void)handleOneFingerMotion:(NSSet *)touches
{

    
}
-(void)handleTwoFingerMotion:(NSSet *)touches
{

        
    
}

//CAMERA OBJECT FUNCTIONS

-(float) getParallaxRatio{
    return 1.f;
}

-(bool) isBounded{
    return YES;
}


@end

