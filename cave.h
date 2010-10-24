#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include <allegro.h>

typedef struct{
  char* data;
  int w;
  int h;
} Map;

typedef struct{
  BITMAP *letter;
  int fg, bg;
} Glyph;

/* map.c */
int luaopen_map(lua_State *L);
void set_draw(void (*draw)(Map*,int,int,int,int));
void set_getkey(int (*getkey)());
void set_draw_status(void (*draw_status)(const char*,int,int,int));

/* save.c */
int luaopen_save(lua_State *L);

/* drawing.c */
void init_drawing();
void close_drawing();
void draw_map(Map* map, int src_x, int src_y, int w, int h);
void draw_status(const char* status, int r, int g, int b);
void draw_mini_map(Map* map, int src_x, int src_y, int w, int h);
void make_glyph_bmps(BITMAP *font_bmp, BITMAP **glyphs, int w, int h);
Glyph glyph_for(char c);
int color_for(char c);
