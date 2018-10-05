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
#import "VOISegmentList.h"

@implementation VOIPath

- (NSUInteger)count {
    // number of segments is 1 less than points when path is open
    return [super count] - (_closed ? 0 : 1);
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[self class]];
}

- (BOOL)isEqualToPath:(VOIPath *)path {
    return (
            [super isEqualToPointList:path] &&
            _closed == path->_closed
            );
}

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

- (NSArray<VOISegment *> *)allSegments {
    NSMutableArray *array = [NSMutableArray array];
    [self iterateSegments:^BOOL(VOISegment *s, NSUInteger i) {
        [array addObject:s];
        return NO;
    }];
    return array;
}

- (VOISegmentList *)asSegmentList {
    
#if 0
    // This feels so lazy
    return [[VOISegmentList alloc] initWithSegments:[self allSegments]];
    
#else
    const NSUInteger count = self.count * 2;
    NSMutableData *data = [NSMutableData dataWithLength:count * sizeof(VOIPoint)];
    VOIPoint *points = data.mutableBytes;

    [self iteratePoints:^(const VOIPoint *p, const NSUInteger i) {
        points[i * 2] = *p;
        return NO;
    }];
    [self iteratePoints:^(const VOIPoint *p, const NSUInteger i) {
        points[(i * 2 + count - 1) % count] = *p;
        return NO;
    }];
    
    return [[VOISegmentList alloc] _initWithData:data];
#endif
}

@end

@implementation VOIPointList (VOIPath)

- (VOIPath *)asPath {
    return [[VOIPath alloc] _initWithData:self.pointsData];
}

@end
