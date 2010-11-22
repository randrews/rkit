//
//  RKitAppDelegate.m
//  RKit
//
//  Created by Ross Andrews on 11/17/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "RKitAppDelegate.h"

@implementation RKitAppDelegate

@synthesize window;
@synthesize rkit_view;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	lua_State *L = lua_open();
	luaL_openlibs(L);
	open_rkit(L, rkit_view, window);
	NSString *path = [[NSBundle mainBundle] pathForResource: @"rkit" ofType: @"lua"];
	NSString *code = [NSString stringWithFormat: @"dofile(\"%@\")", path];
	[self setupLuaState: L withCode: [code UTF8String]];
	new_game();
}

-(void) applicationWillTerminate: (NSNotification *)notification {
	close_rkit();
}

-(BOOL) setupLuaState: (lua_State*) L withCode: (const char*) code {
	int lua_error = luaL_loadbuffer(L, code, strlen(code), "line") || lua_pcall(L, 0, 0, 0);
	
	if(lua_error){ [self logLuaErrorFrom: L]; }
	return !lua_error;	
}

-(void) logLuaErrorFrom:(lua_State *)L {
	NSLog(@"%s\n", lua_tostring(L, -1));
	lua_pop(L, 1);
}

-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication*) app {
    return YES;
}

-(void) restartGame: (id) sender {
	new_game();
}
@end
