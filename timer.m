/*
 *  timer.m
 *  RKit
 *
 *  Created by Ross Andrews on 11/25/10.
 *  Copyright 2010 None. All rights reserved.
 *
 */

#include "rkit.h"

int create_timer(lua_State *L){
	if(!lua_isfunction(L, 1)){ luaL_typerror(L, 1, "function"); }
	double delay = (double)(luaL_checknumber(L, 2));
	
	lua_pushvalue(L, 1);
	int timer_fn_index = luaL_ref(L, LUA_REGISTRYINDEX);
	
	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: delay
													  target: agent(L)
													selector: @selector(callTimer:)
													userInfo: [NSNumber numberWithInt: timer_fn_index]
													 repeats: YES];
	[loaded_objects(L) addObject: timer];
	lua_pushlightuserdata(L, timer);
	return 1;
}

int stop_timer(lua_State *L){
	if(!lua_islightuserdata(L, 1)){ luaL_typerror(L, 1, "timer"); }
	
	NSTimer *timer = (NSTimer*) lua_touserdata(L, 1);
	int timer_idx = [[timer userInfo] intValue];
	
	[timer invalidate];
	luaL_unref(L, LUA_REGISTRYINDEX, timer_idx);
	
	return 0;
}

void rkit_timer_hook(lua_State *L, int timer_fn){
}
