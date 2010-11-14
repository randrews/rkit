#include "rkit.h"

NSColor* color_from_int(int color);

NSMutableArray *loaded_sheets, *loaded_bmps;

lua_State *event_target; /* The Lua state we'll send event notifications to, redraw and input */

RKitView *rkit_view;
NSWindow *window;

/*************************************************/
/*** RKit drawing functions **********************/
/*************************************************/

int clear_screen(lua_State *L){
	int color = (lua_gettop(L) == 0 ?
				 0 :
				 luaL_checkinteger(L, 1));

	NSColor *c = color_from_int(color);
	[c setFill];
	[[NSBezierPath bezierPathWithRect: [rkit_view bounds]] fill];

	return 0;
}

int set_title(lua_State *L){
	const char *title = luaL_checkstring(L, 1);
	[window setTitle: [NSString stringWithUTF8String: title]];
	return 0;
}

int draw_rect(lua_State *L){
	int x = luaL_checkinteger(L, 1);
	int y = luaL_checkinteger(L, 2);
	int w = luaL_checkinteger(L, 3);
	int h = luaL_checkinteger(L, 4);
	NSColor *c = color_from_int(luaL_checkinteger(L, 5));

	[c setStroke];
	[[NSBezierPath bezierPathWithRect: NSMakeRect(x, y, w, h)] stroke];

	return 0;
}

/*************************************************/
/*** RKit event handler registration *************/
/*************************************************/

int input_handler_set = 0; /* Nonzero if the last call to set_input_handler didn't pass nil */
int redraw_handler_set = 0; /* Nonzero if the last call to set_redraw_handler didn't pass nil */

int active_input_handler; /* Index in the Lua registry for the active kbd handler */
int active_redraw_handler; /* Index in the Lua registry for the active kbd handler */

int set_handler(lua_State *L, int *handler){
	int handler_set = !(lua_isnoneornil(L, 1)); /* Check whether we set or cleared the handler */

	/* If this is an invalid handler... */
	if(handler_set && !lua_isfunction(L, 1)){ luaL_typerror(L, 1, "function"); }

	*handler = luaL_ref(L, LUA_REGISTRYINDEX); /* Shove this in the registry */
	return handler_set;
}

int set_input_handler(lua_State *L){
	input_handler_set = set_handler(L, &active_input_handler);
	return 0;
}

int set_redraw_handler(lua_State *L){
	redraw_handler_set = set_handler(L, &active_redraw_handler);
	return 0;
}

/*************************************************/
/*** RKit timer functions ************************/
/*************************************************/

int create_timer(lua_State *L){
	if(!lua_isfunction(L, 1)){ luaL_typerror(L, 1, "function"); }
	double delay = (double)(luaL_checknumber(L, 2));

	lua_pushvalue(L, 1);
	int timer_fn_index = luaL_ref(L, LUA_REGISTRYINDEX);

	NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval: delay
													  target: rkit_view
													selector: @selector(callTimer:)
													userInfo: [NSNumber numberWithInt: timer_fn_index]
													 repeats: YES];
	[timer retain];

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

void redraw(NSRect rect){
	if(redraw_handler_set){
		lua_pushinteger(event_target, active_redraw_handler);
		lua_gettable(event_target, LUA_REGISTRYINDEX);
		lua_call(event_target, 0, 0);
	}
}

int trigger_redraw(lua_State *L){
	[rkit_view setNeedsDisplay: YES];
	return 0;
}

/*************************************************/
/*** RKit input functions ************************/
/*************************************************/

void key_down(const char *letter, int key_code){
	if(input_handler_set){
		lua_pushinteger(event_target, active_input_handler);
		lua_gettable(event_target, LUA_REGISTRYINDEX);
		lua_pushstring(event_target, letter);
		lua_pushinteger(event_target, key_code);
		lua_call(event_target, 2, 0);
	}
}

/*************************************************/
/*** RKit window management functions ************/
/*************************************************/

int set_resizable(lua_State *L){
	int resizable = lua_toboolean(L, 1);
	[window setStyleMask: (NSTitledWindowMask |
						   NSClosableWindowMask |
						   (resizable ? NSResizableWindowMask : 0) |
						   NSMiniaturizableWindowMask)];
	return 0;
}

int resize_window(lua_State *L){
	NSRect frame = [window frame];

	int x = frame.origin.x, y = frame.origin.y;

	int w = luaL_checkinteger(L, 1);
	int h = luaL_checkinteger(L, 2);

	if(lua_gettop(L) >= 4){
		x = luaL_checkinteger(L, 3);
		y = luaL_checkinteger(L, 4);
	}

	[window setFrame: NSMakeRect(x, y, w, h)
			 display: YES];

	return 0;
}

/*************************************************/
/*** RKit mob functions **************************/
/*************************************************/

void mob_redraw_callback(NSRect rect, int lua_function){
	NSLog(@"Redrawing with %d", lua_function);

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
	[mob setFrame: NSMakeRect(x, [rkit_view frame].size.height - y - h, w, h)];
	[mob setRedraw: mob_redraw_callback];
	[mob setLuaFunction: fn];
	[rkit_view addSubview: mob];

	lua_pushlightuserdata(L, mob);
	return 1;
}

int move_mob(lua_State *L){
	if(!lua_islightuserdata(L, 1)){ luaL_typerror(L, 1, "mob"); }
	MobView *mob = (MobView*) lua_touserdata(L, 1);
	int x = luaL_checkinteger(L, 2);
	int y = luaL_checkinteger(L, 3);

	int real_y = [rkit_view frame].size.height - y - [mob frame].size.height;
	[[mob animator] setFrame: NSMakeRect(x,  real_y,
										 [mob frame].size.width,
										 [mob frame].size.height)];
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
	{"set_input_handler", set_input_handler},
	{"set_redraw_handler", set_redraw_handler},
	{"redraw", trigger_redraw},
	{"create_timer", create_timer},
	{"stop_timer", stop_timer},
	{"resizable", set_resizable},
	{"resize", resize_window},
	{"create_mob", create_mob},
	{"move_mob", move_mob},
	{NULL, NULL}
};

int open_rkit(lua_State *L, RKitView *view, NSWindow *window_p){
	loaded_bmps = [NSMutableArray arrayWithCapacity: 1];
	loaded_sheets = [NSMutableArray arrayWithCapacity: 1];

	event_target = L;
	window = window_p;
	rkit_view = view;

	[window retain];
	[rkit_view retain];

	[view setRedraw: redraw];
	[view setKeydown: key_down];
	[view setTimerHook: rkit_timer_hook];

	luaL_openlib(L, "RKit", rkit_lib, 0);
	return 1;
}

/*************************************************/
/*** Closing the RKit functions ******************/
/*************************************************/

void close_rkit(){
	/* Loop over all loaded sheets */
	for(NSValue *ts_id in loaded_sheets){
		Tilesheet *ts = [ts_id pointerValue];
		[ts->bg_image release];
		[ts->bmp release];
		free(ts);
	}

	/* Delete the list of loaded bitmaps */
	for(NSImage *bmp in loaded_bmps){
		[bmp release];
	}

	[rkit_view release];
	[window release];
	[loaded_bmps release];
	[loaded_sheets release];
}
