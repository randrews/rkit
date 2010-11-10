#include "rkit.h"

@implementation RKitView

/*************************************************/
/*** Drawing stuff *******************************/
/*************************************************/

// -(void) drawLayer: (CALayer*) layer inContext: (CGContextRef) ctx {
// }

- (void) drawRect: (NSRect) rect {
	if(redraw){ redraw([self frame]); }
}

-(void) setRedraw: (void (*)(NSRect)) redraw_p {
	redraw = redraw_p;
}

/*************************************************/
/*** Keyboard stuff ******************************/
/*************************************************/

-(BOOL) acceptsFirstResponder { return YES; }

-(void) keyDown: (NSEvent*) event {
	if(keydown){
		keydown([[event characters] UTF8String],
				[event keyCode]);
	}
}

-(void) setKeydown: (void (*)(const char*,int)) keydown_p {
	keydown = keydown_p;
}

/*************************************************/
/*** Timer stuff *********************************/
/*************************************************/

-(void) callTimer: (NSTimer*) timer {
	int timer_num = [[timer userInfo] intValue];
	if(timer_hook){ timer_hook(timer_num); }
}

-(void) setTimerHook: (void (*)(int)) timer_hook_p {
	timer_hook = timer_hook_p;
}

@end

/*************************************************/
/*** Layer stuff *********************************/
/*************************************************/

@implementation MobDelegate

-(void) drawLayer: (CALayer*) layer inContext: (CGContextRef) ctx {
	NSLog(@"layer: %@", layer);
	NSLog(@"ctx: %@", ctx);
}

@end
