//
//  CCNotifications
//
//  Created by Manuel Martinez-Almeida Castañeda.
//  Copyright 2010 Abstraction Works. All rights reserved.
//	http://www.abstractionworks.com
//

#import "CCNotifications.h"
#import "notificationDesign.h"


@implementation ccNotificationData
@synthesize title		= title_;
@synthesize message		= message_;
@synthesize image		= image_;
@synthesize tag			= tag_;
@synthesize animated	= animated_;


- (void) dealloc
{
	[self setTitle:nil];
	[self setMessage:nil];
	[self setImage:nil];
	[super dealloc];
}


@end

@interface CCNotifications (Private)

- (void) _updateAnimationIn;
- (void) _updateAnimationOut;
- (CCIntervalAction*) _animation:(char)type time:(ccTime)time;
- (void) _addFromSafelyMode;
- (void) _startScheduler;
- (void) _hideNotification;
- (void) _hideNotificationScheduler;
- (void) registerWithTouchDispatcher;
- (void) _setState:(char)states;

@end


@implementation CCNotifications
@synthesize notificationDesign		= template_;
@synthesize animationIn				= animationIn_;
@synthesize animationOut			= animationOut_;
@synthesize delegate				= delegate_;
@synthesize showingTime				= showingTime_;
@synthesize cachedNotificationData	= cachedNotificationData_;

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

+ (id) systemWithTemplate:(CCNode <CCNotificationDesignProtocol> *)notifications
{
	NSAssert(sharedManager == nil, @"Attempted to allocate a second instance of a singleton. You should use setTemplate");
	sharedManager = [[CCNotifications alloc] initWithTemplate:notifications];
	
	return sharedManager;
}

+(void)purgeSharedManager
{
	[sharedManager release];
}

- (id) init
{
	CCNode <CCNotificationDesignProtocol> *templates = [[[CCNotificationDefaultDesign alloc] init] autorelease];
	return self = [self initWithTemplate:templates];
}


