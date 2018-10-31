//
//  VOIPath.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIPointList.h"

#import "VOIBox.h"
#import "VOIRange.h"
#import "VOISegmentList.h"
#import "VOITriangle.h"
#import "VOITriangleList.h"

@interface VOIPath : VOIPointList<NSCopying>

@property (readonly) BOOL closed;
@property (readonly, getter=isConvex) BOOL convex;

- (instancetype)initWithPoints:(const VOIPoint *)points count:(NSUInteger)count close:(BOOL)closed;

- (BOOL)isEqualToPath:(VOIPath *)path;
- (VOIPath *)closedPath;
- (VOIPath *)openPath;

- (VOISegment *)segmentAt:(NSUInteger)index;
- (VOISegment *)closestSegmentToPoint:(VOIPoint)point index:(NSUInteger *)pIndex;
- (void)iterateSegments:(VOISegmentIterator)iterator;
- (NSArray<VOISegment *> *)allSegments;
- (VOISegmentList *)asSegmentList;

- (VOITriangle *)triangleAt:(NSUInteger)index;
- (void)iterateTriangles:(VOITriangleIterator)iterator;
- (NSArray<VOITriangle *> *)allTriangles;

- (VOITriangleList *)triangleFanWithCentre:(VOIPoint)point range:(NSRange)range;

- (BOOL)pointInside:(VOIPoint)point;
- (NSRange)rangeVisibleToPoint:(VOIPoint)point closestSegmentIndex:(NSUInteger *)pIndex;
- (VOIPath *)pathVisibleToPoint:(VOIPoint)point closestSegmentIndex:(NSUInteger *)pIndex;
- (VOIPath *)substitutePoint:(VOIPoint)point forSegmentsInRange:(NSRange)range;
- (VOIPath *)convexHullByAddingPoint:(VOIPoint)point triangles:(VOITriangleList **)pTriangles affectedPoint:(NSUInteger *)index;

@end

@interface VOIPointList (VOIPath)

- (VOIPath *)asPath;
- (VOIPath *)asClosedPath;

@end

@interface VOITriangle (VOIPath)

- (instancetype)initWithPath:(VOIPath *)path;
- (VOIPath *)asPath;

@end

@interface VOIBox (VOIPath)

- (VOIPath *)asPath;

@end
