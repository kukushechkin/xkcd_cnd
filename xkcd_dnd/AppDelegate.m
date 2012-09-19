//
//  AppDelegate.m
//  xkcd_dnd
//
//  Created by Vladimir Kukushkin on 9/19/12.
//  Copyright (c) 2012 Vladimir Kukushkin. All rights reserved.
//

#import "AppDelegate.h"

#define contentsHeight(tileSize) (float)((48.0+1.0) * 2.0 * tileSize)
#define contentsWidth(tileSize) (float)((48.0+1.0) * 2.0 * tileSize)

@implementation BlackView

- (void)drawRect:(NSRect)rect
{
    rect = [self bounds];
    [[NSColor blackColor] set];
    [NSBezierPath fillRect: rect];
}

@end

@implementation TileImageView

- (void)reinitWithTileSize:(float)tileSize
{
    NSRect frame;
    if(sector == 0)
        frame = NSMakeRect(contentsWidth(tileSize)/2.0  - tileSize*(float)(i-1),
                           contentsHeight(tileSize)/2.0 - tileSize*(float)(j-1),
                           tileSize,
                           tileSize);
    if(sector == 1)
        frame = NSMakeRect(contentsWidth(tileSize)/2.0  + tileSize*(float)(i),
                           contentsHeight(tileSize)/2.0 - tileSize*(float)(j-1),
                           tileSize,
                           tileSize);
    if(sector == 2)
        frame = NSMakeRect(contentsWidth(tileSize)/2.0  - tileSize*(float)(i-1),
                           contentsHeight(tileSize)/2.0 + tileSize*(float)(j),
                           tileSize,
                           tileSize);
    if(sector == 3)
        frame = NSMakeRect(contentsWidth(tileSize)/2.0  + tileSize*(float)(i),
                           contentsHeight(tileSize)/2.0 + tileSize*(float)(j),
                           tileSize,
                           tileSize);    
    
    self.frame = frame;
    
    if(![self image])
    {
        if(sector == 0 || sector == 1)
        {
            [[[self subviews] objectAtIndex:0] setFrame:NSMakeRect(0, 0, tileSize, tileSize)];
//            BlackView * blackView = [[BlackView alloc] initWithFrame:NSMakeRect(0, 0, tileSize, tileSize)];
//            [self addSubview:blackView];
//            [blackView release];
        }
    }
}

- (TileImageView*)initWithI:(int)_i
                          J:(int)_j
                     sector:(int)_sector
                   tileSize:(float)tileSize
{
    i = _i;
    j = _j;
    sector = _sector;
    
    NSRect frame;
    NSURL *imageUrl;
    if(sector == 0)
    {
        frame = NSMakeRect(contentsWidth(tileSize)/2.0  - tileSize*(float)(i-1),
                           contentsHeight(tileSize)/2.0 - tileSize*(float)(j-1),
                           tileSize,
                           tileSize);
        imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://imgs.xkcd.com/clickdrag/%ds%dw.png", j, i]];
    }
    if(sector == 1)
    {
        frame = NSMakeRect(contentsWidth(tileSize)/2.0  + tileSize*(float)(i),
                           contentsHeight(tileSize)/2.0 - tileSize*(float)(j-1),
                           tileSize,
                           tileSize);
        imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://imgs.xkcd.com/clickdrag/%ds%de.png", j, i]];
    }
    if(sector == 2)
    {
        frame = NSMakeRect(contentsWidth(tileSize)/2.0  - tileSize*(float)(i-1),
                           contentsHeight(tileSize)/2.0 + tileSize*(float)(j),
                           tileSize,
                           tileSize);
        imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://imgs.xkcd.com/clickdrag/%dn%dw.png", j, i]];
    }
    if(sector == 3)
    {
        frame = NSMakeRect(contentsWidth(tileSize)/2.0  + tileSize*(float)(i),
                           contentsHeight(tileSize)/2.0 + tileSize*(float)(j),
                           tileSize,
                           tileSize);
        imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"http://imgs.xkcd.com/clickdrag/%dn%de.png", j, i]];    
    }
    
    self = [super initWithFrame:frame];
    if(self)
    {        
        NSSize aSize;
        aSize.width = tileSize;
        aSize.height = tileSize;
        
        NSLog(@"loading image from url: %@", imageUrl);
        NSImage *anotherImage = [[NSImage alloc] initWithContentsOfURL:imageUrl];
        if(anotherImage)
        {
            [self setImage:anotherImage];
            [anotherImage release];
        }
        else
        {
            if(sector == 0 || sector == 1)
            {
                BlackView * blackView = [[BlackView alloc] initWithFrame:NSMakeRect(0, 0, tileSize, tileSize)];
                [self addSubview:blackView];
                [blackView release];
            }
        }
    }
    return self;
}

