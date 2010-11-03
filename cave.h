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

typedef struct Node{
	char *key;
	struct Node *next;
	void *value;
} Node;

typedef struct{
	Node *head, *last;
} AList;

/* alist.c */

/* Frees all the keys, and returns a new array of the values.
   Does NOT free the AList itself, or any of the values. */
void** alist_free();

/* Sets the value associated with a given key, and returns
   the old value associated with that key, or null. */
void* alist_put(AList *alist, const char *key, void *value);

void* alist_get(AList *alist, const char *key);
int alist_length(AList *alist);

/* map.c */
int luaopen_map(lua_State *L);
void set_draw(void (*draw)(Map*,int,int,int,int));
void set_getkey(int (*getkey)());
void set_draw_status(void (*draw_status)(const char*,int,int,int));
Map* checkmap(lua_State *L, int index);
Map* pushmap(lua_State *L, int w, int h);

/* save.c */
int luaopen_save(lua_State *L);

/* /\* glyph.c *\/ */
/* int luaopen_glyph(lua_State *L); */
/* Glyph* checkglyph(lua_State *L, int index); */
/* Glyph* pushglyph(lua_State *L, int letter, int fg, int bg); */

/* rkit.c */
int open_rkit(lua_State *L);
void close_rkit();

/* drawing.c */
int luaopen_drawing(lua_State *L);

void init_drawing();
void close_drawing();
void draw_map(Map* map, int src_x, int src_y, int w, int h);
void draw_status(const char* status, int r, int g, int b);
void draw_mini_map(Map* map, int src_x, int src_y, int w, int h);
void make_glyph_bmps(BITMAP *font_bmp, BITMAP **glyphs, int w, int h);
Glyph glyph_for(char c);
int color_for(char c);
