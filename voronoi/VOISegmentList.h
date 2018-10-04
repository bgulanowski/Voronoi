//
//  VOISegmentList.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIPointList.h"

@class VOISegment;

typedef BOOL (^VOISegmentIterator)(VOISegment *, NSUInteger);

@interface VOISegmentList : VOIPointList

- (VOISegment *)segmentAt:(NSUInteger)index;
- (void)iterateSegments:(VOISegmentIterator)iterator;

@end
