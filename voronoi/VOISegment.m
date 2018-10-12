//
//  VOISegment.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOISegment.h"

@implementation VOISegment

- (VOIPoint)midpoint {
    return simd_mix(_a, _b, vector2(0.5, 0.5));
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@; [(%.2f, %.2f) -> (%.2f, %.2f)]", [self className], _a.x, _a.y, _b.x, _b.y];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[self class]] && [self isEqualToSegment:object];
}

- (instancetype)initWithPoints:(const VOIPoint *)points {
    self = [super init];
    if (self) {
        _a = points[0];
        _b = points[1];
    }
    return self;
}

- (BOOL)isEqualToSegment:(VOISegment *)other {
    return simd_equal(_a, other->_a) && simd_equal(_b, other->_b);
}

- (VOISegment *)perpendicular {
    VOIPoint v = _b - _a;
    // rotate v 90° CW
    VOIPoint vr = vector2(v.y, -v.x);
    VOIPoint c = (_a + _b) / 2.0;
    VOIPoint d = c + vr;
    VOIPoint cd[] = { c, d };
    return [[VOISegment alloc] initWithPoints:cd];
}

- (VOIPoint)intersectWithSegment:(VOISegment *)other {
    
    VOIPoint a = _a - other->_a;
    VOIPoint b = other->_a - other->_b;
    VOIPoint c = _a - _b;
    
    matrix_double2x2 A = simd_matrix(a, b);
    matrix_double2x2 B = simd_matrix(c, b);
    
    double detA = simd_determinant(A);
    double detB = simd_determinant(B);
    
    if (ABS(detB) <= DBL_EPSILON) {
        return vector2((double)INFINITY, (double)INFINITY);
    }
    
    return _a + detA/detB * (_b - _a);
}

- (VOILineSide)sideForPoint:(VOIPoint)point {
    double s = (_b.x - _a.x) * (point.y - _a.y) - (point.x -  _a.x) * (_b.y - _a.y);
    if (s < 0) {
        return VOILineSideRight;
    }
    else if (s > 0) {
        return VOILineSideLeft;
    }
    else {
        return VOILineSideOn;
    }
}

@end
