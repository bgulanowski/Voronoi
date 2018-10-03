//
//  VOITriangleList.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOITriangleList.h"

#import "VOITriangle.h"

@implementation VOITriangleList

- (NSUInteger)count {
    return [super count] / 3;
}

- (instancetype)initWithPoints:(vector_double2 *)points count:(NSUInteger)count {
    return [super initWithPoints:points count:count * 3];
}

- (VOITriangle *)triangleAt:(NSUInteger)index {
    vector_double2 points[3];
    points[0] = [self pointAtIndex:index * 3];
    points[1] = [self pointAtIndex:index * 3 + 1];
    points[2] = [self pointAtIndex:index * 3 + 2];
    return [[VOITriangle alloc] initWithPoints:points];
}

@end
