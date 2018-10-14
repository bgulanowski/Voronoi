//
//  VOIPath.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIPointList.h"

#import "VOIBox.h"
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
- (void)iterateSegments:(VOISegmentIterator)iterator;
- (NSArray<VOISegment *> *)allSegments;
- (VOISegmentList *)asSegmentList;

- (VOITriangle *)triangleAt:(NSUInteger)index;
- (void)iterateTriangles:(VOITriangleIterator)iterator;
- (NSArray<VOITriangle *> *)allTriangles;
- (VOITriangleList *)asTriangleList;

- (BOOL)pointInside:(VOIPoint)point;
- (VOIPath *)pathVisibleToPoint:(VOIPoint)point;

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
