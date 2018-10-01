//
//  DCircle.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "DCircle.h"

#import "DPoint.h"
#import "DRange.h"


@implementation DCircle {
    vector_double2 _centre;
}

- (DPoint *)centre {
    return [DPoint pointWithX:_centre.x y:_centre.y];
}

- (void)setCentre:(DPoint *)centre {
    _centre.x = centre.x;
    _centre.y = centre.y;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"C: %@ - %.2f (%.0f)", self.centre, _radius, _r2];
}

- (id)initWithCentre:(DPoint *)p radius:(double)r {
    self = [super init];
    if(self) {
        _centre = vector2(p.x, p.y);
        _radius = r;
        _r2 = r*r;
    }
    return self;
}

- (BOOL)containsPoint:(DPoint *)p {
    return [[DRange rangeWithPoint:self.centre point:p] length] <= _radius;
}


+ (DCircle *)circleWithCentre:(DPoint *)p radius:(double)r {
    return [[self alloc] initWithCentre:p radius:r];
}

@end
