#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#import <AppKit/AppKit.h>
#import <QuartzCore/CALayer.h>

/*************************************************/
/*** Classes *************************************/
/*************************************************/

/* An NSView subclass that's the content view for our window. */
@interface RKitView : NSView {
    /* Dependency injection. rkit.m (it'll have to be .m) will define
       a function that draws the screen. We'll store a pointer to it here,
       and when Cocoa wants to redraw, our drawRect method will call
       that function. */
    void (*redraw)(NSRect);
    void (*keydown)(const char*,int);
    void (*timer_hook)(int);
}

-(void) drawRect: (NSRect) rect;
-(void) setRedraw: (void (*)(NSRect)) redraw_p;

-(BOOL) acceptsFirstResponder;
-(void) keyDown: (NSEvent*) event;
-(void) setKeydown: (void (*)(const char*,int)) keydown_p;

-(void) callTimer: (NSTimer*) timer_fn_index;
-(void) setTimerHook: (void (*)(int)) timer_hook_p;
@end

/* NSView subclass for anything on the screen we want to animate */
@interface MobView : NSView {
    void (*redraw)(NSRect, int);
    int lua_function;
}

-(void) drawRect: (NSRect) rect;
-(void) setRedraw: (void (*)(NSRect, int)) redraw_p;
-(void) setLuaFunction: (int) lua_function_p;
@end

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

extern NSMutableArray *loaded_bmps, *loaded_sheets;
extern RKitView* rkit_view;
extern NSWindow* window;

/*************************************************/
/*** Shared functions ****************************/
/*************************************************/

/* rkit.m */
int open_rkit(lua_State *L, RKitView *view, NSWindow *window);
void close_rkit();

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
