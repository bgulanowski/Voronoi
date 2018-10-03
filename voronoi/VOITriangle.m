//
//  VOITriangle.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOITriangle.h"

@implementation VOITriangle {
    vector_double2 _points[3];
}

- (vector_double2)p0 {
    return _points[0];
}

- (vector_double2)p1 {
    return _points[1];
}

- (vector_double2)p2 {
    return _points[2];
}

- (instancetype)initWithPoints:(vector_double2 *)points {
    self = [super init];
    if (self) {
        _points[0] = points[0];
        _points[1] = points[1];
        _points[2] = points[2];
    }
    return self;
}

- (vector_double2)pointAt:(NSUInteger)index {
    return _points[index%3];
}

@end
