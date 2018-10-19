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

- (instancetype)initWithTriangle:(VOITriangle *)t0
                           index:(NSUInteger)t0Idx
                        triangle:(VOITriangle *)t1
                           index:(NSUInteger)t1Idx
                         segment:(VOISegment *)s NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithTriangle:(VOITriangle *)t0 triangle:(VOITriangle *)t1;

+ (instancetype)adjacencyWithTriangle:(VOITriangle *)t0 triangle:(VOITriangle *)t1;
+ (instancetype)emptyAdjacency;

@end
