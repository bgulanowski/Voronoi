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

- (NSArray<VOITriangleNet *> *)adjacentNets {
    NSMutableArray *nets = [NSMutableArray array];
    if (_n0) { [nets addObject:_n0]; }
    if (_n1) { [nets addObject:_n1]; }
    if (_n2) { [nets addObject:_n2]; }
    return nets;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %@ (n0:%@ n1:%@ n2:%@)", [self className], _triangle, _n0.triangle, _n1.triangle, _n2.triangle];
}

- (instancetype)initWithTriangle:(VOITriangle *)triangle adjacentNets:(NSArray<VOITriangleNet *> *)nets {
    self = [super init];
    if (self) {
        _triangle = [triangle standardize];
        [self addAdjacentNets:nets];
    }
    return self;
}

+ (instancetype)netWithTriangle:(VOITriangle *)triangle adjacentNets:(NSArray<VOITriangleNet *> *)nets {
    return [[self alloc] initWithTriangle:triangle adjacentNets:nets];
}

+ (instancetype)netWithTriangle:(VOITriangle *)triangle {
    return [[self alloc] initWithTriangle:triangle adjacentNets:nil];
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

- (void)addAdjacentNet:(VOITriangleNet *)net {
    VOIAdjacency *a = [self adjacencyForNet:net];
    if (!a.empty) {
        [self setNet:net atIndex:a.t0Index];
        [self setAdjacency:a atIndex:a.t0Index];
        [net setNet:self atIndex:a.t1Index];
        [net setAdjacency:a atIndex:a.t1Index];
    }
}

- (void)addAdjacentNets:(NSArray<VOITriangleNet *> *)nets {
    for (VOITriangleNet *net in nets) {
        [self addAdjacentNet:net];
    }
}

- (NSUInteger)indexOf:(VOITriangleNet *)net {
    for (NSUInteger i = 0; i < 3; ++i) {
        if ([self netAtIndex:i] == net) {
            return i;
        }
    }
    return NSNotFound;
}

- (void)removeAllAdjacentNets {
    _n0 = nil;
    _n1 = nil;
    _n2 = nil;
    _a0 = nil;
    _a1 = nil;
    _a2 = nil;
}

- (VOIAdjacency *)adjacencyAtIndex:(NSUInteger)index {
    VOIAdjacency *ta = (__weak VOIAdjacency *[3]){ _a0, _a1, _a2 }[index % 3];
    return ta ?: [self createAdjacencyAtIndex:index];
}

- (VOIAdjacency *)adjacencyForNet:(VOITriangleNet *)net {
    return [VOIAdjacency adjacencyWithTriangle:_triangle triangle:net.triangle];
}

- (void)setAdjacency:(VOIAdjacency *)adjacency atIndex:(NSUInteger)index {
    *((__strong VOIAdjacency **[3]) { &_a0, &_a1, &_a2 }[index % 3]) = adjacency;
}

- (void)flipWith:(NSUInteger)netIndex {
    
    VOIAdjacency *adjacency = [self adjacencyAtIndex:netIndex];
    if (!adjacency.empty) {
        VOITriangleNet *net = [self netAtIndex:netIndex];
        
        // self.triangle and net.triangle are composed out of four points (two shared)
        // We have to switch the adjacent edge from the current points to the other two
        // We know the indices of the current adjacent edges; those are the other points.
        // Which triangle is assigned to which Net is arbitrary
        
        // FIXME: cannot assume that t0 == self.triangle
        VOITriangle *t0;
        VOITriangle *t1;
        if (self.triangle == adjacency.t0) {
            t0 = self.triangle;
            t1 = net.triangle;
        }
        else {
            t0 = net.triangle;
            t1 = self.triangle;
        }
        VOIPoint points[4] = {
            [t0 pointAt:adjacency.t0Index + 1],
            [t0 pointAt:adjacency.t0Index],
            [t1 pointAt:adjacency.t1Index],
            [t1 pointAt:adjacency.t1Index + 1]
        };
        
        t0 = [[VOITriangle alloc] initWithPoints:points];
        t1 = [[VOITriangle alloc] initWithPoints:&points[1]];
        
        self.triangle = [t0 standardize];
        net.triangle = [t1 standardize];
        
#if 1
        
        // lazy but safe
        NSArray *nets = [[self adjacentNets] arrayByAddingObjectsFromArray:[net adjacentNets]];
        [self removeAllAdjacentNets];
        [self addAdjacentNets:nets];
        [net removeAllAdjacentNets];
        [net addAdjacentNets:nets];
        
#else
        // other nets have to be switched to match the new adjacent edges
//        VOITriangleNet *n1 = [self netAtIndex:netIndex + 1];
        VOITriangleNet *n2 = [self netAtIndex:netIndex + 2];
        
        NSUInteger me = [net indexOf:self];
//        VOITriangleNet *n3 = [net netAtIndex:me + 1];
        VOITriangleNet *n4 = [net netAtIndex:me + 2];
        
        // swap n2 with n4
        [self setNet:n2 atIndex:netIndex + 2];
        [net setNet:n4 atIndex:me + 2];
#endif
    }
}

- (VOIAdjacency *)createAdjacencyAtIndex:(NSUInteger)index {
    VOITriangleNet *net = [self netAtIndex:index];
    VOIAdjacency *ta = [VOIAdjacency adjacencyWithTriangle:self.triangle triangle:net.triangle];
    [self setAdjacency:ta atIndex:index];
    // TODO: set the adjacency of adjacent net
    return ta;
}

@end
