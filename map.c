#include "map.h"

int newmap(lua_State* L);

static const struct luaL_reg maplib [] = {
  {"new", newmap},
/*   {"set", setarray}, */
/*   {"get", getarray}, */
/*   {"size", getsize}, */
  {NULL, NULL}
};

int luaopen_map(lua_State *L){
  luaL_newmetatable(L, "Cave.Map");
  luaL_openlib(L, "Map", maplib, 0);
  return 1;
}

int newmap(lua_State* L){
  int w = luaL_checkint(L, 1);
  int h = luaL_checkint(L, 2);

  Map* map = (Map*) lua_newuserdata(L, sizeof(Map));

  map->w = w;
  map->h = h;
  map->data = malloc(w*h);

  luaL_getmetatable(L, "Cave.Map");
  lua_setmetatable(L, -2);

  return 1;
}
