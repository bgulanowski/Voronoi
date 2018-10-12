//
//  VOIPoint.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-12.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//


#define VOI_EPSILON (2 * DBL_EPSILON)

typedef vector_double2 VOIPoint;

typedef vector_double2 VOISize;

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

extern NSString *VOIPointToString(VOIPoint p);
extern VOIPoint VOIPointFromString(NSString *s);

extern VOIPoint VOICentrePoint(VOIPoint points[3]);
