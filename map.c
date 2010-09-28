#include "map.h"

int newmap(lua_State* L);
Map* checkmap(lua_State *L);
int map_size(lua_State *L);
int map_adjacent(lua_State *L);
int adjacent(Map* map, int x, int y, char c);
int map_inbounds(lua_State* L);
int inbounds(Map* map, int x, int y);
int map_gc(lua_State* L);

static const struct luaL_reg maplib [] = {
  {"new", newmap},
  {NULL, NULL}
};

static const struct luaL_reg map_metatable [] = {
      {"size", map_size},
      {"adjacent", map_adjacent},
      {"inbounds", map_inbounds},
      {"__gc", map_gc},
      {NULL, NULL}
};

int luaopen_map(lua_State *L){
  luaL_newmetatable(L, "Cave.Map");

  /* Set the MT's __index to the MT, so default values for Map come from there */
  lua_pushstring(L, "__index");
  lua_pushvalue(L, -2);
  lua_settable(L, -3);

  /* Now the only thing on the stack is the MT, so openlib dumps these into it */
  luaL_openlib(L, NULL, map_metatable, 0);

  luaL_openlib(L, "Map", maplib, 0);
  return 1;
}

int map_gc(lua_State* L){
  Map* map = checkmap(L);
  free(map->data);
  return 0;
}

int map_inbounds(lua_State* L){
  Map* map = checkmap(L);
  int x = luaL_checkint(L,2);
  int y = luaL_checkint(L,3);

  lua_pushboolean(L, inbounds(map, x, y));

  return 1;
}

int inbounds(Map* map, int x, int y){
  return (x >= 0 && x < map->w &&
	  y >= 0 && y < map->h);
}

/* Takes coords and a string, returns the total of the adjacent cells that are any char in that string */
int map_adjacent(lua_State *L){
  Map* map = checkmap(L);
  int x = luaL_checkint(L,2);
  int y = luaL_checkint(L,3);
  const char* c = luaL_checkstring(L, 4);

  int total = 0;
  while(*c){
    total += adjacent(map, x, y, *c);
    c++;
  }

  lua_pushnumber(L, total);
  return 1;
}

/* Helper fn for map_adjacent */
int adjacent(Map* map, int x, int y, char c){
  int total = 0;

  if(x > 0 && map->data[(x-1) + y * map->w] == c){total++;}
  if(y > 0 && map->data[x + (y-1) * map->w] == c){total++;}
  if(x < map->w-1 && map->data[(x+1) + y * map->w] == c){total++;}
  if(y < map->h-1 && map->data[x + (y+1) * map->w] == c){total++;}

  if(x > 0 && y > 0
     && map->data[(x-1) + (y-1) * map->w] == c){total++;}
  if(x > 0 && y < map->h-1
     && map->data[(x-1) + (y+1) * map->w] == c){total++;}
  if(x < map->w-1 && y > 0
     && map->data[(x+1) + (y-1) * map->w] == c){total++;}
  if(x < map->w-1 && y < map->h-1
     && map->data[(x+1) + (y+1) * map->w] == c){total++;}

  return total;
}

/* Returns the width and height of a map */
int map_size(lua_State *L){
  Map* map = checkmap(L);
  lua_pushnumber(L, map->w);
  lua_pushnumber(L, map->h);
  return 2;
}

Map* checkmap(lua_State *L){
  void *map = luaL_checkudata(L, 1, "Cave.Map");
  luaL_argcheck(L, map != NULL, 1, "Map expected");
  return (Map*) map;
}

int newmap(lua_State* L){
  int w = luaL_checkint(L, 1);
  int h = luaL_checkint(L, 2);

  Map* map = (Map*) lua_newuserdata(L, sizeof(Map));

  map->w = w;
  map->h = h;
  map->data = malloc(w*h);

  memset(map->data, '.', map->w * map->h);

  luaL_getmetatable(L, "Cave.Map");
  lua_setmetatable(L, -2);

  return 1;
}
