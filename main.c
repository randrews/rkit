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

typedef struct{
  BITMAP *letter;
  int fg, bg;
} Glyph;

void draw_map(Map* map, int src_x, int src_y, int w, int h);
void draw_mini_map(Map* map, int src_x, int src_y, int w, int h);
void make_glyph_bmps(BITMAP *font_bmp, BITMAP **glyphs, int w, int h);
Glyph glyph_for(char c);
int color_for(char c);

BITMAP **glyph_bmps;

int main(int argc, char** argv){
  char buff[256];
  int error;
  lua_State *L = lua_open();   /* opens Lua */
  luaL_openlibs(L);
  luaopen_map(L);
  set_draw(&draw_mini_map);
  set_getkey(&readkey);

  allegro_init();
  install_keyboard();
  set_gfx_mode(GFX_AUTODETECT_WINDOWED, 800, 600, 0, 0);  

  BITMAP *font_bmp = load_bitmap("Tahin-font.tga", NULL);
  glyph_bmps = malloc(256 * sizeof(BITMAP*));
  make_glyph_bmps(font_bmp, glyph_bmps, 16, 16);

  char* code = "require('cave')";
  error = luaL_loadbuffer(L, code, strlen(code), "line") || lua_pcall(L, 0, 0, 0);

  if(error){
    printf("%s\n", lua_tostring(L, -1));
    lua_pop(L, 1);
  }

  lua_close(L);

  int n;
  for(n=0; n < 256; n++){ destroy_bitmap(glyph_bmps[n]); }
  free(glyph_bmps);

  if(font_bmp){destroy_bitmap(font_bmp);}

  return 0;
}
END_OF_MAIN()

void make_glyph_bmps(BITMAP *font_bmp, BITMAP **glyphs, int w, int h){
  int n;

  for(n=0; n < 256; n++){
    glyphs[n] = create_sub_bitmap(font_bmp, n%16*w, n/16*h, w, h);
  }
}

Glyph glyph_for(char c){
  Glyph g;

  g.letter = glyph_bmps[c];

  switch(c){
  case '.':
    g.fg = makecol(0,128,0);
    g.bg = makecol(0,0,0);
    break;

  case '+':
    g.fg = makecol(0,192,0);
    g.bg = makecol(0,128,64);
    break;

  case 5:
    g.fg = makecol(0,255,0);
    g.bg = makecol(0,128,64);
    break;

  default:
    g.fg = makecol(192, 192, 192);
    g.bg = makecol(0, 0, 0);
  }

  return g;
}

int color_for(char c){
  switch(c){
  case '.':
    return makecol(0,128,0);
  case '+':
    return makecol(0,192,0);
  case '#':
    return makecol(128,128,128);
  case '-':
    return makecol(0,0,192);
  case 5:
    return makecol(0,255,0);
  default:
    return makecol(192, 192, 192);
  }
}

void draw_map(Map* map, int src_x, int src_y, int w, int h){
  int x,y;

  if(!w){w = 800 / 16;}
  if(!h){h = 600 / 16;}

  for(y = 0; y < h; y++){
    for(x = 0; x < w; x++){
      char chr = map->data[(x + src_x) +
			   (y + src_y) * map->w];

      Glyph glyph = glyph_for(chr);

      draw_character_ex(screen, glyph.letter,
			x*16, y*16,
			glyph.fg,
			glyph.bg);
    }
  }
}

void draw_mini_map(Map* map, int src_x, int src_y, int w, int h){
  int x,y;

  if(!w){w = map->w;}
  if(!h){h = map->h;}

  for(y = 0; y < h; y++){
    for(x = 0; x < w; x++){
      char chr = map->data[(x + src_x) +
			   (y + src_y) * map->w];

      int color = color_for(chr);

      rect(screen,
	   x*2, y*2,
	   x*2+1, y*2+1,
	   color);
    }
  }
}
