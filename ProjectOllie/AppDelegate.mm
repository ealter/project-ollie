//
//  AppDelegate.mm
//  ProjectOllie
//
//  Created by Eliot Alter on 5/31/12.
//  Copyright hi ku llc 2012. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import "cocos2d.h"
#import "AppDelegate.h"
#import "ActionLayer.h"
#import "CCBReader.h"
#import "Authentication.h"
#import "FacebookLogin.h"
#import "Facebook.h"
#import "GameConstants.h"
#import "SandboxScene.h"
#import "DrawEnvironmentScene.h"
#import "MyStoreObserver.h"

@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGBA8//kEAGLColorFormatRGB565   //kEAGLColorFormatRGBA8888
								   depthFormat:0                        //GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];
    
    [glView setMultipleTouchEnabled:YES];
 
	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
    assert([self.director isKindOfClass:[CCDirectorIOS class]]);
	
	self.director.wantsFullScreenLayout = YES;
	
	// Display FSP and SPF
    self.director.displayStats = YES;
	
	// set FPS at 60
    self.director.animationInterval = 1.0/FPS;
	
	// attach the openglView to the director
    self.director.view = glView;
	
	// for rotation and other messages
    self.director.delegate = self;
	
	// 2D projection
    self.director.projection = kCCDirectorProjection2D;
	//	[director setProjection:kCCDirectorProjection3D];
    
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director_ enableRetinaDisplay:NO] )
		CCLOG(@"Retina Display Not supported");
	
	// Create a Navigation Controller with the Director
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	self.navController.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
		[window_ setRootViewController:navController_];
	[self.window addSubview:navController_.view];
    
	// make main window visible
	[self.window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
	
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
	
    //Load the CCBI file
    CCScene *scene;/*
    if([[Authentication mainAuth] isLoggedIn])
        scene = [CCBReader sceneWithNodeGraphFromFile:@"MainMenu.ccbi"];
    else
        scene = [CCBReader sceneWithNodeGraphFromFile:@"LoginScreen.ccbi"];*/
    scene = [DrawEnvironmentScene node];
    
    
	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	//[director_ pushScene: [ActionLayer scene]]; 
	[[CCDirector sharedDirector] pushScene:scene];
    
    //Add the store observer
    MyStoreObserver *observer = [[MyStoreObserver alloc] init];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:observer];
    
	return YES;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}



// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [self.navController visibleViewController] == self.director )
		[self.director pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [self.navController visibleViewController] == self.director )
		[self.director resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
	if( [self.navController visibleViewController] == self.director )
		[self.director stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [self.navController visibleViewController] == self.director )
		[self.director startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[Authentication mainAuth].facebookLogin.facebook handleOpenURL:url]; 
}

@end
