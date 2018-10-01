//
//  DCircle.h
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DPoint;

@interface DCircle : NSObject

@property (readonly) DPoint *centre;
@property (readonly) double radius;
@property (readonly) double r2; // _radius^2 (optimization)

- (id)initWithCentre:(DPoint *)p radius:(double)r;
- (BOOL)containsPoint:(DPoint *)p;

+ (DCircle *)circleWithCentre:(DPoint *)p radius:(double)r;

@end
