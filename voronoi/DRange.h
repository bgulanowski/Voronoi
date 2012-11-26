//
//  DRange.h
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DPoint;

@interface DRange : NSObject {
    DPoint *_p0;
    DPoint *_p1;
    
    Float64 _xMin, _xMax, _yMin, _yMax;
}

@property DPoint *p0;
@property DPoint *p1;

@property (readonly) Float64 xMin;
@property (readonly) Float64 xMax;
@property (readonly) Float64 yMin;
@property (readonly) Float64 yMax;

@property (readonly) DPoint *min;
@property (readonly) DPoint *max;

@property (readonly) Float64 lengthSquared;
@property (readonly) Float64 length;
@property (readonly) Float64 width;
@property (readonly) Float64 height;

- (id)initWithPoint:(DPoint *)p0 point:(DPoint *)p1;

- (NSArray *)boundary;

- (BOOL)containsPoint:(DPoint *)point;

+ (DRange *)rangeWithPoint:(DPoint *)p0 point:(DPoint *)p1;

@end
