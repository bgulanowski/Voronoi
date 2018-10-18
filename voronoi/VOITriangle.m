//
//  VOITriangle.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOITriangle.h"

#import "VOIBox.h"
#import "VOISegment.h"
#import "VOISegmentList.h"

static inline void OrderPoints(const VOIPoint *points, NSUInteger *indices) {
    if (points[indices[0]].x > points[indices[1]].x) {
        NSUInteger t = indices[1];
        indices[1] = indices[0];
        indices[0] = t;
    }
}

@implementation VOITriangle {
    VOIPoint _points[3];
    VOIPoint _centre;
    double _radius;
    vector_double3 _normal;
}

#pragma mark - Properties

- (VOIPoint)p0 {
    return _points[0];
}

- (VOIPoint)p1 {
    return _points[1];
}

- (VOIPoint)p2 {
    return _points[2];
}

- (VOIPoint)centre {
    return (!self.degenerate && isnan(_centre.x)) ? [self calculateCentre] : _centre;
}

- (double)radius {
    return (isnan(_radius) ? [self calculateRadius] : _radius);
}

- (BOOL)isDegenerate {
    return ABS(_normal.z) < DBL_EPSILON || isnan(_normal.z);
}

- (BOOL)isRightHanded {
    return _normal.z > DBL_EPSILON;
}

- (BOOL)isLeftHanded {
    return _normal.z < -DBL_EPSILON;
}

- (BOOL)isOrdered {
    return _points[0].x < _points[1].x && _points[0].x < _points[2].x;
}

- (BOOL)isStandard {
    return [self isOrdered] && ![self isLeftHanded];
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: <(%.2f, %.2f) - (%.2f, %.2f) - (%.2f, %.2f)>",
            [self className],
            _points[0].x, _points[0].y,
            _points[1].x, _points[1].y,
            _points[2].x, _points[2].y
            ];
}

- (BOOL)isEqual:(id)object {
    return (
            [object isKindOfClass:[self class]] &&
            [self isEqualToTriangle:object]
            );
}

- (instancetype)initWithPoints:(const VOIPoint *)points {
    self = [super init];
    if (self) {
        _points[0] = points[0];
        _points[1] = points[1];
        _points[2] = points[2];
        _normal = simd_normalize(simd_cross((_points[1] - _points[0]), (_points[2] - _points[0])));
        _centre = vector2((double)NAN, (double)NAN);
        _radius = (double)NAN;
    }
    return self;
}

- (BOOL)isEqualToTriangle:(VOITriangle *)other {
    return (other != nil &&
            simd_equal(_points[0], other->_points[0]) &&
            simd_equal(_points[1], other->_points[1]) &&
            simd_equal(_points[2], other->_points[2])
            );
}

- (BOOL)isEquivalentToTriangle:(VOITriangle *)other {
    VOITriangle *a = [self isStandard] ? self : [self standardize];
    VOITriangle *b = [other isStandard] ? other : [other standardize];
    return [a isEqualToTriangle:b];
}

- (VOIPoint)pointAt:(NSUInteger)index {
    return _points[index%3];
}

- (VOITriangle *)reorder {
    VOIPoint reordered[3] = {
        _points[0],
        _points[2],
        _points[1]
    };
    return [[VOITriangle alloc] initWithPoints:reordered];
}

- (VOITriangle *)standardize {
    NSUInteger indices[3] = { 0, 1, 2 };
    OrderPoints(_points, &indices[1]);
    OrderPoints(_points, &indices[0]);
    OrderPoints(_points, &indices[1]);

    VOIPoint points[3] = {
        _points[indices[0]],
        _points[indices[1]],
        _points[indices[2]]
    };
    
    VOITriangle *t = [[VOITriangle alloc] initWithPoints:points];
    return t.rightHanded ? [t reorder] : t;
}

#pragma mark - Private

- (VOIPoint)calculateCentre {
    return (_centre = VOICentrePoint(_points));
}

- (double)calculateRadius {
    return (_radius = simd_distance(_points[0], self.centre));
}

@end
