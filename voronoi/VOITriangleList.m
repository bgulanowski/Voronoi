//
//  VOITriangleList.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOITriangleList.h"

#import "VOIPointListPrivate.h"
#import "VOITriangle.h"


@implementation VOITriangleList

- (NSUInteger)count {
    return [super count] / 3;
}

- (instancetype)initWithPoints:(const VOIPoint *)points count:(NSUInteger)count {
    return [super initWithPoints:points count:count * 3];
}

- (VOITriangle *)triangleAt:(NSUInteger)index {
    VOIPoint points[3];
    points[0] = [self pointAtIndex:index * 3];
    points[1] = [self pointAtIndex:index * 3 + 1];
    points[2] = [self pointAtIndex:index * 3 + 2];
    return [[VOITriangle alloc] initWithPoints:points];
}

- (void)iterateTriangles:(VOITriangleIterator)iterator {
    [self iteratePoints:^BOOL(const VOIPoint *points, const NSUInteger i) {
        if (i % 3 == 0) {
            VOITriangle *t = [[VOITriangle alloc] initWithPoints:points];
            return iterator(t, i / 3);
        }
        return NO;
    }];
}

- (NSArray<VOITriangle *> *)allTriangles {
    NSMutableArray<VOITriangle *> *triangles = [NSMutableArray array];
    [self iterateTriangles:^BOOL(VOITriangle *t, NSUInteger i) {
        [triangles addObject:t];
        return NO;
    }];
    return triangles;
}

@end

@implementation VOIPointList (VOITriangleList)

- (VOITriangleList *)asTriangleList {
    return [[VOITriangleList alloc] _initWithData:self.pointsData];
}

@end
