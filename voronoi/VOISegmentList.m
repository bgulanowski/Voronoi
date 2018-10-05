//
//  VOISegmentList.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOISegmentList.h"

#import "VOISegment.h"
#import "VOIPointListPrivate.h"

const NSUInteger PPS = 2;

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
