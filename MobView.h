//
//  MobView.h
//  RKit
//
//  Created by Ross Andrews on 11/20/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rkit.h"

@interface MobView : NSView {
    void (*redraw)(lua_State*, NSRect, int);
    int luaFunction;
	lua_State *lua;
}

@property (assign) lua_State *lua;
@property int luaFunction;
@property (assign) void (*redraw)(lua_State*, NSRect, int);

-(void) drawRect: (NSRect) rect;

@end
