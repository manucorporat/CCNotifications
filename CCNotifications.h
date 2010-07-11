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

@protocol CCNotificationsDelegate <NSObject>
@optional
- (void) notificationChangeState:(char)state tag:(int)tag;
- (BOOL) touched:(int)tag;
@end

@protocol CCNotificationDesignProtocol <NSObject>
- (void) setTitle:(NSString*)title message:(NSString*)message texture:(CCTexture2D*)texture;
@end

enum
{
	kCCNotificationStateHide,
	kCCNotificationStateAnimationOut,
	kCCNotificationStateShowing,
	kCCNotificationStateAnimationIn,
};

enum
{
	kCCNotificationPositionBottom,
	kCCNotificationPositionTop,
};

enum
{
	kCCNotificationAnimationMovement,
	kCCNotificationAnimationScale,
};

@interface ccNotificationData : NSObject
{
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

@interface CCNotifications : NSObject <CCStandardTouchDelegate>
{
	id <CCNotificationsDelegate>			delegate_;
	CCNode <CCNotificationDesignProtocol>	*template_;
	ccNotificationData						*cachedNotificationData_;
	char									state_;
	char									position_;
	int										tag_;
	ccTime									showingTime_;
	ccTime									timeAnimationIn_;
	ccTime									timeAnimationOut_;
	char									typeAnimationIn_;
	char									typeAnimationOut_;
	BOOL									animated_;
	
	CCIntervalAction						*animationIn_;
	CCIntervalAction						*animationOut_;
}
@property(nonatomic, retain) id <CCNotificationsDelegate> delegate;
@property(nonatomic, retain) CCNode <CCNotificationDesignProtocol> *notificationDesign;
@property(nonatomic, retain) CCIntervalAction *animationIn;
@property(nonatomic, retain) CCIntervalAction *animationOut;
@property(nonatomic, retain) ccNotificationData *cachedNotificationData;
@property(nonatomic, readwrite, assign) ccTime showingTime;

+ (CCNotifications *) sharedManager;
+ (void) purgeSharedManager;
+ (id) systemWithTemplate:(CCNode <CCNotificationDesignProtocol> *)notifications;

- (id) initWithTemplate:(CCNode <CCNotificationDesignProtocol> *)templates;
- (void) setAnimationIn:(char)type time:(ccTime)time;
- (void) setAnimationOut:(char)type time:(ccTime)time;
- (void) setAnimation:(char)type time:(ccTime)time;
- (void) updateAnimations;
- (void) addSafelyWithTitle:(NSString*)title message:(NSString*)message image:(NSString*)image tag:(int)tag animate:(BOOL)animate;
- (void) addWithTitle:(NSString*)title message:(NSString*)message texture:(CCTexture2D*)texture tag:(int)tag animate:(BOOL)animate;
- (void) addWithTitle:(NSString*)title message:(NSString*)message image:(NSString*)image tag:(int)tag animate:(BOOL)animate;
- (void) visit;
@end
