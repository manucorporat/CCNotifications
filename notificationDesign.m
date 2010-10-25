//
//  CCNotifications
//
//  Created by Manuel Martinez-Almeida Castañeda.
//  Copyright 2010 Abstraction Works. All rights reserved.
//	http://www.abstractionworks.com
//

#import "notificationDesign.h"

@implementation CCNotificationDefaultDesign

- (id) init
{
	CGSize size = [[CCDirector sharedDirector] winSize];
	self = [self initWithColor:ccc4(42, 68, 148, 180) width:size.width height:38];
	if (self != nil) {
		title_ = [CCLabelTTF labelWithString:@" " fontName:@"Arial" fontSize:12];
		[title_ setIsRelativeAnchorPoint:NO];
		[title_ setAnchorPoint:CGPointZero];
		[title_ setPosition:ccp(52, 20)];
		
		message_ = [CCLabelTTF labelWithString:@" " fontName:@"Arial" fontSize:15];
		[message_ setIsRelativeAnchorPoint:NO];
		[message_ setAnchorPoint:CGPointZero];
		[message_ setPosition:ccp(52, 3)];
		
		image_ = [CCSprite node];
		[image_ setPosition:ccp(26, 19)];
		
		[self addChild:title_];
		[self addChild:message_];
		[self addChild:image_];
	}
	return self;
}

- (void) setTitle:(NSString*)title message:(NSString*)message texture:(CCTexture2D*)texture{
	[title_ setString:title];
	[message_ setString:message];
	if(texture){
		CGRect rect = CGRectZero;
		rect.size = texture.contentSize;
		[image_ setTexture:texture];
		[image_ setTextureRect:rect];
		//Same size 32x32
		[image_ setScaleX:32.0f/rect.size.width];
		[image_ setScaleY:32.0f/rect.size.height];
	}
}

- (void) updateColor
{
	//Gradient code
	ccColor3B colorFinal = ccc3(0, 50, 100);
	
	squareColors[0] = color_.r;
	squareColors[1] = color_.g;
	squareColors[2] = color_.b;
	squareColors[3] = opacity_;
	
	squareColors[4] = color_.r;
	squareColors[5] = color_.g;
	squareColors[6] = color_.b;
	squareColors[7] = opacity_;
	
	squareColors[8] = colorFinal.r;
	squareColors[9] = colorFinal.g;
	squareColors[10] = colorFinal.b;
	squareColors[11] = opacity_;
	
	squareColors[12] = colorFinal.r;
	squareColors[13] = colorFinal.g;
	squareColors[14] = colorFinal.b;
	squareColors[15] = opacity_;
}

@end
