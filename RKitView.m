//
//  RKitView.m
//  RKit
//
//  Created by Ross Andrews on 11/19/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "rkit.h"

@implementation RKitView

@synthesize lua;
@synthesize redraw;
@synthesize keydown;
@synthesize mouse;
@synthesize timer_hook;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {}
    return self;
}

/*************************************************/
/*** Drawing stuff *******************************/
/*************************************************/

- (void)drawRect:(NSRect)dirtyRect {
	if(redraw){ redraw(lua, [self frame]); }
}

/*************************************************/
/*** Keyboard stuff ******************************/
/*************************************************/

-(void) keyDown: (NSEvent*) event {
	if(keydown){
		keydown(lua, [[event characters] UTF8String],
					 [event keyCode]);
	}
}

/*************************************************/
/*** Behavior ************************************/
/*************************************************/

-(BOOL) acceptsFirstResponder { return YES; }
-(BOOL) mouseDownCanMoveWindow { return NO; }

/*************************************************/
/*** Keyboard stuff ******************************/
/*************************************************/

-(void) handleMouseEvent: (NSEvent*) event ofType: (NSString*) type {
	NSPoint point = [event locationInWindow];
	if(mouse){
		mouse(lua,
			  [type UTF8String],
			  point.x, point.y,
			  [NSEvent pressedMouseButtons]);
	}
}

-(void) mouseDown: (NSEvent*) event { [self handleMouseEvent: event ofType: @"mousedown"]; }
-(void) rightMouseDown: (NSEvent*) event { [self handleMouseEvent: event ofType: @"mousedown"]; }
-(void) mouseUp: (NSEvent*) event { [self handleMouseEvent: event ofType: @"mouseup"]; }
-(void) mouseDragged: (NSEvent*) event { [self handleMouseEvent: event ofType: @"mousedragged"]; }

-(void) mouseMoved: (NSEvent*) event {
	if([self mouse: [event locationInWindow] inRect: [self frame]]){
		[self handleMouseEvent: event ofType: @"mousemoved"];
	}
}

/*************************************************/
/*** Timer stuff *********************************/
/*************************************************/

-(void) callTimer: (NSTimer*) timer {
	int timer_num = [[timer userInfo] intValue];
	if(timer_hook){ timer_hook(lua, timer_num); }
}

@end
