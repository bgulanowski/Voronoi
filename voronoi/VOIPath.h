//
//  VOIPath.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIPointList.h"

#import "VOISegmentList.h"

@interface VOIPath : VOIPointList

@property (nonatomic) BOOL closed;

- (BOOL)isEqualToPath:(VOIPath *)path;
- (void)iterateSegments:(VOISegmentIterator)iterator;

- (VOISegmentList *)asSegmentList;

@end

@interface VOIPointList (VOIPath)

- (VOIPath *)asPath;

@end
