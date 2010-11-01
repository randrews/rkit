#include "cave.h"

int main(int argc, char** argv){
  char buff[256];
  int error;
  lua_State *L = lua_open();   /* opens Lua */
  luaL_openlibs(L);
  luaopen_map(L);
  luaopen_save(L);
  luaopen_drawing(L);
  set_draw(&draw_map);
  set_getkey(&readkey);
  set_draw_status(&draw_status);

  allegro_init();
  install_keyboard();
  set_gfx_mode(GFX_AUTODETECT_WINDOWED, 800, 600, 0, 0);

  init_drawing();

  char* code = "require('lua/cave')";
  error = luaL_loadbuffer(L, code, strlen(code), "line") || lua_pcall(L, 0, 0, 0);

  if(error){
    printf("%s\n", lua_tostring(L, -1));
    lua_pop(L, 1);
  }

  lua_close(L);
  close_drawing();

  return 0;
}
END_OF_MAIN()
