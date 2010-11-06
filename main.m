#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#include "rkit.h"

void show_lua_error(lua_State *L);
int init_lua(lua_State *L, char* code);
void lua_console(lua_State *L);

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

	RKitView* rkit_view = [[RKitView alloc] init];
	[window setContentView: rkit_view];

	[window setTitle: @"RKit"];
	[window makeKeyAndOrderFront: NSApp];
	[NSApp run];
	[pool drain];

	/*************************************************/
	/*** Lua stuff ***********************************/
	/*************************************************/

	lua_State *L = lua_open();
	init_lua(L, "require('lua/rkit')");
	/* lua_console(L); */

	/*************************************************/
	/*** Cleanup *************************************/
	/*************************************************/

	lua_close(L);
	close_rkit();

	return 0;
}



int init_lua(lua_State *L, char* code){
	luaL_openlibs(L);
	open_rkit(L);

	int lua_error = luaL_loadbuffer(L, code, strlen(code), "line") || lua_pcall(L, 0, 0, 0);

	if(lua_error){ show_lua_error(L); }
	return !lua_error;
}

void lua_console(lua_State *L){
	char* line = malloc(500);
	char* file_read = line; /* If this is ever null, then we got an EOF */
	int lua_error = 0;

	while(file_read && !lua_error){
		file_read = fgets(line, 500, stdin);

		if(file_read){
			lua_error = luaL_loadbuffer(L, line, strlen(line), "line") || lua_pcall(L, 0, 0, 0);
		}
	}

	/* If we broke out of the loop because of an error (as opposed to EOF), print it */
	if(lua_error){ show_lua_error(L); }

	free(line);
}

void show_lua_error(lua_State *L){
	printf("%s\n", lua_tostring(L, -1));
	lua_pop(L, 1);
}
