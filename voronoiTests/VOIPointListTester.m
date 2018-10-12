//
//  VOIPointListTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOIBox.h"
#import "VOIPointList.h"
#import "VOIPointListPrivate.h"
#import "VOITriangle.h"

@interface VOIPointListTester : XCTestCase

@property VOIPointList *pointList;

@end

static VOIPoint points[4];

@implementation VOIPointListTester

+ (void)setUp {
    points[0] = vector2(3.0, 0.0);
    points[1] = vector2(1.0, 0.5);
    points[2] = vector2(0.0, 4.0);
    points[3] = vector2(0.5, 2.0);
}

- (void)setUp {
    [super setUp];
    _pointList = [[VOIPointList alloc] initWithPoints:points count:4];
}

- (void)testIsEqualClass {
    XCTAssertFalse([self.pointList isEqual:@0]);
}

- (void)testIsEqualNil {
    XCTAssertFalse([self.pointList isEqual:nil]);
}

- (void)testCount {
    XCTAssertEqual((NSUInteger)4, _pointList.count);
}

- (void)testPointCount {
    XCTAssertEqual((NSUInteger)4, _pointList.pointCount);
}

- (void)testBoundingBox {
    VOIBox *e = [[VOIBox alloc] initWithOrigin:vector2(0.0, 0.0) size:vector2(3.0, 4.0)];
    VOIBox *a = [self.pointList boundingBox];
    XCTAssertEqualObjects(e, a);
}

