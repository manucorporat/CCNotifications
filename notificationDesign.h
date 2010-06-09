//
//  CCNotifications
//
//  Created by Manuel Martinez-Almeida Castañeda.
//  Copyright 2010 Abstraction Works. All rights reserved.
//	http://www.abstractionworks.com
//

#import <Foundation/Foundation.h>
#import "CCNotifications.h"
#import "cocos2d.h"

@interface CCNotificationDefaultDesign : CCColorLayer <CCNotificationsDesignProtocol>
{
	CCLabel *title_;
	CCLabel *message_;
	CCSprite *image_;
}

@end
