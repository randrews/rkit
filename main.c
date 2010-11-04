#include "rkit.h"

int main(int argc, char** argv){
	char buff[256];
	lua_State *L = lua_open();   /* opens Lua */

	luaL_openlibs(L);
	luaopen_map(L);
	open_rkit(L);

	allegro_init();

	install_keyboard();
	keyboard_lowlevel_callback = rkit_on_keypress;
	set_keyboard_rate(0, 0);

	set_gfx_mode(GFX_AUTODETECT_WINDOWED, 1024, 768, 0, 0);

	char* code = "require('lua/rkit')";
	char* line = malloc(500);
	char* file_read = line;
	int lua_error = luaL_loadbuffer(L, code, strlen(code), "line") || lua_pcall(L, 0, 0, 0);

	while(file_read && !lua_error){
		file_read = fgets(line, 500, stdin);

		if(file_read){
			lua_error = luaL_loadbuffer(L, line, strlen(line), "line") || lua_pcall(L, 0, 0, 0);
		}
	}

	if(lua_error){
		printf("%s\n", lua_tostring(L, -1));
		lua_pop(L, 1);
	}

	lua_close(L);
	close_rkit();
	free(line);

	return 0;
}
END_OF_MAIN()
