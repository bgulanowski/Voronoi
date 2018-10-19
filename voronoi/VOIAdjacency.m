//
//  VOIAdjacency.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-18.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIAdjacency.h"

#import "VOISegment.h"
#import "VOITriangle.h"

@implementation VOIAdjacency

- (BOOL)isEmpty {
    return _s == nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: {%@:%td - %@:%td; %@}", [self className], _t0, _t0Index, _t1, _t1Index, _s ];
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[VOIAdjacency class]] && [self isEqualToAdjacency:object];
}

- (instancetype)init {
    return [self initWithTriangle:nil index:NSNotFound triangle:nil index:NSNotFound segment:nil];
}

- (instancetype)initWithTriangle:(VOITriangle *)t0 index:(NSUInteger)t0Idx triangle:(VOITriangle *)t1 index:(NSUInteger)t1Idx segment:(VOISegment *)s {
    self = [super init];
    if (self) {
        _t0 = t0;
        _t1 = t1;
        _s = s;
        _t0Index = t0Idx;
        _t1Index = t1Idx;
    }
    return self;
}

- (instancetype)initWithTriangle:(VOITriangle *)t0 triangle:(VOITriangle *)t1 {
    NSUInteger indices[2];
    VOISegment *s = [t0 segmentInCommonWith:t1 indices:indices];
    return [self initWithTriangle:t0 index:indices[0] triangle:t1 index:indices[1] segment:s];
}

+ (instancetype)adjacencyWithTriangle:(VOITriangle *)t0 triangle:(VOITriangle *)t1 {
    VOIAdjacency *a = [[self alloc] initWithTriangle:t0 triangle:t1];
    return (a.s) ? a : [self emptyAdjacency];
}

+ (instancetype)emptyAdjacency {
    static dispatch_once_t onceToken;
    static VOIAdjacency *empty;
    dispatch_once(&onceToken, ^{
        empty = [[self alloc] init];
    });
    return empty;
}

- (BOOL)isEqualToAdjacency:(VOIAdjacency *)other {
    return (
            other != nil &&
            _t0Index == other->_t0Index &&
            _t1Index == other->_t1Index &&
            [_t0 isEqualToTriangle:other->_t0] &&
            [_t1 isEqualToTriangle:other->_t1] &&
            [_s isEqualToSegment:other->_s]
            );
}

- (BOOL)isEquivalentToAdjacency:(VOIAdjacency *)other {
    return (
            other != nil &&
            ((
              _t0Index == other->_t0Index &&
              _t1Index == other->_t1Index &&
              [_t0 isEquivalentToTriangle:other->_t0] &&
              [_t1 isEquivalentToTriangle:other->_t1]
             ) ||
             (
              _t0Index == other->_t1Index &&
              _t1Index == other->_t0Index &&
              [_t0 isEquivalentToTriangle:other->_t1] &&
              [_t1 isEquivalentToTriangle:other->_t0]
             )) &&
            [_s isEquivalentToSegment:other->_s]
            );
}

@end
