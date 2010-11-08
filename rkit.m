#include "rkit.h"

NSColor* color_from_int(int color);

typedef struct {
	int width, height;
	NSImage *bmp;

	/* We have to make a separate NSImage and draw a rect there,
	   so we can composite it to the screen. So we store it and its rect,
	   so we can avoid making one every draw_glyph. */
	NSImage *bg_image;
	NSRect bg_rect;
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

	NSImage* bmp = (NSImage*) alist_get(&loaded_bmps, bmp_name);
	if(!bmp){ return luaL_error(L, "Invalid bitmap name %s", bmp_name); }

	int w = [bmp size].width, h = [bmp size].height;
	if(numargs >= 6){ w = luaL_checkinteger(L, 6); }
	if(numargs >= 7){ h = luaL_checkinteger(L, 7); }

	/* There are some tricky things here.
	   We are taking from Lua a src top-left point and a dest top-left point,
	   measured from the top left of the window, but Cocoa expects a src and
	   dest bottom-left point, measured from the bottom left. So, we subtract
	   the y value from the height of the whole region, to convert the origin
	   of the coord system, then we subtract the height of the rect we have
	   from that, to compensate for which corner it expects. */
	int screen_h = [rkit_view bounds].size.height;
	[bmp drawAtPoint: NSMakePoint(x, screen_h - y - h)
			fromRect: NSMakeRect(sx, [bmp size].height - sy - h, w, h)
		   operation: NSCompositeCopy
			fraction: 1.0];

	return 0;
}

/*************************************************/
/*** RKit tilesheet functions ********************/
/*************************************************/

int draw_glyph(lua_State *L){
	int fg = 255 + (255 << 8) + (255 << 16); /* Default: white */
	int bg = -1;

	const char *ts_name = luaL_checkstring(L, 1);
	/* Skipping 2 ... */
	int x = luaL_checkinteger(L, 3);
	int y = luaL_checkinteger(L, 4);
	if(lua_gettop(L) >= 5){ fg = luaL_checkinteger(L, 5); }
	if(lua_gettop(L) >= 6){ bg = luaL_checkinteger(L, 6); }

	Tilesheet* ts = (Tilesheet*) alist_get(&loaded_sheets, ts_name);
	if(!ts){ return luaL_error(L, "Invalid tilesheet name %s", ts_name); }

	/* Arg 2 is the tile index, which is non a one-liner to read. */
	int tile_index;
	if(lua_type(L, 2) == LUA_TSTRING){
		const char *c = luaL_checkstring(L, 2);
		tile_index = (int)(*c);
	} else {
		tile_index = luaL_checkinteger(L, 2);
	}

	/* Figure out the coords we're blitting from on the tilesheet.
	   These are Lua coordinates (top-left), we convert them below. */
	int tiles_per_row = [ts->bmp size].width / ts->width;
	int tile_x = (tile_index % tiles_per_row) * ts->width;
	int tile_y = (tile_index / tiles_per_row) * ts->height;

	/* Make rects to blit from and to */
	NSRect src = NSMakeRect(tile_x,
							[ts->bmp size].height - tile_y - ts->height,
							ts->width, ts->height);

	int screen_h = [rkit_view bounds].size.height;
	NSPoint dest = NSMakePoint(x,
							   screen_h - y - ts->height);

	NSRect dest_rect = NSMakeRect(dest.x, dest.y, ts->width, ts->height);

	/* We have a background color, blit that first */
	if(bg != -1){
		NSColor *bg_color = color_from_int(bg);
		[bg_color setFill];
		[[NSBezierPath bezierPathWithRect: dest_rect] fill];
	}

	/* Double-blit the foreground char */
	NSColor *fg_color = color_from_int(fg);
	[ts->bg_image lockFocus];
	[fg_color setFill];
	[[NSBezierPath bezierPathWithRect: ts->bg_rect] fill];
	[ts->bg_image unlockFocus];

	[ts->bmp drawAtPoint: dest
				fromRect: src
			   operation: NSCompositeDestinationOut
				fraction: 1.0];

	[ts->bg_image drawAtPoint: dest
					 fromRect: ts->bg_rect
					operation: NSCompositeDestinationAtop
					 fraction: 1.0];
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

	NSString *ns_path = [NSString stringWithUTF8String: path];
	ts->bmp = [[NSImage alloc] initWithContentsOfFile: ns_path];

	ts->bg_rect = NSMakeRect(0, 0, ts->width, ts->height);
	ts->bg_image = [[NSImage alloc] initWithSize: ts->bg_rect.size];

	if(!ts->bmp){ return luaL_error(L, "Failed to load bitmap %s", path); }

	alist_put(&loaded_sheets, path, ts);
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
	[[NSBezierPath bezierPathWithRect: [rkit_view bounds]] fill];

	return 0;
}

int set_title(lua_State *L){
	const char *title = luaL_checkstring(L, 1);
	[window setTitle: [NSString stringWithUTF8String: title]];
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
	[view setKeydown: key_down];

	luaL_openlib(L, "RKit", rkit_lib, 0);
	return 1;
}

/*************************************************/
/*** Closing the RKit functions ******************/
/*************************************************/

void close_rkit(){
	/* Loop over all loaded sheets */
	Tilesheet **sheets = (Tilesheet**) alist_free(&loaded_sheets);

	int n = 0;
	while(sheets[n]){
		[sheets[n]->bg_image release];
		[sheets[n]->bmp release];
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
