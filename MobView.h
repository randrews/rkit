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
    void (*redraw)(NSRect, int);
    int lua_function;
}

-(void) drawRect: (NSRect) rect;
-(void) setRedraw: (void (*)(NSRect, int)) redraw_p;
-(void) setLuaFunction: (int) lua_function_p;

@end
