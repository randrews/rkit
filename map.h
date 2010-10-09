#ifndef MAP_H
#define MAP_H

#include <stdlib.h>
#include <string.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

typedef struct{
  char* data;
  int w;
  int h;
} Map;

int luaopen_map(lua_State *L);
void set_draw(void (*draw)(Map*,int,int,int,int));
void set_getkey(int (*getkey)());
void set_draw_status(void (*draw_status)(char*,int,int,int));

#endif
