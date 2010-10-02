#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include <ncurses.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include "map.h"

const int dest_x = 0;
const int dest_y = 0;

void draw_border(int x, int y, int w, int h);
void draw_layout();
void draw_map(Map* map, int src_x, int src_y, int w, int h);
void fill_map(Map* map);
int adjacent(Map* map, int x, int y, char c);

int main(int argc, char** argv){
  char buff[256];
  int error;
  lua_State *L = lua_open();   /* opens Lua */
  luaL_openlibs(L);
  luaopen_map(L);
  set_draw(&draw_map);
  set_getkey(&getch);

  initscr();

  char* code = "require('cave')";
  error = luaL_loadbuffer(L, code, strlen(code), "line") || lua_pcall(L, 0, 0, 0);

  if(error){
    mvaddstr(LINES-2, 0, lua_tostring(L,-1));
    lua_pop(L, 1);
    getch();
  }

  endwin();
  lua_close(L);

  return 0;
}

void draw_map(Map* map, int src_x, int src_y, int w, int h){
  if(!w){w = COLS;}
  if(!h){h = LINES;}

  int x, y;
  int src_w = map->w;

  for(y=0; y < h; y++){
    for(x=0; x < w; x++){
      char c = map->data[((y+src_y)*src_w) + (x+src_x)%src_w];
      mvaddch(y, x, c);
    }
  }
}

void fill_map(Map* map){
  memset(map->data, '.', map->w * map->h);

  srand(time(0));

  int n;
  for(n=0; n < map->w * map->h; n++){
    if(rand()%2){continue;}
    map->data[n] = '+';
  }

  for(n=0; n<4; n++){
    int x,y;

    for(y=0; y < map->h; y++){
      for(x=0; x < map->w; x++){
	char c = map->data[x + map->w * y];
	int a = adjacent(map, x, y, '+');

	if(c == '.' && a > 4){ map->data[x + map->w * y] = '+'; }
	if(c == '+' && a < 4){ map->data[x + map->w * y] = '.'; }
      }
    }
  }
}

void draw_layout(){
  int n;
  for(n = 0; n < COLS; n++){
    mvaddch(LINES-8, n, 196);
  }

  for(n = 0; n < LINES-8; n++){
    mvaddch(n, COLS-21, 179);
  }

  mvaddch(LINES-8, COLS-21, 193);
}

void draw_border(int x, int y, int w, int h){
  mvaddch(y+h,x+w,217);
  mvaddch(y,x,218);
  mvaddch(y,x+w,191);
  mvaddch(y+h,x,192);

  int n;

  for(n=y+1; n < y+h; n++){
    mvaddch(y+n, x, 179);
    mvaddch(y+n, x+w, 179);
  }

  for(n=x+1; n < x+w; n++){
    mvaddch(y, x+n, 196);
    mvaddch(y+h, x+n, 196);
  }
}
