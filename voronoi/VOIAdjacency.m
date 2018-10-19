//
//  VOIAdjacency.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-18.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIAdjacency.h"

#import "VOITriangle.h"

@implementation VOIAdjacency

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
    return (t0 && t1) ? [[self alloc] initWithTriangle:t0 triangle:t1] : [self emptyAdjacency];
}

+ (instancetype)emptyAdjacency {
    static dispatch_once_t onceToken;
    static VOIAdjacency *empty;
    dispatch_once(&onceToken, ^{
        empty = [[self alloc] init];
    });
    return empty;
}

@end
