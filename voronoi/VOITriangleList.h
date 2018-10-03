//
//  VOITriangleList.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIPointList.h"

#import <simd/simd.h>

@class VOITriangle;

@interface VOITriangleList : VOIPointList

- (VOITriangle *)triangleAt:(NSUInteger)index;

@end
