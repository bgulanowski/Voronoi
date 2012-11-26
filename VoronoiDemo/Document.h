//
//  Document.h
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-06.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>


typedef struct {
    NSUInteger a;
    NSUInteger b;
} Segment;


@class VDemoView, Voronoi;

@interface Document : NSDocument {
    Voronoi *_voronoi;
    Segment *_segments;
    CGPoint *_points;
}

@property (weak) IBOutlet VDemoView *meterView;

@property (nonatomic, readonly) Voronoi *voronoi;
@property (nonatomic) Segment *segments;
@property (nonatomic) CGPoint *points;
@property (nonatomic) CGSize size;
@property (nonatomic) NSUInteger count;


@end
