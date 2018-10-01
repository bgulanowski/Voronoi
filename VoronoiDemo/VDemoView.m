//
//  MeterView.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-06.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "VDemoView.h"

#import "Document.h"

#import <voronoi/Voronoi.h>
#import <voronoi/DCircle.h>
#import <voronoi/DPoint.h>
#import <voronoi/DRegion.h>
#import <voronoi/DSegment.h>
#import <voronoi/DTriad.h>


@interface DTriad (Drawing)
- (NSBezierPath *)trianglePathWithPoints:(NSArray *)points;
- (NSBezierPath *)circlePath;
@end


static __strong NSBezierPath *cross;
static __strong NSBezierPath *hatch;


@implementation VDemoView

@synthesize document=_document;

- (void)MeterView_commonInit {
    _mouseRegion = NSNotFound;
}

- (id)init {
    self = [super init];
    if(self) {
        
    }
    return self;
}

+ (void)initialize {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cross = [[NSBezierPath alloc] init];
        [cross moveToPoint:NSMakePoint(-2, 0)];
        [cross lineToPoint:NSMakePoint(2, 0)];
        [cross moveToPoint:NSMakePoint(0, -2)];
        [cross lineToPoint:NSMakePoint(0, 2)];
        hatch = [[NSBezierPath alloc] init];
        [hatch moveToPoint:NSMakePoint(-4, -4)];
        [hatch lineToPoint:NSMakePoint( 4,  4)];
        [hatch moveToPoint:NSMakePoint(-4,  4)];
        [hatch lineToPoint:NSMakePoint( 4, -4)];
    });
}

- (BOOL)acceptsFirstResponder { return YES; }

- (void)mouseMoved:(NSEvent *)theEvent {
    
    NSColor *color = NSReadPixel([theEvent locationInWindow]);
    
    if(!color) return;
    
    NSUInteger hash = [color hash];
    
    if(_colorHash != hash) {
        
        NSNumber *regionNumber = [_regionIndex objectForKey:@(hash)];
        
        _colorHash = hash;
        _mouseRegion = regionNumber ? [regionNumber unsignedIntegerValue] : NSNotFound;

        if(NSNotFound == _mouseRegion)
            _infoString = @"No region";
        else
            _infoString = [NSString stringWithFormat:@"Region: %lu", _mouseRegion];
        [self setNeedsDisplay:YES];
    }
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self)
        [self MeterView_commonInit];
    return self;
}

// Only called if the view is used as contentView of a window
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self)
        [self MeterView_commonInit];
    return self;
}

- (void)drawSegments:(NSRect)dirtyRect points:(CGPoint *)points count:(NSUInteger)count {
    
    if(!_segmentPaths && _document.segments) {
        
        NSBezierPath *segmentPaths = [NSBezierPath bezierPath];
        Segment *segments = _document.segments;
        
        for(NSUInteger i=0; i<count; ++i) {
            [segmentPaths moveToPoint:points[segments[i].a]];
            [segmentPaths lineToPoint:points[segments[i].b]];
        }
        
        _segmentPaths = segmentPaths;
    }
    
    [[NSColor blueColor] set];
    [_segmentPaths stroke];
}

- (void)drawRegions:(NSRect)dirtyRect {
    
    Voronoi *voronoi = _document.voronoi;
    
    if(!voronoi) return;
    
    if(!_regionPaths) {
        
        NSMutableDictionary *regions = [NSMutableDictionary dictionary];
        NSMutableDictionary *hash = [NSMutableDictionary dictionary];
        NSUInteger i=0;
        
        for (DRegion *region in voronoi.regions) {
            
            NSColor *color = [NSColor randomLightColor];
            NSBezierPath *rPath = [NSBezierPath bezierPath];
            NSArray *points = region.points;
            
//            if(i == 3)
//                _solidColorHash = [color hash];
            
            [rPath moveToPoint:[[points lastObject] CGPoint]];
            for (DPoint *point in points)
                [rPath lineToPoint:[point CGPoint]];
            
            [regions setObject:rPath forKey:color];
            [hash setObject:@(i++) forKey:@([color hash])];
        }
        
        _regionPaths = [regions copy];
        _regionIndex = [hash copy];
    }
    
    for(NSColor *color in _regionPaths) {
        [color set];
        NSBezierPath *rPath = [_regionPaths objectForKey:color];
//        if(_solidColorHash == [color hash])
            [rPath fill];
//        else
//            [rPath stroke];
    }
}

