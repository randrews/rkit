#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#import <AppKit/AppKit.h>
#import <QuartzCore/CALayer.h>

#include "RKitView.h"
#include "MobView.h"

/*************************************************/
/*** Structs *************************************/
/*************************************************/

typedef struct {
    int width, height;
    NSImage *bmp;

    /* We have to make a separate NSImage and draw a rect there,
       so we can composite it to the screen. So we store it and its rect,
       so we can avoid making one every draw_glyph. */
    NSImage *bg_image;
    NSRect bg_rect;
} Tilesheet;

/*************************************************/
/*** Shared variables ****************************/
/*************************************************/

extern NSMutableArray *loaded_objects, *loaded_sheets;
extern RKitView* rkit_view;
extern NSWindow* window;

/*************************************************/
/*** Shared functions ****************************/
/*************************************************/

/* rkit.m */
int open_rkit(lua_State *L, RKitView *view, NSWindow *window);
void close_rkit();
void new_game();

/* drawing.m */
int load_lua_bitmap(lua_State *L);
int load_tilesheet(lua_State *L);
int draw_bitmap(lua_State *L);
int draw_glyph(lua_State *L);
int make_color(lua_State *L);
NSColor* color_from_int(int color);
int clear_screen(lua_State *L);
int set_title(lua_State *L);
int draw_rect(lua_State *L);
int draw_text(lua_State *L);
int set_resizable(lua_State *L);
int resize_window(lua_State *L);
