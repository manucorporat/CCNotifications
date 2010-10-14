//
//  CCNotifications
//
//  Created by Manuel Martinez-Almeida Castañeda.
//  Copyright 2010 Abstraction Works. All rights reserved.
//	http://www.abstractionworks.com
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#define KNOTIFICATIONMIN_SCALE 0.0001f

@interface ccNotificationData : NSObject
{
	NSString *title_;
	NSString *message_;
	id media_;
	int mediaType_;
	int tag_;
	BOOL animated_;
}
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *message;
@property(nonatomic, retain) id media;
@property(nonatomic, readwrite, assign) int mediaType;
@property(nonatomic, readwrite, assign) int tag;
@property(nonatomic, readwrite, assign) BOOL animated;

@end

@protocol CCNotificationsDelegate <NSObject>
@optional
- (void) notification:(ccNotificationData*)notification newState:(char)state;
- (BOOL) touched:(int)tag;
- (void) notificationChangeState:(char)state tag:(int)tag DEPRECATED_ATTRIBUTE;
@end

@protocol CCNotificationDesignProtocol <NSObject>
- (void) setTitle:(NSString*)title message:(NSString*)message texture:(CCTexture2D*)texture;
@end

enum
{
	kCCNotificationStateHide = 0,
	kCCNotificationStateAnimationOut,
	kCCNotificationStateShowing,
	kCCNotificationStateAnimationIn,
};

enum
{
	kCCNotificationPositionBottom = 0,
	kCCNotificationPositionTop,
};

enum
{
	kCCNotificationAnimationMovement = 0,
	kCCNotificationAnimationScale,
};

enum
{
	kCCNotificationMediaPath,
	kCCNotificationMediaTexture,
};

@interface CCNotifications : NSObject <CCStandardTouchDelegate>
{
	id <CCNotificationsDelegate>			delegate_;
	CCNode <CCNotificationDesignProtocol>	*template_;
	char									state_;
	char									position_;
	ccTime									showingTime_;
	ccTime									timeAnimationIn_;
	ccTime									timeAnimationOut_;
	char									typeAnimationIn_;
	char									typeAnimationOut_;
	
	//Caching
	CCArray									*cachedNotifications_;
	ccNotificationData						*currentNotification_;
	
	CCActionInterval						*animationIn_;
	CCActionInterval						*animationOut_;
}
@property(nonatomic, retain) id <CCNotificationsDelegate> delegate;
@property(nonatomic, retain) CCNode <CCNotificationDesignProtocol> *notificationDesign;
@property(nonatomic, retain) CCActionInterval *animationIn;
@property(nonatomic, retain) CCActionInterval *animationOut;
@property(nonatomic, retain) ccNotificationData *currentNotification;
@property(nonatomic, readwrite, assign) char position;
@property(nonatomic, readwrite, assign) ccTime showingTime;

+ (CCNotifications *) sharedManager;
+ (void) purgeSharedManager;
+ (id) systemWithTemplate:(CCNode <CCNotificationDesignProtocol> *)notifications;

- (id) initWithTemplate:(CCNode <CCNotificationDesignProtocol> *)templates;
- (void) setAnimationIn:(char)type time:(ccTime)time;
- (void) setAnimationOut:(char)type time:(ccTime)time;
- (void) setAnimation:(char)type time:(ccTime)time;
- (void) updateAnimations;

- (ccNotificationData*) addWithTitle:(NSString*)title message:(NSString*)message image:(NSString*)image tag:(int)tag animate:(BOOL)animate waitUntilDone:(BOOL)isCached;
- (ccNotificationData*) addWithTitle:(NSString*)title message:(NSString*)message texture:(CCTexture2D*)texture tag:(int)tag animate:(BOOL)animate waitUntilDone:(BOOL)isCached;

- (ccNotificationData*) addWithTitle:(NSString*)title message:(NSString*)message image:(NSString*)image tag:(int)tag animate:(BOOL)animate;
- (ccNotificationData*) addWithTitle:(NSString*)title message:(NSString*)message texture:(CCTexture2D*)texture tag:(int)tag animate:(BOOL)animate;

- (ccNotificationData*) addWithTitle:(NSString*)title message:(NSString*)message image:(NSString*)image;
- (ccNotificationData*) addWithTitle:(NSString*)title message:(NSString*)message texture:(CCTexture2D*)texture;

- (void) addSafelyWithTitle:(NSString*)title message:(NSString*)message image:(NSString*)image tag:(int)tag animate:(BOOL)animate DEPRECATED_ATTRIBUTE;


- (void) visit;
@end
