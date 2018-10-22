//
//  VOIAdjacency.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-18.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VOITriangle;
@class VOISegment;

@interface VOIAdjacency : NSObject

@property (readonly) VOITriangle *t0;
@property (readonly) VOITriangle *t1;
@property (readonly) VOISegment *s;

@property (readonly) NSUInteger t0Index;
@property (readonly) NSUInteger t1Index;

@property (readonly, getter=isEmpty) BOOL empty;

- (instancetype)initWithTriangle:(VOITriangle *)t0 triangle:(VOITriangle *)t1 NS_DESIGNATED_INITIALIZER;

+ (instancetype)adjacencyWithTriangle:(VOITriangle *)t0 triangle:(VOITriangle *)t1;
+ (instancetype)emptyAdjacency;

- (BOOL)isEqualToAdjacency:(VOIAdjacency *)other;
- (BOOL)isEquivalentToAdjacency:(VOIAdjacency *)other;

- (VOIAdjacency *)invert;

@end
