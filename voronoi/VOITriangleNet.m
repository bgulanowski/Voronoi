//
//  VOITriangleNet.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-17.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOITriangleNet.h"

#import "VOITriangle.h"
#import "VOIAdjacency.h"

@interface VOITriangleNet ()

@property (readwrite) VOITriangle *triangle;

@property (readwrite, weak) VOITriangleNet *n0;
@property (readwrite, weak) VOITriangleNet *n1;
@property (readwrite, weak) VOITriangleNet *n2;

@property (readwrite) VOIAdjacency *a0;
@property (readwrite) VOIAdjacency *a1;
@property (readwrite) VOIAdjacency *a2;

@end

@implementation VOITriangleNet

- (instancetype)initWithTriangle:(VOITriangle *)triangle net0:(VOITriangleNet *)n0 net1:(VOITriangleNet *)n1 net2:(VOITriangleNet *)n2 {
    self = [super init];
    if (self) {
        _triangle = triangle;
        _n0 = n0 ?: [VOITriangleNet emptyNet];
        _n1 = n1 ?: [VOITriangleNet emptyNet];
        _n2 = n2 ?: [VOITriangleNet emptyNet];
    }
    return self;
}

+ (instancetype)netWithTriangle:(VOITriangle *)triangle adjacentNets:(__weak VOITriangleNet *[3])nets {
    return [[self alloc] initWithTriangle:triangle net0:nets[0] net1:nets[1] net2:nets[2]];
}

+ (instancetype)netWithTriangle:(VOITriangle *)triangle {
    return [[self alloc] initWithTriangle:triangle net0:nil net1:nil net2:nil];
}

+ (instancetype)emptyNet {
    static VOITriangleNet *empty;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        empty = [[self alloc] init];
    });
    return empty;
}

- (VOITriangleNet *)netAtIndex:(NSUInteger)index {
    return ((__weak VOITriangleNet *[3]){ _n0, _n1, _n2 }[index % 3]);
}

- (void)setNet:(VOITriangleNet *)net atIndex:(NSUInteger)index {
    *((__weak VOITriangleNet **[3]){ &_n0, &_n1, &_n2 }[index % 3]) = net;
    [self setAdjacency:nil atIndex:index];
}

- (NSUInteger)indexOf:(VOITriangleNet *)net {
    for (NSUInteger i = 0; i < 3; ++i) {
        if ([self netAtIndex:i] == net) {
            return i;
        }
    }
    return NSNotFound;
}

- (VOIAdjacency *)adjacencyAtIndex:(NSUInteger)index {
    VOIAdjacency *ta = (__weak VOIAdjacency *[3]){ _a0, _a1, _a2 }[index % 3];
    return ta ?: [self createAdjacencyAtIndex:index];
}

- (VOIAdjacency *)adjacencyForNet:(VOITriangleNet *)net {
    return [[VOIAdjacency alloc] initWithTriangle:_triangle triangle:net.triangle];
}

- (void)setAdjacency:(VOIAdjacency *)adjacency atIndex:(NSUInteger)index {
    *((__strong VOIAdjacency **[3]) { &_a0, &_a1, &_a2 }[index % 3]) = adjacency;
}

- (void)flipWith:(NSUInteger)netIndex {
    VOITriangleNet *net = [self netAtIndex:netIndex];
    VOITriangle *complement = net.triangle;
    // Which edge is complement matches which edge in _triangle?
}

@end
