//
//  VOIPath.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIPath.h"

#import "VOIPointListPrivate.h"
#import "VOISegment.h"

@implementation VOIPath {
    BOOL _checkedConvex;
    BOOL _convex;
}

@synthesize boundingBox=_boundingBox;

#pragma mark - Properties

- (NSUInteger)count {
    // number of segments is 1 less than points when path is open
    return [super count] - (_closed ? 0 : 1);
}

- (NSUInteger)segmentCount {
    return self.count;
}

- (NSUInteger)triangleCount {
    if (self.pointCount == 3) {
        return 1;
    }
    else {
        return self.pointCount - (_closed ? 0 : 2);
    }
}

- (BOOL)isConvex {
    return _convex || (!_checkedConvex && [self calculateConvex]);
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    return (
            [object isKindOfClass:[self class]] &&
            [self isEqualToPath:object]
            );
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    VOIPath *copy = [super copyWithZone:zone];
    copy->_closed = _closed;
    return copy;
}

#pragma mark - VOIPointList

- (instancetype)_initWithData:(NSMutableData *)data {
    return [self _initWithData:data close:NO];
}

- (instancetype)initWithPoints:(const VOIPoint *)points count:(NSUInteger)count {
    return [self initWithPoints:points count:count close:NO];
}

- (instancetype)reverseList {
    VOIPath *path = (VOIPath *)[super reverseList];
    path->_checkedConvex = _checkedConvex;
    path->_convex = _convex;
    path->_closed = _closed;
    return path;
}

- (instancetype)substitutePoints:(VOIPointList *)points inRange:(NSRange)range {
    VOIPath *path = (VOIPath *)[super substitutePoints:points inRange:range];
    path->_closed = _closed;
    path->_convex = _convex;
    path->_checkedConvex = _checkedConvex;
    return path;
}

#pragma mark - VOIPath

- (instancetype)initWithPoints:(const VOIPoint *)points count:(NSUInteger)count close:(BOOL)closed {
    self = [super initWithPoints:points count:count];
    if (self) {
        _closed = closed;
        [self quickCheckConvex];
    }
    return self;
}

- (instancetype)_initWithData:(NSMutableData *)data close:(BOOL)closed {
    self = [super _initWithData:data];
    if (self) {
        _closed = closed;
        [self quickCheckConvex];
    }
    return self;
}

- (BOOL)isEqualToPath:(VOIPath *)path {
    return (
            [super isEqualToPointList:path] &&
            _closed == path->_closed
            );
}

- (VOIPath *)closedPath {
    VOIPath *path = self;
    if (!_closed) {
        path = [self copy];
        path->_closed = YES;
        [path quickCheckConvex];
    }
    return path;
}

- (VOIPath *)openPath {
    VOIPath *path = self;
    if (_closed) {
        path = [self copy];
        path->_closed = NO;
        path->_convex = NO;
        path->_checkedConvex = YES;
    }
    return path;
}

#pragma mark - Segments

- (VOISegment *)segmentAt:(NSUInteger)index {
    const NSUInteger count = self.count;
    VOIPoint points[2];
    points[0] = [self pointAtIndex:index % count];
    points[1] = [self pointAtIndex:(index + 1) % count];
    return [[VOISegment alloc] initWithPoints:points];
}

- (VOISegment *)closestSegmentToPoint:(VOIPoint)point index:(NSUInteger *)pIndex {
    const NSUInteger count = self.count;
    NSUInteger index;
    [self pointClosestToPoint:point index:&index];
    
    VOISegment *s0 = [self segmentAt:index + count - 1];
    VOISegment *s1 = [self segmentAt:index];
    
    // Which segment is right?
    VOILineSide side0 = [s0 sideForPoint:point];
    VOILineSide side1 = [s1 sideForPoint:point];
    
    VOISegment *result = nil;
    if (side0 == side1) {
        // choose the closest by midpoint
        double d0 = [s0 distanceSquaredFromPoint:point];
        double d1 = [s1 distanceSquaredFromPoint:point];
        if (d0 < d1) {
            result = s0;
            --index;
        }
        else {
            result = s1;
        }
    }
    else {
        // if s0.a is on the same side of s1 as point, then it's s0. otherwise, s1.
        if ([s1 sideForPoint:s0.a] == side1) {
            result = s0;
            --index;
        }
        else {
            result = s1;
        }
    }
    
    if(pIndex) {
        *pIndex = (index + count) % count;
    }
    return result;
}

