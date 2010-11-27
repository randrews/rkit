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

//////////////////////////////////////////////////////////////////
/// Utility methods //////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

-(void) logLuaError {
	NSLog(@"%s\n", lua_tostring(lua, -1));
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

-(void) prepareLua {
	lua = lua_open();
	luaL_openlibs(lua);
	rkit_view.lua = lua;
	open_rkit(lua);
	rkit_set_window(lua, window);
	rkit_set_view(lua, rkit_view);
	rkit_set_agent(lua, self);	
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
	NSLog(@"Releasing %@", self);
	[super finalize];
}

-(void) awakeFromNib {
	[self prepareLua];
	[self runFile];
}

-(void) windowWillClose: (NSNotification*) notification {
	NSLog(@"Closing");
	[self closeLua];
}

-(void) restart: (id) sender {
	[self closeLua];
	[self prepareLua];
	[self runFile];
	NSLog(@"Reload");
}

-(NSImage*) loadImage: (const char*) path {
	NSString *ns_path = [NSString stringWithUTF8String: path];
	NSString *real_path = [[NSBundle mainBundle] pathForResource: ns_path ofType: @"png"];
	return [[[NSImage alloc] initWithContentsOfFile: real_path] autorelease];
}

@end
