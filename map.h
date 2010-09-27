#ifndef MAP_H
#define MAP_H

#include <stdlib.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

typedef struct{
  char* data;
  int w;
  int h;
} Map;

int luaopen_map(lua_State *L);

#endif
