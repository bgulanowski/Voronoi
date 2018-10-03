//
//  VOIPointList.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIPointList.h"

@interface VOIPointList ()

@property (nonatomic) vector_double2 *points;

@end

@implementation VOIPointList

- (void)dealloc {
    free(_points);
}

- (instancetype)initWithPointsNoCopy:(vector_double2 *)points count:(NSUInteger)count {
    self = [super init];
    if (self) {
        _count = count;
        _points = points;
    }
    return self;
}

- (instancetype)initWithPoints:(vector_double2 *)points count:(NSUInteger)count {
    const size_t len = sizeof(vector_double2) * (size_t)count;
    vector_double2 *copy = malloc(len);
    memcpy(copy, points, len);
    return [self initWithPointsNoCopy:copy count:count];
}

- (vector_double2)pointAtIndex:(NSUInteger)index {
    return _points[index];
}

- (VOIPointList *)sortedPointList:(VOIPointComparator)comparator {
    VOIPointList *copy = [[VOIPointList alloc] initWithPoints:_points count:_count];
    qsort_b(copy->_points, _count, sizeof(vector_double2), [comparator copy]);
    return copy;
}

@end
