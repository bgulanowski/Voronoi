//
//  NSValue+VOIPoint.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-25.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOIPoint.h"

@interface NSValue (VOIPoint)

@property (readonly) VOIPoint point;
+ (instancetype)valueWithPoint:(VOIPoint)point;

@property (readonly) VOIPoints2 points2;
+ (instancetype)valueWithPoints2:(VOIPoints2)points2;

@property (readonly) VOIPoints3 points3;
+ (instancetype)valueWithPoints3:(VOIPoints3)points3;

@end
