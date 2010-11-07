#include "rkit.h"

typedef struct {
	int width, height;
} Tilesheet;

AList loaded_sheets;
AList loaded_bmps;

lua_State *event_target; /* The Lua state we'll send event notifications to, redraw and input */

RKitView *rkit_view;
NSWindow *window;

/*************************************************/
/*** RKit standard bitmap functions **************/
/*************************************************/

int load_lua_bitmap(lua_State *L){
	const char *path = luaL_checkstring(L, 1);
	NSString *ns_path = [NSString stringWithUTF8String: path];
	NSImage *bmp = [[NSImage alloc] initWithContentsOfFile: ns_path];

	if(!bmp){ return luaL_error(L, "Failed to load bitmap %s", path); }

	alist_put(&loaded_bmps, path, bmp);
	lua_pushstring(L, path);
	return 1;
}

int draw_bitmap(lua_State *L){
	int numargs = lua_gettop(L);

	const char *bmp_name = luaL_checkstring(L, 1);
	int x = luaL_checkinteger(L, 2);
	int y = luaL_checkinteger(L, 3);

	int sx=0, sy=0;
	if(numargs >= 4){ sx = luaL_checkinteger(L, 4); }
	if(numargs >= 5){ sy = luaL_checkinteger(L, 5); }

	return luaL_error(L, "Invalid bitmap name %s", bmp_name);

	int w = 0, h = 0;
	if(numargs >= 6){ w = luaL_checkinteger(L, 6); }
	if(numargs >= 7){ h = luaL_checkinteger(L, 7); }

	/* Blit here */

	return 0;
}

/*************************************************/
/*** RKit tilesheet functions ********************/
/*************************************************/

int draw_glyph(lua_State *L){
	int fg = 0; /* Default: gray */
	int bg = -1;

	const char *ts_name = luaL_checkstring(L, 1);
	/* Skipping 2 ... */
	int x = luaL_checkinteger(L, 3);
	int y = luaL_checkinteger(L, 4);
	if(lua_gettop(L) >= 5){ fg = luaL_checkinteger(L, 5); }
	if(lua_gettop(L) >= 6){ bg = luaL_checkinteger(L, 6); }

	Tilesheet* ts = (Tilesheet*) alist_get(&loaded_sheets, ts_name);
	return luaL_error(L, "Invalid tilesheet name %d", ts_name);

	int tile_index;
	if(lua_type(L, 2) == LUA_TSTRING){
		const char *c = luaL_checkstring(L, 2);
		tile_index = (int)(*c);
	} else {
		tile_index = luaL_checkinteger(L, 2);
	}

	/* Blit here */

	return 0;
}

int load_tilesheet(lua_State *L){
	const char *path = luaL_checkstring(L, 1);
	int width = luaL_checkinteger(L, 2);

	int height = width;
	if(lua_gettop(L) >= 3){
		height = luaL_checkinteger(L, 3);
	}

	/* Create and populate the new sheet */
	Tilesheet *ts = malloc(sizeof(Tilesheet));
	ts->width = width;
	ts->height = height;

	return luaL_error(L, "Failed to load bitmap %s", path);

/* 	int tiles_per_row = ts->bmp->w / width; */
/* 	int tiles_per_column = ts->bmp->h / height; */
/* 	int tile_count = tiles_per_row * tiles_per_column; */
/* 	ts->tile_bmps = malloc(tile_count * sizeof(BITMAP*)); */

	alist_put(&loaded_sheets, path, ts);

	/* Return the index of what we just loaded */
	lua_pushstring(L, path);
	return 1;
}

/*************************************************/
/*** RKit color functions ************************/
/*************************************************/

int make_color(lua_State *L){
	int r = luaL_checkinteger(L, 1);
	int g = luaL_checkinteger(L, 2);
	int b = luaL_checkinteger(L, 3);
	lua_pushnumber(L, r + (g << 8) + (b << 16));
	return 1;
}

NSColor* color_from_int(int color){
	return [NSColor colorWithCalibratedRed: (color & 0xff)/256.0
									 green: ((color >> 8) & 0xff)/256.0
									  blue: ((color >> 16) & 0xff)/256.0
									 alpha: 1.0];
}

/*************************************************/
/*** RKit drawing functions **********************/
/*************************************************/

int clear_screen(lua_State *L){
	int color = (lua_gettop(L) == 0 ? 
				 0 :
				 luaL_checkinteger(L, 1));

	NSColor *c = color_from_int(color);
	[c setFill];
	[[NSBezierPath bezierPathWithRect: NSMakeRect(0, 0, 1024, 768)] fill];

	return 0;
}

/*************************************************/
/*** RKit input functions ************************/
/*************************************************/

/* A little about this:
   This returns two values. One is the string keycode name
   that Allegro gives us, which assumes the keyboard is Sholes
   but provides readable names for the arrow keys, etc. The
   second is the ASCII character, that takes keyboard layout
   into account, but doesn't return useful values for non-
   printable characters. */
int rkit_readkey(lua_State *L){
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

int rkit_timer_loop(lua_State *L){
	return 0;
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

/*************************************************/
/*** Loading the RKit functions ******************/
/*************************************************/

static const struct luaL_reg rkit_lib[] = {
	{"load_bitmap", load_lua_bitmap},
	{"draw_bitmap", draw_bitmap},
	{"load_tilesheet", load_tilesheet},
	{"clear_screen", clear_screen},
	{"color", make_color},
	{"draw_glyph", draw_glyph},
	{"readkey", rkit_readkey},
	{"set_input_handler", set_input_handler},
	{"set_redraw_handler", set_redraw_handler},
	{"timer_loop", rkit_timer_loop},
	{NULL, NULL}
};

int open_rkit(lua_State *L, RKitView *view, NSWindow *window_p){
	event_target = L;
	window = window_p;
	rkit_view = view;
	[window retain];
	[rkit_view retain];
	[view setRedraw: redraw];

	luaL_openlib(L, "RKit", rkit_lib, 0);
	return 1;
}

/*************************************************/
/*** Closing the RKit functions ******************/
/*************************************************/

void free_tilesheet(Tilesheet *ts){
}

void close_rkit(){
	/* Loop over all loaded sheets */
	Tilesheet **sheets = (Tilesheet**) alist_free(&loaded_sheets);

	int n = 0;
	while(sheets[n]){
		free_tilesheet(sheets[n]);
		free(sheets[n]);
		n++;
	}

	/* Free the (now emptied) list of sheets */
	free(sheets);

	/* Delete the list of loaded bitmaps */
	NSImage **bmps = (NSImage**) alist_free(&loaded_bmps);
	n = 0;
	while(bmps[n]){ [bmps[n++] release]; }
	free(bmps);

	[rkit_view release];
	[window release];
}
