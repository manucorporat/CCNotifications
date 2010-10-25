//
//  CCNotificationsAppDelegate.h
//  CCNotifications
//
//  Created by Manuel Martinez-Almeida on 25/10/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCNotifications.h"


@interface CCNotificationsAppDelegate : NSObject <UIApplicationDelegate, CCNotificationsDelegate> {
	UIWindow *window;
}

@property (nonatomic, retain) UIWindow *window;

@end
