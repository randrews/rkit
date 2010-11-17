#include "rkit.h"

/*************************************************/
/*** RKit standard bitmap functions **************/
/*************************************************/

int load_lua_bitmap(lua_State *L){
	const char *path = luaL_checkstring(L, 1);
	NSString *ns_path = [NSString stringWithUTF8String: path];
	NSImage *bmp = [[NSImage alloc] initWithContentsOfFile: ns_path];

	if(!bmp){ return luaL_error(L, "Failed to load bitmap %s", path); }

	[loaded_bmps addObject: bmp];
	lua_pushlightuserdata(L, bmp);
	return 1;
}

int draw_bitmap(lua_State *L){
	int numargs = lua_gettop(L);

	if(!lua_islightuserdata(L, 1)){ luaL_typerror(L, 1, "bitmap"); }
	NSImage *bmp = lua_touserdata(L, 1);
	int x = luaL_checkinteger(L, 2);
	int y = luaL_checkinteger(L, 3);

	int sx=0, sy=0;
	if(numargs >= 4){ sx = luaL_checkinteger(L, 4); }
	if(numargs >= 5){ sy = luaL_checkinteger(L, 5); }

	int w = [bmp size].width, h = [bmp size].height;
	if(numargs >= 6){ w = luaL_checkinteger(L, 6); }
	if(numargs >= 7){ h = luaL_checkinteger(L, 7); }

	[bmp drawAtPoint: NSMakePoint(x, y)
			fromRect: NSMakeRect(sx, sy, w, h)
		   operation: NSCompositeSourceOver
			fraction: 1.0];

	return 0;
}

/*************************************************/
/*** RKit tilesheet functions ********************/
/*************************************************/

int draw_glyph(lua_State *L){
	int fg = 255 + (255 << 8) + (255 << 16); /* Default: white */
	int bg = -2;

	if(!lua_islightuserdata(L, 1)){ luaL_typerror(L, 1, "tilesheet"); }
	Tilesheet *ts = lua_touserdata(L, 1);
	/* Skipping 2 ... */
	int x = luaL_checkinteger(L, 3);
	int y = luaL_checkinteger(L, 4);
	if(lua_gettop(L) >= 5){ fg = luaL_checkinteger(L, 5); }
	if(lua_gettop(L) >= 6){ bg = luaL_checkinteger(L, 6); }

	/* Arg 2 is the tile index, which is not a one-liner to read. */
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
	NSRect src = NSMakeRect(tile_x, tile_y, ts->width, ts->height);
	NSRect dest = NSMakeRect(x, y, ts->width, ts->height);

	/* We have a background color, blit that first */
	if(bg >= 0){
		NSColor *bg_color = color_from_int(bg);
		[bg_color setFill];
		[[NSBezierPath bezierPathWithRect: dest] fill];
	}

	/* Triple-blit the foreground char */
	NSColor *fg_color = color_from_int(fg);
	[ts->bg_image lockFocus];
	[fg_color setFill];
	[[NSBezierPath bezierPathWithRect: ts->bg_rect] fill];
	[ts->bg_image unlockFocus];

	if(bg == -1){	
		[ts->bmp drawAtPoint: dest.origin
		   fromRect: src
		   operation: NSCompositeClear
		   fraction: 1.0];

		[ts->bmp drawAtPoint: dest.origin
		   fromRect: src
		   operation: NSCompositeCopy
		   fraction: 1.0];

		[ts->bg_image drawAtPoint: dest.origin
		   fromRect: ts->bg_rect
		   operation: NSCompositeSourceIn
		   fraction: 1.0];

	} else {
		[ts->bmp drawAtPoint: dest.origin
		   fromRect: src
		   operation: NSCompositeDestinationOut
		   fraction: 1.0];

		[ts->bg_image drawAtPoint: dest.origin
		   fromRect: ts->bg_rect
		   operation: NSCompositeDestinationAtop
		   fraction: 1.0];
	}

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

	[loaded_sheets addObject: [NSValue valueWithPointer: ts]];
	lua_pushlightuserdata(L, ts);
	return 1;
}

/*************************************************/
/*** Color functions *****************************/
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
/*** Drawing functions ***************************/
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

int draw_text(lua_State *L){
	NSString *str = [NSString stringWithUTF8String: luaL_checkstring(L, 1)];
	int x = luaL_checkinteger(L, 2);
	int y = luaL_checkinteger(L, 3);

	[str drawAtPoint: NSMakePoint(x, y) withAttributes: nil];
	return 0;
}

/*************************************************/
/*** Window management functions *****************/
/*************************************************/

int set_title(lua_State *L){
	const char *title = luaL_checkstring(L, 1);
	[window setTitle: [NSString stringWithUTF8String: title]];
	return 0;
}

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
