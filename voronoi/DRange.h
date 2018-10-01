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

@property (readonly) DPoint *p0;
@property (readonly) DPoint *p1;

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

@property (nonatomic, readonly) NSArray *boundarySegments;

- (instancetype)init:(vector_double2)p0 :(vector_double2)p1 NS_DESIGNATED_INITIALIZER;
- (id)initWithPoint:(DPoint *)p0 point:(DPoint *)p1;

- (BOOL)containsPoint:(DPoint *)point;

+ (DRange *)rangeWithPoint:(DPoint *)p0 point:(DPoint *)p1;

@end
