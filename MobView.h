//
//  MobView.h
//  RKit
//
//  Created by Ross Andrews on 11/20/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rkit.h"

@interface MobView : NSView {
    int redrawFunction;
	lua_State *lua;
}

@property (assign) lua_State *lua;
@property int redrawFunction;

-(void) drawRect: (NSRect) rect;

@end
