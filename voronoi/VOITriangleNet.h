//
//  VOITriangleNet.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-17.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VOITriangle;
@class VOIAdjacency;

@interface VOITriangleNet : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTriangle:(VOITriangle *)triangle
                            net0:(VOITriangleNet *)n0
                            net1:(VOITriangleNet *)n1
                            net2:(VOITriangleNet *)n2 NS_DESIGNATED_INITIALIZER;

+ (instancetype)netWithTriangle:(VOITriangle *)triangle adjacentNets:(__weak VOITriangleNet *[3])nets;
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

- (VOITriangleNet *)netAtIndex:(NSUInteger)index;
- (void)setNet:(VOITriangleNet *)net atIndex:(NSUInteger)index;
- (NSUInteger)indexOf:(VOITriangleNet *)net;

- (VOIAdjacency *)adjacencyAtIndex:(NSUInteger)index;

- (void)flipWith:(NSUInteger)netIndex;

@end
