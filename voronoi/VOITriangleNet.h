//
//  VOITriangleNet.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-17.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VOIAdjacency;
@class VOITriangle;
@class VOISegment;

@interface VOITriangleNet : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTriangle:(VOITriangle *)triangle adjacentNets:(NSArray<VOITriangleNet *> *)nets NS_DESIGNATED_INITIALIZER;

+ (instancetype)netWithTriangle:(VOITriangle *)triangle adjacentNets:(NSArray<VOITriangleNet *> *)nets;
+ (instancetype)netWithTriangle:(VOITriangle *)triangle;
+ (instancetype)emptyNet;

@property (readonly) VOITriangle *triangle;

// Net0 corresponds to triangle.segment0 etc
@property (readonly, weak) VOITriangleNet *n0;
@property (readonly, weak) VOITriangleNet *n1;
@property (readonly, weak) VOITriangleNet *n2;

@property (readonly) VOIAdjacency *a0;
@property (readonly) VOIAdjacency *a1;
@property (readonly) VOIAdjacency *a2;

@property (readonly) NSArray<VOITriangleNet *> *adjacentNets;

@property (readonly) id<NSCopying> hashKey;

@property (readonly) BOOL minimized;

- (VOITriangleNet *)netAtIndex:(NSUInteger)index;
- (VOITriangleNet *)netForSegment:(VOISegment *)segment;
- (BOOL)includesSegment:(VOISegment *)segment;

- (void)addAdjacentNet:(VOITriangleNet *)net;
- (void)addAdjacentNets:(NSArray<VOITriangleNet *> *)nets;

- (VOIAdjacency *)adjacencyAtIndex:(NSUInteger)index;
- (VOIAdjacency *)adjacencyForNet:(VOITriangleNet *)net;

// divide the combined quad along the alternate axis
// replace existing triangles with two new triangles
// update the adjacent nets to match
// return the net at netIndex
- (VOITriangleNet *)flipWith:(NSUInteger)netIndex;

- (BOOL)isMinimizedAt:(NSUInteger)index;
- (VOITriangleNet *)minimizeRecurse:(BOOL)recurse;
- (VOITriangleNet *)minimize;

@end
