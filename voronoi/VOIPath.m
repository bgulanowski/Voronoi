//
//  VOIPath.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIPath.h"

#import "VOIPointListPrivate.h"
#import "VOISegment.h"

@implementation VOIPath

- (VOISegment *)segmentAt:(NSUInteger)index {
    const NSUInteger count = self.count;
    VOIPoint points[2];
    points[0] = [self pointAtIndex:index % count];
    points[1] = [self pointAtIndex:(index + 1) % count];
    return [[VOISegment alloc] initWithPoints:points];
}

- (void)iterateSegments:(VOISegmentIterator)iterator {
    const NSUInteger last = self.count - 1;
    [self iteratePoints:^(const VOIPoint *points, const NSUInteger i) {
        VOISegment *segment = nil;
        if (i < last) {
            segment = [[VOISegment alloc] initWithPoints:points];
        }
        else if (self.closed) {
            segment = [self segmentAt:last];
        }
        return (BOOL)(segment ? iterator(segment, i) : NO);
    }];
}

- (VOISegmentList *)asSegmentList {

    const NSUInteger segmentCount = self.count - (_closed ? 0 : 1);
    NSMutableData *segmentsData = [NSMutableData dataWithLength:segmentCount * 2 * sizeof(VOIPoint)];
    VOIPoint *segmentPoints = segmentsData.mutableBytes;

    [self iteratePoints:^BOOL(const VOIPoint *p, const NSUInteger i) {
        segmentPoints[i * 2] = p[0];
        segmentPoints[i * 2 + 1] = p[1];
        return (i == segmentCount);
    }];

    return [[VOISegmentList alloc] _initWithData:segmentsData];
}

@end

@implementation VOIPointList (VOIPath)

- (VOIPath *)asPath {
    return [[VOIPath alloc] _initWithData:self.pointsData];
}

@end
