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

-(void) openFile: (id) sender {
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];

	[oPanel setAllowedFileTypes:[NSArray arrayWithObject:@"lua"]];
    [oPanel setAllowsMultipleSelection:NO];
	
    if ([oPanel runModal] == NSOKButton) {
        NSString *file = [[oPanel URL] path];
		RKitAgent *agent = [[RKitAgent alloc] initWithFile: file];
		[loaded_agents addObject: agent];
    }
}

-(void) applicationWillTerminate: (NSNotification*) notification {
	//close_rkit();
}

@end
