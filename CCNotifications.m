//
//  CCNotifications
//
//  Created by Manuel Martinez-Almeida Castañeda.
//  Copyright 2010 Abstraction Works. All rights reserved.
//	http://www.abstractionworks.com
//

#import "CCNotifications.h"
#import "CCArray.h"
#import "notificationDesign.h"


@implementation ccNotificationData
@synthesize title		= title_;
@synthesize message		= message_;
@synthesize media		= media_;
@synthesize mediaType	= mediaType_;
@synthesize tag			= tag_;
@synthesize animated	= animated_;


- (void) dealloc
{
	[self setTitle:nil];
	[self setMessage:nil];
	[self setMedia:nil];
	[super dealloc];
}


@end

@interface CCNotifications (Private)

- (void) _updateAnimationIn;
- (void) _updateAnimationOut;
- (CCActionInterval*) _animation:(char)type time:(ccTime)time;
- (void) _showNotification;
- (void) _addNotificationToArray:(ccNotificationData*)data cached:(BOOL)isCached;
- (void) _startScheduler;
- (void) _hideNotification;
- (void) _hideNotificationScheduler;
- (void) registerWithTouchDispatcher;
- (void) _setState:(char)states;

@end


@implementation CCNotifications
@synthesize position				= position_;
@synthesize notificationDesign		= template_;
@synthesize animationIn				= animationIn_;
@synthesize animationOut			= animationOut_;
@synthesize delegate				= delegate_;
@synthesize showingTime				= showingTime_;
@synthesize currentNotification		= currentNotification_;

static CCNotifications *sharedManager;

+ (CCNotifications *)sharedManager
{
	if (!sharedManager)
		sharedManager = [[CCNotifications alloc] init];
	
	return sharedManager;
}

+ (id) alloc
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

+ (void) purgeSharedManager
{
	[sharedManager release];
}

- (id) init
{
	CCNode <CCNotificationDesignProtocol> *templates = [[[CCNotificationDefaultDesign alloc] init] autorelease];
	return self = [self initWithTemplate:templates];
}


- (id) initWithTemplate:(CCNode <CCNotificationDesignProtocol> *)templates
{
	if( (self = [super init]) ) {
		self.notificationDesign = templates;
		
		delegate_			= nil;
		state_				= kCCNotificationStateHide;
		typeAnimationIn_	= kCCNotificationAnimationMovement;
		typeAnimationOut_	= kCCNotificationAnimationMovement;
		timeAnimationIn_	= 0.0f;
		timeAnimationOut_	= 0.0f;
		
		cachedNotifications_ = [[CCArray alloc] initWithCapacity:4];
		
		//Default settings
		showingTime_		= 4.0f;
		position_			= kCCNotificationPositionTop;
		
		[self setAnimation:kCCNotificationAnimationMovement time:0.5f];
		//[self setAnimationIn:kCCNotificationAnimationMovement time:0.5f];
		//[self setAnimationOut:kCCNotificationAnimationScale time:0.5f];
	}	
	return self;
}

- (void) _setState:(char)states
{
	if(state_==states) return;
	state_ = states;
	
	if([delegate_ respondsToSelector:@selector(notification:newState:)])
		[delegate_ notification:currentNotification_ newState:state_];
	
	if([delegate_ respondsToSelector:@selector(notificationChangeState:tag:)])
		[delegate_ notificationChangeState:state_ tag:[currentNotification_ tag]];
}

- (void) setPosition:(char)positions
{
	position_ = positions;
	[self updateAnimations];
}

