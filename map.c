#include "map.h"

int newmap(lua_State* L);
Map* checkmap(lua_State *L);
int map_size(lua_State *L);
int map_adjacent(lua_State *L);
int adjacent(Map* map, int x, int y, char c);
int map_inbounds(lua_State* L);
int inbounds(Map* map, int x, int y);
int map_gc(lua_State* L);
int map_each(lua_State* L);
int map_each_helper(lua_State* L);
int map_each_range_helper(lua_State* L);
int map_get(lua_State* L);
int map_set(lua_State* L);
int map_draw(lua_State* L);
int map_getkey(lua_State* L);
int map_draw_status(lua_State* L);

void (*DRAW)(Map*,int,int,int,int) = NULL;
int (*GETKEY)() = NULL;
void (*DRAW_STATUS)(const char*,int,int,int) = NULL;

static const struct luaL_reg maplib [] = {
  {"new", newmap},
  {NULL, NULL}
};

static const struct luaL_reg map_metatable [] = {
      {"size", map_size},
      {"adjacent", map_adjacent},
      {"inbounds", map_inbounds},
      {"each", map_each},
      {"get", map_get},
      {"set", map_set},
      {"draw", map_draw},
      {"__gc", map_gc},
      {NULL, NULL}
};

int luaopen_map(lua_State *L){
  lua_pushcfunction(L, &map_getkey);
  lua_setglobal(L, "getkey");

  lua_pushcfunction(L, &map_draw_status);
  lua_setglobal(L, "draw_status");

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

void set_draw(void (*draw)(Map*,int,int,int,int)){
  DRAW = draw;
}

void set_getkey(int (*getkey)()){
  GETKEY = getkey;
}

void set_draw_status(void (*draw_status)(const char*,int,int,int)){
  DRAW_STATUS = draw_status;
}

int map_getkey(lua_State* L){
  if(GETKEY){
	int code = (*GETKEY)();
	char chr = code & 0xff; /* Low byte is ASCII */
	int scan = code >> 8; /* High byte is the scancode */

	lua_pushlstring(L, &chr, 1);
	lua_pushnumber(L, scan);
	return 2;
  } else {
	return 0;
  }
}

int map_draw_status(lua_State* L){
  const char *str = luaL_checkstring(L, 1);

  int r=255, g=255, b=255;

  if(lua_gettop(L) >= 4){
    r = luaL_checkinteger(L, 2);
    g = luaL_checkinteger(L, 3);
    b = luaL_checkinteger(L, 4);
  }

  if(DRAW_STATUS){ (*DRAW_STATUS)(str, r, g, b); }

  return 0;
}

int map_draw(lua_State* L){
  Map* map = checkmap(L);

  int x,y,w,h;

  if(lua_gettop(L) >= 5){
    x = luaL_checkinteger(L, 2);
    y = luaL_checkinteger(L, 3);
    w = luaL_checkinteger(L, 4);
    h = luaL_checkinteger(L, 5);
  } else {
    x = y = 0;
    w = h = 0;
  }

  if(DRAW){
    (*DRAW)(map, x, y, w, h);
  }

  return 0;
}

int map_get(lua_State* L){
  Map* map = checkmap(L);
  int x = luaL_checkinteger(L, 2);
  int y = luaL_checkinteger(L, 3);

  if(inbounds(map, x, y)){
    lua_pushlstring(L, map->data + x + y*map->w, 1);
  } else {
    lua_pushnil(L);
  }

  return 1;
}

int map_set(lua_State* L){
  Map* map = checkmap(L);
  int x = luaL_checkinteger(L, 2);
  int y = luaL_checkinteger(L, 3);
  const char* v = luaL_checkstring(L, 4);

  if(inbounds(map, x, y)){
    int n = x + y * map->w;
    map->data[n] = *v;
    lua_pushlstring(L, map->data + n, 1);
  } else {
    lua_pushnil(L);
  }

  return 1;
}

int map_each(lua_State* L){
  Map* map = checkmap(L);
  if(lua_gettop(L) >= 5) {
    /* range iteration */
    int x = luaL_checkinteger(L, 2);
    int y = luaL_checkinteger(L, 3);
    int w = luaL_checkinteger(L, 4);
    int h = luaL_checkinteger(L, 5);

    lua_pushnumber(L, 0);
    lua_pushcclosure(L, &map_each_range_helper, 5);
  } else {
    /* simple iteration */
    lua_pushnumber(L, 0);
    lua_pushcclosure(L, &map_each_helper, 1);
  }

  lua_pushvalue(L, 1);
  return 2;
}

int map_each_range_helper(lua_State* L){
  Map* map = checkmap(L);
  int x = lua_tonumber(L, lua_upvalueindex(1));
  int y = lua_tonumber(L, lua_upvalueindex(2));
  int w = lua_tonumber(L, lua_upvalueindex(3));
  int h = lua_tonumber(L, lua_upvalueindex(4));
  int n = lua_tonumber(L, lua_upvalueindex(5));

  if(n >= w*h){
    lua_pushnil(L);
    return 1;
  } else {
    int range_x = n % w;
    int range_y = n / w;

    lua_pushnumber(L, x + range_x);
    lua_pushnumber(L, y + range_y);

    lua_pushlstring(L, map->data + (x+range_x) + (y+range_y)*(map->w), 1);

    lua_pushnumber(L, ++n);
    lua_replace(L, lua_upvalueindex(5));

    return 3;
  }
}

int map_each_helper(lua_State* L){
  Map* map = checkmap(L);
  int n = lua_tonumber(L, lua_upvalueindex(1));

  if(n >= map->w * map->h){
    lua_pushnil(L);
    return 1;
  } else {
    lua_pushnumber(L, n % map->w);
    lua_pushnumber(L, n / map->w);
    lua_pushlstring(L, map->data + n, 1);

    lua_pushnumber(L, ++n);
    lua_replace(L, lua_upvalueindex(1));

    return 3;
  }
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
