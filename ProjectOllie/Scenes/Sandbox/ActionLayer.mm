//
//  ActionLayer.m
//  ProjectOllie
//
//  Created by a young lion named Sam Zeckendorf on 6/1/12.
//  Copyright (c) 2012 hi ku llc All rights reserved.
//

#import "ActionLayer.h"
#import "AppDelegate.h"
#import "GWPhysicsSprite.h"
#import "ScrollingBackground.h"
#import "MaskedSprite.h"
#import "GameConstants.h"
#import "GWCharacter.h"
#import "GWWater.h"
#import "GWGestures.h"
#import "HMVectorNode.h"
#import "Grenade.h"
#import "Shotgun.h"
#import "GaussRifle.h"
#import "GWContactListener.h"
#import "GWUiLayer.h"

#define kTagPoly 10
#define kTagBox 20

enum {
	kTagParentNode = 1,
};

@interface ActionLayer()
{
    GWCharacter* _character;
    GWGestures* gestures;
}
-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) handleOneFingerMotion:(NSSet *)touches;
-(void) handleTwoFingerMotion:(NSSet *)touches;


@end

@implementation ActionLayer

@synthesize gameTerrain          = _gameTerrain;


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

-(id) initWithCamera:(GWCamera*)camera
{
    if( (self=[super init])) {
        
        //Action layer is at z of 0
        super.z = 0;
        
        //set up screen parameters
        self.anchorPoint = ccp(0,0);
        [self setIgnoreAnchorPointForPosition:YES];
        
        //keep track of camera motion
        self.camera = camera;

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
        
       /* CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap screen" fontName:@"Marker Felt" fontSize:32];
        [self addChild:label z:0];
        [label setColor:ccc3(0,0,255)];
        label.position = ccp( self.contentSize.width/2, self.contentSize.height-50);*/
        
        /* Make a border rectangle for debug drawing */
        
        
        CGPoint worldRectPx[4];
        worldRectPx[0].x = 0;                 worldRectPx[0].y = 0;
        worldRectPx[1].x = 0;                 worldRectPx[1].y = WORLD_HEIGHT_PX;
        worldRectPx[2].x = WORLD_WIDTH_PX;    worldRectPx[2].y = WORLD_HEIGHT_PX;
        worldRectPx[3].x = WORLD_WIDTH_PX;    worldRectPx[3].y = 0;
        HMVectorNode* worldBounds = [HMVectorNode node];
        [worldBounds setColor:ccc4f(1, 0, 0, 1)];
        for (int i = 0; i < 4; i++)
            [worldBounds drawSegmentFrom:worldRectPx[i] to:worldRectPx[(i+1)%4] radius:4];
        [self addChild:worldBounds z:256];
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
    gravity.Set(0, -2.f);
    world = new b2World(gravity);

    // Do we want to let bodies sleep?
    world->SetAllowSleeping(true);

    world->SetContinuousPhysics(true);
    
    //Set up the Contact Listener
    GWContactListener *_contactListener = new GWContactListener();
    
    world->SetContactListener(_contactListener);

    m_debugDraw = new GLESDebugDraw( PTM_RATIO );
    world->SetDebugDraw(m_debugDraw);

    uint32 flags = 0;
    flags += b2Draw::e_shapeBit;
    //   	flags += b2Draw::e_jointBit;
    //		flags += b2Draw::e_aabbBit;
    //		flags += b2Draw::e_pairBit;
    //		flags += b2Draw::e_centerOfMassBit;
    m_debugDraw->SetFlags(flags);		


    // Define the ground body.
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0); // bottom-left corner
    
    _character = [[GWCharacter alloc]initWithIdentifier:@"construction" spriteIndices:[NSArray array] box2DWorld:world];
    [self addChild:_character];
    
    //ui layer
    GWUILayer *uiLayer = [[GWUILayer alloc] init];
    _character.uiLayer = uiLayer;
    [self addChild:uiLayer z:PTM_RATIO];
    
    //weapons loading
    NSArray* weaponArray = [NSArray arrayWithObjects:[[GaussRifle alloc] initWithPosition:CGPointMake(1, 1) ammo:99 box2DWorld:world gameWorld:self],[[Grenade alloc] initWithPosition:CGPointMake(1, 1) ammo:99 box2DWorld:world gameWorld:self],nil];
    
    [_character loadWeapons:weaponArray];
    _character.selectedWeapon = [weaponArray objectAtIndex:0];

    
    //gesture layer
    gestures = [[GWGestures alloc] init];
    [[gestures children] addObject:_character];
    [self addChild:gestures z:2];

}

-(void) draw
{
    [super draw];
    
    /* Box2d debug drawing */
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    kmGLPushMatrix();
    world->DrawDebugData();	
    kmGLPopMatrix();
    
}

-(void) addNewSpriteAtPosition:(CGPoint)p
{
    CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
    CCNode *parent = [self getChildByTag:kTagParentNode];
    
    //We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
    //just randomly picking one of the images
    int idx = (CCRANDOM_0_1() > .5 ? 0:1);
    int idy = (CCRANDOM_0_1() > .5 ? 0:1);
   
    GWPhysicsSprite *sprite = [GWPhysicsSprite spriteWithTexture:spriteTexture_ rect:CGRectMake(32 * idx,32 * idy,32,32)];

    sprite.position = p;
    
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
    fixtureDef.filter.categoryBits = CATEGORY_PROJECTILES;
    fixtureDef.filter.maskBits = MASK_PROJECTILES;
    body->CreateFixture(&fixtureDef);
   
    [sprite setPhysicsBody:body];
    [parent addChild:sprite];
   
    //[self.camera followNode:sprite];
}

-(void) update: (ccTime) dt
{
    //It is recommended that a fixed time step is used with Box2D for stability
    //of the simulation, however, we are using a variable time step here.
    //You need to make an informed choice, the following URL is useful
    //http://gafferongames.com/game-physics/fix-your-timestep/
   
    GWPhysicsSprite* lastChild = [[self getChildByTag:kTagParentNode].children lastObject];
    if(lastChild != nil)
    {
        if(![lastChild physicsBody]->IsAwake() && self.camera.target != nil)
        {   
            // pffft wat
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
    [_character update:dt];

}


- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.camera touchesBegan:[event allTouches]];
    UITouch *touch = [touches anyObject];
    CGPoint tl = [touch locationInView:[touch view]];
    if(tl.x > [[CCDirector sharedDirector]winSizeInPixels].width/2)
        [_character walkRight];
    else [_character walkLeft];
    
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.camera touchesEnded:touches];
    [_character stopWalking];
    //Add a new body/atlas sprite at the touched location
    CGPoint location;
    for( UITouch *touch in touches ) {
        location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];

        location = [self convertToNodeSpace:location];
        
    }
    
    /* add box */
    CGRect bounds = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    if([touches count] == 3)
        if(CGRectContainsPoint(bounds, location))
        {
            [self addNewSpriteAtPosition: location];
            //[self.camera addIntensity:10.f]; 
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


-(void)setTerrain:(Terrain*)t
{    
    //Add as a child so it draws
    [self addChild:t];
    
    if (t != NULL) {
        self.gameTerrain = t;
    }
    
    //Add all of the edge shapes to the world
    [t addToWorld:world];
}


@end