- (void)drawCircles:(NSRect)dirtyRect {
    
    CGPoint lastPoint = CGPointZero;
    NSAffineTransform *transform = [NSAffineTransform transform];

    [transform translateXBy:0.5f yBy:0.5f];
    
    for (DTriad *triad in _document.voronoi.triads) {
        
        CGPoint p = triad.circumcircle.centre.CGPoint;
        
        [[NSColor redColor] set];
        [transform translateXBy:p.x-lastPoint.x yBy:p.y-lastPoint.y];
        [[transform transformBezierPath:hatch] stroke];
        
        [[NSColor whiteColor] set];
        [[triad circlePath] stroke];
        
        lastPoint = p;
    }
}

- (void)drawCircleCentres:(NSRect)dirtyRect {
    
    CGPoint lastPoint = CGPointZero;
    NSAffineTransform *transform = [NSAffineTransform transform];
    
    [transform translateXBy:0.5f yBy:0.5f];
    
    for (DTriad *triad in _document.voronoi.triads) {
        
        CGPoint p = triad.circumcircle.centre.CGPoint;
        
        [[NSColor redColor] set];
        [transform translateXBy:p.x-lastPoint.x yBy:p.y-lastPoint.y];
        [[transform transformBezierPath:hatch] stroke];
        
        lastPoint = p;
    }
}

- (void)drawTriads:(NSRect)dirtyRect {
    
    Voronoi *voronoi = _document.voronoi;
    
    if(!voronoi) return;
        
    if(!_trianglePaths) {
    
        NSMutableArray *triangles = [NSMutableArray array];
        NSArray *points = voronoi.points;
        
        for (DTriad *triad in _document.voronoi.triads)
            [triangles addObject:[triad trianglePathWithPoints:points]];
        
        _trianglePaths = triangles;
    }

    [[NSColor colorWithDeviceRed:1.f green:0.5f blue:0.5f alpha:1.0f] set];
    for (NSBezierPath *path in _trianglePaths)
        [path stroke];
}

- (void)drawPoints:(NSRect)dirtyRect gradient:(BOOL)gradient {
    
//    CGPoint *points = _document.points;
    NSUInteger count = _document.count;
    CGPoint lastPoint = CGPointZero;

    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:0.5f yBy:0.5f];
    
    [[NSColor blueColor] set];
    
    NSUInteger i=0;
    
//    for (NSUInteger i=0; i<count; ++i)
    for (DPoint *dp in _document.voronoi.points) {
        
        CGPoint p = [dp CGPoint];
        
        if(NSPointInRect(p, dirtyRect)) {
            if(gradient) {
                CGFloat drift = (CGFloat)i++/(CGFloat)count;
                [[NSColor colorWithDeviceRed:p.x/1024 green:p.y/1024 blue:1.0f - drift alpha:1.f] set];
            }
            [transform translateXBy:p.x - lastPoint.x yBy:p.y - lastPoint.y];
            [[transform transformBezierPath:cross] stroke];
            lastPoint = p;
        }
    }

}

- (void)drawRect:(NSRect)dirtyRect {
    
    [[NSColor blackColor] set];
    [NSBezierPath fillRect:dirtyRect];
    
    [self drawRegions:dirtyRect];
//    [self drawCircleCentres:dirtyRect];
    [self drawTriads:dirtyRect];
    [self drawPoints:dirtyRect gradient:NO];
    
    [[NSColor blackColor] set];
    [_infoString drawAtPoint:NSMakePoint(8, 8) withAttributes:nil];
}

@end


@implementation DTriad (Drawing)

- (NSBezierPath *)trianglePathWithPoints:(NSArray *)points {
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    
    [path moveToPoint:[[points objectAtIndex:self.a] CGPoint]];
    [path lineToPoint:[[points objectAtIndex:self.b] CGPoint]];
    [path lineToPoint:[[points objectAtIndex:self.c] CGPoint]];
    [path lineToPoint:[[points objectAtIndex:self.a] CGPoint]];
    
    return path;
}

- (NSBezierPath *)circlePath {
 
    DCircle *circle = self.circumcircle;
    CGPoint p = circle.centre.CGPoint;
    double r = circle.radius;
    NSRect rect = NSMakeRect(p.x-r, p.y-r, 2*r, 2*r);

    return [NSBezierPath bezierPathWithOvalInRect:rect];
}

@end