- (void)iterateSegments:(VOISegmentIterator)iterator {
    const NSUInteger last = self.pointCount - 1;
    [self iteratePoints:^(const VOIPoint *points, const NSUInteger i) {
        return (BOOL)(i == last || iterator([[VOISegment alloc] initWithPoints:points], i));
    }];
    if (self.closed) {
        iterator([self segmentAt:last], last);
    }
}

- (NSArray<VOISegment *> *)allSegments {
    NSMutableArray *array = [NSMutableArray array];
    [self iterateSegments:^BOOL(VOISegment *s, NSUInteger i) {
        [array addObject:s];
        return NO;
    }];
    return array;
}

- (VOISegmentList *)asSegmentList {
    
    // Creating segments requires doubling the number of points
    
    const NSUInteger count = [self segmentCount] * 2;
    NSMutableData *data = [NSMutableData dataWithLength:count * sizeof(VOIPoint)];
    VOIPoint *points = data.mutableBytes;

    [self iteratePoints:^(const VOIPoint *p, const NSUInteger i) {
        points[i * 2] = *p;
        return NO;
    }];
    // offset by (count - 1) (value must be positive before remainder operation)
    [self iteratePoints:^(const VOIPoint *p, const NSUInteger i) {
        points[(i * 2 + count - 1) % count] = *p;
        return NO;
    }];
    
    return [[VOISegmentList alloc] _initWithData:data];
}

#pragma mark - Triangles

- (VOITriangle *)triangleAt:(NSUInteger)index {
    const NSUInteger count = self.pointCount;
    NSUInteger indices[3] = {
        index % count,
        (index + 1) % count,
        (index + 2) % count
    };
    return [self triangleForIndices:indices];
}

- (void)iterateTriangles:(VOITriangleIterator)iterator {
    const NSUInteger count = self.triangleCount;
    for (NSUInteger i = 0; i < count; ++i) {
        if (iterator([self triangleAt:i], i)) {
            break;
        }
    }
}

- (NSArray<VOITriangle *> *)allTriangles {
    NSMutableArray *triangles = [NSMutableArray array];
    [self iterateTriangles:^(VOITriangle *t, NSUInteger i) {
        [triangles addObject:t];
        return NO;
    }];
    return triangles;
}

- (VOITriangleList *)triangleFanWithCentre:(VOIPoint)point range:(NSRange)range {
    NSUInteger triCount = range.length;
    NSMutableData *data = [NSMutableData dataWithLength:sizeof(VOIPoint) * triCount * 3];
    VOIPoint *points = data.mutableBytes;
    for (NSUInteger i = 0; i < triCount; ++i) {
        points[i * 3] = [self pointAtIndex:range.location + i];
        points[i * 3 + 1] = point;
        points[i * 3 + 2] = [self pointAtIndex:range.location + i + 1];
    }
    return [[VOITriangleList alloc] _initWithData:data];
}

#pragma mark - Points

- (BOOL)pointInside:(VOIPoint)point {
    if (!_closed) {
        return NO;
    }
    __block NSUInteger count = 0;
    // Calculate the winding number by counting the number of times
    // segments cross a horizontal line through provided point
    // 0 means outside, otherwise inside.
    [self iterateSegments:^BOOL(VOISegment *s, NSUInteger i) {
        VOIVerticalPosition pos = [s verticalPosition:point.y];
        VOILineSide side = [s sideForPoint:point];
        if (pos == VOIUpward && side == VOILineSideLeft) {
            count++;
        }
        else if(pos == VOIDownward && side == VOILineSideRight) {
            count--;
        }
        return NO;
    }];
    return count != 0;
}

