//
//  VOITriangle.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOITriangle.h"

@implementation VOITriangle {
    VOIPoint _points[3];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: <(%.2f, %.2f) - (%.2f, %.2f) - (%.2f, %.2f)>",
            [self className],
            _points[0].x, _points[0].y,
            _points[1].x, _points[1].y,
            _points[2].x, _points[2].y
            ];
}

- (VOIPoint)p0 {
    return _points[0];
}

- (VOIPoint)p1 {
    return _points[1];
}

- (VOIPoint)p2 {
    return _points[2];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[self class]];
}

- (instancetype)initWithPoints:(const VOIPoint *)points {
    self = [super init];
    if (self) {
        _points[0] = points[0];
        _points[1] = points[1];
        _points[2] = points[2];
    }
    return self;
}

- (BOOL)isEqualToTriangle:(VOITriangle *)other {
    return (
            simd_equal(_points[0], other->_points[0]) &&
            simd_equal(_points[1], other->_points[1]) &&
            simd_equal(_points[2], other->_points[2])
            );
}

- (VOIPoint)pointAt:(NSUInteger)index {
    return _points[index%3];
}

@end
