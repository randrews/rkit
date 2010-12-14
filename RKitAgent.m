//
//  RKitAgent.m
//  RKit
//
//  Created by Ross Andrews on 11/24/10.
//  Copyright 2010 None. All rights reserved.
//

#import "rkit.h"


@implementation RKitAgent

@synthesize window;
@synthesize rkit_view;
@synthesize lua;
@synthesize file;
@synthesize log;
@synthesize log_drawer;

//////////////////////////////////////////////////////////////////
/// Utility methods //////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

-(void) logLuaError {
	NSString *msg = [NSString stringWithFormat: @"%s\n", lua_tostring(lua, -1)];
	[self addToLog: msg];
	lua_pop(lua, 1);
}

-(void) closeLua {
	close_rkit(lua);
	lua_close(lua);
	lua = 0;	
}

-(BOOL) runLuaCode: (const char*) code {
	int lua_error = luaL_loadbuffer(lua, code, strlen(code), "line") || lua_pcall(lua, 0, 0, 0);
	
	if(lua_error){ [self logLuaError]; }
	return !lua_error;	
}

-(void) runFile {
	NSString *code = [NSString stringWithFormat: @"dofile(\"%@\")", file];
	[self runLuaCode: [code UTF8String]];	
}

-(void) runUtils: (NSString*) util_path {
	NSString *util = [NSString stringWithFormat: @"dofile(\"%@\")", util_path];
	[self runLuaCode: [util UTF8String]];	
}

-(void) prepareLua {
	lua = lua_open();
	luaL_openlibs(lua);
	rkit_view.lua = lua;
	open_rkit(lua);
	rkit_set_window(lua, window);
	rkit_set_view(lua, rkit_view);
	rkit_set_agent(lua, self);

	NSString *util_path = [[NSBundle mainBundle] pathForResource:@"util" ofType:@"lua"];
	NSString *util_dir = [util_path stringByDeletingLastPathComponent];
	rkit_add_load_path(lua, [util_dir UTF8String]);
	[self runUtils: util_path];
	
	rkit_add_load_path(lua, [[file stringByDeletingLastPathComponent] UTF8String]);
}

//////////////////////////////////////////////////////////////////
/// Interface methods ////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

-(id) initWithFile: (NSString*) file_p {
	[super init];
	self.file = file_p;
	[NSBundle loadNibNamed:@"rkit_window" owner:self];
	return self;
}

-(void) finalize {
	[super finalize];
}

-(void) awakeFromNib {
	[self prepareLua];
	[self runFile];
}

-(void) windowWillClose: (NSNotification*) notification {
	[self closeLua];
}

-(void) restart: (id) sender {
	[self closeLua];
	[self prepareLua];
	[self runFile];
	[self addToLog: @"Reload\n"];
}

-(NSImage*) loadImage: (const char*) path {
	NSString *ns_path = [NSString stringWithUTF8String: path];
	NSString *real_path = [[NSBundle mainBundle] pathForResource: ns_path ofType: @"png"];
	return [[[NSImage alloc] initWithContentsOfFile: real_path] autorelease];
}

-(void) addToLog: (NSString*) msg {
	[[[log textStorage] mutableString] appendString: msg];
	[[log textStorage] setFont: [NSFont fontWithName: @"Courier" size:12]];
	[log scrollRangeToVisible: NSMakeRange([[log textStorage] length], 0)];
}

/*************************************************/
/*** Timer stuff *********************************/
/*************************************************/

-(void) callTimer: (NSTimer*) timer {
	int timer_num = [[timer userInfo] intValue];
	lua_pushinteger(lua, timer_num);
	lua_gettable(lua, LUA_REGISTRYINDEX);
	lua_call(lua, 0, 0);
}
@end
