//
//  MeterView.h
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-06.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class Document;

@interface VDemoView : NSView {
    __strong NSBezierPath *_segmentPaths;
    __strong NSDictionary *_regionIndex;
    __strong NSDictionary *_regionPaths;
    __strong NSArray *_trianglePaths;
    __strong NSString *_infoString;
    
    NSUInteger _colorHash;
    NSUInteger _solidColorHash;
    NSUInteger _mouseRegion;
}

@property (nonatomic, weak) Document *document;

@end
