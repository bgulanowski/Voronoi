//
//  VOITriangle.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <simd/simd.h>

@interface VOITriangle : NSObject

@property (readonly) vector_double2 p0;
@property (readonly) vector_double2 p1;
@property (readonly) vector_double2 p2;

// must be 3 points
- (instancetype)initWithPoints:(vector_double2 *)points;

// any index will do - uses %3
- (vector_double2)pointAt:(NSUInteger)index;

@end
