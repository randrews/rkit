#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#ifdef OBJC

#import <AppKit/AppKit.h>

@interface RKitView : NSView {
    /* Dependency injection. rkit.m (it'll have to be .m) will define
       a function that draws the screen. We'll store a pointer to it here,
       and when Cocoa wants to redraw, our drawRect method will call
       that function. */
    void (*redraw)(NSView*, NSRect);
}

-(void) drawRect: (NSRect) rect;

@end

#endif

#ifndef OBJC
typedef void* RKitView;
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

/* rkit.c */
int open_rkit(lua_State *L);
void close_rkit();
void rkit_on_keypress(int scancode); /* We let main.c set this to be the keyboard callback */
