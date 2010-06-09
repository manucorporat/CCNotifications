//
//  CCNotifications
//
//  Created by Manuel Martinez-Almeida Castañeda.
//  Copyright 2010 Abstraction Works. All rights reserved.
//	http://www.abstractionworks.com
//

#import "CCNotifications.h"
#import "notificationDesign.h"

@interface CCNotifications (Private)

- (CCIntervalAction*) animation:(char)type time:(ccTime)time;
- (void) hideNotificationScheduler;
- (void) setState:(char)states;

@end

@interface ccNotificationData : NSObject {
	NSString *title_;
	NSString *message_;
	NSString *image_;
	int tag_;
	BOOL animated_;
}
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *message;
@property(nonatomic, retain) NSString *image;
@property(nonatomic, readwrite, assign) int tag;
@property(nonatomic, readwrite, assign) BOOL animated;

@end

@implementation ccNotificationData
@synthesize title = title_;
@synthesize message = message_;
@synthesize image = image_;
@synthesize tag = tag_;
@synthesize animated = animated_;


- (void) dealloc
{
	[self setTitle:nil];
	[self setMessage:nil];
	[self setImage:nil];
	[super dealloc];
}


@end

@implementation CCNotifications
@synthesize animationIn = animationIn_;
@synthesize animationOut = animationOut_;
@synthesize delegate = delegate_;
@synthesize showingTime = showingTime_;

static CCNotifications *sharedManager;

+ (CCNotifications *)sharedManager
{
	if (!sharedManager)
		sharedManager = [[CCNotifications alloc] init];
	
	return sharedManager;
}

+(id)alloc
{
	NSAssert(sharedManager == nil, @"Attempted to allocate a second instance of a singleton.");
	return [super alloc];
}

+(void)purgeSharedManager
{
	[sharedManager release];
}

-(id) init
{
	if( (self=[super init]) ) {
		notification = [[CCNotificationDefaultDesign alloc] init];
		[notification setIsRelativeAnchorPoint:YES];
		[notification setVisible:NO];
		
		delegate_			= nil;
		tag_				= -1;
		state_				= kCCNotificationStateHide;
		typeAnimationIn_	= 0;
		typeAnimationOut_	= 0;
		timeAnimationIn_	= 0;
		timeAnimationOut_	= 0;
		
		//Default settings
		showingTime_		= 4.0f;
		position_			= kCCNotificationPositionTop;
		
		[self setAnimation:kCCNotificationAnimationMovement time:0.5f];
		//[self setAnimationIn:kCCNotificationAnimationMovement time:0.5f];
		//[self setAnimationOut:kCCNotificationAnimationScale time:0.5f];
	}	
	return self;
}

- (void) setState:(char)states{
	if(state_==states) return;
	[delegate_ notificationChangeState:states tag:tag_];
	state_ = states;
}

- (void) setPosition:(char)position{
	position_ = position;
	[self updateAnimations];
}

#pragma mark Notification Actions

- (CCIntervalAction*) animation:(char)type time:(ccTime)time{
	CCIntervalAction *action = nil;
	switch (type) {
		case kCCNotificationAnimationMovement:
			if(position_==kCCNotificationPositionBottom)
				action = [CCMoveBy actionWithDuration:time position:ccp(0, notification.contentSize.height)];
			else if(position_ == kCCNotificationPositionTop)
				action = [CCMoveBy actionWithDuration:time position:ccp(0, -notification.contentSize.height)];
			break;
		case kCCNotificationAnimationScale:
			action = [CCScaleBy actionWithDuration:time scale:(1.0f-KNOTIFICATIONMIN_SCALE)/KNOTIFICATIONMIN_SCALE];
			break;
		default: break;
	}
	return action;
}

- (void) updateAnimationIn{
	self.animationIn = [CCSequence actionOne:[self animation:typeAnimationIn_ time:timeAnimationIn_] two:[CCCallFunc actionWithTarget:self selector:@selector(startScheduler)]];
}

- (void) updateAnimationOut{
	CCIntervalAction *tempAction = [self animation:typeAnimationOut_ time:timeAnimationOut_];
	self.animationOut = [CCSequence actionOne:[tempAction reverse] two:[CCCallFunc actionWithTarget:self selector:@selector(hideNotification)]];
}

- (void) updateAnimations{
	[self updateAnimationIn];
	[self updateAnimationOut];
}

- (void) setAnimationIn:(char)type time:(ccTime)time{
	typeAnimationIn_ = type;
	timeAnimationIn_ = time;
	[self updateAnimationIn];
}

- (void) setAnimationOut:(char)type time:(ccTime)time{
	typeAnimationOut_ = type;
	timeAnimationOut_ = time;
	[self updateAnimationOut];
}

- (void) setAnimation:(char)type time:(ccTime)time{
	typeAnimationIn_ = typeAnimationOut_ = type;
	timeAnimationIn_ = timeAnimationOut_ = time;
	[self updateAnimations];
}

