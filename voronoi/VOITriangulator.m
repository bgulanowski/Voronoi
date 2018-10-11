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
    
    NSIndexSet *indexSet = [self indicesForSeedTrianglePoints];
    VOITriangle *firstTriangle = [_pointList triangleForIndexSet:indexSet];
    VOIPointList *remaining = [_pointList pointListByDeletingPointsAtIndices:indexSet];
    NSArray<VOITriangle *> *triangles = [NSMutableArray arrayWithObject:firstTriangle];
    
    [self addTriangles:triangles fromPoints:remaining];

    _triangulation = [[VOITriangleList alloc] initWithTriangles:triangles];
    return _triangulation;
}

- (NSIndexSet *)indicesForSeedTrianglePoints {
    
    NSMutableIndexSet *indices = [NSMutableIndexSet indexSet];
    VOIPoint points[3];
    NSUInteger index = NSNotFound;
    
    points[0] = [_pointList pointClosestToPoint:_pointList.centre index:&index ignoreIfEqual:NO];
    [indices addIndex:index];
    points[1] = [_pointList pointClosestToPoint:points[0] index:&index];
    [indices addIndex:index];
    
    VOIPoint *pPoints = points;
    __block double delta = (double)INFINITY;
    [_pointList iteratePoints:^(const VOIPoint *p, const NSUInteger i) {
        if (![indices containsIndex:i]) {
            pPoints[2] = *p;
            VOIPoint c = VOICentrePoint(pPoints);
            double d = simd_distance_squared(*p, c);
            if (d < delta) {
                delta = d;
                [indices addIndex:i];
            }
        }
        return NO;
    }];
    
    return indices;
}

- (void)addTriangles:(NSArray<VOITriangle *> *)triangles fromPoints:(VOIPointList *)points {
    
    VOIPath *hull = [triangles[0] asPath];
    
    [points iteratePoints:^BOOL(const VOIPoint *p, const NSUInteger i) {
        
        return NO;
    }];
}

@end
