//
//  VOITriangleList.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIPointList.h"

#import <simd/simd.h>

@class VOITriangle;

typedef BOOL (^VOITriangleIterator)(VOITriangle *t, NSUInteger i);

@interface VOITriangleList : VOIPointList

- (instancetype)initWithTriangles:(NSArray<VOITriangle *> *)triangles;
- (BOOL)isEqualToTriangleList:(VOITriangleList *)other;

- (VOITriangle *)triangleAt:(NSUInteger)index;
- (void)iterateTriangles:(VOITriangleIterator)iterator;
- (NSArray<VOITriangle *> *)allTriangles;

@end

@interface VOIPointList (VOITriangleList)
- (VOITriangleList *)asTriangleList;
@end
