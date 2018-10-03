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

@interface VOIPointList : NSObject

@property (readonly) NSUInteger count;

- (instancetype)initWithPoints:(VOIPoint *)points count:(NSUInteger)count;

- (VOIPoint)pointAtIndex:(NSUInteger)index;

- (VOIPointList *)sortedPointList:(VOIPointComparator)comparator;
- (VOIPointList *)sortedByLength;
- (VOIPointList *)sortedByDistanceFrom:(VOIPoint)p;

@end
