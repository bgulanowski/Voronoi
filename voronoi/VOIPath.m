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

- (instancetype)initWithPoints:(const VOIPoint *)points count:(NSUInteger)count {
    return [self initWithPoints:points count:count close:NO];
}

- (VOIPointList *)reverseList {
    VOIPath *path = (VOIPath *)[super reverseList];
    path->_checkedConvex = _checkedConvex;
    path->_convex = _convex;
    path->_closed = _closed;
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

- (VOISegment *)segmentAt:(NSUInteger)index {
    const NSUInteger count = self.count;
    VOIPoint points[2];
    points[0] = [self pointAtIndex:index % count];
    points[1] = [self pointAtIndex:(index + 1) % count];
    return [[VOISegment alloc] initWithPoints:points];
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

- (VOITriangle *)triangleAt:(NSUInteger)index {
    const NSUInteger count = self.triangleCount;
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

- (VOITriangleList *)asTriangleList {
    
    const NSUInteger count = [self triangleCount];
    NSMutableData *data;
    
    if (count == 1) {
        data = self.pointsData;
    }
    else {
        data = [NSMutableData dataWithLength:count * 3];
        VOIPoint *points = data.mutableBytes;
        const BOOL closed = _closed;
        for (NSUInteger j = 0; j < 3; ++j) {
            [self iteratePoints:^(const VOIPoint *p, const NSUInteger i) {
                if (!closed || i > j) {
                    points[(i * 3 + count - j) % count] = *p;
                }
                return (BOOL)(i == count - 1);
            }];
        }
    }
    
    return [[VOITriangleList alloc] _initWithData:data];
}

- (NSArray<VOITriangle *> *)allTriangles {
    NSMutableArray *triangles = [NSMutableArray array];
    [self iterateTriangles:^(VOITriangle *t, NSUInteger i) {
        [triangles addObject:t];
        return NO;
    }];
    return triangles;
}

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

- (VOIPath *)pathVisibleToPoint:(VOIPoint)point {
    NSAssert(self.convex, @"Cannot determine visibility set for non-convex path");
    
    return nil;
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
