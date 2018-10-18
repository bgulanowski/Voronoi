//
//  VOITriangulator.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-05.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOITriangulator.h"

#import "VOIPath.h"
#import "VOIPointList.h"
#import "VOITriangle.h"
#import "VOITriangleList.h"

@interface VOITriangulator ()

@property VOITriangleList *triangulation;

@end

@implementation VOITriangulator

- (instancetype)initWithPointList:(VOIPointList *)pointList {
    self = [super init];
    if (self) {
        _pointList = pointList;
    }
    return self;
}

- (VOITriangleList *)triangulate {
    return _triangulation ? _triangulation : [self generateTriangulation];
}

- (VOITriangleList *)generateTriangulation {
    
    NSMutableIndexSet *indices = [NSMutableIndexSet indexSet];
    VOITriangle *firstTriangle = [self seedTriangleIndices:indices];
    VOIPointList *remaining = [_pointList deleteIndices:indices];
    remaining = [remaining sortedByDistanceFrom:firstTriangle.centre];
    
    NSMutableArray<VOITriangle *> *triangles = [NSMutableArray arrayWithObject:firstTriangle];
    [self addTriangles:triangles fromPoints:remaining];

    _triangulation = [[VOITriangleList alloc] initWithTriangles:triangles];
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

// Points should already be sorted by distance from
- (void)addTriangles:(NSMutableArray<VOITriangle *> *)triangles fromPoints:(VOIPointList *)points {
    
    __block VOIPath *hull = [triangles[0] asPath];
    [points iteratePoints:^BOOL(const VOIPoint *p, const NSUInteger i) {
        VOITriangleList *tList;
        hull = [hull convexHullByAddingPoint:*p triangles:&tList];
        NSArray<VOITriangle *> *newTriangles = [tList allTriangles];
        NSLog(@"Adding triangles: %@", newTriangles);
        [triangles addObjectsFromArray:newTriangles];
        return NO;
    }];
    NSLog(@"Hull: %@", hull);
}

@end
