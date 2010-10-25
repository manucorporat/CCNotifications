/*
 * CCNotifications
 *
 * Copyright (c) 2010 ForzeField Studios S.L.
 * http://forzefield.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


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
