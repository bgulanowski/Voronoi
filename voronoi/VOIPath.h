//
//  VOIPath.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIPointList.h"

#import "VOISegmentList.h"

@interface VOIPath : VOIPointList<NSCopying>

@property (readonly) BOOL closed;

- (instancetype)initWithPoints:(const VOIPoint *)points count:(NSUInteger)count close:(BOOL)closed;

- (BOOL)isEqualToPath:(VOIPath *)path;
- (VOIPath *)closedPath;
- (VOIPath *)openPath;

- (VOISegment *)segmentAt:(NSUInteger)index;
- (void)iterateSegments:(VOISegmentIterator)iterator;
- (VOISegmentList *)asSegmentList;

- (NSArray<VOISegment *> *)allSegments;

@end

@interface VOIPointList (VOIPath)

- (VOIPath *)asPath;

@end