@end

@implementation AppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)rearrangeAlreadyDrawnTiles
{
    NSArray * subviews = [[imagesScrollView.documentView subviews] copy];
    for(TileImageView * anotherTileImageView in subviews)
    {
        [anotherTileImageView removeFromSuperview];
        [anotherTileImageView reinitWithTileSize:tileSize];
        [imagesScrollView.documentView addSubview:anotherTileImageView];
    }
//    [imagesScrollView.documentView setNeedsDisplay:YES];
    [subviews release];
}

- (IBAction)zoomIn:(id)sender
{
    tileSize *= 2.0;
    [self rearrangeAlreadyDrawnTiles];
    [imagesScrollView.documentView setFrame:CGRectMake(0, 0, contentsHeight(tileSize), contentsHeight(tileSize))];
}

- (IBAction)zoomOut:(id)sender
{
    tileSize /= 2.0;
    [self rearrangeAlreadyDrawnTiles];
    [imagesScrollView.documentView setFrame:CGRectMake(0, 0, contentsHeight(tileSize), contentsHeight(tileSize))];
}

- (void)awakeFromNib
{
    zoom = 1.0;    
    oldZoom = zoom;
    tileSize = 100.0;
    
    [imagesScrollView.documentView setFrame:CGRectMake(0, 0, contentsHeight(tileSize), contentsHeight(tileSize))];
    
    dispatch_queue_t nw = dispatch_queue_create("com.kukushechkin.xkcddnd.nw", 0);
    dispatch_queue_t ne = dispatch_queue_create("com.kukushechkin.xkcddnd.ne", 0);
    dispatch_queue_t sw = dispatch_queue_create("com.kukushechkin.xkcddnd.sw", 0);
    dispatch_queue_t se = dispatch_queue_create("com.kukushechkin.xkcddnd.se", 0);
    
    dispatch_queue_t mainqq = dispatch_queue_create("com.kukushechkin.xkcddnd.main", 0);
    
    dispatch_async(mainqq, ^{
        for(int k = 1; k < 100; k++)
            for(int i = 1; i < 48; i++) // x
                for(int j = 1; j < 48; j++) // y
                {                    
                    if((i+j) != k) continue;

                    dispatch_async(sw, ^{
                        TileImageView * anotherTileImageView = [[TileImageView alloc] initWithI:i
                                                                                              J:j
                                                                                         sector:0                                                                                       
                                                                                       tileSize:tileSize];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [imagesScrollView.documentView addSubview:anotherTileImageView];
                        });
                        [anotherTileImageView release];
                    });
                    dispatch_async(se, ^{
                        TileImageView * anotherTileImageView = [[TileImageView alloc] initWithI:i
                                                                                              J:j
                                                                                         sector:1
                                                                                       tileSize:tileSize];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [imagesScrollView.documentView addSubview:anotherTileImageView];
                        });
                        [anotherTileImageView release];
                    });
                    dispatch_async(nw, ^{
                        TileImageView * anotherTileImageView = [[TileImageView alloc] initWithI:i
                                                                                              J:j
                                                                                         sector:2
                                                                                       tileSize:tileSize];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [imagesScrollView.documentView addSubview:anotherTileImageView];
                        });
                        [anotherTileImageView release];
                    });
                    dispatch_async(ne, ^{
                        TileImageView * anotherTileImageView = [[TileImageView alloc] initWithI:i
                                                                                              J:j
                                                                                         sector:3
                                                                                       tileSize:tileSize];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [imagesScrollView.documentView addSubview:anotherTileImageView];
                        });
                        [anotherTileImageView release];
                    });
                }
    });
}

@end
