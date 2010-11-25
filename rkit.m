#import "rkit.h"

NSMutableArray *loaded_sheets, *loaded_objects;

lua_State *event_target; /* The Lua state we'll send event notifications to, redraw and input */

/*************************************************/
/*** Event handler registration ******************/
/*************************************************/

void set_handler(lua_State *L, const char *name){
	int handler_set = !(lua_isnoneornil(L, 1)); /* Check whether we set or cleared the handler */

	/* If this is an invalid handler... */
	if(handler_set && !lua_isfunction(L, 1)){ luaL_typerror(L, 1, "function"); }

	lua_pushstring(L, name);
	lua_pushvalue(L, 1);
	lua_settable(L, LUA_REGISTRYINDEX); /* Shove this in the registry */
}

int set_input_handler(lua_State *L){
	set_handler(L, "input");
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

/*************************************************/
/*** Timer functions *****************************/
/*************************************************/

int create_timer(lua_State *L){
	if(!lua_isfunction(L, 1)){ luaL_typerror(L, 1, "function"); }
	double delay = (double)(luaL_checknumber(L, 2));

	lua_pushvalue(L, 1);
	int timer_fn_index = luaL_ref(L, LUA_REGISTRYINDEX);

	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: delay
													  target: rkit_view(L)
													selector: @selector(callTimer:)
													userInfo: [NSNumber numberWithInt: timer_fn_index]
													 repeats: YES];
	[timer retain];

	[loaded_objects addObject: timer];
	lua_pushlightuserdata(L, timer);
	return 1;
}

int stop_timer(lua_State *L){
	if(!lua_islightuserdata(L, 1)){ luaL_typerror(L, 1, "timer"); }

	NSTimer *timer = (NSTimer*) lua_touserdata(L, 1);
	int timer_idx = [[timer userInfo] intValue];

	[timer invalidate];
	[timer release];
	luaL_unref(L, LUA_REGISTRYINDEX, timer_idx);

	return 0;
}

void rkit_timer_hook(int timer_fn){
	lua_pushinteger(event_target, timer_fn);
	lua_gettable(event_target, LUA_REGISTRYINDEX);
	lua_call(event_target, 0, 0);
}

/*************************************************/
/*** RKit redraw hook ****************************/
/*************************************************/

void redraw(lua_State *L, NSRect rect){
	lua_pushstring(L, "redraw");
	lua_gettable(L, LUA_REGISTRYINDEX);
	if(!lua_isnil(L, -1)){
		lua_call(L, 0, 0);
	}
}

int trigger_redraw(lua_State *L){
	[rkit_view(L) setNeedsDisplay: YES];
	return 0;
}

void new_game(lua_State *L){
	lua_pushstring(L, "new_game");
	lua_gettable(L, LUA_REGISTRYINDEX);
	if(!lua_isnil(L, -1)){
		lua_call(L, 0, 0);
	}
}

/*************************************************/
/*** RKit input functions ************************/
/*************************************************/

void key_down(lua_State *L, const char *letter, int key_code){
	lua_pushstring(L, "input");
	lua_gettable(L, LUA_REGISTRYINDEX);
	if(!lua_isnil(L, -1)){
		lua_pushstring(L, letter);
		lua_pushinteger(L, key_code);
		lua_call(L, 2, 0);
	}
}

/*************************************************/
/*** RKit mob functions **************************/
/*************************************************/

void mob_redraw_callback(NSRect rect, int lua_function){
	lua_pushinteger(event_target, lua_function);
	lua_gettable(event_target, LUA_REGISTRYINDEX);
	lua_call(event_target, 0, 0);
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

	[loaded_objects addObject: mob];
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
	[loaded_objects removeObjectIdenticalTo: mob];
	[mob release];
	return 0;
}

/*************************************************/
/*** Loading the RKit functions ******************/
/*************************************************/

static const struct luaL_reg rkit_lib[] = {
	{"load_bitmap", load_lua_bitmap},
	{"draw_bitmap", draw_bitmap},
	{"load_tilesheet", load_tilesheet},
	{"clear_screen", clear_screen},
	{"set_title", set_title},
	{"color", make_color},
	{"draw_glyph", draw_glyph},
	{"rect", draw_rect},
	{"text", draw_text},
	{"set_input_handler", set_input_handler},
	{"set_redraw_handler", set_redraw_handler},
	{"set_new_game", set_new_game},
	{"redraw", trigger_redraw},
	{"create_timer", create_timer},
	{"stop_timer", stop_timer},
	{"resizable", set_resizable},
	{"resize", resize_window},
	{"create_mob", create_mob},
	{"move_mob", move_mob},
	{"close_mob", close_mob},
	{"teleport_mob", teleport_mob},
	{NULL, NULL}
};

void rkit_register_value(lua_State *L, const char *key, void *value){
	lua_pushstring(L, key);
	lua_pushlightuserdata(L, value);
	lua_settable(L, LUA_REGISTRYINDEX);
}

void rkit_set_window(lua_State *L, NSWindow *window){
	rkit_register_value(L, "window", window);
	[window retain];
}

void rkit_set_view(lua_State *L, RKitView *view){
	rkit_register_value(L, "view", view);
	view.redraw = redraw;
	view.keydown = key_down;
	//view.timer_hook = rkit_timer_hook;
	[view retain];
}

void rkit_set_agent(lua_State *L, RKitAgent *agent){
	rkit_register_value(L, "agent", agent);
	[agent retain];
}

int open_rkit(lua_State *L){
	NSMutableArray *loaded_objects = [[NSMutableArray arrayWithCapacity: 1] retain];
	NSMutableArray *loaded_sheets = [[NSMutableArray arrayWithCapacity: 1] retain];

	rkit_register_value(L, "loaded_objects", loaded_objects);
	rkit_register_value(L, "loaded_sheets", loaded_sheets);

	luaL_openlib(L, "RKit", rkit_lib, 0);
	return 1;
}

/*************************************************/
/*** Closing the RKit functions ******************/
/*************************************************/

void close_rkit(){
	/* Loop over all loaded sheets */
	/* Since we need to do special things to kill tilesheets,
		we can't put them in the same list as everything else */
	for(NSValue *ts_id in loaded_sheets){
		Tilesheet *ts = [ts_id pointerValue];
		[ts->bg_image release];
		[ts->bmp release];
		free(ts);
	}

	/* Delete the list of loaded everything else */
	for(NSObject *obj in loaded_objects){
		[obj release];
	}

//	[rkit_view release];
//	[window release];
	[loaded_objects release];
	[loaded_sheets release];
}
