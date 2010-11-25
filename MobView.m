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

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	if(redraw){ redraw(lua, [self frame], lua_function); }
}

-(void) setLuaFunction: (int) lua_function_p {
	lua_function = lua_function_p;
}

@end
