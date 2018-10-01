//
//  DRange.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "DRange.h"
#import "DPoint.h"
#import "DSegment.h"


@implementation DRange {
    vector_double2 _p0;
    vector_double2 _p1;
}

- (DPoint *)p0 {
    return [DPoint pointWithX:_p0.x y:_p0.y];
}

- (DPoint *)p1 {
    return [DPoint pointWithX:_p1.x y:_p1.y];
}

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"[(%.1f, %.1f) - (%.1f, %.1f)]", _p0.x, _p0.y, _p1.x, _p1.y];
}

- (instancetype)init {
    return [self init:0 :1];
}

- (BOOL)isEqual:(id)object {
    if(![object isKindOfClass:[self class]])
        return NO;
    
    DRange *other = (DRange *)object;
    return (fabs(other->_p0.x - _p0.x) < DBL_EPSILON &&
            fabs(other->_p0.y - _p0.y) < DBL_EPSILON &&
            fabs(other->_p1.x - _p1.x) < DBL_EPSILON &&
            fabs(other->_p1.y - _p1.y) < DBL_EPSILON);
}


#pragma mark - DRange
- (instancetype)init:(vector_double2)p0 :(vector_double2)p1 {
    self = [super init];
    if(self) {
        
        _p0 = p0;
        _p1 = p1;
        
        if(_p0.x < _p1.x) {
            _xMin = _p0.x; _xMax = _p1.x;
        }
        else {
            _xMin = _p1.x;
            _xMax = _p0.x;
        }
        if(_p0.y < _p1.y) {
            _yMin = _p0.y;
            _yMax = _p1.y;
        }
        else {
            _yMin = _p1.y;
            _yMax = _p0.y;
        }
    }
    return self;
}

- (id)initWithPoint:(DPoint *)p0 point:(DPoint *)p1 {
    return [self init:vector2(p0.x, p0.y) :vector2(p1.x, p1.y)];
}

- (double)lengthSquared {
    return simd_distance_squared(_p1, _p0);
}

- (double)length {
    return simd_distance(_p1, _p0);
}

- (double)width {
    return fabs(_xMax - _xMin);
}

- (double)height {
    return fabs(_yMax - _yMin);
}

- (DPoint *)min {
    return [DPoint pointWithX:_xMin y:_yMin];
}

- (DPoint *)max {
    return [DPoint pointWithX:_xMax y:_yMax];
}

- (NSArray *)boundarySegments {
    
    DPoint *a = [DPoint pointWithX:_xMin y:_yMax];
    DPoint *b = self.max;
    DPoint *c = [DPoint pointWithX:_xMax y:_yMin];
    DPoint *d = self.min;
    return @[
             [DSegment segmentWithPoint:a point:b],
             [DSegment segmentWithPoint:b point:c],
             [DSegment segmentWithPoint:c point:d],
             [DSegment segmentWithPoint:d point:a]
             ];
}

- (BOOL)containsPoint:(DPoint *)point {
    // This rounds the point coordinates slightly
    // Many things fail if we don't do this
    double x = (float)point.x, y = (float)point.y;
    return x >= _xMin && x <= _xMax && y >= _yMin && y <= _yMax;
}

+(DRange *)rangeWithPoint:(DPoint *)p0 point:(DPoint *)p1 {
    return [[[self class] alloc] initWithPoint:p0 point:p1];
}

@end