- (void) setNotificationDesign:(CCNode <CCNotificationDesignProtocol>*) templates
{
	if(state_!=kCCNotificationStateHide)
		[template_ stopAllActions];

	if(state_==kCCNotificationStateShowing)
	{
		[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
		[[CCScheduler sharedScheduler] unscheduleSelector:@selector(_hideNotificationScheduler) forTarget:self];		
	}
	
	[templates retain];
	[template_ release];
	template_ = templates;
	[template_ setVisible:NO];
	[template_ setIsRelativeAnchorPoint:YES];
	
	[self _setState:kCCNotificationStateHide];
}
#pragma mark Notification Actions

- (CCActionInterval*) _animation:(char)type time:(ccTime)time
{
	CCActionInterval *action = nil;
	switch (type){
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
	CCActionInterval *tempAction = [self _animation:typeAnimationOut_ time:timeAnimationOut_];
	self.animationOut = [CCSequence actionOne:[tempAction reverse] two:[CCCallFunc actionWithTarget:self selector:@selector(_hideNotification)]];
}

- (void) updateAnimations
{
	[self _updateAnimationIn];
	[self _updateAnimationOut];
}

- (void) setAnimationIn:(char)type time:(ccTime)time
{
	typeAnimationIn_ = type;
	timeAnimationIn_ = time;
	[self _updateAnimationIn];
}

- (void) setAnimationOut:(char)type time:(ccTime)time
{
	typeAnimationOut_ = type;
	timeAnimationOut_ = time;
	[self _updateAnimationOut];
}

- (void) setAnimation:(char)type time:(ccTime)time
{
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
	
	//Release current notification
	[cachedNotifications_ removeObject:currentNotification_];
	self.currentNotification = nil;
	
	//Check next notification
	[self _showNotification];
}

- (void) _hideNotificationScheduler
{	
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[[CCScheduler sharedScheduler] unscheduleSelector:@selector(_hideNotificationScheduler) forTarget:self];
	if([currentNotification_ animated])
	{
		[self _setState:kCCNotificationStateAnimationOut];
		[template_ runAction:animationOut_];
	}else
		[self _hideNotification];
}

#pragma mark Manager Notifications

- (void) _addNotificationToArray:(ccNotificationData*)data cached:(BOOL)isCached
{
	if(isCached)
	{
		[cachedNotifications_ addObject:data];
		if([cachedNotifications_ count]==1)
			[self _showNotification];
	}else{
		if(currentNotification_)
		{
			[cachedNotifications_ removeObject:currentNotification_];
		}
		[cachedNotifications_ insertObject:data atIndex:0];
		[self _showNotification];
	}
}

- (ccNotificationData*) addWithTitle:(NSString*)title message:(NSString*)message image:(NSString*)image tag:(int)tag animate:(BOOL)animate waitUntilDone:(BOOL)isCached
{
	ccNotificationData *data = [[ccNotificationData alloc] init];
	data.title		= title;
	data.message	= message;
	data.media		= image;
	data.mediaType  = kCCNotificationMediaPath;
	data.tag		= tag;
	data.animated	= animate;
	
	[self _addNotificationToArray:data cached:isCached];
	[data release];
	return data;
}

- (ccNotificationData*) addWithTitle:(NSString*)title message:(NSString*)message texture:(CCTexture2D*)texture tag:(int)tag animate:(BOOL)animate waitUntilDone:(BOOL)isCached
{
	ccNotificationData *data = [[ccNotificationData alloc] init];
	data.title		= title;
	data.message	= message;
	data.media		= texture;
	data.mediaType  = kCCNotificationMediaTexture;
	data.tag		= tag;
	data.animated	= animate;
	
	[self _addNotificationToArray:data cached:isCached];
	[data release];
	return data;
}

- (ccNotificationData*) addWithTitle:(NSString*)title message:(NSString*)message image:(NSString*)image tag:(int)tag animate:(BOOL)animate
{
	return [self addWithTitle:title message:message image:image tag:tag animate:animate waitUntilDone:YES];
}

- (ccNotificationData*) addWithTitle:(NSString*)title message:(NSString*)message texture:(CCTexture2D*)texture tag:(int)tag animate:(BOOL)animate
{
	return [self addWithTitle:title message:message texture:texture tag:tag animate:animate waitUntilDone:YES];
}

/* Fast methods */

- (ccNotificationData*) addWithTitle:(NSString*)title message:(NSString*)message image:(NSString*)image
{
	return [self addWithTitle:title message:message image:image tag:-1 animate:YES waitUntilDone:YES];
}

- (ccNotificationData*) addWithTitle:(NSString*)title message:(NSString*)message texture:(CCTexture2D*)texture
{
	return [self addWithTitle:title message:message texture:texture tag:-1 animate:YES waitUntilDone:YES];
}

/* Deprecated */
- (void) addSafelyWithTitle:(NSString*)title message:(NSString*)message image:(NSString*)image tag:(int)tag animate:(BOOL)animate
{
	[self addWithTitle:title message:message image:image tag:tag animate:animate waitUntilDone:YES];
}


- (void) _showNotification
{
	if([cachedNotifications_ count]==0) return;
	//Get notification data
	self.currentNotification = [cachedNotifications_ objectAtIndex:0];
	
	//Stop system
	if(state_==kCCNotificationStateShowing)
		[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	
	if(state_!=kCCNotificationStateHide)
	{
		[self _setState:kCCNotificationStateHide];
		
		[template_ setVisible:NO];
		[template_ stopAllActions];
		[template_ onExit];
		[[CCScheduler sharedScheduler] unscheduleSelector:@selector(_hideNotificationScheduler) forTarget:self];
	}
	
	//Get variables
	CCTexture2D *texture = (currentNotification_.media) ? ((currentNotification_.mediaType==kCCNotificationMediaTexture) ? (CCTexture2D*)currentNotification_.media : [[CCTextureCache sharedTextureCache] addImage:(NSString*)currentNotification_.media]) : nil;
	
	//Prepare template
	[template_ setVisible:NO];
	[template_ stopAllActions];
	[template_ onExit];
	
	//Prepare animation
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	if(currentNotification_.animated)
	{
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
			
		}else if(position_==kCCNotificationPositionTop)
		{
			[template_ setAnchorPoint:ccp(0.5f, 1)];
			switch (typeAnimationIn_){
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
	
	//Update template
	[template_ setTitle:[currentNotification_ title] message:[currentNotification_ message] texture:texture];
	[template_ setVisible:YES];
}

#pragma mark Touch Events

- (void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addStandardDelegate:self priority:INT_MIN];
}

- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint point = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
	CGRect rect = [template_ boundingBox];
	if(CGRectContainsPoint(rect, point))
		if([delegate_ respondsToSelector:@selector(touched:)] && [delegate_ touched:[currentNotification_ tag]])
			[self _hideNotificationScheduler];
}

#pragma mark Other methods

- (void) visit
{	
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
	[cachedNotifications_ release];
	[self setCurrentNotification:nil];
	[self setNotificationDesign:nil];
	[self setDelegate:nil];
	[self setAnimationIn:nil];
	[self setAnimationOut:nil];
	[super dealloc];
}
@end