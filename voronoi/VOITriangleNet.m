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

- (void)updateNets:(NSArray<VOITriangleNet *> *)nets {
    [self removeAllAdjacentNets];
    [self addAdjacentNets:nets];
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
        if (self.triangle == adjacency.t1) {
            [net flipAdjacency:adjacency withNet:self];
        }
        else {
            [self flipAdjacency:adjacency withNet:net];
        }
    }
}


#pragma mark - Private

- (void)flipAdjacency:(VOIAdjacency *)adjacency withNet:(VOITriangleNet *)net {
    
    adjacency = [adjacency flip];
    self.triangle = adjacency.t0;
    net.triangle = adjacency.t1;
    [self setAdjacency:adjacency atIndex:adjacency.t0Index];
    [net setAdjacency:adjacency atIndex:adjacency.t1Index];
    
    NSArray *nets = [[self adjacentNets] arrayByAddingObjectsFromArray:[net adjacentNets]];
    [self updateNets:nets];
    [net updateNets:nets];
}

- (VOIAdjacency *)createAdjacencyAtIndex:(NSUInteger)index {
    VOITriangleNet *net = [self netAtIndex:index];
    VOIAdjacency *ta = [VOIAdjacency adjacencyWithTriangle:self.triangle triangle:net.triangle];
    [self setAdjacency:ta atIndex:index];
    // TODO: set the adjacency of adjacent net
    return ta;
}

@end
