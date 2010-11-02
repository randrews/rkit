#include "cave.h"

typedef struct {
  BITMAP *bmp;
  int width, height;
  BITMAP **tile_bmps;
} Tilesheet;

int loaded_count = 0;
Tilesheet *loaded_sheets;

/*************************************************/
/*** RKit tilesheet functions ********************/
/*************************************************/

int draw_glyph(lua_State *L){
  int fg = makecol(128,128,128);
  int bg = -1;

  int ts_index = luaL_checkinteger(L, 1);
  /* Skipping 2 ... */
  int x = luaL_checkinteger(L, 3);
  int y = luaL_checkinteger(L, 4);
  if(lua_gettop(L) >= 5){ fg = luaL_checkinteger(L, 5); }
  if(lua_gettop(L) >= 6){ bg = luaL_checkinteger(L, 6); }

  int tile_index;

  if(lua_type(L, 2) == LUA_TSTRING){
    const char *c = luaL_checkstring(L, 2);
	tile_index = (int)(*c);
  } else {
	tile_index = luaL_checkinteger(L, 2);
  }

  BITMAP *letter = loaded_sheets[ts_index].tile_bmps[tile_index];

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
  Tilesheet ts;
  ts.bmp = load_bitmap(path, NULL);
  ts.width = width;
  ts.height = height;

  if(!ts.bmp){
	return luaL_error(L, "Failed to load bitmap %s", path);
  }

  int tiles_per_row = ts.bmp->w / width;
  int tiles_per_column = ts.bmp->h / height;
  int tile_count = tiles_per_row * tiles_per_column;
  ts.tile_bmps = malloc(tile_count * sizeof(BITMAP*));

  int n;
  for(n = 0; n < tile_count; n++){
	ts.tile_bmps[n] = create_sub_bitmap(ts.bmp,
										n % tiles_per_row * width,
										n / tiles_per_row * height,
										width, height);
  }

  /* Increase size of loaded_sheets by one */
  Tilesheet *new_loaded_sheets = malloc(sizeof(Tilesheet) * (loaded_count + 1));
  memcpy(new_loaded_sheets, loaded_sheets, sizeof(Tilesheet) * loaded_count);
  free(loaded_sheets);
  loaded_sheets = new_loaded_sheets;
  loaded_count++;

  /* Copy the new tilesheet into loaded_sheets */
  memcpy(loaded_sheets + loaded_count - 1, &ts, sizeof(Tilesheet));

  /* Return the index of what we just loaded */
  lua_pushnumber(L, loaded_count - 1);
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

void close_rkit(){
  /* Loop over all loaded sheets */
  int n;
  for(n = 0; n < loaded_count; n++){
	Tilesheet ts = loaded_sheets[n];

	/* Find out how many tile bmps we have to kill */
	int tiles_per_row = ts.bmp->w / ts.width;
	int tiles_per_column = ts.bmp->h / ts.height;
	int tile_count = tiles_per_row * tiles_per_column;

	/* Destroy all tile bmps */
	int i;
	for(i = 0; i < tile_count; i++){
	  destroy_bitmap(ts.tile_bmps[i]);
	}

	/* Free the (now empty) list of tile bmps, and the main bmp */
	free(ts.tile_bmps);
	destroy_bitmap(ts.bmp);
  }

  /* Free the (now emptied) list of sheets */
  free(loaded_sheets);
  loaded_count = 0;
}