- (NSRange)rangeVisibleToPoint:(VOIPoint)point closestSegmentIndex:(NSUInteger *)pIndex {
    if (!_closed || [self pointInside:point]) {
        return NSMakeRange(0, 0);
    }
    
    // point must be on the same side of all segments
    // find start and end indices
    NSUInteger closest;
    VOISegment *segment = [self closestSegmentToPoint:point index:&closest];

    closest += self.count; // see if this fixes range weirdness
    NSUInteger first = closest;
    VOILineSide side = [segment sideForPoint:point];
    segment = [self segmentAt:first - 1];
    while ([segment sideForPoint:point] == side) {
        first--;
        segment = [self segmentAt:first - 1];
    }
    
    NSUInteger last = closest;
    segment = [self segmentAt:last + 1];
    while([segment sideForPoint: point] == side) {
        last++;
        segment = [self segmentAt:last + 1];
    }
    
    if (pIndex) {
        *pIndex = closest;
    }
    
    return NSMakeRange(first % self.count, last - first + 1);
}

- (VOIPath *)pathVisibleToPoint:(VOIPoint)point closestSegmentIndex:(NSUInteger *)pIndex {
    NSRange range = [self rangeVisibleToPoint:point closestSegmentIndex:pIndex];
    return range.length > 0 ? [[self selectRange:range] asPath] : nil;
}

- (VOIPath *)substitutePoint:(VOIPoint)point forSegmentsInRange:(NSRange)range {
    VOIPointList *list = [[VOIPointList alloc] initWithPoints:&point count:1];
    NSRange pointRange = NSMakeRange((range.location + 1) % self.count, range.length - 1);
    return [self substitutePoints:list inRange:pointRange];
}

- (VOIPath *)convexHullByAddingPoint:(VOIPoint)point triangles:(VOITriangleList **)pTriangles affectedPoint:(NSUInteger *)index {
    if (!self.convex) {
        return nil;
    }
    
    NSRange range = [self rangeVisibleToPoint:point closestSegmentIndex:NULL];
    if (pTriangles) {
        *pTriangles = [self triangleFanWithCentre:point range:range];
    }
    if (index) {
        *index = range.location;
    }
    return [self substitutePoint:point forSegmentsInRange:range];
}

#pragma mark - Private

- (void)quickCheckConvex {
    if (!_closed || self.count < 3) {
        _convex = NO;
        _checkedConvex = YES;
    }
    else if (self.count == 3) {
        _convex = YES;
        _checkedConvex = YES;
    }
    else {
        _convex = NO;
        _checkedConvex = NO;
    }
}

- (BOOL)calculateConvex {

    _convex = YES;
    
    __block VOITriangle *valid = nil;
    [self iterateTriangles:^BOOL(VOITriangle *t, NSUInteger i) {
        if(!t.degenerate) {
            if (valid == nil) {
                valid = t;
            }
            else {
                self->_convex = valid.rightHanded == t.rightHanded;
            }
        }
        return !self->_convex;
    }];

    _checkedConvex = YES;
    return _convex;
}

@end

@implementation VOIPointList (VOIPath)

- (VOIPath *)asPath {
    return [[VOIPath alloc] _initWithData:self.pointsData];
}

- (VOIPath *)asClosedPath {
    return [[VOIPath alloc] _initWithData:self.pointsData close:YES];
}

@end

@implementation VOITriangle (VOIPath)

- (instancetype)initWithPath:(VOIPath *)path {
    VOIPoint points[3];
    for (NSUInteger i = 0; i < 3; ++i) {
        points[i] = [path pointAtIndex:i];
    }
    return [self initWithPoints:points];
}

- (VOIPath *)asPath {
    VOIPoint points[3] = {
         self.p0,
         self.p1,
         self.p2
    };
    return [[VOIPath alloc] initWithPoints:points count:3 close:YES];
}

@end

@implementation VOIBox (VOIPath)

- (VOIPath *)asPath {
    return [[self asPointList] asClosedPath];
}

@end
