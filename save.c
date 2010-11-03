#include "cave.h"

int save_game(lua_State *L);
int load_game(lua_State *L);

static const struct luaL_reg save_lib[] = {
	{"save", save_game},
	{"load", load_game},
	{NULL, NULL}
};

int luaopen_save(lua_State *L){
	luaL_openlib(L, "Savegame", save_lib, 0);
	return 1;
}

/*************************************************
 *** Save library ********************************
 *************************************************/

int save_game(lua_State *L){
	const char *filename = luaL_checkstring(L, 1);
	Map* map = checkmap(L, 2);

	FILE* fp = fopen(filename, "wb");

	fwrite(&(map->w), 4, 1, fp);
	fwrite(&(map->h), 4, 1, fp);

	fwrite(map->data, 1, map->w * map->h, fp);

	fclose(fp);

	return 0;
}

int load_game(lua_State *L){
	const char *filename = luaL_checkstring(L, 1);

	FILE* fp = fopen(filename, "rb");
	int w, h;
	Map* map;

	if(fp){
		if(fread(&w, 4, 1, fp) != 1){ return 0; }
		if(fread(&h, 4, 1, fp) != 1){ return 0; }

		map = pushmap(L, w, h);

		int read = fread(map->data, 1, w * h, fp);
		fclose(fp);

		if(read != w * h){
			lua_pop(L, 1); /* Pop off the dead map */
			free(map->data); /* Free it */
			free(map);
			return 0;
		}

		return 1;
	}

	return 0;
}
