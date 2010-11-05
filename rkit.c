#include "rkit.h"

typedef struct {
	BITMAP *bmp;
	int width, height;
	BITMAP **tile_bmps;
} Tilesheet;

AList loaded_sheets;
AList loaded_bmps;

/*************************************************/
/*** RKit standard bitmap functions **************/
/*************************************************/

int load_lua_bitmap(lua_State *L){
	const char *path = luaL_checkstring(L, 1);

	BITMAP *bmp = load_bitmap(path, NULL);
	if(!bmp){
		return luaL_error(L, "Failed to load bitmap %s", path);
	}

	BITMAP *old_bmp = (BITMAP*) alist_put(&loaded_bmps, path, bmp);
	if(old_bmp){ destroy_bitmap(old_bmp); }

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

	BITMAP *bmp = (BITMAP*) alist_get(&loaded_bmps, bmp_name);

	if(!bmp){
		return luaL_error(L, "Invalid bitmap name %s", bmp);
	}

	int w=bmp->w, h=bmp->h;
	if(numargs >= 6){ w = luaL_checkinteger(L, 6); }
	if(numargs >= 7){ h = luaL_checkinteger(L, 7); }

	blit(bmp, screen, sx, sy, x, y, w, h);

	return 0;
}

/*************************************************/
/*** RKit tilesheet functions ********************/
/*************************************************/

int draw_glyph(lua_State *L){
	int fg = makecol(128,128,128);
	int bg = -1;

	const char *ts_name = luaL_checkstring(L, 1);
	/* Skipping 2 ... */
	int x = luaL_checkinteger(L, 3);
	int y = luaL_checkinteger(L, 4);
	if(lua_gettop(L) >= 5){ fg = luaL_checkinteger(L, 5); }
	if(lua_gettop(L) >= 6){ bg = luaL_checkinteger(L, 6); }

	Tilesheet* ts = (Tilesheet*) alist_get(&loaded_sheets, ts_name);
	if(!ts){
		return luaL_error(L, "Invalid tilesheet name %d", ts_name);
	}

	int tile_index;
	if(lua_type(L, 2) == LUA_TSTRING){
		const char *c = luaL_checkstring(L, 2);
		tile_index = (int)(*c);
	} else {
		tile_index = luaL_checkinteger(L, 2);
	}

	BITMAP *letter = ts->tile_bmps[tile_index];

	draw_character_ex(screen, letter,
					  x, y,
					  fg, bg);

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
	ts->bmp = load_bitmap(path, NULL);
	ts->width = width;
	ts->height = height;

	if(!ts->bmp){
		return luaL_error(L, "Failed to load bitmap %s", path);
	}

	int tiles_per_row = ts->bmp->w / width;
	int tiles_per_column = ts->bmp->h / height;
	int tile_count = tiles_per_row * tiles_per_column;
	ts->tile_bmps = malloc(tile_count * sizeof(BITMAP*));

	int n;
	for(n = 0; n < tile_count; n++){
		ts->tile_bmps[n] = create_sub_bitmap(ts->bmp,
											 n % tiles_per_row * width,
											 n / tiles_per_row * height,
											 width, height);
	}

	/* Increase size of loaded_sheets by one */
	alist_put(&loaded_sheets, path, ts);

	/* Return the index of what we just loaded */
	lua_pushstring(L, path);
	return 1;
}

int make_color(lua_State *L){
	int r = luaL_checkinteger(L, 1);
	int g = luaL_checkinteger(L, 2);
	int b = luaL_checkinteger(L, 3);

	lua_pushnumber(L, makecol(r, g, b));
	return 1;
}


/*************************************************/
/*** RKit input functions ************************/
/*************************************************/

int input_handler_set = 0; /* Nonzero if the last call to set_input_handler didn't pass nil */
int active_handler; /* Index in the Lua registry for the active kbd handler */
lua_State *input_target; /* The Lua state we'll send keyboard event notifications to */

/* A little about this:
   This returns two values. One is the string keycode name
   that Allegro gives us, which assumes the keyboard is Sholes
   but provides readable names for the arrow keys, etc. The
   second is the ASCII character, that takes keyboard layout
   into account, but doesn't return useful values for non-
   printable characters. */
int rkit_readkey(lua_State *L){
	int code = readkey();
	char chr = code & 0xff; /* Low byte is ASCII */
	int scan = code >> 8; /* High byte is the scancode */
	const char *name = scancode_to_name(scan);
	lua_pushstring(L, name);
	lua_pushlstring(L, &chr, 1);
	return 2;
}

int set_input_handler(lua_State *L){
	input_handler_set = !(lua_isnoneornil(L, 1)); /* Check whether we set or cleared the handler */

	/* If this is an invalid handler... */
	if(input_handler_set && !lua_isfunction(L, 1)){ luaL_typerror(L, 1, "function"); }

	active_handler = luaL_ref(L, LUA_REGISTRYINDEX); /* Shove this in the registry */
	lua_pushboolean(L, input_handler_set);
	return 1;
}

/* Allegro keypress handler */
void rkit_on_keypress(int scancode){
	int released = scancode & 0x80; /* zero if the key was pressed, nonzero if released */
	if(!input_handler_set){ return; } /* Bail if there's no handler */
	if(released){ scancode -= 0x80; } /* If released, subtract the flag, so we can get the scan name */

	lua_rawgeti(input_target, LUA_REGISTRYINDEX, active_handler); /* Push the active handler */
	lua_pushstring(input_target, scancode_to_name(scancode)); /* Push the arguments */
	lua_pushboolean(input_target, !released);
	lua_call(input_target, 2, 0); /* Call with two args, drop return values */
}
END_OF_FUNCTION(rkit_on_keypress)
LOCK_FUNCTION(rkit_on_keypress)

/*************************************************/
/*** RKit timer functions ************************/
/*************************************************/

int rkit_timer_loop(lua_State *L){
	while(1){
		lua_pushvalue(L, 1);
		lua_call(L, 0, 0);
		sleep(1);
	}
}

/*************************************************/
/*** Loading the RKit functions ******************/
/*************************************************/

static const struct luaL_reg rkit_lib[] = {
	{"load_bitmap", load_lua_bitmap},
	{"draw_bitmap", draw_bitmap},
	{"load_tilesheet", load_tilesheet},
	{"color", make_color},
	{"draw_glyph", draw_glyph},
	{"readkey", rkit_readkey},
	{"set_input_handler", set_input_handler},
	{"timer_loop", rkit_timer_loop},
	{NULL, NULL}
};

int open_rkit(lua_State *L){
	input_target = L;
	luaL_openlib(L, "RKit", rkit_lib, 0);
	return 1;
}

/*************************************************/
/*** Closing the RKit functions ******************/
/*************************************************/

void free_tilesheet(Tilesheet *ts){
	/* Find out how many tile bmps we have to kill */
	int tiles_per_row = ts->bmp->w / ts->width;
	int tiles_per_column = ts->bmp->h / ts->height;
	int tile_count = tiles_per_row * tiles_per_column;

	/* Destroy all tile bmps */
	int i;
	for(i = 0; i < tile_count; i++){
		destroy_bitmap(ts->tile_bmps[i]);
	}

	/* Free the (now empty) list of tile bmps, and the main bmp */
	free(ts->tile_bmps);
	destroy_bitmap(ts->bmp);
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
	BITMAP **bmps = (BITMAP**) alist_free(&loaded_bmps);

	n = 0;
	while(bmps[n]){ destroy_bitmap(bmps[n++]); }

	free(bmps);
}
