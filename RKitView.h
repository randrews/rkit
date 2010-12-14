//
//  RKitView.h
//  RKit
//
//  Created by Ross Andrews on 11/19/10.
//  Copyright 2010 Home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "rkit.h"

@interface RKitView : NSView {
	lua_State *lua;
}

@property (assign) lua_State *lua;

@end
