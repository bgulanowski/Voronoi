//
//  VOIPointList.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <simd/simd.h>

typedef int (^VOIPointComparator)(const vector_double2 *, const vector_double2 *);

@interface VOIPointList : NSObject

@property (readonly) NSUInteger count;

- (instancetype)initWithPoints:(vector_double2 *)points count:(NSUInteger)count;

- (vector_double2)pointAtIndex:(NSUInteger)index;

- (VOIPointList *)sortedPointList:(VOIPointComparator)comparator;

@end
