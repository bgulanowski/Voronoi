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

static inline void CopyPoints(const VOIPoint src[3], VOIPoint dst[3]) {
    dst[0] = src[0];
    dst[1] = src[1];
    dst[2] = src[2];
}

static inline void OrderPoints(const VOIPoint *points, NSUInteger *indices) {
    if (points[indices[0]].x > points[indices[1]].x) {
        NSUInteger t = indices[1];
        indices[1] = indices[0];
        indices[0] = t;
    }
}

// Return true/YES if already standard
static inline BOOL StandardizePoints(const VOIPoint src[3], VOIPoint dst[3]) {
    
    NSUInteger indices[3] = { 0, 1, 2 };
    OrderPoints(src, &indices[1]);
    OrderPoints(src, &indices[0]);
    OrderPoints(src, &indices[1]);
    
    if (simd_cross((src[indices[1]] - src[indices[0]]), (src[indices[2]] - src[indices[0]])).z > DBL_EPSILON) {
        NSUInteger t = indices[1];
        indices[1] = indices[2];
        indices[2] = t;
    }
    
    dst[0] = src[indices[0]];
    dst[1] = src[indices[1]];
    dst[2] = src[indices[2]];
    
    return (indices[0] == 0 && indices[1] == 1);
}

static inline vector_double3 CalculateNormal(VOIPoint points[3]) {
    return simd_normalize(simd_cross((points[1] - points[0]), (points[2] - points[0])));
}

@implementation VOITriangle {
    VOIPoint _points[3];
    vector_double3 _normal;
}

@synthesize centre=_centre;
@synthesize radius=_radius;
@synthesize ordered=_ordered;
@synthesize standard=_standard;

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

- (VOISegment *)s0 {
    return [self segmentAt:0];
}

- (VOISegment *)s1 {
    return [self segmentAt:1];
}

- (VOISegment *)s2 {
    return [self segmentAt:2];
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: <%@:%@:%@>",
            [self className],
            VOIPointToString(_points[0]),
            VOIPointToString(_points[1]),
            VOIPointToString(_points[2])
            ];
}

- (BOOL)isEqual:(id)object {
    return (
            [object isKindOfClass:[self class]] &&
            [self isEqualToTriangle:object]
            );
}

#pragma mark - VOITriangle

- (instancetype)initWithPoints:(const VOIPoint *)points standardize:(BOOL)standardize {
    self = [super init];
    if (self) {
        if (standardize) {
            StandardizePoints(points, _points);
        }
        else {
            CopyPoints(points, _points);
        }
        _normal = CalculateNormal(_points);
        _standard = standardize || (self.ordered && self.leftHanded);
        _centre = vector2((double)NAN, (double)NAN);
        _radius = (double)NAN;
    }
    return self;
}

- (instancetype)initWithPoints:(const VOIPoint *)points {
    return [self initWithPoints:points standardize:NO];
}

- (BOOL)isEqualToTriangle:(VOITriangle *)other {
    return (other != nil &&
            simd_equal(_points[0], other->_points[0]) &&
            simd_equal(_points[1], other->_points[1]) &&
            simd_equal(_points[2], other->_points[2])
            );
}

- (BOOL)isEquivalentToTriangle:(VOITriangle *)other {
    return [[self standardize] isEqualToTriangle:[other standardize]];
}

- (VOIPoint)pointAt:(NSUInteger)index {
    return _points[index%3];
}

- (VOISegment *)segmentAt:(NSUInteger)index {
    return [[VOISegment alloc] initWithPoint:_points[(index + 1)%3] otherPoint:_points[(index + 2)%3]];
}

- (NSUInteger)indexForSegment:(VOISegment *)segment {
    NSUInteger index = NSNotFound;
    for (NSUInteger i = 0; i < 3; ++i) {
        if ([[self segmentAt:i] isEquivalentToSegment:segment]) {
            index = i;
            break;
        }
    }
    return index;
}

- (VOISegment *)segmentInCommonWith:(VOITriangle *)other indices:(NSUInteger[2])indices {
    for (NSUInteger i = 0; i < 3; ++i) {
        VOISegment *segment = [self segmentAt:i];
        NSUInteger otherIndex = [other indexForSegment:segment];
        if (otherIndex != NSNotFound) {
            if (indices) {
                indices[0] = i;
                indices[1] = otherIndex;
            }
            return segment;
        }
    }
    return nil;
}

- (VOITriangle *)reverseOrder {
    VOIPoint reordered[3] = {
        _points[0],
        _points[2],
        _points[1]
    };
    return [[VOITriangle alloc] initWithPoints:reordered];
}

- (VOITriangle *)standardize {

    VOIPoint points[3];
    VOITriangle *t;
    
    if (_standard || StandardizePoints(_points, points)) {
        t = self;
    }
    else {
        t = [[VOITriangle alloc] initWithPoints:points];
        NSAssert([t isLeftHanded], @"Error");
    }
    
    t->_standard = YES;
    
    return t;
}

#pragma mark - Private

- (VOIPoint)calculateCentre {
    return (_centre = VOICentrePoint(_points));
}

- (double)calculateRadius {
    return (_radius = simd_distance(_points[0], self.centre));
}

@end
