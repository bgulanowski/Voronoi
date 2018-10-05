//
//  VOIPointList.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <simd/simd.h>

typedef vector_double2 VOIPoint;

typedef int (^VOIPointComparator)(const VOIPoint *, const VOIPoint *);
typedef BOOL (^VOIPointIterator)(const VOIPoint *, const NSUInteger);

@interface VOIPointList : NSObject<NSCopying>

// -count is overridden by subclasses to count the specific primitive
// -pointCount always returns the number of underlying points
@property (readonly) NSUInteger count;
@property (readonly) NSUInteger pointCount;

- (instancetype)initWithPoints:(const VOIPoint *)points count:(NSUInteger)count;

- (BOOL)isEqualToPointList:(VOIPointList *)other;

- (VOIPointList *)add:(VOIPointList *)other;
// index is truncated with %
- (VOIPoint)pointAtIndex:(NSUInteger)index;
// range can be anything; indices will be truncated with %
- (VOIPointList *)pointListWithRange:(NSRange)range;

- (VOIPointList *)sortedPointList:(VOIPointComparator)comparator;
- (VOIPointList *)sortedByLength;
- (VOIPointList *)sortedByDistanceFrom:(VOIPoint)p;

- (void)iteratePoints:(VOIPointIterator)iterator;

@end
