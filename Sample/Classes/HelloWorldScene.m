//
//  HelloWorldLayer.m
//  Sample
//
//  Created by Manuel Martinez-Almeida Castañeda on 12/07/10.
//  Copyright Abstraction Works 2010. All rights reserved.
//

// Import the interfaces
#import "HelloWorldScene.h"
#import "CCNotifications.h"

// HelloWorld implementation
@implementation HelloWorld

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
		// ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
		
		
		CCLabel *positionLa = [CCLabel labelWithString:@"Position:" fontName:@"Arial" fontSize:16];
		[positionLa setAnchorPoint:ccp(0, 0.5f)];
		[positionLa setPosition:ccp(20, size.height-82)];
		
		CCLabel *animationIn = [CCLabel labelWithString:@"Animation In:" fontName:@"Arial" fontSize:16];
		[animationIn setAnchorPoint:ccp(0, 0.5f)];
		[animationIn setPosition:ccp(20, size.height-136)];
		
		CCLabel *animationOut = [CCLabel labelWithString:@"Animation Out:" fontName:@"Arial" fontSize:16];
		[animationOut setAnchorPoint:ccp(0, 0.5f)];
		[animationOut setPosition:ccp(20, size.height-184)];

		
		// setPosition
		[[CCNotifications sharedManager] setPosition:kCCNotificationPositionBottom];
		CCMenuItem *positionBottom = [CCMenuItemFont itemFromString:@"Bottom"];
		CCMenuItem *positionTop = [CCMenuItemFont itemFromString:@"Top"];
		CCMenuItemToggle *positionOptions = [CCMenuItemToggle itemWithTarget:self selector:@selector(setNotPosition:) items:positionBottom, positionTop, nil];
		
		// setAnimationIn
		CCMenuItem *inAnimationMove = [CCMenuItemFont itemFromString:@"Movement"];
		CCMenuItem *inAnimationScale = [CCMenuItemFont itemFromString:@"Scale"];
		CCMenuItemToggle *inOptions = [CCMenuItemToggle itemWithTarget:self selector:@selector(setAnimationIn:) items:inAnimationMove, inAnimationScale, nil];
		
		// setAnimationIn
		CCMenuItem *outAnimationMove = [CCMenuItemFont itemFromString:@"Movement"];
		CCMenuItem *outAnimationScale = [CCMenuItemFont itemFromString:@"Scale"];
		CCMenuItemToggle *outOptions = [CCMenuItemToggle itemWithTarget:self selector:@selector(setAnimationOut:) items:outAnimationMove, outAnimationScale, nil];
		
		//Button
		CCMenuItem *sendCached = [CCMenuItemFont itemFromString:@"Send notification cached" target:self selector:@selector(sendCached:)];
		CCMenuItem *sendNoCached = [CCMenuItemFont itemFromString:@"Send notification no cached" target:self selector:@selector(sendNoCached:)];
		
		CCMenu *menu = [CCMenu menuWithItems:positionOptions, inOptions, outOptions, sendCached, sendNoCached, nil];
		[menu alignItemsVerticallyWithPadding:15];
		[menu setPosition:ccp(size.width/2.0f+30, size.height/2.0f)];
		// add the label as a child to this Layer
		[self addChild: menu];
		
		[self addChild:positionLa];
		[self addChild:animationIn];
		[self addChild:animationOut];

	}
	return self;
}

- (void) setNotPosition:(id)sender
{
	[[CCNotifications sharedManager] setPosition:[sender selectedIndex]];
}

- (void) setAnimationIn:(id)sender
{
	[[CCNotifications sharedManager] setAnimationIn:[sender selectedIndex] time:0.5f];
}

- (void) setAnimationOut:(id)sender
{

	[[CCNotifications sharedManager] setAnimationOut:[sender selectedIndex] time:0.5f];
}

- (void) sendCached:(id)sender
{
	//Fast method
	[[CCNotifications sharedManager] addWithTitle:@"Notification sample" message:@"I wait until done" image:nil];
	
	//Complex method
	//[[CCNotifications sharedManager] addWithTitle:@"Notification sample" message:@"I wait until done" image:nil tag:-1 animate:YES waitUntilDone:YES];
}

- (void) sendNoCached:(id)sender
{
	//Complex method
	[[CCNotifications sharedManager] addWithTitle:@"Notification sample" message:@"I don't wait until done" image:nil tag:-1 animate:YES waitUntilDone:NO];
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
