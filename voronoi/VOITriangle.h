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
@property (readonly, getter=isDegenerate) BOOL degenerate; // points of line are colinear
@property (readonly, getter=isRightHanded) BOOL rightHanded; // clockwise ordering
@property (readonly, getter=isLeftHanded) BOOL leftHanded; // counter-clockwise ordering
@property (readonly, getter=isOrdered) BOOL ordered; // point with smallest x is at p0
@property (readonly, getter=isStandard) BOOL standard; // ordered && leftHanded

// must be 3 points
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPoints:(const VOIPoint *)points standardize:(BOOL)standardize NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPoints:(const VOIPoint *)points;
- (BOOL)isEqualToTriangle:(VOITriangle *)other;
// Will check standardized versions of both
- (BOOL)isEquivalentToTriangle:(VOITriangle *)other;

// any index will do - uses %3
- (VOIPoint)pointAt:(NSUInteger)index;
- (VOISegment *)segmentAt:(NSUInteger)index;

// Switches handedness by changing point ordering
- (VOITriangle *)reverseOrder;
// returns possibly new triangle with points in standard order
- (VOITriangle *)standardize;

@end
