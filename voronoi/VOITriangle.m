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

#import "NSValue+VOIPoint.h"

static inline void CopyPoints(const VOIPoint src[3], VOIPoint dst[3]) {
    dst[0] = src[0];
    dst[1] = src[1];
    dst[2] = src[2];
}

static inline void OrderPoints(const VOIPoint *points, NSUInteger *indices) {
    NSComparisonResult ordering = VOIComparePoints(points[indices[0]], points[indices[1]]);
    if (ordering == NSOrderedDescending) {
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
    NSUInteger _hash;
}

@synthesize centre=_centre;
@synthesize centroid=_centroid;
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

- (double)minX {
    return MIN(_points[0].x, MIN(_points[1].x, _points[2].x));
}

- (double)maxX {
    return MAX(_points[0].x, MAX(_points[1].x, _points[2].x));
}

- (double)minY {
    return MIN(_points[0].y, MIN(_points[1].y, _points[2].y));
}

- (double)maxY {
    return MAX(_points[0].y, MAX(_points[1].y, _points[2].y));
}

- (VOIPoint)centre {
    return (!self.degenerate && isnan(_centre.x)) ? [self calculateCentre] : _centre;
}

- (VOIPoint)centroid {
    return isnan(_centroid.x) ? [self calculateCentroid] : _centroid;
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

- (id<NSCopying>)hashKey {
#if FAST_HASH
    return @(self.hash);
#else
    return [NSValue valueWithThreePoints:_points];
#endif
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

- (VOISegment *)m0 {
    return [self medianAt:0];
}

- (VOISegment *)m1 {
    return [self medianAt:1];
}

- (VOISegment *)m2 {
    return [self medianAt:2];
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

- (NSUInteger)hash {
    return _hash ?: [self calculateHash];
}

- (BOOL)isEqual:(id)object {
    return (
            [object isKindOfClass:[self class]] &&
            [self isEqualToTriangle:object]
            );
}

- (BOOL)isEquivalent:(id)object {
    return [object isKindOfClass:[VOITriangle class]] && [self isEquivalentToTriangle:object];
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
        _centroid = _centre = vector2((double)NAN, (double)NAN);
        _radius = (double)NAN;
    }
    return self;
}

- (instancetype)initWithPoints:(const VOIPoint *)points {
    return [self initWithPoints:points standardize:NO];
}

- (BOOL)isEqualToTriangle:(VOITriangle *)other {
    return (
            other == self ||
            (other != nil &&
             simd_equal(_points[0], other->_points[0]) &&
             simd_equal(_points[1], other->_points[1]) &&
             simd_equal(_points[2], other->_points[2])
             )
            );
}

- (BOOL)isEquivalentToTriangle:(VOITriangle *)other {
    return other == self || [[self standardize] isEqualToTriangle:[other standardize]];
}

- (NSComparisonResult)compare:(VOITriangle *)other {
    NSComparisonResult cr = VOIComparePoints(self.centroid, other.centroid);
    return cr ?: VOICompareDoubles(self.radius, other.radius);
}

- (VOIPoint)pointAt:(NSUInteger)index {
    return _points[index%3];
}

- (double)angleAt:(NSUInteger)index {
    // law of cosines
    double a = [self lengthOfSegmentAt:index + 1];
    double b = [self lengthOfSegmentAt:index + 2];
    double cc = [self squareLengthOfSegmentAt:index];
    double cosc = (a * a + b * b - cc) / (2 * a * b);
    return acos(cosc);
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

- (double)lengthOfSegmentAt:(NSUInteger)index {
    VOIPoint a = [self pointAt:index + 1];
    VOIPoint b = [self pointAt:index + 2];
    return simd_length(b - a);
}

- (double)squareLengthOfSegmentAt:(NSUInteger)index {
    VOIPoint a = [self pointAt:index + 1];
    VOIPoint b = [self pointAt:index + 2];
    return simd_length_squared(b - a);
}

- (VOISegment *)segmentInCommonWith:(VOITriangle *)other indices:(NSUInteger[2])indices {
    if (other == nil || [other isEquivalentToTriangle:self]) {
        return nil;
    }
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

- (VOISegment *)medianAt:(NSUInteger)index {
    return [[VOISegment alloc] initWithPoint:_points[index] otherPoint:[self segmentAt:index].midpoint];
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

- (NSString *)tabDelimitedString {
    return [NSString stringWithFormat:@"%.2f\t%.2f\n%.2f\t%.2f\n%.2f\t%.2f",
            _points[0].x, _points[0].y,
            _points[1].x, _points[1].y,
            _points[2].x, _points[2].y
            ];
}

#pragma mark - Private

- (VOIPoint)calculateCentre {
    return (_centre = VOICentrePoint(_points));
}

- (VOIPoint)calculateCentroid {
    if (self.degenerate) {
        return (_centroid = vector2((self.minX + self.maxX) * 0.5, (self.minY + self.maxY) * 0.5));
    }
    else {
        return (_centroid = [self.m0 intersectWithSegment:self.m1]);
    }
}

- (double)calculateRadius {
    return (_radius = simd_distance(_points[0], self.centre));
}

- (NSUInteger)calculateHash {
    static NSMutableData *data;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        data = [NSMutableData dataWithLength:sizeof(VOIPoint) * 3];
    });
    memcpy(data.mutableBytes, _points, sizeof(VOIPoint) * 3);
    return data.hash;
//    return (_hash = VOIPointHash(_points, 3));
}

@end