- (void)testDescription {
    NSString *e = @"VOIPointList: points: [(3.00, 0.00), (1.00, 0.50), (0.00, 4.00), (0.50, 2.00), ...] count: 4";
    NSString *a = [_pointList description];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointAtIndex {
    for (NSUInteger i = 0; i < 4; ++i) {
        VOIPoint e = points[i];
        VOIPoint a = [_pointList pointAtIndex:i];
        AssertEqualPoints(e, a);
    }
}

- (void)testPointClosestToPoint {
    NSUInteger index = NSNotFound;
    VOIPoint e = points[2];
    VOIPoint a = [self.pointList pointClosestToPoint:vector2(-1.0, 4.0) index:&index];
    AssertEqualPoints(e, a);
    XCTAssertEqual(2, index);
}

- (void)testBinarySearch {
    NSMutableData *data = [NSMutableData dataWithLength:sizeof(VOIPoint) * 100];
    VOIBox *box = [[VOIBox alloc] initWithOrigin:vector2(-50.0, -50.0) size:vector2(100.0, 100.0)];
    VOIPoint *pPoints = data.mutableBytes;
    srandom(88);
    for (NSUInteger i = 0; i < 100; ++i) {
        pPoints[i] = [box randomPoint];
    }
    VOIPointList *list = [[[VOIPointList alloc] _initWithData:data] sortedPointList:^int(const VOIPoint *a, const VOIPoint *b) {
        if (a->y < b->y) { return -1; }
        if (a->y > b->y) { return 1; }
        return 0;
    }];
    
    VOIPoint e = pPoints[71];
    NSUInteger index = [list binarySearch:^(VOIPoint *p) {
        return p->y - e.y;
    }];
    VOIPoint a = [list pointAtIndex:index];
    
    AssertEqualPoints(e, a);
}

- (void)testReverseList {
    VOIPoint reverse[4] = {
        points[3],
        points[2],
        points[1],
        points[0]
    };
    VOIPointList *e = [[VOIPointList alloc] initWithPoints:reverse count:4];
    VOIPointList *a = [self.pointList reverseList];
    XCTAssertEqualObjects(e, a);
}

- (void)testAdd {
    VOIPointList *a = [[VOIPointList alloc] initWithPoints:points count:2];
    VOIPointList *b = [[VOIPointList alloc] initWithPoints:&points[2] count:2];
    a = [a add:b];
    VOIPointList *e = self.pointList;
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListWithRangeEmpty {
    VOIPointList *a = [self.pointList pointListWithRange:NSMakeRange(0, 0)];
    VOIPointList *e = [VOIPointList new];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListWithRangeAll {
    VOIPointList *e = self.pointList;
    VOIPointList *a = [self.pointList pointListWithRange:NSMakeRange(0, _pointList.count)];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListWithRangeInsetStart {
    VOIPointList *e = [[VOIPointList alloc] initWithPoints:&points[2] count:2];
    VOIPointList *a = [self.pointList pointListWithRange:NSMakeRange(2, 2)];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListWithRangeShort {
    VOIPointList *e = [[VOIPointList alloc] initWithPoints:points count:2];
    VOIPointList *a = [self.pointList pointListWithRange:NSMakeRange(0, 2)];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListWithRangeInsetBothEnds {
    VOIPointList *e = [[VOIPointList alloc] initWithPoints:&points[1] count:2];
    VOIPointList *a = [self.pointList pointListWithRange:NSMakeRange(1, 2)];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListWithRangeExtended {
    
    const NSUInteger Location = 2;
    const NSUInteger Length = 10;
    NSRange range = NSMakeRange(Location, Length);
    
    VOIPoint repeating[Length];
    for (NSUInteger i = 0; i < Length; ++i) {
        repeating[i] = points[(i + Location) % 4];
    }
    
    VOIPointList *e = [[VOIPointList alloc] initWithPoints:repeating count:10];
    VOIPointList *a = [self.pointList pointListWithRange:range];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListWithRangeLocationBeyondEnd {
    VOIPointList *e = [[VOIPointList alloc] initWithPoints:&points[1] count:3];
    VOIPointList *a = [self.pointList pointListWithRange:NSMakeRange(5, 3)];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListByDeletingRange {
    VOIPoint p[2] = { points[0], points[3] };
    VOIPointList *e = [[VOIPointList alloc]  initWithPoints:p count:2];
    VOIPointList *a = [self.pointList pointListByDeletingRange:NSMakeRange(1, 2)];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListByDeletingPointAtIndex {
    VOIPointList *e = [[VOIPointList alloc] initWithPoints:&points[1] count:3];
    VOIPointList *a = [self.pointList pointListByDeletingPointAtIndex:0];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListByDeletingPointsAtIndices {
    NSMutableIndexSet *indices = [NSMutableIndexSet indexSet];
    [indices addIndex:0];
    [indices addIndex:3];
    VOIPointList *list = [self.pointList pointListByDeletingPointsAtIndices:indices];
    XCTAssertEqual(list.count, (NSUInteger)2);
    AssertEqualPoints(points[1], [list pointAtIndex:0]);
    AssertEqualPoints(points[2], [list pointAtIndex:1]);
}

- (void)testSortedByLength {
    
    VOIPoint sorted[] = {
        points[1],
        points[3],
        points[0],
        points[2]
    };
    
    VOIPointList *e = [[VOIPointList alloc] initWithPoints:sorted count:4];
    VOIPointList *a = [_pointList sortedByLength];
    
    XCTAssertEqualObjects(e, a);
}

- (void)testSortedByDistance {
    VOIPoint from = vector2(1.0, 1.0);
    VOIPoint sorted[] = {
        points[1],
        points[3],
        points[0],
        points[2]
    };
    
    VOIPointList *e = [[VOIPointList alloc] initWithPoints:sorted count:4];
    VOIPointList *a = [_pointList sortedByDistanceFrom:from];
    
    XCTAssertEqualObjects(e, a);
}

- (void)testTriangleForIndices {
    NSUInteger indices[3] = { 3, 2, 1 };
    VOIPoint vertices[3] = {
        points[indices[0]],
        points[indices[1]],
        points[indices[2]]
    };
    VOITriangle *e = [[VOITriangle alloc] initWithPoints:vertices];
    VOITriangle *a = [self.pointList triangleForIndices:indices];
    
    XCTAssertEqualObjects(e, a);
}

- (void)testTriangleForIndexSet {
    NSUInteger indices[3] = { 3, 2, 1 };
    VOIPoint vertices[3] = {
        points[indices[0]],
        points[indices[1]],
        points[indices[2]]
    };
    VOITriangle *e = [[[VOITriangle alloc] initWithPoints:vertices] standardize];
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    [indexSet addIndex:indices[0]];
    [indexSet addIndex:indices[1]];
    [indexSet addIndex:indices[2]];
    VOITriangle *a = [[self.pointList triangleForIndexSet:indexSet] standardize];
    
    XCTAssertEqualObjects(e, a);
}

@end
