//
//  DSegment.h
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DRange.h"

@class DPoint;

@interface DSegment : DRange {
    Float64 _a;
    Float64 _b;
    Float64 _c;
}

@property Float64 a;
@property Float64 b;
@property Float64 c;

- (DSegment *)projectToPoint:(DPoint *)point;
- (DPoint *)intersection:(DSegment *)segment restrictToRange:(BOOL)flag;
- (DPoint *)intersection:(DSegment *)segment;
- (NSArray *)perpendicularsThroughPoint:(DPoint *)point scale:(Float64)scale;

+ (DSegment *)segmentWithPoint:(DPoint *)p0 point:(DPoint *)p1;

@end
