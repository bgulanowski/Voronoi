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

@property (nonatomic) VOIPoint *points;
@property (nonatomic) NSMutableData *pointsData;

@end

@implementation VOIPointList

- (NSString *)description {
    // up to the first eight points and the count
    NSMutableArray *pointStrings = [NSMutableArray array];
    NSUInteger max = _count > 8 ? 8 : _count;
    for (NSUInteger i = 0; i < max; ++i) {
        VOIPoint p = _points[i];
        [pointStrings addObject:[NSString stringWithFormat:@"(%.2f, %.2f)", p.x, p.y]];
    }
    NSString *pointsString = [pointStrings componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"VOIPointList: points: [%@, ...] count: %td", pointsString, _count];
}

- (BOOL)isEqual:(id)object {
    return (
            [object isKindOfClass:[VOIPointList class]] &&
            [self isEqualToPointList:object]
            );
}

- (instancetype)initWithPoints:(VOIPoint *)points count:(NSUInteger)count {
    self = [super init];
    if (self) {
        _pointsData = [[NSMutableData alloc] initWithBytes:points length:(count * sizeof(VOIPoint))];
        _points = _pointsData.mutableBytes;
        _count = 4;
    }
    return self;
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

@end
