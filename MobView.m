//
//  MobView.m
//  RKit
//
//  Created by Ross Andrews on 11/20/10.
//  Copyright 2010 Home. All rights reserved.
//

#import "rkit.h"


@implementation MobView

@synthesize lua;
@synthesize redrawFunction;

- (void)drawRect:(NSRect)dirtyRect {
	if(redrawFunction){
		lua_pushinteger(lua, redrawFunction);
		lua_gettable(lua, LUA_REGISTRYINDEX);
		lua_call(lua, 0, 0);		
	}
}

@end
