#include "cave.h"

BITMAP *font_bmp;
BITMAP **glyph_bmps;

/* Layout constants */
const int dest_x = 0; /* Coords we draw the upper left corner of the map at */
const int dest_y = 0;

/*************************************************
 *** Drawing lib stuff ***************************
 *************************************************/

int draw_glyph(lua_State *L);

static const struct luaL_reg draw_lib[] = {
  {"draw_glyph", draw_glyph},
  {NULL, NULL}
};

int luaopen_drawing(lua_State *L){
  luaL_openlib(L, "Drawing", draw_lib, 0);
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

/*************************************************
 *** Drawing functions ***************************
 *************************************************/

void init_drawing(){
  font_bmp = load_bitmap("Tahin-font.tga", NULL);
  glyph_bmps = malloc(256 * sizeof(BITMAP*));
  make_glyph_bmps(font_bmp, glyph_bmps, 16, 16);
}

void close_drawing(){
  int n;
  for(n=0; n < 256; n++){ destroy_bitmap(glyph_bmps[n]); }
  free(glyph_bmps);

  if(font_bmp){destroy_bitmap(font_bmp);}
}

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
    return makecol(0,192,0);
  case '+':
    return makecol(0,255,0);
  case '#':
    return makecol(255,255,102);
  case '-':
    return makecol(0,0,192);
  case '^':
    return makecol(255,0,0);
  case '*':
    return makecol(0,0,0);
  case 5:
    return makecol(0,255,0);
  default:
    return makecol(192, 192, 192);
  }
}

void draw_status(const char* status, int r, int g, int b){
  int line_width = 800 / 8; /* Number of chars that can fit on a line */
  int max = strlen(status);
  int col = makecol(r,g,b);

  textout_ex(screen, font, status, 2, 590, col, 0);

  /* If there's space left, blank it out */
  if(max < line_width) {
    rectfill(screen, max*8+2, 590, 800, 600, 0);
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
      putpixel(screen, x, y, color);
    }
  }
}
