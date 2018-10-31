//
//  VOIPointList.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIPointList.h"

#import "VOIBox.h"
#import "VOIRange.h"
#import "VOITriangle.h"

static VOIPointComparator length = ^(const VOIPoint *p0, const VOIPoint *p1) {
    double l0 = simd_length(*p0);
    double l1 = simd_length(*p1);
    if (l0 < l1) {
        return -1;
    }
    else if (l1 < l0) {
        return 1;
    }
    else {
        return 0;
    }
};

static VOIPointComparator distanceFrom(const VOIPoint p) {
    return ^(const VOIPoint *p0, const VOIPoint *p1) {
        double d0 = simd_distance_squared(*p0, p);
        double d1 = simd_distance_squared(*p1, p);
        if (d0 < d1) {
            return -1;
        }
        else if (d1 < d0) {
            return 1;
        }
        else {
            return 0;
        }
    };
}

@interface VOIPointList ()

- (instancetype)_initWithData:(NSMutableData *)data NS_DESIGNATED_INITIALIZER;

@property (nonatomic) VOIPoint *points;
@property (nonatomic) NSMutableData *pointsData;
@property (nonatomic) VOIBox *boundingBox;

@end

@implementation VOIPointList

#pragma mark - Properties

- (NSUInteger)pointCount {
    return _count;
}

- (VOIPoint)centre {
    return self.boundingBox.centre;
}

- (VOIBox *)boundingBox {
    return _boundingBox ?: [self calculateBoundingBox];
}

#pragma mark - NSObject

- (NSString *)description {
    // up to the first eight points and the count
    NSMutableArray *pointStrings = [NSMutableArray array];
    NSUInteger max = _count > 8 ? 8 : _count;
    for (NSUInteger i = 0; i < max; ++i) {
        VOIPoint p = _points[i];
        [pointStrings addObject:[NSString stringWithFormat:@"(%.2f, %.2f)", p.x, p.y]];
    }
    NSString *pointsString = [pointStrings componentsJoinedByString:@", "];
    return [NSString stringWithFormat:@"%@: points: [%@, ...] count: %td", self.className, pointsString, self.count];
}

- (BOOL)isEqual:(id)object {
    return (
            [object isKindOfClass:[VOIPointList class]] &&
            [self isEqualToPointList:object]
            );
}

- (instancetype)init {
    return [self initWithPoints:NULL count:0];
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] _initWithData:_pointsData];
}

#pragma mark - VOIPointList

- (instancetype)_initWithData:(NSMutableData *)data {
    self = [super init];
    if (self) {
        _pointsData = data;
        _points = _pointsData.mutableBytes;
        _count = _pointsData.length / sizeof(VOIPoint);
    }
    return self;
}

- (instancetype)initWithPoints:(const VOIPoint *)points count:(NSUInteger)count {
    NSMutableData *data = [[NSMutableData alloc] initWithBytes:points length:(count * sizeof(VOIPoint))];
    return [self _initWithData:data];
}

- (BOOL)isEqualToPointList:(VOIPointList *)other {
    return (
            other != nil &&
            [_pointsData isEqualToData:other->_pointsData] &&
            _count == other->_count
            );
}

- (VOIPoint)pointAtIndex:(NSUInteger)index {
    return _points[(index % _count)];
}

- (VOIPoint)pointClosestToPoint:(VOIPoint)p index:(NSUInteger *)pIndex ignoreIfEqual:(BOOL)ignore {
    __block NSUInteger index = NSNotFound;
    __block double best = (double)INFINITY;
    [self iteratePoints:^(const VOIPoint *q, const NSUInteger i) {
        if (!ignore || !VOIPointsEqual(p, *q)) {
            double d = simd_distance(*q, p);
            if (d < best) {
                best = d;
                index = i;
            }
        }
        return NO;
    }];
    if (pIndex) {
        *pIndex = index;
    }
    return _points[index];
}

- (VOIPoint)pointClosestToPoint:(VOIPoint)p index:(NSUInteger *)pIndex {
    return [self pointClosestToPoint:p index:pIndex ignoreIfEqual:YES];
}

- (NSUInteger)binarySearch:(VOIPointEvaluator)evaluator {
    
    NSUInteger min = 0, max = self.pointCount;
    NSUInteger index = (min + max) / 2;
    
    do {
        VOIPoint p = [self pointAtIndex:index];
        double newValue = evaluator(&p);
        if (newValue == 0) {
            break;
        }
        if (newValue < 0) {
            min = index;
        }
        else {
            max = index;
        }
        index = (min + max) / 2;
    } while (max - min > 1);
    
    return index;
}

- (instancetype)reverseList {
    NSMutableData *data = [NSMutableData dataWithLength:self.pointsData.length];
    VOIPoint *points = self.pointsData.mutableBytes;
    VOIPoint *reversePoints = data.mutableBytes;
    const NSUInteger count = self.pointCount;
    for (NSUInteger i = 0; i < count; ++i) {
        reversePoints[count - 1 - i] = points[i];
    }
    return [[[self class] alloc] _initWithData:data];
}

