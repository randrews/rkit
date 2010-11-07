#include "rkit.h"

@implementation RKitView

- (void) drawRect: (NSRect) rect {
  if(redraw){ redraw(rect); }
}

-(void) setRedraw: (void (*)(NSRect)) redraw_p {
	redraw = redraw_p;
}

@end
