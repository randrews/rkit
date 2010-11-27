//
//  RKitAgent.h
//  RKit
//
//  Created by Ross Andrews on 11/24/10.
//  Copyright 2010 None. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rkit.h"

@interface RKitAgent : NSObject {
	NSWindow *window;
	RKitView *rkit_view;
	lua_State *lua;
	NSString *file;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet RKitView *rkit_view;
@property (retain) NSString *file;
@property (readonly) lua_State *lua;

-(id) initWithFile: (NSString*) file_p;
-(void) finalize;

-(void) awakeFromNib;
-(void) windowWillClose: (NSNotification*) notification;
-(void) restart: (id) sender;

// We want to do different things here for whether we're in dev mode,
// so we'll have a method that the lua responders will call.
-(NSImage*) loadImage: (const char*) name;

@end
