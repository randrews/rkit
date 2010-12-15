/*
 *  mob.m
 *  RKit
 *
 *  Created by Ross Andrews on 11/25/10.
 *  Copyright 2010 None. All rights reserved.
 *
 */

#import "rkit.h"

int create_mob(lua_State *L){
	int x = luaL_checkinteger(L, 1);
	int y = luaL_checkinteger(L, 2);
	int w = luaL_checkinteger(L, 3);
	int h = luaL_checkinteger(L, 4);
	if(!lua_isfunction(L, 5)){ luaL_typerror(L, 5, "function"); }
	lua_pushvalue(L, 5);
	int fn = luaL_ref(L, LUA_REGISTRYINDEX); /* Shove this in the registry */

	NSView *parent;
	if(lua_gettop(L) >= 6){ /* They specified a parent */
		if(!lua_islightuserdata(L,6)){ luaL_typerror(L, 6, "mob"); }
		parent = (MobView*) lua_touserdata(L, 6);
	} else {
		parent = rkit_view(L);
	}
	
	MobView *mob = [[[MobView alloc] initWithFrame:NSMakeRect(x, y, w, h)] autorelease];
	[mob setLua: L];
	[mob setWantsLayer: YES];
	[mob setRedrawFunction: fn];
	[parent addSubview: mob];
	[mob setNeedsDisplay: YES];

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