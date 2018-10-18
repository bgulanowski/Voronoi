//
//  VOITriangleNet.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-17.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VOITriangle;

@interface VOITriangleNet : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTriangle:(VOITriangle *)triangle
                            net0:(VOITriangleNet *)n0
                            net1:(VOITriangleNet *)n1
                            net2:(VOITriangleNet *)n2 NS_DESIGNATED_INITIALIZER;

@property (readonly) VOITriangle *triangle;

// Net0 corresponds to triangle.segment0 etc
@property (readonly) VOITriangleNet *n0;
@property (readonly) VOITriangleNet *n1;
@property (readonly) VOITriangleNet *n2;

- (VOITriangleNet *)netAtIndex:(NSUInteger)index;

- (void)flipWith:(NSUInteger)netIndex;

@end
