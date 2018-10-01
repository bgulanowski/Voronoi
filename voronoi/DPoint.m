//
//  DPoint.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "DPoint.h"

@implementation DPoint

- (double)x {
    return _p.x;
}

- (double)y {
    return _p.y;
}

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"{%.2f, %.2f}", _p.x, _p.y];
}

- (BOOL)isEqual:(id)object {
    if(![object isKindOfClass:[self class]])
        return NO;
    DPoint *other = object;
    return fabs(other->_p.x - _p.x) < DBL_EPSILON && fabs(other->_p.y - _p.y) < DBL_EPSILON;
}


#pragma mark - NSCoding
- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithX:_p.x y:_p.y];
}


#pragma mark - DPoint
- (id)initWithX:(double)x y:(double)y {
    self = [self init];
    if(self) {
        _p = vector2(x, y);
    }
    return self;
}

- (id)initWithCGPoint:(CGPoint)point {
    return [self initWithX:point.x y:point.y];
}

- (DPoint *)add:(DPoint *)other {
    vector_double2 p = _p + other->_p;
    return [DPoint pointWithX:p.x y:p.y];
}

- (DPoint *)subtract:(DPoint *)other {
    vector_double2 p = _p - other->_p;
    return [DPoint pointWithX:p.x y:p.y];
}

- (double)distanceTo:(DPoint *)other {
    return simd_distance(other->_p, _p);
}

- (double)distanceSquaredTo:(DPoint *)other {
    return simd_distance_squared(other->_p, _p);
}

- (double)distanceFromOrigin {
    return simd_length(_p);
}

-(CGPoint)CGPoint {
    return CGPointMake(_p.x, _p.y);
}

+ (DPoint *)pointWithX:(double)x y:(double)y {
    return [[self alloc] initWithX:x y:y];
}

+ (DPoint *)pointWithCGPoint:(CGPoint)point {
    return [[self alloc] initWithX:point.x y:point.y];
}

@end
