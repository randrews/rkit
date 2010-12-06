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
    if (self) {
        // Initialization code here.
    }
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

-(BOOL) acceptsFirstResponder { return YES; }

-(void) keyDown: (NSEvent*) event {
	if(keydown){
		keydown(lua, [[event characters] UTF8String],
					 [event keyCode]);
	}
}

-(BOOL) mouseDownCanMoveWindow { return NO; }

-(void) mouseDown: (NSEvent*) event {
	if(mouse){
		NSPoint pt = [event locationInWindow];
		mouse(lua, pt.x, pt.y, "mousedown");
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
