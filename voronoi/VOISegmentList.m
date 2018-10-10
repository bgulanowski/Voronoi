//
//  VOISegmentList.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOISegmentList.h"

#import "VOIPointListPrivate.h"
#import "VOISegment.h"
#import "VOITriangle.h"

#import <simd/simd.h>

const NSUInteger PPS = 2;

// Sorts from longest to shortest
static VOIPointComparator SegmentLength = ^(const VOIPoint *s0, const VOIPoint *s1) {
    double l0 = simd_distance(s0[0], s0[1]);
    double l1 = simd_distance(s1[0], s1[1]);
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

@implementation VOISegmentList

#pragma mark - Accessors

- (NSUInteger)count {
    return [super count] / 2;
}

#pragma mark - VOIPointList

- (instancetype)initWithPoints:(const VOIPoint *)points count:(NSUInteger)count {
    return [super initWithPoints:points count:count * PPS];
}

#pragma mark - VOISegmentList

- (instancetype)initWithSegments:(NSArray<VOISegment *> *)segments {
    NSMutableData *data = [NSMutableData dataWithLength:segments.count * 2 * sizeof(VOIPoint)];
    VOIPoint *points = data.mutableBytes;
    NSUInteger i = 0;
    for (VOISegment *segment in segments) {
        points[i++] = segment.a;
        points[i++] = segment.b;
    }
    return [self _initWithData:data];
}

- (instancetype)initWithTriangle:(VOITriangle *)triangle {
    VOIPoint points[6] = {
        triangle.p0,
        triangle.p1,
        triangle.p1,
        triangle.p2,
        triangle.p2,
        triangle.p0
    };
    return [self initWithPoints:points count:3];
}

- (BOOL)isEqualToSegmentList:(VOISegmentList *)other {
    return [super isEqualToPointList:other];
}

- (VOISegment *)segmentAt:(NSUInteger)index {
    const NSUInteger count = self.pointCount;
    VOIPoint points[2];
    points[0] = [self pointAtIndex:(index * PPS) % count];
    points[1] = [self pointAtIndex:(index * PPS + 1) % count];
    return [[VOISegment alloc] initWithPoints:points];
}

- (void)iterateSegments:(VOISegmentIterator)iterator {
    [self iteratePoints:^(const VOIPoint *points, const NSUInteger i) {
        if (i % PPS == 0) {
            VOISegment *segment = [[VOISegment alloc] initWithPoints:points];
            return iterator(segment, i / PPS);
        }
        return NO;
    }];
}

- (VOISegmentList *)sortedByLength {
    VOISegmentList *copy = [self copy];
    qsort_b(copy.pointsData.mutableBytes, self.count, sizeof(VOIPoint) * 2, [SegmentLength copy]);
    return copy;
}

- (NSArray<VOISegment *> *)allSegments {
    NSMutableArray *segments = [NSMutableArray array];
    [self iterateSegments:^BOOL(VOISegment *s, NSUInteger i) {
        [segments addObject:s];
        return NO;
    }];
    return segments;
}

#pragma mark - VOISegmentListAdditions

- (VOISegmentList *)asSegmentList {
    return self;
}

@end

@implementation VOIPointList (VOISegmentListAdditions)

- (VOISegmentList *)asSegmentList {
    return [[VOISegmentList alloc] _initWithData:self.pointsData];
}

@end
