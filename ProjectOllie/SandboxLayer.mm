//
//  SandboxLayer.m
//  ProjectOllie
//
//  Created by Lion User on 6/1/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import "SandboxLayer.h"
#import "AppDelegate.h"
#import "CCAction.h"
#import "GWCamera.h"
#import "PhysicsSprite.h"
#import "Background.h"


//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO (32)
#define kTagPoly 10
#define kTagBox 20


enum {
	kTagParentNode = 1,
};

@interface SandboxLayer()

-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) addNewStaticBodyAtPosition:(CGPoint)p;
-(void) followCenter;
-(void) handleOneFingerMotion:(NSSet *)touches;
-(void) handleTwoFingerMotion:(NSSet *)touches;
@end

@implementation SandboxLayer

@synthesize center      = _center;
@synthesize camera      = _camera;
@synthesize windowSize  = _windowSize;

+(CCScene *) scene
{
    // 'scene' is an autorelease object.
    CCScene *scene = [CCScene node];

    // 'layer' is an autorelease object.
    SandboxLayer *layer = [SandboxLayer node];

    // add layer as a child to scene
    [scene addChild: layer];

    // return the scene
    return scene;
}

-(id) init
{
    if( (self=[super init])) {
        
        self.anchorPoint = ccp(.5f,.5f);
        
        //keep track of camera motion
        s = self.contentSize;
        self.windowSize = s;
        self.camera = [[GWCamera alloc] initWithSubject:self worldDimensions:s];
        self.center = [CCNode node];
        self.center.position = ccp(s.width/2, s.height/2);
        [self.camera revertTo:self.center];
        
        //set up parallax
        parallax_ = [CCParallaxNode node];
        CCSprite* bglayer1 = [CCSprite spriteWithFile:@"background.jpg"];
        bglayer1.scale = 2.f;
        [parallax_ addChild:bglayer1 z:-1 parallaxRatio:ccp(.4f,.5f) positionOffset:self.center.position];
        
        [self addChild:parallax_ z:-1];
        
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
        
        
        [self addNewStaticBodyAtPosition:ccp(s.width/2, s.height/2)];
        
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap screen" fontName:@"Marker Felt" fontSize:32];
        [self addChild:label z:0];
        [label setColor:ccc3(0,0,255)];
        label.position = ccp( s.width/2, s.height-50);
        
        [self addChild:self.center];
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

[super dealloc];
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
    vs[1].Set(s.width/PTM_RATIO,0);
    vs[2].Set(s.width/PTM_RATIO,s.height/PTM_RATIO);
    vs[3].Set(0,s.height/PTM_RATIO);
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
    CCNode *parent = [self getChildByTag:kTagParentNode];

    //We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
    //just randomly picking one of the images
    int idx = (CCRANDOM_0_1() > .5 ? 0:1);
    int idy = (CCRANDOM_0_1() > .5 ? 0:1);
   // PhysicsSprite *sprite = [PhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(16 * idx,16 * idy,16,16)];					
	
    /**
     * With the debug drawing features we have, bodies draw themselves. Not yet sure how we will texurize
     * the polygons.
     */
    
    //[parent addChild:sprite];
    // will eventually make this a piece of terrain

   // sprite.position = ccp( p.x, p.y); //cocos2d point

    // Define the dynamic body.
    //Set up a 1m squared box in the physics world
    b2BodyDef bodyDef;
    bodyDef.type = b2_staticBody;
    bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    b2Body *body = world->CreateBody(&bodyDef);

    // Define another box shape for our dynamic body.
    //b2PolygonShape dynamicBox;
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

    //[sprite setPhysicsBody:body];
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
        if(![lastChild physicsBody]->IsAwake() && self.camera.target != self.center)
        {   
            [self.camera revertTo:self.center];
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
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    [self.camera touchesBegan:[event allTouches]];
    
        
    
}
- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

    //Add a new body/atlas sprite at the touched location
  
    for( UITouch *touch in touches ) {
        CGPoint location = [touch locationInView: [touch view]];
        
        
        location = [[CCDirector sharedDirector] convertToGL: location];
        location = [self convertToNodeSpace:location];
        
        CGRect bounds = CGRectMake(0, 0, s.width, s.height);
      //  if(CGRectContainsPoint(bounds, location))
        //   [self addNewSpriteAtPosition: location];
        //[self.camera addIntensity:6.f];
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





@end

