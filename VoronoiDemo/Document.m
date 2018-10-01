//
//  Document.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-06.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "Document.h"

#import "VDemoView.h"

#import <voronoi/Voronoi.h>
#import <voronoi/DPoint.h>
#import <voronoi/DRange.h>
#import <voronoi/DTriad.h>


#define WIDTH  1280
#define HEIGHT 800


@implementation Document

@synthesize segments=_segments;
@synthesize meterView = _meterView;
@synthesize points=_points;
@synthesize size=_size;
@synthesize count=_count;

static int comparePointsXDistanceIndexed(CGPoint *points, NSUInteger *pi1, NSUInteger *pi2) {
    CGFloat x1 = points[*pi1].x, x2 = points[*pi2].x;
    if(x1 == x2) return 0;
    if(x1 < x2) return -1;
    return 1;
}

static int comparePointsYDistanceIndexed(CGPoint *points, NSUInteger *pi1, NSUInteger *pi2) {
    CGFloat y1 = points[*pi1].y, y2 = points[*pi2].y;
    if(y1 == y2) return 0;
    if(y1 < y2) return -1;
    return 1;
}

- (void)createSegments {
    
    NSUInteger *xIndices = malloc(sizeof(NSUInteger)*_count);
    NSUInteger *yIndices = malloc(sizeof(NSUInteger)*_count);
    
    for(NSUInteger i=0; i<_count; ++i)
        xIndices[i] = yIndices[i] = i;
    
    qsort_r(xIndices, _count, sizeof(NSUInteger), _points, (int (*)(void *, const void *, const void *))comparePointsXDistanceIndexed);
    qsort_r(yIndices, _count, sizeof(NSUInteger), _points, (int (*)(void *, const void *, const void *))comparePointsYDistanceIndexed);
    
    if(!_segments) _segments = malloc(sizeof(Segment)*_count);
    
    
    for (NSUInteger j=0; j<_count; ++j) {
        
        CGFloat db = CGFLOAT_MAX;
        NSUInteger b = NSUIntegerMax;
        
        _segments[j].a = j;
        
        for (NSUInteger i=0; i+j<_count; ++i) {
            
            CGFloat min;
            NSUInteger mini;
            
            NSUInteger xi = xIndices[j+i], yi = yIndices[j+i];
            CGFloat dxx, dxy, dyx, dyy, dxi = CGFLOAT_MAX, dyi = CGFLOAT_MAX;
            
            if(xi != j) {
                dxx = _points[xi].x - _points[j].x;
                dxy = _points[xi].y - _points[j].y;
                dxi = dxx * dxx + dxy * dxy;
            }
            if(yi != j) {
                dyx = _points[yi].x - _points[j].x;
                dyy = _points[yi].y - _points[j].y;
                dyi = dyx * dyx + dyy * dyy;
            }
            
            if(dxi < dyi) {
                min = dxi;
                mini = xi;
            }
            else {
                min = dyi;
                mini = yi;
            }
            
            if(i <= j) {
                xi = xIndices[j-i];
                yi = yIndices[j-i];
                
                if(xi != j) {
                    dxx = _points[xi].x - _points[j].x;
                    dxy = _points[xi].y - _points[j].y;
                    dxi = dxx * dxx + dxy * dxy;
                }
                else
                    dxi = CGFLOAT_MAX;
                
                if(yi != j) {
                    dyx = _points[yi].x - _points[j].x;
                    dyy = _points[yi].y - _points[j].y;
                    dyi = dyx * dyx + dyy * dyy;
                }
                else
                    dyi = CGFLOAT_MAX;
                
                if(dxi < dyi && dxi < min) {
                    min = dxi;
                    mini = xi;
                }
                else if(dyi < min) {
                    min = dyi;
                    mini = yi;
                }
            }
            
            if(db > min) {
                db = min;
                b = mini;
            }
            // We're looking for a heuristic that lets us detect that we can bail out early
            // We shoudn't have to search throught the whole set of points, only those nearby...
//            else if(xi != j && yi != j) {
//                break;
//            }
        }
        
        NSAssert(b != NSIntegerMax, @"oops");
        
        _segments[j].b = b;
    }
}

- (void)createVoronoi {
    
    NSMutableArray *points = [NSMutableArray array];
    DRange *range = [DRange rangeWithPoint:[DPoint pointWithX:0 y:0] point:[DPoint pointWithX:WIDTH y:HEIGHT]];
    
    for (NSUInteger i=0; i<_count; ++i)
        [points addObject:[DPoint pointWithCGPoint:_points[i]]];
    
    _voronoi = [Voronoi voronoiWithPoints:points range:range];
    
    
    // Relax the points
    CGPoint *relaxed = malloc(sizeof(CGPoint)*_count);
    
    NSMutableArray *lookups = [NSMutableArray array];
    
    for (NSUInteger i=0; i<_count; ++i)
        [lookups addObject:[NSMutableIndexSet indexSet]];
    
    for (DTriad *triad in _voronoi.triads) {
        NSMutableIndexSet *indexSet;
        
        indexSet = [lookups objectAtIndex:triad.a];
        [indexSet addIndex:triad.b];
        [indexSet addIndex:triad.c];
        
        indexSet = [lookups objectAtIndex:triad.b];
        [indexSet addIndex:triad.c];
        [indexSet addIndex:triad.a];
        
        indexSet = [lookups objectAtIndex:triad.c];
        [indexSet addIndex:triad.a];
        [indexSet addIndex:triad.b];
    }
    
    NSUInteger i=0;
    
    for (NSMutableIndexSet *indexSet in lookups) {
        
        __block CGPoint p = CGPointZero;
        __block NSUInteger n = 0;
        
        [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            p.x += self->_points[idx].x;
            p.y += self->_points[idx].y;
            ++n;
        }];
        relaxed[i].x = p.x/n;
        relaxed[i].y = p.y/n;
        
        ++i;
    }
    
    [points removeAllObjects];
    for (NSUInteger i=0; i<_count; ++i)
        [points addObject:[DPoint pointWithCGPoint:relaxed[i]]];
    
    _voronoi = [Voronoi voronoiWithPoints:points range:range];
}

- (void)createPoints {
    
//    srandom(88);
    srandom((unsigned)time(NULL));
//    srandom(50001);
    
    if(!_points) _points = malloc(sizeof(CGPoint)*_count);
    
    for (NSUInteger i=0; i<_count; ++i) {
        _points[i].x = floor(BARandomCGFloatInRange(0, _size.width));
        _points[i].y = floor(BARandomCGFloatInRange(0, _size.height));
    }
    
//    qsort(_points, _count, sizeof(CGPoint), (int (*)(const void *, const void *))comparePointsDistanceFromOrigin);
}

- (id)init
{
    self = [super init];
    if (self) {
        _size = CGSizeMake(WIDTH, HEIGHT);
        _count = BARandomIntegerInRange(20, 500);
        [self createPoints];
//        [self createSegments];
        [self createVoronoi];
    }
    return self;
}

- (NSString *)windowNibName {
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController {
    [super windowControllerDidLoadNib:aController];
    _meterView.document = self;
    [aController.window setAcceptsMouseMovedEvents:YES];
}

+ (BOOL)autosavesInPlace {
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    return YES;
}

@end
