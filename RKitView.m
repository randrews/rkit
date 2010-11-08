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
	NSLog(@"Fnar: %@", event);
}

-(void) setKeydown: (void (*)()) keydown_p {
	keydown = keydown_p;
}

@end
