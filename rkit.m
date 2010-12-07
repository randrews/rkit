#import "rkit.h"

int rkit_log(lua_State *L){
	const char *str = luaL_checkstring(L, 1);
	NSString *msg = [NSString stringWithFormat:@"%s\n", str];
	[agent(L) addToLog: msg];
	return 0;
}

/*************************************************/
/*** RKit redraw hook ****************************/
/*************************************************/

// RKitView calls this one
void redraw(lua_State *L, NSRect rect){
	lua_getglobal(L, "print");
	lua_pushstring(L, "redraw");
	lua_gettable(L, LUA_REGISTRYINDEX);
	if(!lua_isnil(L, -1)){
		lua_pcall(L, 0, 0, -2);
	}
}

// Lua calls this one
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
	lua_getglobal(L, "print");
	lua_pushstring(L, "input");
	lua_gettable(L, LUA_REGISTRYINDEX);
	if(!lua_isnil(L, -1)){
		lua_pushstring(L, letter);
		lua_pushinteger(L, key_code);
		lua_pcall(L, 2, 0, -4);
	}
}

void mouse_event(lua_State *L, const char *event, int x, int y, int buttons){
	lua_getglobal(L, "print");
	lua_pushstring(L, "mouse");
	lua_gettable(L, LUA_REGISTRYINDEX);
	if(!lua_isnil(L, -1)){
		lua_pushstring(L, event);
		lua_pushinteger(L, x);
		lua_pushinteger(L, y);
		lua_pushinteger(L, buttons);
		lua_pcall(L, 4, 0, -6);
	}
}

/*************************************************/
/*** Loading the RKit functions ******************/
/*************************************************/

static const struct luaL_reg rkit_lib[] = {
	{"log", rkit_log},
	{"load_bitmap", load_lua_bitmap},
	{"draw_bitmap", draw_bitmap},
	{"load_tilesheet", load_tilesheet},
	{"clear_screen", clear_screen},
	{"set_title", set_title},
	{"color", make_color},
	{"draw_glyph", draw_glyph},
	{"draw_tile", draw_tile},
	{"rect", draw_rect},
	{"text", draw_text},
	{"set_input_handler", set_input_handler},
	{"set_mouse_handler", set_mouse_handler},
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

int open_rkit(lua_State *L){
	NSMutableArray *loaded_objects = [[NSMutableArray arrayWithCapacity: 1] retain];
	NSMutableArray *loaded_sheets = [[NSMutableArray arrayWithCapacity: 1] retain];

	// These aren't leaks; we release them in close_rkit
	// Because the only thing holding a ref to them is Lua,
	// we need to keep them retained.
	rkit_register_value(L, "loaded_objects", loaded_objects);
	rkit_register_value(L, "loaded_sheets", loaded_sheets);

	luaL_openlib(L, "RKit", rkit_lib, 0);
	return 1;
}

void rkit_set_view(lua_State *L, RKitView *view){
	rkit_register_value(L, "rkit_view", view);
	view.redraw = redraw;
	view.keydown = key_down;
	view.mouse = mouse_event;
	view.timer_hook = rkit_timer_hook;
	[view retain];
}

void rkit_add_load_path(lua_State *L, const char *path){
	lua_getglobal(L, "package");
	lua_pushstring(L, "path");	
	lua_pushstring(L, "path");
	lua_gettable(L, -3); // [table, "path", old_path]
	lua_pushstring(L, ";");
	lua_pushstring(L, path);
	lua_pushstring(L, "/?.lua");
	lua_concat(L, 4); // [table, "path", new_path]
	lua_settable(L, -3);
}

/*************************************************/
/*** Closing the RKit functions ******************/
/*************************************************/

void close_rkit(lua_State *L){
	/* Loop over all loaded sheets */
	/* Since we need to do special things to kill tilesheets,
		we can't put them in the same list as everything else */
	for(NSValue *ts_id in loaded_sheets(L)){
		Tilesheet *ts = [ts_id pointerValue];
		[ts->bmp release];
		[ts->bg_image release];
		free(ts);
	}

	/* Stop all the timers */
	for(NSObject *obj in loaded_objects(L)){
		if([obj isKindOfClass:[NSTimer class]]){
			NSTimer *timer = (NSTimer*) obj;
			[timer invalidate];
		}
	}

	/* Releasing the arrays releases everything in them */
	[loaded_objects(L) release];
	[loaded_sheets(L) release];
}
