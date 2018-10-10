//
//  VOITriangle.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VOI_EPSILON (2 * DBL_EPSILON)

typedef vector_double2 VOIPoint;

typedef struct {
    VOIPoint p0;
    VOIPoint p1;
} VOIPointPair;

typedef union {
    VOIPointPair pair;
    VOIPoint points[2];
} VOIPoints2;

typedef struct {
    VOIPoint p0;
    VOIPoint p1;
    VOIPoint p2;
} VOIPointTriple;

typedef union {
    VOIPointTriple triple;
    VOIPoint points[3];
} VOIPoints3;

NS_INLINE BOOL VOIPointsEqual(VOIPoint a, VOIPoint b) {
    return ABS(a.x - b.x) < VOI_EPSILON && ABS(a.y - b.y) < VOI_EPSILON;
}

extern VOIPoint VOICentrePoint(VOIPoint points[3]);

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

// any index will do - uses %3
- (VOIPoint)pointAt:(NSUInteger)index;

- (VOITriangle *)reorder;
- (VOITriangle *)standardize;

@end
