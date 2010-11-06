#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#include "rkit.h"

int main(int argc, char** argv){
	/*************************************************/
	/*** Cocoa stuff *********************************/
	/*************************************************/

	objc_startCollectorThread();
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[NSApplication sharedApplication];

	int style = NSTitledWindowMask |
		NSClosableWindowMask |
		NSResizableWindowMask |
		NSMiniaturizableWindowMask;

	NSWindow *window = [[NSWindow alloc]
						   initWithContentRect: NSMakeRect(0, 0, 1024, 768)
						   styleMask: style
						   backing: NSBackingStoreBuffered
						   defer: NO];

	[window setTitle: @"RKit"];
	[window makeKeyAndOrderFront: NSApp];
	[NSApp run];
	[pool drain];

	/*************************************************/
	/*** Lua stuff ***********************************/
	/*************************************************/

	lua_State *L = lua_open();
	luaL_openlibs(L);
	open_rkit(L);

	char* code = "require('lua/rkit')";
	char* line = malloc(500);
	char* file_read = line;
	int lua_error = luaL_loadbuffer(L, code, strlen(code), "line") || lua_pcall(L, 0, 0, 0);

	while(file_read && !lua_error){
		file_read = fgets(line, 500, stdin);

		if(file_read){
			lua_error = luaL_loadbuffer(L, line, strlen(line), "line") || lua_pcall(L, 0, 0, 0);
		}
	}

	if(lua_error){
		printf("%s\n", lua_tostring(L, -1));
		lua_pop(L, 1);
	}

	/*************************************************/
	/*** Cleanup *************************************/
	/*************************************************/

	lua_close(L);
	close_rkit();
	free(line);

	return 0;
}
