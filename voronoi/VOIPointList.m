//
//  VOIPointList.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIPointList.h"

static VOIPointComparator length = ^(const VOIPoint *p0, const VOIPoint *p1) {
    double l0 = simd_length(*p0);
    double l1 = simd_length(*p1);
    if (l0 < l1) {
        return -1;
    }
    else if (l1 < l0) {
        return 1;
    }
    else {
        return 0;
    }
};

static VOIPointComparator distanceFrom(const VOIPoint p) {
    return ^(const VOIPoint *p0, const VOIPoint *p1) {
        double d0 = simd_distance_squared(*p0, p);
        double d1 = simd_distance_squared(*p1, p);
        if (d0 < d1) {
            return -1;
        }
        else if (d1 < d0) {
            return 1;
        }
        else {
            return 0;
        }
    };
}

@interface VOIPointList ()

- (instancetype)_initWithData:(NSMutableData *)data NS_DESIGNATED_INITIALIZER;

@property (nonatomic) VOIPoint *points;
@property (nonatomic) NSMutableData *pointsData;

@end

@implementation VOIPointList

- (NSUInteger)pointCount {
    return _count;
}

- (NSString *)description {
    // up to the first eight points and the count
    NSMutableArray *pointStrings = [NSMutableArray array];
    NSUInteger max = _count > 8 ? 8 : _count;
    for (NSUInteger i = 0; i < max; ++i) {
        VOIPoint p = _points[i];
        [pointStrings addObject:[NSString stringWithFormat:@"(%.2f, %.2f)", p.x, p.y]];
    }
    NSString *pointsString = [pointStrings componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"VOIPointList: points: [%@, ...] count: %td", pointsString, self.count];
}

- (BOOL)isEqual:(id)object {
    return (
            [object isKindOfClass:[VOIPointList class]] &&
            [self isEqualToPointList:object]
            );
}

- (instancetype)_initWithData:(NSMutableData *)data {
    self = [super init];
    if (self) {
        _pointsData = data;
        _points = _pointsData.mutableBytes;
        _count = _pointsData.length / sizeof(VOIPoint);
    }
    return self;
}

- (instancetype)initWithPoints:(const VOIPoint *)points count:(NSUInteger)count {
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:points length:(count * sizeof(VOIPoint))];
    return [self _initWithData:data];
}

- (BOOL)isEqualToPointList:(VOIPointList *)other {
    return (
            other != nil &&
            [_pointsData isEqualToData:other->_pointsData] &&
            _count == other->_count
            );
}

- (VOIPoint)pointAtIndex:(NSUInteger)index {
    NSParameterAssert(index < _count);
    return _points[index];
}

- (VOIPointList *)sortedPointList:(VOIPointComparator)comparator {
    VOIPointList *copy = [[VOIPointList alloc] initWithPoints:_points count:_count];
    qsort_b(copy->_points, _count, sizeof(VOIPoint), [comparator copy]);
    return copy;
}

- (VOIPointList *)sortedByLength {
    return [self sortedPointList:[length copy]];
}

- (VOIPointList *)sortedByDistanceFrom:(VOIPoint)p {
    return [self sortedPointList:distanceFrom(p)];
}

- (void)iteratePoints:(VOIPointIterator)iterator {
    for (NSUInteger i = 0; i < _count; ++i) {
        if (iterator(&_points[i], i)) {
            break;
        }
    }
}

@end
