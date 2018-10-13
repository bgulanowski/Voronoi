//
//  VOIPointList.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <simd/simd.h>

typedef int (^VOIPointComparator)(const VOIPoint *p1, const VOIPoint *p2);
typedef BOOL (^VOIPointIterator)(const VOIPoint *p, const NSUInteger i);
typedef double (^VOIPointEvaluator)(VOIPoint *p);

@class VOIBox;
@class VOITriangle;

@interface VOIPointList : NSObject<NSCopying>

// -count is overridden by subclasses to count the specific primitive
// -pointCount always returns the number of underlying points
@property (readonly) NSUInteger count;
@property (readonly) NSUInteger pointCount;
@property (readonly) VOIBox *boundingBox;
@property (readonly) VOIPoint centre;

- (instancetype)initWithPoints:(const VOIPoint *)points count:(NSUInteger)count;

- (BOOL)isEqualToPointList:(VOIPointList *)other;

// index is truncated with %
- (VOIPoint)pointAtIndex:(NSUInteger)index;
- (VOIPoint)pointClosestToPoint:(VOIPoint)p index:(NSUInteger *)pIndex ignoreIfEqual:(BOOL)ignore;
- (VOIPoint)pointClosestToPoint:(VOIPoint)p index:(NSUInteger *)index;

// searches for minimum value
// assumes continuous change between points
- (NSUInteger)binarySearch:(VOIPointEvaluator)evaluator;

- (VOIPointList *)reverseList;
- (VOIPointList *)add:(VOIPointList *)other;

// range can be anything; indices will be truncated with %
- (VOIPointList *)pointListWithRange:(NSRange)range;
- (VOIPointList *)pointListByDeletingRange:(NSRange)range;
- (VOIPointList *)pointListByDeletingPointAtIndex:(NSUInteger)index;
- (VOIPointList *)pointListByDeletingPointsAtIndices:(NSIndexSet *)indexSet;

- (VOIPointList *)sortedPointList:(VOIPointComparator)comparator;
- (VOIPointList *)sortedByLength;
- (VOIPointList *)sortedByDistanceFrom:(VOIPoint)p;

- (VOITriangle *)triangleForIndices:(NSUInteger[3])indices;
- (VOITriangle *)triangleForIndexSet:(NSIndexSet *)indexSet;

- (void)iteratePoints:(VOIPointIterator)iterator;

@end
