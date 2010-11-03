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
/*** Loading the RKit functions ******************/
/*************************************************/

static const struct luaL_reg rkit_lib[] = {
	{"load_bitmap", load_lua_bitmap},
	{"draw_bitmap", draw_bitmap},
	{"load_tilesheet", load_tilesheet},
	{"color", make_color},
	{"draw_glyph", draw_glyph},
	{NULL, NULL}
};

int open_rkit(lua_State *L){
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
