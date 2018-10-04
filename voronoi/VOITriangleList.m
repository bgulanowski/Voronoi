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

const NSUInteger PPT = 3;

@implementation VOITriangleList

- (NSUInteger)count {
    return [super count] / PPT;
}

- (instancetype)initWithPoints:(const VOIPoint *)points count:(NSUInteger)count {
    return [super initWithPoints:points count:count * PPT];
}

- (VOITriangle *)triangleAt:(NSUInteger)index {
    const NSUInteger count = self.pointCount;
    VOIPoint points[3];
    points[0] = [self pointAtIndex:(index * PPT) % count];
    points[1] = [self pointAtIndex:(index * PPT + 1) % count];
    points[2] = [self pointAtIndex:(index * PPT + 2) % count];
    return [[VOITriangle alloc] initWithPoints:points];
}

- (void)iterateTriangles:(VOITriangleIterator)iterator {
    [self iteratePoints:^BOOL(const VOIPoint *points, const NSUInteger i) {
        if (i % PPT == 0) {
            VOITriangle *t = [[VOITriangle alloc] initWithPoints:points];
            return iterator(t, i / PPT);
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
