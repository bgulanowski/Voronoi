//
//  VOISegment.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOISegment.h"

#import "VOIBox.h"

@implementation VOISegment

- (VOIPoint)midpoint {
    return simd_mix(_a, _b, vector2(0.5, 0.5));
}

- (VOIBox *)boundingBox {
    return [[VOIBox alloc] initWithOrigin:_a size:(_b - _a)];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: [%@ -> %@]", [self className], VOIPointToString(_a), VOIPointToString(_b)];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[self class]] && [self isEqualToSegment:object];
}

- (BOOL)isEquivalent:(id)object {
    return [object isKindOfClass:[VOISegment class]] && [self isEquivalentToSegment:object];
}

- (instancetype)init {
    return [self initWithPoint:vector2(0.0, 0.0) otherPoint:vector2(0.0, 0.0)];
}

- (instancetype)initWithPoint:(VOIPoint)point otherPoint:(VOIPoint)other {
    self = [super init];
    if (self) {
        _a = point;
        _b = other;
    }
    return self;
}

- (instancetype)initWithPoints:(const VOIPoint *)points {
    return [self initWithPoint:points[0] otherPoint:points[1]];
}

- (BOOL)isEqualToSegment:(VOISegment *)other {
    return other == self || (simd_equal(_a, other->_a) && simd_equal(_b, other->_b));
}

- (BOOL)isEquivalentToSegment:(VOISegment *)other {
    return (
            other == self ||
            (other != nil &&
             ((simd_equal(_a, other->_a) && simd_equal(_b, other->_b)) ||
              (simd_equal(_a, other->_b) && simd_equal(_b, other->_a)))
             )
            );
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

- (double)distanceFromPoint:(VOIPoint)point {
    return simd_distance(point, self.midpoint);
}

- (double)distanceSquaredFromPoint:(VOIPoint)point {
    return simd_distance_squared(point, self.midpoint);
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

- (VOIVerticalPosition)verticalPosition:(double)y {
    if (_a.y > y) {
        return (_b.y <= y) ? VOIDownward : VOIAbove;
    }
    else if (_a.y < y) {
        return (_b.y >= y) ? VOIUpward : VOIBelow;
    }
    else {
        return (_b.y > y) ? VOIUpward : ((_b.y < y) ? VOIDownward : VOIHorizontalUpon);
    }
}

- (VOIHorizontalPosition)horizontalPosition:(double)x {
    if (_a.x > x) {
        return (_b.x <= x) ? VOILeftward : VOIRight;
    }
    else if (_a.x < x) {
        return (_b.x >= x) ? VOIRightward : VOILeft;
    }
    else {
        return (_b.x > x) ? VOILeftward : ((_b.x < x) ? VOIRightward : VOIVerticalUpon);
    }
}

@end