- (instancetype)add:(VOIPointList *)other {
    NSMutableData *copy = [_pointsData mutableCopy];
    [copy appendData:other.pointsData];
    return [[[self class] alloc] _initWithData:copy];
}

- (instancetype)selectRange:(NSRange)range {
    
    range.location %= _count;
    
    VOIPointList *result = [VOIPointList new];
    NSUInteger count = MIN(range.length, _count - range.location);
    
    while (count) {
        VOIPointList *next = [[[self class] alloc] initWithPoints:&_points[range.location] count:count];
        result = [result add:next];
        range.location = 0;
        range.length -= count;
        count = MIN(range.length, _count);
    }
    
    return result;
}

- (instancetype)deleteRange:(NSRange)range {
    NSRange a = NSMakeRange(0, range.location);
    NSUInteger end = NSMaxRange(range);
    NSRange b = NSMakeRange(end, _count - end);
    return [[self selectRange:a] add:[self selectRange:b]];
}

- (instancetype)deleteIndex:(NSUInteger)index {
    return [self deleteRange:NSMakeRange(index, 1)];
}

- (instancetype)deleteIndices:(NSIndexSet *)indexSet {

    NSMutableData *data = [[NSMutableData alloc]  initWithLength:(_count - indexSet.count) * sizeof(VOIPoint)];
    VOIPoint *points = data.mutableBytes;
    NSUInteger di = 0;
    
    for (NSUInteger i = 0; i < _count; ++i) {
        if (![indexSet containsIndex:i]) {
            points[di++] = _points[i];
        }
    }
    
    return [[[self class] alloc] _initWithData:data];
}

- (instancetype)tail {
    return [self selectRange:NSMakeRange(1, _count - 1)];
}

- (instancetype)substitutePoint:(VOIPoint)point atIndex:(NSUInteger)index {
    NSMutableData *data = [self.pointsData mutableCopy];
    VOIPoint *points = data.mutableBytes;
    points[index] = point;
    return [[[self class] alloc] _initWithData:data];
}

- (instancetype)substitutePoints:(VOIPointList *)points inRange:(NSRange)range {
    NSMutableData *data = [_pointsData mutableCopy];
    NSRange bytesRange = NSMakeRange(range.location * sizeof(VOIPoint), range.length * sizeof(VOIPoint));
    [data substitute:points.pointsData inRange:bytesRange];
    return [[[self class] alloc] _initWithData:data];
}

- (VOIPointList *)sortedPointList:(VOIPointComparator)comparator {
    NSMutableData *data = [_pointsData mutableCopy];
    qsort_b(data.mutableBytes, _count, sizeof(VOIPoint), [comparator copy]);
    return [[[self class] alloc] _initWithData:data];
}

- (instancetype)sortedByLength {
    return [self sortedPointList:[length copy]];
}

- (instancetype)sortedByDistanceFrom:(VOIPoint)p {
    return [self sortedPointList:distanceFrom(p)];
}

- (void)iteratePoints:(VOIPointIterator)iterator {
    for (NSUInteger i = 0; i < _count; ++i) {
        if (iterator(&_points[i], i)) {
            break;
        }
    }
}

- (VOITriangle *)triangleForIndices:(NSUInteger[3])indices {
    VOIPoint points[3] = {
        _points[indices[0]],
        _points[indices[1]],
        _points[indices[2]]
    };
    return [[VOITriangle alloc] initWithPoints:points];
}

- (VOITriangle *)triangleForIndexSet:(NSIndexSet *)indexSet {
    NSUInteger indices[3];
    [indexSet getIndexes:indices maxCount:3 inIndexRange:NULL];
    return [self triangleForIndices:indices];
}

- (NSString *)tabDelimitedString {
    NSMutableArray *lines = [NSMutableArray array];
    [self iteratePoints:^(const VOIPoint *p, const NSUInteger i) {
        [lines addObject:[NSString stringWithFormat:@"%.2f\t%.2f", p->x, p->y]];
        return NO;
    }];
    [lines addObject:@""];
    return [lines componentsJoinedByString:@"\n"];
}

#pragma mark - Private

- (VOIBox *)calculateBoundingBox {
    
    double Inf = (double)INFINITY;
    __block VOIPoint ll = vector2(Inf, Inf);
    __block VOIPoint ur = vector2(-Inf, -Inf);
    
    [self iteratePoints:^(const VOIPoint *p, const NSUInteger i) {
        VOIPoint point = *p;
        ll.x = MIN(ll.x, point.x);
        ll.y = MIN(ll.y, point.y);
        ur.x = MAX(ur.x, point.x);
        ur.y = MAX(ur.y, point.y);
        return NO;
    }];
    
    VOIPoint origin = ll;
    VOISize size = ur - ll;
    _boundingBox = [[VOIBox alloc] initWithOrigin:origin size:size];
    
    return _boundingBox;
}

@end
