//
//  DPoint.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "DPoint.h"


@implementation DPoint

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"{%.2f, %.2f}", _x, _y];
}

- (BOOL)isEqual:(id)object {
    if(![object isKindOfClass:[self class]])
        return NO;
    DPoint *other = (DPoint *)object;
    return fabs(other->_x - _x) < DBL_EPSILON && fabs(other->_y - _y) < DBL_EPSILON;
}


#pragma mark - NSCoding
- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithX:_x y:_y];
}


#pragma mark - DPoint
- (id)initWithX:(double)x y:(double)y {
    self = [self init];
    if(self) {
        _x = x;
        _y = y;
    }
    return self;
}

- (id)initWithCGPoint:(CGPoint)point {
    return [self initWithX:point.x y:point.y];
}

- (DPoint *)add:(DPoint *)other {
    return [DPoint pointWithX:_x + other->_x y:_y + other->_y];
}

- (DPoint *)subtract:(DPoint *)other {
    return [DPoint pointWithX:_x - other->_x y:_y - other->_y];
}

- (double)distanceTo:(DPoint *)other {
    double dx = other->_x-_x, dy = other->_y-_y;
    return sqrt(dx*dx + dy*dy);
}

- (double)distanceSquaredTo:(DPoint *)other {
    double dx = other->_x-_x, dy = other->_y-_y;
    return dx*dx + dy*dy;
}

- (double)distanceFromOrigin {
    return sqrt(_x*_x + _y*_y);
}

-(CGPoint)CGPoint {
    return CGPointMake(_x, _y);
}

+ (DPoint *)pointWithX:(double)x y:(double)y {
    return [[self alloc] initWithX:x y:y];
}

+ (DPoint *)pointWithCGPoint:(CGPoint)point {
    return [[self alloc] initWithX:point.x y:point.y];
}

@end
