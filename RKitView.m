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

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {}
    return self;
}

/*************************************************/
/*** Drawing stuff *******************************/
/*************************************************/

- (void)drawRect:(NSRect)dirtyRect {
	lua_getglobal(lua, "print");
	lua_pushstring(lua, "redraw");
	lua_gettable(lua, LUA_REGISTRYINDEX);
	if(!lua_isnil(lua, -1)){
		lua_pcall(lua, 0, 0, -2);
	}
}

/*************************************************/
/*** Keyboard stuff ******************************/
/*************************************************/

-(void) keyDown: (NSEvent*) event {
	lua_getglobal(lua, "print");
	lua_pushstring(lua, "input");
	lua_gettable(lua, LUA_REGISTRYINDEX);
	if(!lua_isnil(lua, -1)){
		lua_pushstring(lua, [[event characters] UTF8String]);
		lua_pushinteger(lua, [event keyCode]);
		lua_pcall(lua, 2, 0, -4);
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
	lua_getglobal(lua, "print");
	lua_pushstring(lua, "mouse");
	lua_gettable(lua, LUA_REGISTRYINDEX);
	if(!lua_isnil(lua, -1)){
		lua_pushstring(lua, [type UTF8String]);
		lua_pushinteger(lua, point.x);
		lua_pushinteger(lua, point.y);
		lua_pushinteger(lua, [NSEvent pressedMouseButtons]);
		lua_pcall(lua, 4, 0, -6);
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
@end
