//
//  VOITriangle.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VOISegment;

@interface VOITriangle : NSObject

@property (readonly) VOIPoint p0;
@property (readonly) VOIPoint p1;
@property (readonly) VOIPoint p2;

@property (readonly) double minX;
@property (readonly) double maxX;
@property (readonly) double minY;
@property (readonly) double maxY;

@property (readonly) VOIPoint centre;
@property (readonly) VOIPoint centroid;
@property (readonly) double radius;

@property (readonly, getter=isDegenerate) BOOL degenerate; // points of line are colinear
@property (readonly, getter=isRightHanded) BOOL rightHanded; // clockwise ordering
@property (readonly, getter=isLeftHanded) BOOL leftHanded; // counter-clockwise ordering
@property (readonly, getter=isOrdered) BOOL ordered; // point with smallest x is at p0
@property (readonly, getter=isStandard) BOOL standard; // ordered && leftHanded

// Segments are opposite their similarly named point
@property (readonly) VOISegment *s0;
@property (readonly) VOISegment *s1;
@property (readonly) VOISegment *s2;

// Medians are numbered as their point of origin
@property (readonly) VOISegment *m0;
@property (readonly) VOISegment *m1;
@property (readonly) VOISegment *m2;

// must be 3 points
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithPoints:(const VOIPoint *)points standardize:(BOOL)standardize NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPoints:(const VOIPoint *)points;
- (BOOL)isEqualToTriangle:(VOITriangle *)other;
// Will check standardized versions of both
- (BOOL)isEquivalentToTriangle:(VOITriangle *)other;

- (NSComparisonResult)compare:(VOITriangle *)other;

// any index will do - uses %3
- (VOIPoint)pointAt:(NSUInteger)index;
- (double)angleAt:(NSUInteger)index;

- (VOISegment *)segmentAt:(NSUInteger)index;
- (NSUInteger)indexForSegment:(VOISegment *)segment;

// compare two triangles to see if they are adjacent, returning details
- (double)lengthOfSegmentAt:(NSUInteger)index;
- (double)squareLengthOfSegmentAt:(NSUInteger)index;
- (VOISegment *)segmentInCommonWith:(VOITriangle *)other indices:(NSUInteger[2])indices;

- (VOISegment *)medianAt:(NSUInteger)index;

// Switches handedness by changing point ordering
- (VOITriangle *)reverseOrder;
// returns possibly new triangle with points in standard order
- (VOITriangle *)standardize;

@end
