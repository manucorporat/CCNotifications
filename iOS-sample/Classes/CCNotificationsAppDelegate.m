//
//  SampleAppDelegate.m
//  Sample
//
//  Created by Manuel Martinez-Almeida Castañeda on 12/07/10.
//  Copyright Abstraction Works 2010. All rights reserved.
//

#import "CCNotificationsAppDelegate.h"
#import "cocos2d.h"
#import "HelloWorldScene.h"

@implementation CCNotificationsAppDelegate

@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window" var (it must already be declared)
	// 4. Parents EAGLView to the newly created window
	// 5. Creates Display Link Director
	// 5a. If it fails, it will use an NSTimer director
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Device orientation: Portrait
	// 9. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];
	
	// Sets landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
	// Turn on display FPS
	[director setDisplayFPS:NO];
	
	// Turn on multiple touches
	EAGLView *view = [director openGLView];
	[view setMultipleTouchEnabled:YES];
	
	/** INIT OPENFEINT 
	 
	 //Openfeint init
	 NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
	 [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight], OpenFeintSettingDashboardOrientation,
	 [NSNumber numberWithBool:YES], OpenFeintSettingEnablePushNotifications,
	 nil
	 ];
	 
	 OFDelegatesContainer* delegates = [OFDelegatesContainer
	 containerWithOpenFeintDelegate:self
	 andChallengeDelegate:nil
	 andNotificationDelegate:self];
	 
	 [OpenFeint initializeWithProductKey:@"blablbla"
	 andSecret:@"blablabla"
	 andDisplayName:@"blablabla"
	 andSettings:settings
	 andDelegates:delegates];
	 */
	
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];	
	
	
	
	/** Init CCNotifications (very easy) **/
	CCNotifications *notifications = [CCNotifications sharedManager];
	[notifications setDelegate:self];
	
	/** Add to cocos2d loop **/
	[[CCDirector sharedDirector] setNotificationNode:notifications];
	
	
	[[CCDirector sharedDirector] runWithScene: [HelloWorld scene]];
}


#pragma mark CCNotifications delegate methods (optional)

- (void) notification:(ccNotificationData*)notification newState:(char)state
{
	switch (state) {
		case kCCNotificationStateHide:
			NSLog(@"Notification hidden");
			//Play sound
			break;
		case kCCNotificationStateShowing:
			NSLog(@"Showing notification");
			//Play sound
			
			break;
		case kCCNotificationStateAnimationIn:
			NSLog(@"Animation-In, began");
			//Play sound
			
			break;
		case kCCNotificationStateAnimationOut:
			NSLog(@"Animation-Out, began");
			//Play sound
			
			break;
		default: break;
	}
}

/*
 - (BOOL) touched:(int)tag
 {
 //When you add a notification to [CCNotifications sharedManager] you must set a tag.
 if(tag==2){
 [OpenFeint launchDashboard]; //example
 return YES;
 }
 return NO
 }
 */

#pragma mark OpenFeint integration

/*
 - (BOOL) isOpenFeintNotificationAllowed:(OFNotificationData*)notificationData
 {	 
 return NO;
 }
 
 - (void)handleDisallowedNotification:(OFNotificationData*)notificationData
 {
 //Using safety mode (You can send notification from any thread
 [[CCNotifications sharedManager] addSafelyWithTitle:@"Openfeint:" message:[notificationData notificationText] image:@"YOUR IMAGE EXAMPLE" tag:-1 animate:YES];
 }
 */

#pragma mark App state methods

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[[CCDirector sharedDirector] end];
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[super dealloc];
}

@end

