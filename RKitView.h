//
//  RKitView.h
//  RKit
//
//  Created by Ross Andrews on 11/19/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rkit.h"

@interface RKitView : NSView {
    /* Dependency injection. rkit.m (it'll have to be .m) will define
       a function that draws the screen. We'll store a pointer to it here,
       and when Cocoa wants to redraw, our drawRect method will call
       that function. */
    void (*redraw)(lua_State*,NSRect);
    void (*keydown)(lua_State*,const char*,int);
	void (*mouse)(lua_State*,const char*,int,int,int);
    void (*timer_hook)(lua_State*,int);
	lua_State *lua;
}

@property (assign) lua_State *lua;
@property (assign) void (*redraw)(lua_State*,NSRect);
@property (assign) void (*keydown)(lua_State*,const char*,int);
@property (assign) void (*mouse)(lua_State*,const char*,int,int,int);
@property (assign) void (*timer_hook)(lua_State*,int);


-(void) callTimer: (NSTimer*) timer_fn_index;
@end
