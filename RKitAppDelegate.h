//
//  RKitAppDelegate.h
//  RKit
//
//  Created by Ross Andrews on 11/17/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include "rkit.h"

@interface RKitAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	RKitView *rkit_view;
}

@property (assign) IBOutlet RKitView *rkit_view;
@property (assign) IBOutlet NSWindow *window;

-(BOOL) setupLuaState: (lua_State*) L withCode: (const char*) code;
-(void) logLuaErrorFrom: (lua_State*) L;
-(BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication*) app;
-(void) restartGame: (id) sender;
-(void) applicationWillTerminate: (NSNotification *)notification;
@end
