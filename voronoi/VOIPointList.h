//
//  VOIPointList.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <simd/simd.h>

#import "VOITriangle.h"

typedef int (^VOIPointComparator)(const VOIPoint *, const VOIPoint *);
typedef BOOL (^VOIPointIterator)(const VOIPoint *, const NSUInteger);

@class VOIBox;

@interface VOIPointList : NSObject<NSCopying>

// -count is overridden by subclasses to count the specific primitive
// -pointCount always returns the number of underlying points
@property (readonly) NSUInteger count;
@property (readonly) NSUInteger pointCount;
@property (readonly) VOIBox *boundingBox;
@property (readonly) VOIPoint centre;

- (instancetype)initWithPoints:(const VOIPoint *)points count:(NSUInteger)count;

- (BOOL)isEqualToPointList:(VOIPointList *)other;

- (VOIPointList *)add:(VOIPointList *)other;
// index is truncated with %
- (VOIPoint)pointAtIndex:(NSUInteger)index;
- (VOIPoint)pointClosestToPoint:(VOIPoint)p index:(NSUInteger *)pIndex ignoreIfEqual:(BOOL)ignore;
- (VOIPoint)pointClosestToPoint:(VOIPoint)p index:(NSUInteger *)index;

// range can be anything; indices will be truncated with %
- (VOIPointList *)pointListWithRange:(NSRange)range;
- (VOIPointList *)pointListByDeletingRange:(NSRange)range;
- (VOIPointList *)pointListByDeletingPointAtIndex:(NSUInteger)index;

- (VOIPointList *)sortedPointList:(VOIPointComparator)comparator;
- (VOIPointList *)sortedByLength;
- (VOIPointList *)sortedByDistanceFrom:(VOIPoint)p;

- (VOITriangle *)triangleWithIndices:(NSUInteger[3])indices;

- (void)iteratePoints:(VOIPointIterator)iterator;

@end
