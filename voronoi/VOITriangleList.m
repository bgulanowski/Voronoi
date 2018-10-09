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

#pragma mark - Properties

- (NSUInteger)count {
    return [super count] / PPT;
}

#pragma mark - VOITriangleList

- (instancetype)initWithPoints:(const VOIPoint *)points count:(NSUInteger)count {
    return [super initWithPoints:points count:count * PPT];
}

- (instancetype)initWithTriangles:(NSArray<VOITriangle *> *)triangles {
    NSMutableData *data = [NSMutableData dataWithLength:(triangles.count * 3 *sizeof(VOIPoint))];
    VOIPoint *cursor = data.mutableBytes;
    for (VOITriangle *triangle in triangles) {
        *cursor = triangle.p0;
        ++cursor;
        *cursor = triangle.p1;
        ++cursor;
        *cursor = triangle.p2;
        ++cursor;
    }
    return [self _initWithData:data];
}

- (BOOL)isEqualToTriangleList:(VOITriangleList *)other {
    return [super isEqualToPointList:other];
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
