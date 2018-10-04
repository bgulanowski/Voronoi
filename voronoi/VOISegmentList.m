//
//  VOISegmentList.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOISegmentList.h"

#import "VOISegment.h"

@interface VOIPointList (VOIPrivate)
- (instancetype)initWithData:(NSMutableData *)data;
@property (nonatomic, readonly) NSMutableData *pointsData;
@end

@interface VOIPointList (VOISegmentList)
- (VOISegmentList *)asSegments;
@end

@implementation VOISegmentList

- (NSUInteger)count {
    return [super count] / 2;
}

- (instancetype)initWithPoints:(const VOIPoint *)points count:(NSUInteger)count {
    return [super initWithPoints:points count:count * 3];
}

- (VOISegment *)segmentAt:(NSUInteger)index {
    VOIPoint points[2];
    points[0] = [self pointAtIndex:index * 2];
    points[1] = [self pointAtIndex:index * 2 + 1];
    return [[VOISegment alloc] initWithPoints:points];
}

- (void)iterateSegments:(VOISegmentIterator)iterator {
    [self iteratePoints:^(const VOIPoint *points, const NSUInteger i) {
        if (i % 2) {
            VOISegment *segment = [[VOISegment alloc] initWithPoints:points];
            return iterator(segment, i / 2);
        }
        return NO;
    }];
}

@end

@implementation VOIPointList (VOISegmentList)

- (VOISegmentList *)asSegments {
    return [[VOISegmentList alloc] initWithData:self.pointsData];
}

@end
