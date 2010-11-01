
int draw_glyph(lua_State *L);

static const struct luaL_reg rkit_lib[] = {
  {"draw_glyph", draw_glyph},
  {NULL, NULL}
};

int luaopen_rkit(lua_State *L){
  luaL_openlib(L, "RKit", rkit_lib, 0);
  return 1;
}

int draw_glyph(lua_State *L){
  const char *c = luaL_checkstring(L, 1);
  int x = luaL_checkinteger(L, 2);
  int y = luaL_checkinteger(L, 3);

  Glyph glyph = glyph_for(*c);

  draw_character_ex(screen, glyph.letter,
					x*16, y*16,
					makecol(128,128,128),
					makecol(0,0,0));

  return 0;
}
