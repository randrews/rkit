//
//  RKitView.h
//  RKit
//
//  Created by Ross Andrews on 11/19/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RKitView : NSView {
    /* Dependency injection. rkit.m (it'll have to be .m) will define
       a function that draws the screen. We'll store a pointer to it here,
       and when Cocoa wants to redraw, our drawRect method will call
       that function. */
    void (*redraw)(NSRect);
    void (*keydown)(const char*,int);
    void (*timer_hook)(int);
}

-(void) drawRect: (NSRect) rect;
-(void) setRedraw: (void (*)(NSRect)) redraw_p;

-(BOOL) acceptsFirstResponder;
-(void) keyDown: (NSEvent*) event;
-(void) setKeydown: (void (*)(const char*,int)) keydown_p;

-(void) callTimer: (NSTimer*) timer_fn_index;
-(void) setTimerHook: (void (*)(int)) timer_hook_p;

@end
