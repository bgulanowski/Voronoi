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
    double _a;
    double _b;
    double _c;
}

@property double a;
@property double b;
@property double c;

- (DSegment *)projectToPoint:(DPoint *)point;
- (DPoint *)intersection:(DSegment *)segment restrictToRange:(BOOL)flag;
- (DPoint *)intersection:(DSegment *)segment;
- (NSArray *)perpendicularsThroughPoint:(DPoint *)point scale:(double)scale;

+ (DSegment *)segmentWithPoint:(DPoint *)p0 point:(DPoint *)p1;

@end
