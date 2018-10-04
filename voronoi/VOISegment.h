//
//  VOISegment.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOIPointList.h"

@interface VOISegment : NSObject

@property (readonly) VOIPoint a;
@property (readonly) VOIPoint b;

// must be two points
- (instancetype)initWithPoints:(const VOIPoint *)points;
- (BOOL)isEqualToSegment:(VOISegment *)other;

@end
