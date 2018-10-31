//
//  VOITriangulator.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-05.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEEP_VERIFY YES

@class VOIPointList;
@class VOITriangleList;

@interface VOITriangulator : NSObject

@property (readonly) VOIPointList *pointList;
@property (readonly) BOOL minimized; // only valid if triangulation done

@property BOOL exportTriangles;

- (instancetype)initWithPointList:(VOIPointList *)pointList;

- (VOITriangleList *)triangulate;

@end
