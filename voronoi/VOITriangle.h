//
//  VOITriangle.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <simd/simd.h>

#import "VOIPointList.h"

@class VOISegment, VOISegmentList;

@interface VOITriangle : NSObject

@property (readonly) VOIPoint p0;
@property (readonly) VOIPoint p1;
@property (readonly) VOIPoint p2;

// must be 3 points
- (instancetype)initWithPoints:(const VOIPoint *)points;

// any index will do - uses %3
- (VOIPoint)pointAt:(NSUInteger)index;

@end
