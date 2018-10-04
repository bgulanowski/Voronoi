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

@interface VOIPointList : NSObject

@property (readonly) NSUInteger count;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithPoints:(const VOIPoint *)points count:(NSUInteger)count;

- (BOOL)isEqualToPointList:(VOIPointList *)other;

- (VOIPoint)pointAtIndex:(NSUInteger)index;

- (VOIPointList *)sortedPointList:(VOIPointComparator)comparator;
- (VOIPointList *)sortedByLength;
- (VOIPointList *)sortedByDistanceFrom:(VOIPoint)p;

- (void)iteratePoints:(VOIPointIterator)iterator;

@end
