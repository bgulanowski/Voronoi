//
//  VOISegmentTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-05.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOIBox.h"
#import "VOISegment.h"

@interface VOISegmentTester : XCTestCase

@property (nonatomic) VOISegment *s1;
@property (nonatomic) VOISegment *s2;

@end

@implementation VOISegmentTester

- (void)setUp {
    [super setUp];
    VOIPoint points[4] = {
        vector2(0.0, 0.0),
        vector2(2.0, 2.0),
        vector2(4.0, 0.0)
    };
    _s1 = [[VOISegment alloc] initWithPoints:points];
    _s2 = [[VOISegment alloc] initWithPoints:&points[1]];
}

- (void)testMidpoint {
    VOIPoint e = vector2(1.0, 1.0);
    VOIPoint a = self.s1.midpoint;
    AssertEqualPoints(e, a);
}

- (void)testBoundingBox {
    VOIBox *e = [[VOIBox alloc] initWithOrigin:vector2(0.0, 0.0) size:vector2(2.0, 2.0)];
    VOIBox *a = self.s1.boundingBox;
    XCTAssertEqualObjects(e, a);
}

- (void)testDescription {
    NSString *e = @"VOISegment: [(0.00, 0.00) -> (2.00, 2.00)]";
    NSString *a = self.s1.description;
    XCTAssertEqualObjects(e, a);
}

- (void)testInit {
    VOISegment *e = [[VOISegment alloc] initWithPoint:vector2(0.0, 0.0) otherPoint:vector2(0.0, 0.0)];
    VOISegment *a = [[VOISegment alloc] init];
    XCTAssertEqualObjects(e, a);
}

- (void)testEquivalentToSegment {
    XCTAssertFalse([self.s1 isEquivalentToSegment:self.s2]);
    XCTAssertTrue([self.s1 isEquivalentToSegment:self.s1]);
    VOISegment *s = [[VOISegment alloc] initWithPoint:self.s1.b otherPoint:self.s1.a];
    XCTAssertTrue([self.s1 isEquivalentToSegment:s]);
}

- (void)testPerpendicular {
    VOIPoint points[4] = {
        vector2(1.0, 1.0),
        vector2(3.0, -1.0),
        vector2(3.0, 1.0),
        vector2(1.0, -1.0)
    };
    VOISegment *e = [[VOISegment alloc] initWithPoints:points];
    VOISegment *a = [_s1 perpendicular];
    XCTAssertEqualObjects(e, a);
    
    e = [[VOISegment alloc] initWithPoints:&points[2]];
    a = [_s2 perpendicular];
    XCTAssertEqualObjects(e, a);
}

- (void)testIntersection90 {
    VOISegment *p1 = [_s1 perpendicular];
    VOISegment *p2 = [_s2 perpendicular];
    VOIPoint e = vector2(2.0, 0.0);
    VOIPoint a = [p1 intersectWithSegment:p2];
    XCTAssertTrue(simd_equal(e, a));
}

- (void)testIntersection120 {
    VOIPoint points[3] = {
        vector2(-1.0, 2.0),
        vector2(-3.0, 2.0),
        vector2(-4.0, 2.0 + sqrt(3.0))
    };
    _s1 = [[VOISegment alloc] initWithPoints:points];
    _s2 = [[VOISegment alloc] initWithPoints:&points[1]];
    
    VOISegment *p1 = [_s1 perpendicular];
    VOISegment *p2 = [_s2 perpendicular];
    VOIPoint e = vector2(-2.0, 2.0 + sqrt(3.0));
    VOIPoint a = [p1 intersectWithSegment:p2];
    
    const double Tolerance = 2.0 * DBL_EPSILON;
    
    XCTAssertLessThanOrEqual(ABS(a.x - e.x), Tolerance);
    XCTAssertLessThanOrEqual(ABS(a.y - e.y), Tolerance);
}

- (void)testIntersectionParallel {
    VOISegment *p = [_s1 perpendicular];
    VOIPoint e = vector2((double)INFINITY, (double)INFINITY);
    VOIPoint a = [p intersectWithSegment:p];
    XCTAssertEqual(a.x, e.x);
    XCTAssertEqual(a.y, e.y);
}

- (void)testSideForPoint {
    VOIPoint p = vector2(1.0, 2.0);
    XCTAssertEqual(VOILineSideLeft, [self.s1 sideForPoint:p]);
    XCTAssertEqual(VOILineSideRight, [self.s2 sideForPoint:p]);
    p = vector2(3.0, 2.0);
    XCTAssertEqual(VOILineSideRight, [self.s1 sideForPoint:p]);
    XCTAssertEqual(VOILineSideLeft, [self.s2 sideForPoint:p]);
    p = vector2(1.0, 1.0);
    XCTAssertEqual(VOILineSideOn, [self.s1 sideForPoint:p]);
    p = vector2(3.0, 1.0);
    XCTAssertEqual(VOILineSideOn, [self.s2 sideForPoint:p]);
}

- (void)testDistanceFromPoint {
    
    VOIPoint m = (self.s1.b - self.s1.a) / 2.0;
    VOISize v = m - self.s2.b;
    
    double e = v.x * v.x + v.y * v.y;
    double a = [self.s1 distanceSquaredFromPoint:self.s2.b];
    
    XCTAssertEqual(e, a);
    
    e = sqrt(e);
    a = [self.s1 distanceFromPoint:self.s2.b];

    XCTAssertEqual(e, a);
}

- (void)testVerticalPosition {
    XCTAssertEqual(VOIUpward, [self.s1 verticalPosition:2.0]);
    XCTAssertEqual(VOIDownward, [self.s2 verticalPosition:2.0]);
    XCTAssertEqual(VOIUpward, [self.s1 verticalPosition:0.0]);
    XCTAssertEqual(VOIDownward, [self.s2 verticalPosition:0.0]);
    XCTAssertEqual(VOIUpward, [self.s1 verticalPosition:1.0]);
    XCTAssertEqual(VOIDownward, [self.s2 verticalPosition:1.0]);
    XCTAssertEqual(VOIAbove, [self.s1 verticalPosition:-1.0]);
    XCTAssertEqual(VOIAbove, [self.s2 verticalPosition:-1.0]);
    XCTAssertEqual(VOIBelow, [self.s1 verticalPosition:3.0]);
    XCTAssertEqual(VOIBelow, [self.s2 verticalPosition:3.0]);

    VOIPoint horiz[2] = { vector2(0.0, 0.0), vector2(2.0, 0.0) };
    VOISegment *horizontal = [[VOISegment alloc] initWithPoints:horiz];
    XCTAssertEqual(VOIHorizontalUpon, [horizontal verticalPosition:0.0]);
}

- (void)testHorizontalPosition {
    XCTAssertEqual(VOILeft, [self.s1 horizontalPosition:3.0]);
    XCTAssertEqual(VOIRightward, [self.s1 horizontalPosition:1.0]);

    XCTAssertEqual(VOIRight, [self.s2 horizontalPosition:1.0]);
    XCTAssertEqual(VOIRightward, [self.s2 horizontalPosition:3.0]);
    
    VOIPoint vert[2] = { vector2(0.0, 0.0), vector2(0.0, 2.0) };
    VOISegment *vertical = [[VOISegment alloc] initWithPoints:vert];
    XCTAssertEqual(VOIVerticalUpon, [vertical horizontalPosition:0.0]);
}

@end
