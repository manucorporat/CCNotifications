//
//  SampleAppDelegate.h
//  Sample
//
//  Created by Manuel Martinez-Almeida Castañeda on 12/07/10.
//  Copyright Abstraction Works 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

//Import CCNotifications
#import "CCNotifications.h"

@interface SampleAppDelegate : NSObject <UIApplicationDelegate, CCNotificationsDelegate> {
	UIWindow *window;
}

@property (nonatomic, retain) UIWindow *window;

@end
