#include <ncurses.h>
#include <stdio.h>
#include <string.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

void draw_border(int x, int y, int w, int h);
    
int main(int argc, char** argv){
  char buff[256];
  int error;
  lua_State *L = lua_open();   /* opens Lua */
  luaL_openlibs(L);
    
/*   while (fgets(buff, sizeof(buff), stdin) != NULL) { */
/*     error = luaL_loadbuffer(L, buff, strlen(buff), "line") || */
/*       lua_pcall(L, 0, 0, 0); */
/*     if (error) { */
/*       fprintf(stderr, "%s", lua_tostring(L, -1)); */
/*       lua_pop(L, 1);  /\* pop error message from the stack *\/ */
/*     } */
/*   } */
    
  lua_close(L);

  initscr();

  draw_border(0,0,5,6);

  getch();
  endwin();
  return 0;
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
