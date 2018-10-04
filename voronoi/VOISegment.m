//
//  VOISegment.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOISegment.h"

@implementation VOISegment

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[self class]] && [self isEqualToSegment:object];
}

- (instancetype)initWithPoints:(const VOIPoint *)points {
    self = [super init];
    if (self) {
        _a = points[0];
        _b = points[1];
    }
    return self;
}

- (BOOL)isEqualToSegment:(VOISegment *)other {
    return simd_equal(_a, other->_a) && simd_equal(_b, other->_b);
}

@end