-(id) initWithTemplate:(CCNode <CCNotificationDesignProtocol> *)templates
{
	if( (self = [super init]) ) {
		self.notificationDesign = templates;
		cachedNotificationData_ = nil;
		[template_ setIsRelativeAnchorPoint:YES];
		[template_ setVisible:NO];
		
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

- (void) _setState:(char)states{
	if(state_==states) return;
	if([delegate_ respondsToSelector:@selector(notificationChangeState:tag:)])
		[delegate_ notificationChangeState:states tag:tag_];
	
	state_ = states;
}

- (void) setPosition:(char)position{
	position_ = position;
	[self updateAnimations];
}

- (void) setNotificationDesign:(CCNode <CCNotificationDesignProtocol>*) templates
{
	if(state_!=kCCNotificationStateHide)
		[template_ stopAllActions];

	if(state_==kCCNotificationStateShowing){
		[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
		[[CCScheduler sharedScheduler] unscheduleSelector:@selector(_hideNotificationScheduler) forTarget:self];		
	}
	[templates retain];
	[template_ release];
	template_ = templates;
	
	[self _setState:kCCNotificationStateHide];
}
#pragma mark Notification Actions

- (CCIntervalAction*) _animation:(char)type time:(ccTime)time{
	CCIntervalAction *action = nil;
	switch (type) {
		case kCCNotificationAnimationMovement:
			if(position_==kCCNotificationPositionBottom)
				action = [CCMoveBy actionWithDuration:time position:ccp(0, template_.contentSize.height)];
			else if(position_ == kCCNotificationPositionTop)
				action = [CCMoveBy actionWithDuration:time position:ccp(0, -template_.contentSize.height)];
			
			break;
		case kCCNotificationAnimationScale:
			action = [CCScaleBy actionWithDuration:time scale:(1.0f-KNOTIFICATIONMIN_SCALE)/KNOTIFICATIONMIN_SCALE];
			
			break;
		default: break;
	}
	return action;
}

- (void) _updateAnimationIn
{
	self.animationIn = [CCSequence actionOne:[self _animation:typeAnimationIn_ time:timeAnimationIn_] two:[CCCallFunc actionWithTarget:self selector:@selector(_startScheduler)]];
}

- (void) _updateAnimationOut
{
	CCIntervalAction *tempAction = [self _animation:typeAnimationOut_ time:timeAnimationOut_];
	self.animationOut = [CCSequence actionOne:[tempAction reverse] two:[CCCallFunc actionWithTarget:self selector:@selector(_hideNotification)]];
}

- (void) updateAnimations{
	[self _updateAnimationIn];
	[self _updateAnimationOut];
}

- (void) setAnimationIn:(char)type time:(ccTime)time{
	typeAnimationIn_ = type;
	timeAnimationIn_ = time;
	[self _updateAnimationIn];
}

- (void) setAnimationOut:(char)type time:(ccTime)time{
	typeAnimationOut_ = type;
	timeAnimationOut_ = time;
	[self _updateAnimationOut];
}

- (void) setAnimation:(char)type time:(ccTime)time{
	typeAnimationIn_ = typeAnimationOut_ = type;
	timeAnimationIn_ = timeAnimationOut_ = time;
	[self updateAnimations];
}

#pragma mark Notification steps

- (void) _startScheduler
{
	[self registerWithTouchDispatcher];
	[self _setState:kCCNotificationStateShowing];
	[template_ stopAllActions];
	[[CCScheduler sharedScheduler] scheduleSelector:@selector(_hideNotificationScheduler) forTarget:self interval:showingTime_ paused:NO];
}

- (void) _hideNotification
{
	[self _setState:kCCNotificationStateHide];
	[template_ setVisible:NO];
	[template_ stopAllActions];
	[template_ onExit];
}

- (void) _hideNotificationScheduler
{	
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(_hideNotificationScheduler) forTarget:self];
	if(animated_){
		[self _setState:kCCNotificationStateAnimationOut];
		[template_ runAction:animationOut_];
	}else
		[self _hideNotification];
}

#pragma mark Manager Notifications

- (void) addWithTitle:(NSString*)title message:(NSString*)message texture:(CCTexture2D*)texture tag:(int)tag animate:(BOOL)animate
{
	if(state_!=kCCNotificationStateHide){
		[delegate_ notificationChangeState:kCCNotificationStateHide tag:tag_];
		[template_ setVisible:NO];
		[template_ stopAllActions];
		[template_ onExit];
		[[CCScheduler sharedScheduler] unscheduleSelector:@selector(_hideNotificationScheduler) forTarget:self];
	}
	
	if(state_==kCCNotificationStateShowing)
		[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	
	tag_		= tag;
	animated_	= animate;
	[template_ setVisible:NO];
	[template_ stopAllActions];
	[template_ onExit];
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	if(animate){
		if(position_==kCCNotificationPositionBottom){
			[template_ setAnchorPoint:ccp(0.5f, 0)];
			switch (typeAnimationIn_) {
				case kCCNotificationAnimationMovement:
					[template_ setScale:1.0f];
					[template_ setPosition:ccp(winSize.width/2.0f, -template_.contentSize.height)];
					
					break;
				case kCCNotificationAnimationScale:
					[template_ setScale:KNOTIFICATIONMIN_SCALE];
					[template_ setPosition:ccp(winSize.width/2.0f, 0)];
					
					break;
				default: return;
			}
			
		}else if(position_==kCCNotificationPositionTop){
			[template_ setAnchorPoint:ccp(0.5f, 1)];
			switch (typeAnimationIn_) {
				case kCCNotificationAnimationMovement:
					[template_ setScale:1.0f];
					[template_ setPosition:ccp(winSize.width/2.0f, winSize.height+template_.contentSize.height)];
					
					break;
				case kCCNotificationAnimationScale:
					[template_ setScale:KNOTIFICATIONMIN_SCALE];
					[template_ setPosition:ccp(winSize.width/2.0f, winSize.height)];
					
					break;
				default: return;
			}
		}
		[self _setState:kCCNotificationStateAnimationIn];
		[template_ onEnter];
		[template_ runAction:animationIn_];
		
	}else{
		if(position_==kCCNotificationPositionBottom)
		{
			[template_ setAnchorPoint:ccp(0.5f, 0)];
			[template_ setPosition:ccp(winSize.width/2.0f, 0)];
		}else if(position_==kCCNotificationPositionTop)
		{
			[template_ setAnchorPoint:ccp(0.5f, 1)];
			[template_ setPosition:ccp(winSize.width/2.0f, winSize.height)];
		}
		[self _startScheduler];
	}
	[template_ setTitle:title message:message texture:texture];
	[template_ setVisible:YES];
}

- (void) addWithTitle:(NSString*)title message:(NSString*)message image:(NSString*)image tag:(int)tag animate:(BOOL)animate
{
	CCTexture2D *texture = (image==nil) ? nil : [[CCTextureCache sharedTextureCache] addImage:image];
	[self addWithTitle:title message:message texture:texture tag:tag animate:animate];
}

- (void) _addFromSafelyMode
{
	ccNotificationData *data = self.cachedNotificationData;
	[self addWithTitle:data.title message:data.message image:data.image tag:data.tag animate:data.animated];
	self.cachedNotificationData = nil;
}

- (void) addSafelyWithTitle:(NSString*)title message:(NSString*)message image:(NSString*)image tag:(int)tag animate:(BOOL)animate
{
	ccNotificationData *data = [[ccNotificationData alloc] init];
	data.title		= title;
	data.message	= message;
	data.image		= image;
	data.tag		= tag;
	data.animated	= animate;
	self.cachedNotificationData = data; //2 retains
	[data release]; //1 retain
}

#pragma mark Touch Events

- (void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:INT_MIN+3];
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint point = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	CGRect rect = [template_ boundingBox];
	if(CGRectContainsPoint(rect, point))
		if([delegate_ respondsToSelector:@selector(touched:)] && [delegate_ touched:tag_])
			[self _hideNotificationScheduler];
}

#pragma mark Other methods

- (void) visit{
	if(cachedNotificationData_)
		[self _addFromSafelyMode];
	
	[template_ visit];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %08X>", [self class], self];
}

-(void) dealloc
{
	CCLOG(@"cocos2d: deallocing %@", self);
	
	sharedManager = nil;
	[self setNotificationDesign:nil];
	[self setDelegate:nil];
	[self setAnimationIn:nil];
	[self setAnimationOut:nil];
	[self setCachedNotificationData:nil];
	[super dealloc];
}
@end