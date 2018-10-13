//
//  VOISegmentList.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIPointList.h"

@class VOISegment;
@class VOITriangle;

typedef BOOL (^VOISegmentIterator)(VOISegment *s, NSUInteger i);

@interface VOISegmentList : VOIPointList

- (instancetype)initWithSegments:(NSArray<VOISegment *> *)segments;
- (instancetype)initWithTriangle:(VOITriangle *)triangle;

- (BOOL)isEqualToSegmentList:(VOISegmentList *)other;
- (VOISegment *)segmentAt:(NSUInteger)index;
- (void)iterateSegments:(VOISegmentIterator)iterator;
- (VOISegmentList *)sortedByLength;
- (NSArray<VOISegment *> *)allSegments;

@end

@interface VOIPointList (VOISegmentListAdditions)
- (VOISegmentList *)asSegmentList;
@end
