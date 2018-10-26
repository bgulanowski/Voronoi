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

@implementation VOITriangleNet {
    BOOL _minimizing;
}

@synthesize hashKey=_hashKey;

#pragma mark - Properties

- (NSArray<VOITriangleNet *> *)adjacentNets {
    NSMutableArray *nets = [NSMutableArray array];
    if (_n0) { [nets addObject:_n0]; }
    if (_n1) { [nets addObject:_n1]; }
    if (_n2) { [nets addObject:_n2]; }
    return nets;
}

- (BOOL)minimized {
    for (NSUInteger i = 0; i < 3; ++i) {
        if (![self isMinimizedAt:i]) {
            return NO;
        }
    }
    return YES;
}

- (id<NSCopying>)hashKey {
    return _hashKey ?: (_hashKey = _triangle.hashKey);
}

#pragma mark - NSObject

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %@ (n0:%@ n1:%@ n2:%@)", [self className], _triangle, _n0.triangle, _n1.triangle, _n2.triangle];
}

- (NSUInteger)hash {
    return _triangle.hash;
}

- (BOOL)isEqual:(id)object {
    return (self == object) ||
    ([object isKindOfClass:[self class]] && [self isEqualToTriangleNet:object]);
}

#pragma mark - Instantiation

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

#pragma mark - VOITriangleNet

- (BOOL)isEqualToTriangleNet:(VOITriangleNet *)other {
    return [self.triangle isEqualToTriangle:other.triangle];
}

- (VOITriangleNet *)netAtIndex:(NSUInteger)index {
    switch (index % 3) {
        case 0: return _n0;
        case 1: return _n1;
        case 2: return _n2;
        default: return nil;
    }
}

- (void)setNet:(VOITriangleNet *)net atIndex:(NSUInteger)index {
    switch (index % 3) {
        case 0: _n0 = net; break;
        case 1: _n1 = net; break;
        case 2: _n2 = net; break;
        default: break;
    }
    [self setAdjacency:nil atIndex:index];
}

- (void)removeAdjacentNet:(VOITriangleNet *)net {
    NSUInteger index = [self indexOf:net];
    if (index != NSNotFound) {
        [self setNet:nil atIndex:index];
    }
}

- (void)addAdjacentNet:(VOITriangleNet *)net {
    if (net == self) {
        return;
    }
    VOIAdjacency *a = [self adjacencyForNet:net];
    if (!a.empty) {
        [self setNet:net atIndex:a.t0Index];
        [self setAdjacency:a atIndex:a.t0Index];
        [net removeAdjacentNet:self];
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

- (VOITriangleNet *)netForSegment:(VOISegment *)segment {
    NSUInteger index = [self.triangle indexForSegment:segment];
    return [self netAtIndex:index];
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
    VOIAdjacency *a = nil;
    switch (index % 3) {
        case 0: a = _a0;
        case 1: a = _a1;
        case 2: a = _a2;
        default: a = nil;
    }
    return a ?: [self createAdjacencyAtIndex:index];
}

- (VOIAdjacency *)adjacencyForNet:(VOITriangleNet *)net {
    return [VOIAdjacency adjacencyWithTriangle:_triangle triangle:net.triangle];
}

- (void)setAdjacency:(VOIAdjacency *)adjacency atIndex:(NSUInteger)index {
    switch (index % 3) {
        case 0: _a0 = adjacency; break;
        case 1: _a1 = adjacency; break;
        case 2: _a2 = adjacency; break;
        default: break;
    }
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

- (BOOL)isMinimizedAt:(NSUInteger)index {
    VOIAdjacency *adj = [self adjacencyAtIndex:index];
    return !adj.empty ? adj.minimized : YES;
}

- (void)minimizeRecurse:(BOOL)recurse {
    if (_minimizing) {
        return;
    }
    
    BOOL flipped = NO;
    for (NSUInteger i = 0; i < 3; ++i) {
        if (![self isMinimizedAt:i]) {
            [self flipWith:i];
            flipped = YES;
            break;
        }
    }
    if (recurse && flipped) {
        for (NSUInteger i = 0; i < 3; ++i) {
            [[self netAtIndex:i] minimizeRecurse:YES];
        }
    }
    _minimizing = NO;
}

- (void)minimize {
    [self minimizeRecurse:YES];
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
    [net setAdjacency:ta atIndex:ta.t1Index];
    return ta;
}

@end
