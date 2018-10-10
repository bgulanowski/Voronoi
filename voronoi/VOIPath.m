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
#import "VOISegmentList.h"

@implementation VOIPath {
    BOOL _checkedConvex;
    BOOL _convex;
}

#pragma mark - Properties

- (NSUInteger)count {
    // number of segments is 1 less than points when path is open
    return [super count] - (_closed ? 0 : 1);
}

- (BOOL)isConvex {
    return (_checkedConvex && _convex) || [self calculateConvex];
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
    copy->_checkedConvex = _checkedConvex;
    copy->_convex = _convex;
    return copy;
}

#pragma mark - VOIPointList

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
    }
    return self;
}

- (instancetype)_initWithData:(NSMutableData *)data close:(BOOL)closed {
    self = [super _initWithData:data];
    if (self) {
        _closed = closed;
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
    }
    return path;
}

- (VOIPath *)openPath {
    VOIPath *path = self;
    if (_closed) {
        path = [self copy];
        path->_closed = NO;
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
    
    const NSUInteger count = self.count * 2;
    NSMutableData *data = [NSMutableData dataWithLength:count * sizeof(VOIPoint)];
    VOIPoint *points = data.mutableBytes;

    [self iteratePoints:^(const VOIPoint *p, const NSUInteger i) {
        points[i * 2] = *p;
        return NO;
    }];
    [self iteratePoints:^(const VOIPoint *p, const NSUInteger i) {
        points[(i * 2 + count - 1) % count] = *p;
        return NO;
    }];
    
    return [[VOISegmentList alloc] _initWithData:data];
}

- (VOIPath *)pathVisibleToPoint:(VOIPoint)point {
    NSAssert(self.convex, @"Cannot determine visibility set for non-convex path");
    
    return nil;
}

#pragma mark - Private

- (BOOL)calculateConvex {
    
    const NSUInteger pointCount = self.pointCount;
    if (_closed) {
        if (pointCount == 3) {
            _convex = YES;
        }
        else if (pointCount > 3) {
            const NSUInteger stop = pointCount - 3;
            __block VOITriangle *first = nil;
            __block BOOL convex = YES;
            [self iteratePoints:^(const VOIPoint *p, const NSUInteger i) {
                VOITriangle *t = [[VOITriangle alloc] initWithPoints:p];
                if (!t.degenerate) {
                    if (first == nil) {
                        first = t;
                    }
                    else {
                        if (first.rightHanded != t.rightHanded) {
                            convex = NO;
                            return YES;
                        }
                    }
                }
                return (BOOL)(i == stop);
            }];
            if (convex) {
                NSMutableIndexSet *indices = [NSMutableIndexSet indexSet];
                [indices addIndex:pointCount - 1];
                [indices addIndex:pointCount - 2];
                [indices addIndex:pointCount - 3];
                VOITriangle *last = [self triangleForIndexSet:indices];
                if (first.rightHanded != last.rightHanded) {
                    convex = NO;
                }
            }
            _convex = convex;
        }
    }
    else {
        _convex = NO;
    }
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
