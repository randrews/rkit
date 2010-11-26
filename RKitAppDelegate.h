//
//  RKitAppDelegate.h
//  RKit
//
//  Created by Ross Andrews on 11/17/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "RKitAgent.h"
#import "rkit.h"

@interface RKitAppDelegate : NSObject <NSApplicationDelegate> {
	NSMutableArray *loaded_agents;
}

-(id) init;
-(void) finalize;

-(void) applicationWillTerminate: (NSNotification*) notification;
-(void) openFile: (id) sender;
-(BOOL) application: (NSApplication*) app openFile: (NSString*) path;
@end
