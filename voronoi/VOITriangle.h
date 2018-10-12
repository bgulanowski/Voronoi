//
//  VOITriangle.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VOITriangle : NSObject

@property (readonly) VOIPoint p0;
@property (readonly) VOIPoint p1;
@property (readonly) VOIPoint p2;
@property (readonly) VOIPoint centre;
@property (readonly) double radius;
@property (readonly, getter=isDegenerate) BOOL degenerate;
@property (readonly, getter=isRightHanded) BOOL rightHanded;

// must be 3 points
- (instancetype)initWithPoints:(const VOIPoint *)points;
- (BOOL)isEqualToTriangle:(VOITriangle *)other;
// Will check standardized versions of both
- (BOOL)isEquivalentToTriangle:(VOITriangle *)other;

// any index will do - uses %3
- (VOIPoint)pointAt:(NSUInteger)index;

- (VOITriangle *)reorder;
- (VOITriangle *)standardize;

@end
