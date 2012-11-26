//
//  DCircle.h
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DPoint;

@interface DCircle : NSObject {
    DPoint *_centre;
    Float64 _radius;
    Float64 _r2; // _radius^2 (optimization)
}

@property (readonly) DPoint *centre;
@property (readonly) Float64 radius;
@property (readonly) Float64 r2;

- (id)initWithCentre:(DPoint *)p radius:(Float64)r;
- (BOOL)containsPoint:(DPoint *)p;

+ (DCircle *)circleWithCentre:(DPoint *)p radius:(Float64)r;

@end
