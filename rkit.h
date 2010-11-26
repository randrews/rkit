#ifndef _RKIT_H_
#define _RKIT_H_
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#import <AppKit/AppKit.h>
#import <QuartzCore/CALayer.h>

#import "MobView.h"
#import "RKitView.h"
#import "RKitAppDelegate.h"

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
/*** Shared functions ****************************/
/*************************************************/

/* rkit.m */
int open_rkit(lua_State *L);
void rkit_set_view(lua_State *L, RKitView *view);
void close_rkit(lua_State *L);
void new_game();
void key_down(lua_State *L, const char *letter, int key_code);

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

/* timer.m */
int create_timer(lua_State *L);
int stop_timer(lua_State *L);
void rkit_timer_hook(lua_State *L, int timer_fn);

/* util.m */
void *get_value(lua_State *L, const char *key);
void rkit_register_value(lua_State *L, const char *key, void *value);
void set_handler(lua_State *L, const char *name);
void rkit_set_window(lua_State *L, NSWindow *window);
void rkit_set_agent(lua_State *L, RKitAgent *agent);
RKitView* rkit_view(lua_State *L);
NSWindow* window(lua_State *L);
NSMutableArray* loaded_sheets(lua_State *L);
NSMutableArray* loaded_objects(lua_State *L);
RKitAgent* agent(lua_State *L);
int set_input_handler(lua_State *L);
int set_redraw_handler(lua_State *L);
int set_new_game(lua_State *L);

/* mob.m */
int create_mob(lua_State *L);
int move_mob(lua_State *L);
int close_mob(lua_State *L);
int teleport_mob(lua_State *L);

#endif