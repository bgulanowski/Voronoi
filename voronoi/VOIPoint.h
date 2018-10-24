//
//  VOIPoint.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-12.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//


#define VOI_EPSILON (DBL_EPSILON)

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

NS_INLINE BOOL VOIDoublesEqual(double a, double b) {
    int _ae, _ab;
    a = frexp(a, &_ae);
    b = frexp(b, &_ab);
    return _ae == _ab && fabs(a - b) <= VOIEpsilon;
}

NS_INLINE NSComparisonResult VOICompareDoubles(double a, double b) {
    return VOIDoublesEqual(a, b) ? NSOrderedSame : (a < b ? NSOrderedAscending : NSOrderedDescending);
}

NS_INLINE BOOL VOIPointsEqual(VOIPoint a, VOIPoint b) {
    return VOIDoublesEqual(a.x, b.x) && VOIDoublesEqual(a.y, b.y);
}

NS_INLINE NSComparisonResult VOIComparePoints(VOIPoint a, VOIPoint b) {
    NSComparisonResult cr = VOICompareDoubles(a.x, b.x);
    return cr ?: VOICompareDoubles(a.y, b.y);
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
