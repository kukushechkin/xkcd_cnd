//
//  AppDelegate.h
//  xkcd_dnd
//
//  Created by Vladimir Kukushkin on 9/19/12.
//  Copyright (c) 2012 Vladimir Kukushkin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSScrollView * imagesScrollView;
    float zoom;
    float oldZoom;
    float tileSize;
}

@property (assign) IBOutlet NSWindow *window;

@end

@interface BlackView : NSView
@end

@interface TileImageView : NSImageView
{
    int i;
    int j;
    int sector;
}
- (TileImageView*)initWithI:(int)_i J:(int)_j sector:(int)_sector tileSize:(float)tileSize;
- (void)reinitWithTileSize:(float)tileSize;
@end