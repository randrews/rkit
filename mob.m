/*
 *  mob.m
 *  RKit
 *
 *  Created by Ross Andrews on 11/25/10.
 *  Copyright 2010 None. All rights reserved.
 *
 */

#import "rkit.h"

void mob_redraw_callback(lua_State *L, NSRect rect, int lua_function){
	lua_pushinteger(L, lua_function);
	lua_gettable(L, LUA_REGISTRYINDEX);
	lua_call(L, 0, 0);
}

int create_mob(lua_State *L){
	int x = luaL_checkinteger(L, 1);
	int y = luaL_checkinteger(L, 2);
	int w = luaL_checkinteger(L, 3);
	int h = luaL_checkinteger(L, 4);
	if(!lua_isfunction(L, 5)){ luaL_typerror(L, 5, "function"); }
	lua_pushvalue(L, 5);
	int fn = luaL_ref(L, LUA_REGISTRYINDEX); /* Shove this in the registry */
	
	MobView *mob = [[MobView alloc] init];
	[mob setWantsLayer: YES];
	[mob setFrame: NSMakeRect(x, y, w, h)];
	[mob setRedraw: mob_redraw_callback];
	[mob setLuaFunction: fn];
	[rkit_view(L) addSubview: mob];
	
	[loaded_objects(L) addObject: mob];
	lua_pushlightuserdata(L, mob);
	return 1;
}

int move_mob(lua_State *L){
	if(!lua_islightuserdata(L, 1)){ luaL_typerror(L, 1, "mob"); }
	MobView *mob = (MobView*) lua_touserdata(L, 1);
	int x = luaL_checkinteger(L, 2);
	int y = luaL_checkinteger(L, 3);
	
	[[mob animator] setFrame: NSMakeRect(x,  y,
										 [mob frame].size.width,
										 [mob frame].size.height)];
	return 0;
}

int teleport_mob(lua_State *L){
	if(!lua_islightuserdata(L, 1)){ luaL_typerror(L, 1, "mob"); }
	MobView *mob = (MobView*) lua_touserdata(L, 1);
	int x = luaL_checkinteger(L, 2);
	int y = luaL_checkinteger(L, 3);
	
	[mob setFrame: NSMakeRect(x,  y,
							  [mob frame].size.width,
							  [mob frame].size.height)];
	return 0;
}

int close_mob(lua_State *L){
	if(!lua_islightuserdata(L, 1)){ luaL_typerror(L, 1, "mob"); }
	MobView *mob = (MobView*) lua_touserdata(L, 1);
	[mob removeFromSuperview];
	[loaded_objects(L) removeObjectIdenticalTo: mob];
	[mob release];
	return 0;
}