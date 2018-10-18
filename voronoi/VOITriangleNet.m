//
//  VOITriangleNet.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-17.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOITriangleNet.h"

#import "VOITriangle.h"

@implementation VOITriangleNet

- (instancetype)initWithTriangle:(VOITriangle *)triangle net0:(VOITriangleNet *)n0 net1:(VOITriangleNet *)n1 net2:(VOITriangleNet *)n2 {
    self = [super init];
    if (self) {
        _triangle = triangle;
        _n0 = n0;
        _n1 = n1;
        _n2 = n2;
    }
    return self;
}

- (VOITriangleNet *)netAtIndex:(NSUInteger)index {
    index %= 3;
    switch (index) {
        case 0:
            return _n0;
        case 1:
            return _n1;
        case 2:
        default:
            return _n2;
    }
}

- (void)flipWith:(NSUInteger)netIndex {
    VOITriangleNet *net = [self netAtIndex:netIndex];
    VOITriangle *complement = net.triangle;
    // Which edge is complement matches which edge in _triangle?
}

@end
