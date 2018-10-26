//
//  VOITriangulator.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-05.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOITriangulator.h"

#import "VOIAdjacency.h"
#import "VOIPath.h"
#import "VOIPointList.h"
#import "VOISegment.h"
#import "VOITriangle.h"
#import "VOITriangleList.h"
#import "VOITriangleNet.h"

@interface VOITriangulator ()

@property VOITriangleList *triangulation;
@property VOIPath *convexHull;
@property NSMutableArray<VOITriangleNet *> *nets;
// indexed by segment.hashKey
@property NSMutableDictionary<id<NSCopying>, VOITriangleNet *> *borderNets;

@end

@implementation VOITriangulator

- (BOOL)minimized {
    return [_nets count] > 0 && ![[NSSet setWithArray:[_nets valueForKey:@"minimized"]] containsObject:@NO];
}

- (instancetype)initWithPointList:(VOIPointList *)pointList {
    self = [super init];
    if (self) {
        _pointList = pointList;
        _nets = [NSMutableArray array];
        _borderNets = [NSMutableDictionary dictionary];
    }
    return self;
}

- (VOITriangleList *)triangulate {
    return _triangulation ? _triangulation : [self generateTriangulation];
}

- (VOITriangleList *)generateTriangulation {
    
    NSMutableIndexSet *indices = [NSMutableIndexSet indexSet];
    VOITriangle *seedTriangle = [self seedTriangleIndices:indices];
    [self registerSeedTriangle:seedTriangle];

    VOIPointList *remaining = [_pointList deleteIndices:indices];
    remaining = [remaining sortedByDistanceFrom:seedTriangle.centre];
    [self addTrianglesFromPoints:remaining];

    _triangulation = [[VOITriangleList alloc] initWithTriangles:[self.nets valueForKey:@"triangle"]];
    return _triangulation;
}

- (VOITriangle *)seedTriangleIndices:(NSMutableIndexSet *)indices {
    
    VOIPoint points[3];
    NSUInteger index = NSNotFound;
    
    // The first point is arbitrary. Chose the closest to centre for aesthetic reasons.
    points[0] = [_pointList pointClosestToPoint:_pointList.centre index:&index ignoreIfEqual:NO];
    [indices addIndex:index];
    // The second point is the closest to the first point
    points[1] = [_pointList pointClosestToPoint:points[0] index:&index];
    [indices addIndex:index];
    
    VOIPoint *pPoints = points;
    __block NSUInteger index3 = NSNotFound;
    __block double delta = (double)INFINITY;
    // Find a third point that creates the triangle with the smallest circumcircle (centre)
    // All other points will be outside of this circle, seeding our triangulation
    [_pointList iteratePoints:^(const VOIPoint *p, const NSUInteger i) {
        if (![indices containsIndex:i]) {
            pPoints[2] = *p;
            VOIPoint c = VOICentrePoint(pPoints);
            double d = simd_distance_squared(*p, c);
            if (d < delta) {
                delta = d;
                index3 = i;
            }
        }
        return NO;
    }];
    
    [indices addIndex:index3];

    return [_pointList triangleForIndexSet:indices];
}

// Points should already be sorted by distance from seed triangle
- (void)addTrianglesFromPoints:(VOIPointList *)points {
    [points iteratePoints:^BOOL(const VOIPoint *p, const NSUInteger i) {
        [self addPointToHull:*p];
        return NO;
    }];
}

- (void)addPointToHull:(VOIPoint)point {
    VOITriangleList *tList;
    NSUInteger index;
    VOIPath *newHull = [self.convexHull convexHullByAddingPoint:point triangles:&tList affectedPoint:&index];
    __block VOITriangleNet *prev = nil;
    NSMutableArray *newNets = [NSMutableArray array];
    [tList iterateTriangles:^(VOITriangle *t, NSUInteger i) {
        VOITriangleNet *old = [self removeBorderNetForHullIndex:index + i];
        NSArray *adjacent = prev ? @[prev, old] : @[old];
        VOITriangleNet *net = [[VOITriangleNet alloc] initWithTriangle:t adjacentNets:adjacent];
//        [self registerBorderNet:new atHullIndex:index + i]; // impossible
        [newNets addObject:net];
        prev = net;
        return NO;
    }];

    // There's a weird case when we add a new point at index 0
    // but the index we get back is that of the last segment
    // in that case, we may need to increment the index to ensure
    // we add a net for the new segment at 0, instead of overwriting
    // the second last one from the end
    // Need to determine the correct criteria for noticing this situation
    VOIPoint newp0 = [newHull pointAtIndex:0];
    if (point.x == newp0.x && point.y == newp0.y && newHull.count > _convexHull.count) {
        ++index;
    }

    self.convexHull = newHull;

    [self registerBorderNet:[newNets firstObject] atHullIndex:index];
    VOITriangleNet *last = [newNets lastObject];
    for (VOITriangleNet *net in newNets) {
        [net minimize];
    }
    VOISegment *lastSegment = [newHull segmentAt:index + 1];
    if ([last.triangle indexForSegment:lastSegment] == NSNotFound) {
        last = [last netForSegment:lastSegment];
    }
    [self registerBorderNet:last atHullIndex:index + 1];
    
    NSAssert(_borderNets.count == newHull.count, @"inconsistent segments and border nets");
    
    [self.nets addObjectsFromArray:newNets];
}

- (void)registerSeedTriangle:(VOITriangle *)triangle {
    VOITriangleNet *net = [[VOITriangleNet alloc] initWithTriangle:triangle adjacentNets:nil];
    self.convexHull = [triangle asPath];
    [self registerBorderNet:net atHullIndex:0];
    [self registerBorderNet:net atHullIndex:1];
    [self registerBorderNet:net atHullIndex:2];
    [_nets addObject:net];
}

- (VOITriangleNet *)borderNetForHullIndex:(NSUInteger)index {
    id<NSCopying>key = [self.convexHull segmentAt:index].hashKey;
    return _borderNets[key];
}

- (void)registerBorderNet:(VOITriangleNet *)borderNet atHullIndex:(NSUInteger)index {
    id<NSCopying>key = [self.convexHull segmentAt:index].hashKey;
    NSAssert(_borderNets[key] == nil, @"Overwriting borderNet at index %td", index);
    _borderNets[key] = borderNet;
}

- (VOITriangleNet *)removeBorderNetForHullIndex:(NSUInteger)index {
    id<NSCopying>key = [self.convexHull segmentAt:index].hashKey;
    VOITriangleNet *net = _borderNets[key];
    _borderNets[key] = nil;
    return net;
}

@end