#pragma mark Notification steps

- (void) startScheduler{
	[self registerWithTouchDispatcher];
	[self setState:kCCNotificationStateShowing];
	[notification stopAllActions];
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(hideNotificationScheduler) forTarget:self interval:showingTime_ paused:NO];
}

- (void) hideNotification{
	[self setState:kCCNotificationStateHide];
	[notification setVisible:NO];
	[notification stopAllActions];
	[notification onExit];
}

- (void) hideNotificationScheduler{
	
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(hideNotificationScheduler) forTarget:self];
	if(animated_){
		[self setState:kCCNotificationStateAnimationOut];
		[notification runAction:animationOut_];
	}else
		[self hideNotification];
}

#pragma mark Manager Notifications

- (void) addWithTitle:(NSString*)title message:(NSString*)message texture:(CCTexture2D*)texture tag:(int)tag animate:(BOOL)animate{
	if(state_!=kCCNotificationStateHide){
		[delegate_ notificationChangeState:kCCNotificationStateHide tag:tag_];
		[notification setVisible:NO];
		[notification stopAllActions];
		[notification onExit];
		[[CCScheduler sharedScheduler] unscheduleSelector:@selector(hideNotificationScheduler) forTarget:self];
	}
	
	if(state_==kCCNotificationStateShowing)
		[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	
	tag_		= tag;
	animated_	= animate;
	[notification setVisible:NO];
	[notification stopAllActions];
	[notification onExit];
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	if(animate){
		if(position_==kCCNotificationPositionBottom){
			[notification setAnchorPoint:ccp(0.5f, 0)];
			switch (typeAnimationIn_) {
				case kCCNotificationAnimationMovement:
					[notification setScale:1.0f];
					[notification setPosition:ccp(winSize.width/2.0f, -notification.contentSize.height)];
					break;
				case kCCNotificationAnimationScale:
					[notification setScale:KNOTIFICATIONMIN_SCALE];
					[notification setPosition:ccp(winSize.width/2.0f, 0)];
					break;
				default: return;
			}
			
		}else if(position_==kCCNotificationPositionTop){
			[notification setAnchorPoint:ccp(0.5f, 1)];
			switch (typeAnimationIn_) {
				case kCCNotificationAnimationMovement:
					[notification setScale:1.0f];
					[notification setPosition:ccp(winSize.width/2.0f, winSize.height+notification.contentSize.height)];
					break;
				case kCCNotificationAnimationScale:
					[notification setScale:KNOTIFICATIONMIN_SCALE];
					[notification setPosition:ccp(winSize.width/2.0f, winSize.height)];
					break;
				default: return;
			}
		}
		[self setState:kCCNotificationStateAnimationIn];
		[notification onEnter];
		[notification runAction:animationIn_];
		
	}else{
		if(position_==kCCNotificationPositionBottom){
			[notification setAnchorPoint:ccp(0.5f, 0)];
			[notification setPosition:ccp(winSize.width/2.0f, 0)];
		}else if(position_==kCCNotificationPositionTop){
			[notification setAnchorPoint:ccp(0.5f, 1)];
			[notification setPosition:ccp(winSize.width/2.0f, winSize.height)];
		}
		[self startScheduler];
	}
	[notification setTitle:title message:message texture:texture];
	[notification setVisible:YES];
}

- (void) addWithTitle:(NSString*)title message:(NSString*)message image:(NSString*)image tag:(int)tag animate:(BOOL)animate{
	CCTexture2D *texture = (image==nil) ? nil : [[CCTextureCache sharedTextureCache] addImage:image];
	[self addWithTitle:title message:message texture:texture tag:tag animate:animate];
}

- (void) _addFromSafelyMode:(ccNotificationData*)data{
	[self addWithTitle:data.title message:data.message image:data.image tag:data.tag animate:data.animated];
	[data release];
}

- (void) addSafelyWithTitle:(NSString*)title message:(NSString*)message image:(NSString*)image tag:(int)tag animate:(BOOL)animate{
	ccNotificationData *data = [[ccNotificationData alloc] init];
	data.title = title;
	data.message = message;
	data.image = image;
	data.tag = tag;
	data.animated = animate;
	[self performSelectorOnMainThread:@selector(_addFromSafelyMode:) withObject:data waitUntilDone:YES];
}

#pragma mark Touch Events

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:INT_MIN+3];
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch *touch = [touches anyObject];
	CGPoint point = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	CGRect rect = [notification boundingBox];
	if(CGRectContainsPoint(rect, point))
		if([delegate_ touched:tag_])
			[self hideNotificationScheduler];
}

#pragma mark Other methods

- (void) visit{
	[notification visit];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X>", [self class], self];
}

-(void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);
	
	sharedManager = nil;
	[notification release];
	[self setDelegate:nil];
	[self setAnimationIn:nil];
	[self setAnimationOut:nil];
	[super dealloc];
}
@end