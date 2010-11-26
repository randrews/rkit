//
//  MobView.m
//  RKit
//
//  Created by Ross Andrews on 11/20/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "rkit.h"


@implementation MobView

@synthesize redraw;
@synthesize lua;
@synthesize luaFunction;

- (void)drawRect:(NSRect)dirtyRect {
	if(redraw){ redraw(lua, [self frame], luaFunction); }
}

@end
