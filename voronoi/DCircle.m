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


@implementation DCircle

- (NSString *)description {
    return [NSString stringWithFormat:@"C: %@ - %.2f (%.0f)", _centre, _radius, _r2];
}

- (id)initWithCentre:(DPoint *)p radius:(Float64)r {
    self = [super init];
    if(self) {
        _centre = p;
        _radius = r;
        _r2 = r*r;
    }
    return self;
}

- (BOOL)containsPoint:(DPoint *)p {
    return [[DRange rangeWithPoint:_centre point:p] length] <= _radius;
}


+ (DCircle *)circleWithCentre:(DPoint *)p radius:(Float64)r {
    return [[self alloc] initWithCentre:p radius:r];
}

@end
