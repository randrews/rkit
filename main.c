#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include <allegro.h>

#include "map.h"

const int dest_x = 0;
const int dest_y = 0;

BITMAP *font_bmp;

void draw_map(Map* map, int src_x, int src_y, int w, int h);

int main(int argc, char** argv){
  char buff[256];
  int error;
  lua_State *L = lua_open();   /* opens Lua */
  luaL_openlibs(L);
  luaopen_map(L);
  set_draw(&draw_map);
  set_getkey(&readkey);

  allegro_init();
  install_keyboard();
  set_gfx_mode(GFX_AUTODETECT_WINDOWED, 800, 600, 0, 0);  

  font_bmp = load_bitmap("Tahin-font.tga", NULL);

  char* code = "require('cave')";
  error = luaL_loadbuffer(L, code, strlen(code), "line") || lua_pcall(L, 0, 0, 0);

  if(error){
    printf("%s\n", lua_tostring(L, -1));
    lua_pop(L, 1);
  }

  readkey();
  lua_close(L);

  if(font_bmp){destroy_bitmap(font_bmp);}

  return 0;
}
END_OF_MAIN()

void draw_map(Map* map, int src_x, int src_y, int w, int h){
  BITMAP* letter;
  int x,y;

  if(!w){w = 800 / 16;}
  if(!h){h = 600 / 16;}

  for(y = 0; y < h; y++){
    for(x = 0; x < w; x++){
      int chr = map->data[(x + src_x) +
			  (y + src_y) * map->w];
      letter = create_sub_bitmap(font_bmp, chr%16*16, chr/16*16, 16, 16);

      draw_character_ex(screen, letter,
			x*16, y*16,
			makecol(0, 255, 0),
			makecol(0, 0, 0));
      destroy_bitmap(letter);
    }
  }
}
