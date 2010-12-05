//
//  RKitAppDelegate.m
//  RKit
//
//  Created by Ross Andrews on 11/17/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "rkit.h"

@implementation RKitAppDelegate

-(id) init {
	[super init];
	loaded_agents = [[NSMutableArray alloc] initWithCapacity: 1];
	return self;
}

-(void) finalize {
	for(RKitAgent* agent in loaded_agents){
		[agent release];
	}
	[loaded_agents release];
	[super finalize];
}

-(void) applicationDidFinishLaunching:(NSNotification *)aNotification {

}

-(BOOL) application: (NSApplication*) app openFile: (NSString*) path {
	RKitAgent *agent = [[[RKitAgent alloc] initWithFile: path] autorelease];
	[agent.window makeKeyAndOrderFront: self];
	[loaded_agents addObject: agent];
	return YES;
}

-(void) openFile: (id) sender {
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];

	[oPanel setAllowedFileTypes:[NSArray arrayWithObject:@"lua"]];
    [oPanel setAllowsMultipleSelection:NO];
	
    if ([oPanel runModal] == NSOKButton) {
		[[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL: [oPanel URL]];
		NSString *file = [[oPanel URL] path];
		[self application: [NSApplication sharedApplication]
				 openFile: file];
    }
}

-(void) restartActiveWindow: (id) sender {
	RKitAgent *agent = (RKitAgent*) [[[NSApplication sharedApplication] keyWindow] delegate];
	[agent restart: sender];
}

-(void) toggleActiveWindowLog: (id) sender {
	RKitAgent *agent = (RKitAgent*) [[[NSApplication sharedApplication] keyWindow] delegate];
	[[agent log_drawer] toggle: self];
}

-(void) applicationWillTerminate: (NSNotification*) notification {
}

@end
