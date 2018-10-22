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

- (BOOL)isEquivalent:(id)object {
    return [object isKindOfClass:[VOIAdjacency class]] && [self isEquivalentToAdjacency:object];
}

- (instancetype)init {
    return [self initWithTriangle:nil triangle:nil];
}

- (instancetype)initWithTriangle:(VOITriangle *)t0 triangle:(VOITriangle *)t1 {
    NSUInteger indices[2];
    if (self) {
        _s = [t0 segmentInCommonWith:t1 indices:indices];
        _t0 = t0;
        _t1 = t1;
        _t0Index = indices[0];
        _t1Index = indices[1];
    }
    return self;
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

// s and indices are derived, so no need to verify equality/equivalence
- (BOOL)isEqualToAdjacency:(VOIAdjacency *)other {
    return (
            other == self ||
            (other != nil &&
             VOIIsEqual(_t0, other->_t0) &&
             VOIIsEqual(_t1, other->_t1)
             )
            );
}

NS_INLINE BOOL SameTriangles(VOIAdjacency *a, VOIAdjacency *b) {
    return (VOIIsEquiv(a->_t0, b->_t0) && VOIIsEquiv(a->_t1, b->_t1));
}

NS_INLINE BOOL SwappedTriangles(VOIAdjacency *a, VOIAdjacency *b) {
    return (VOIIsEquiv(a->_t0, b->_t1) && VOIIsEquiv(a->_t1, b->_t0));
}

NS_INLINE BOOL EquivalentTriangles(VOIAdjacency *a, VOIAdjacency *b) {
    return SameTriangles(a, b) || SwappedTriangles(a, b);
}

- (BOOL)isEquivalentToAdjacency:(VOIAdjacency *)other {
    return (
            other == self ||
            (other != nil &&
             EquivalentTriangles(self, other)
             )
            );
}

@end
