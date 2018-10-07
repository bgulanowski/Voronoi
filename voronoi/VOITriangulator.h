//
//  VOITriangulator.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-05.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VOIPointList;
@class VOITriangleList;

@interface VOITriangulator : NSObject

@property (readonly) VOIPointList *pointList;

- (instancetype)initWithPointList:(VOIPointList *)pointList;

- (VOITriangleList *)triangulate;

@end
