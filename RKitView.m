#include "rkit.h"

@implementation RKitView

/*************************************************/
/*** Drawing stuff *******************************/
/*************************************************/

- (void) drawRect: (NSRect) rect {
  if(redraw){ redraw(rect); }
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

@end
