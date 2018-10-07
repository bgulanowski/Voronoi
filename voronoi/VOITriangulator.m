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
    
    if (_triangulation) {
        return _triangulation;
    }
    
    VOIPointList *remaining;
    VOITriangle *first = [self selectInitialTriangleRemainingPoints:&remaining];
    
    return [[VOITriangleList alloc] initWithTriangles:@[first]];
}

- (VOITriangle *)selectInitialTriangleRemainingPoints:(VOIPointList **)pRemaining {
    
    NSUInteger i;
    VOIPoint points[3];
    VOIPoint *pPoints = points;
    
    points[0] = [_pointList pointClosestToPoint:_pointList.centre index:&i];
    VOIPointList *remaining = [_pointList pointListByDeletingPointAtIndex:i];
    points[1] = [remaining pointClosestToPoint:points[0] index:&i];
    remaining = [remaining pointListByDeletingPointAtIndex:i];
    points[2] = points[1];
    
    __block NSUInteger index = NSNotFound;
    __block VOITriangle *triangle = [[VOITriangle alloc] initWithPoints:points];
    [remaining iteratePoints:^(const VOIPoint *p, const NSUInteger i) {
        pPoints[2] = *p;
        VOITriangle *t = [[VOITriangle alloc] initWithPoints:pPoints];
        if ([t radius] < [triangle radius]) {
            index = i;
            triangle = t;
        }
        return NO;
    }];
    
    if (pRemaining) {
        *pRemaining = [remaining pointListByDeletingPointAtIndex:index];
    }
    
    return triangle.rightHanded ? triangle : [triangle reorder];
}

@end
