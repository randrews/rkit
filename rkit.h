#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

/* Declare the interface of the RKitView. C files include this too,
   so we'll wrap it in an ifdef, and only define that when compiling
   .m files */
#ifdef OBJC
#import <AppKit/AppKit.h>
#import <QuartzCore/CALayer.h>

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

/* We can't have this be in RKitView, because then the root layer will
   try to call it, so make a new class. But, we can shove the Lua fn
   indices into the individual layers (so cool) so we only need one of
   these, and no members. */
@interface MobDelegate : NSObject
-(void) drawLayer: (CALayer*) layer inContext: (CGContextRef) ctx;
@end
#else
/* C files may still have to see RKitView in a prototype, so just tell
   them it's a void* and be done with it. */
typedef void RKitView;
typedef void MobDelegate;
typedef void NSWindow;
#endif

typedef struct{
    char* data;
    int w;
    int h;
} Map;

typedef struct Node{
    char *key;
    struct Node *next;
    void *value;
} Node;

typedef struct{
    Node *head, *last;
} AList;

/* alist.c */

/* Frees all the keys, and returns a new array of the values.
   Does NOT free the AList itself, or any of the values. */
void** alist_free();

/* Sets the value associated with a given key, and returns
   the old value associated with that key, or null. */
void* alist_put(AList *alist, const char *key, void *value);

void* alist_get(AList *alist, const char *key);
int alist_length(AList *alist);

/* map.c */
int luaopen_map(lua_State *L);
void set_draw(void (*draw)(Map*,int,int,int,int));
void set_getkey(int (*getkey)());
void set_draw_status(void (*draw_status)(const char*,int,int,int));
Map* checkmap(lua_State *L, int index);
Map* pushmap(lua_State *L, int w, int h);

/* rkit.m */
int open_rkit(lua_State *L, RKitView *view, NSWindow *window);
void close_rkit();
