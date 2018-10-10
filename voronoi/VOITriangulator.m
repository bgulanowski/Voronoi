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
    
    NSUInteger indices[3];
    [self selectSeedPointsReturningIndices:indices];
    VOITriangle *first = [_pointList triangleForIndices:indices];

    _triangulation = [[VOITriangleList alloc] initWithTriangles:@[first]];
    return _triangulation;
}

- (void)selectSeedPointsReturningIndices:(NSUInteger[3])indices {
    
    VOIPoint points[3];
    points[0] = [_pointList pointClosestToPoint:_pointList.centre index:&indices[0] ignoreIfEqual:NO];
    points[1] = [_pointList pointClosestToPoint:points[0] index:&indices[1]];
    
    VOIPoint *pPoints = points;
    __block double delta = (double)INFINITY;
    [_pointList iteratePoints:^(const VOIPoint *p, const NSUInteger i) {
        if (i != indices[0] && i != indices[1]) {
            pPoints[2] = *p;
            VOIPoint c = VOICentrePoint(pPoints);
            double d = simd_distance_squared(*p, c);
            if (d < delta) {
                delta = d;
                indices[2] = i;
            }
        }
        return NO;
    }];
}

@end
