//
//  VOIPoint.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-12.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//


#define VOI_EPSILON (2 * DBL_EPSILON)

extern const double VOIEpsilon;
extern const double VOIPi;

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

static inline NSComparisonResult VOIComparePoints(VOIPoint a, VOIPoint b) {
    if (fabs(a.x - b.x) < DBL_EPSILON) {
        if (fabs(a.y - b.y) < DBL_EPSILON) {
            return NSOrderedSame;
        }
        return (a.y < b.y) ? NSOrderedAscending : NSOrderedDescending;
    }
    return (a.x < b.x) ? NSOrderedAscending : NSOrderedDescending;
}

NS_INLINE long long VOIRandomLongLong() {
    return (((long long)random() << 32) | (long long)random());
}

NS_INLINE double VOIRandomDouble() {
    return ((double)VOIRandomLongLong()/(double)LLONG_MAX);
}

NS_INLINE double VOIRandomDoubleBetween(double min, double max) {
    return VOIRandomDouble() * fabs(min - max) + MIN(min, max);
}

NS_INLINE VOIPoint VOIRandomPointBetween(VOIPoint min, VOIPoint max) {
    return vector2(
                   VOIRandomDoubleBetween(min.x, max.x),
                   VOIRandomDoubleBetween(min.y, max.y)
                   );
}

extern NSString *VOIPointToString(VOIPoint p);
extern VOIPoint VOIPointFromString(NSString *s);

extern VOIPoint VOICentrePoint(VOIPoint points[3]);
