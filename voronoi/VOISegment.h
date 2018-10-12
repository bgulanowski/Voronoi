//
//  VOISegment.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOIPointList.h"

typedef enum {
    VOILineSideRight,
    VOILineSideOn,
    VOILineSideLeft
} VOILineSide;

@interface VOISegment : NSObject

@property (readonly) VOIPoint a;
@property (readonly) VOIPoint b;
@property (readonly) VOIPoint midpoint;

// must be two points
- (instancetype)initWithPoints:(const VOIPoint *)points;
- (BOOL)isEqualToSegment:(VOISegment *)other;
- (VOISegment *)perpendicular;
// Treat point b like a vector
- (VOIPoint)intersectWithSegment:(VOISegment *)other;

// Forward is the direction of the vector b - a
- (VOILineSide)sideForPoint:(VOIPoint)point;

@end
