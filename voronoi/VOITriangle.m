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

typedef enum {
    DegenerateUnknown,
    DegenerateYes,
    DegenerateNo
} Degeneracy;

typedef enum {
    HandednessUnknown,
    HandednessLeft,
    HandednessRight
} Handedness;

@implementation VOITriangle {
    VOIPoint _points[3];
    VOIPoint _centre;
    double _radius;
    Degeneracy _degeneracy;
    Handedness _handedness;
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

- (VOIPoint)centre {
    return (!self.degenerate && isnan(_centre.x)) ? [self calculateCentre] : _centre;
}

- (double)radius {
    return (isnan(_radius) ? [self calculateRadius] : _radius);
}

- (BOOL)isDegenerate {
    return (_degeneracy == DegenerateUnknown) ? [self calculateDegeneracy] : (_degeneracy == DegenerateYes);
}

- (BOOL)isRightHanded {
    return (_handedness == HandednessUnknown) ? [self calculateHandedness] : (_handedness == HandednessRight);
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

#pragma mark - Private

- (BOOL)calculateDegeneracy {
    BOOL degenerate = [[VOIPointList alloc] initWithPoints:_points count:3].boundingBox.degenerate;
    _degeneracy = degenerate ? DegenerateYes : DegenerateNo;
    return degenerate;
}

- (BOOL)calculateHandedness {
    vector_double3 cross = simd_cross((_points[1] - _points[0]), (_points[2] - _points[0]));
    BOOL rightHanded = cross.z > 0;
    _handedness = rightHanded ? HandednessRight : HandednessLeft;
    return rightHanded;
}

- (VOIPoint)calculateCentre {
    return (_centre = VOICentrePoint(_points));
}

- (double)calculateRadius {
    return (_radius = simd_distance(_points[0], self.centre));
}

@end

VOIPoint VOICentrePoint(VOIPoint points[3]) {
    VOISegment *p0 = [[VOISegment alloc] initWithPoints:&points[0]].perpendicular;
    VOISegment *p1 = [[VOISegment alloc] initWithPoints:&points[1]].perpendicular;
    return [p0 intersectWithSegment:p1];
}
