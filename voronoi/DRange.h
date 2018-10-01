//
//  DRange.h
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DPoint;

@interface DRange : NSObject

@property DPoint *p0;
@property DPoint *p1;

@property (readonly) double xMin;
@property (readonly) double xMax;
@property (readonly) double yMin;
@property (readonly) double yMax;

@property (readonly) DPoint *min;
@property (readonly) DPoint *max;

@property (readonly) double lengthSquared;
@property (readonly) double length;
@property (readonly) double width;
@property (readonly) double height;

- (id)initWithPoint:(DPoint *)p0 point:(DPoint *)p1;

- (NSArray *)boundary;

- (BOOL)containsPoint:(DPoint *)point;

+ (DRange *)rangeWithPoint:(DPoint *)p0 point:(DPoint *)p1;

@end
