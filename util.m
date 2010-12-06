/*
 *  util.c
 *  RKit
 *
 *  Created by Ross Andrews on 11/25/10.
 *  Copyright 2010 None. All rights reserved.
 *
 */

#import "rkit.h"

void rkit_register_value(lua_State *L, const char *key, void *value){
	lua_pushstring(L, key);
	lua_pushlightuserdata(L, value);
	lua_settable(L, LUA_REGISTRYINDEX);
}

void* get_value(lua_State *L, const char *key){
	lua_pushstring(L, key);
	lua_gettable(L, LUA_REGISTRYINDEX);
	return lua_touserdata(L, -1);
}

void set_handler(lua_State *L, const char *name){
	int handler_set = !(lua_isnoneornil(L, 1)); /* Check whether we set or cleared the handler */
	
	/* If this is an invalid handler... */
	if(handler_set && !lua_isfunction(L, 1)){ luaL_typerror(L, 1, "function"); }
	
	lua_pushstring(L, name);
	lua_pushvalue(L, 1);
	lua_settable(L, LUA_REGISTRYINDEX); /* Shove this in the registry */
}

/////////////////////////////////////////////////////////

void rkit_set_window(lua_State *L, NSWindow *window){
	rkit_register_value(L, "window", window);
	[window retain];
}

void rkit_set_agent(lua_State *L, RKitAgent *agent){
	rkit_register_value(L, "agent", agent);
	[agent retain];
}

NSMutableArray* loaded_sheets(lua_State *L){
	return (NSMutableArray*)get_value(L, "loaded_sheets");
}

NSMutableArray* loaded_objects(lua_State *L){
	return (NSMutableArray*)get_value(L, "loaded_objects");
}

NSWindow* window(lua_State *L){
	return (NSWindow*)get_value(L, "window");
}

RKitView* rkit_view(lua_State *L){
	return (RKitView*)get_value(L, "rkit_view");
}

RKitAgent* agent(lua_State *L){
	return (RKitAgent*)get_value(L, "agent");
}

int set_input_handler(lua_State *L){
	set_handler(L, "input");
	return 0;
}

int set_mouse_handler(lua_State *L){
	set_handler(L, "mouse");
	return 0;
}

int set_redraw_handler(lua_State *L){
	set_handler(L, "redraw");
	return 0;
}

int set_new_game(lua_State *L){
	set_handler(L, "new_game");
	return 0;
}
