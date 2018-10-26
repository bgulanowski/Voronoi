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

@interface VOINetAdjacency : VOIAdjacency
@property (readonly, weak) VOITriangleNet *inside;
@property (readonly, weak) VOITriangleNet *outside;
+ (instancetype)adjacencyWithinside:(VOITriangleNet *)inside outside:(VOITriangleNet *)outside;
@end

@interface VOITriangulator ()

@property VOITriangleList *triangulation;
@property VOIPath *convexHull;
@property NSMutableArray<VOITriangleNet *> *nets;
// indexed by segment.hashKey
@property NSMutableDictionary<id<NSCopying>, VOINetAdjacency *> *borderNets;

@end

@implementation VOITriangulator

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
    self.convexHull = [self.convexHull convexHullByAddingPoint:point triangles:&tList affectedPoint:&index];
    [tList iterateTriangles:^(VOITriangle *t, NSUInteger i) {
        VOITriangleNet *newInside = [self removeAdjacencyForHullIndex:index + i];
        VOITriangleNet *newOutside = [[VOITriangleNet alloc] initWithTriangle:t adjacentNets:@[newInside]];
        [self registerBorderNet:newOutside adjacentToNet:newInside];
        [self.nets addObject:newOutside];
        return NO;
    }];
}

- (void)registerSeedTriangle:(VOITriangle *)triangle {
    VOITriangleNet *net = [[VOITriangleNet alloc] initWithTriangle:triangle adjacentNets:nil];
    
    self.convexHull = [triangle asPath];
    [_nets addObject:net];
}

- (void)registerBorderNet:(VOITriangleNet *)borderNet adjacentToNet:(VOITriangleNet *)net {
    // We might already have this information
    // Also, it's a bit of a shame that we can't use the adjacency provided by the net
    // We could revise Adjacency to weakly reference it's net, instead of triangles,
    // but then an adjacency would not be usable outside of a net.
    id<NSCopying>key = [borderNet adjacencyForNet:net].s.hashKey;
    _borderNets[key] = [VOINetAdjacency adjacencyWithinside:borderNet outside:net];
}

- (VOITriangleNet *)removeAdjacencyForHullIndex:(NSUInteger)index {
    id<NSCopying>key = [self.convexHull segmentAt:index].hashKey;
    VOINetAdjacency *adj = _borderNets[key];
    VOITriangleNet *outside = adj.outside;
    _borderNets[key] = nil;
    return outside;
}

@end

@implementation VOINetAdjacency

+ (instancetype)adjacencyWithinside:(VOITriangleNet *)inside outside:(VOITriangleNet *)outside {
    VOINetAdjacency *adjacency = [[self alloc] initWithTriangle:inside.triangle triangle:outside.triangle];
    adjacency->_inside = inside;
    adjacency->_outside = outside;
    return adjacency;
}

@end
