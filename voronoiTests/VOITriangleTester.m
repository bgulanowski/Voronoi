//
//  VOITriangleTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-06.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOITriangle.h"

@interface VOITriangleTester : XCTestCase
@property VOITriangle *triangle;
@property VOITriangle *degenerate;
@end

static VOIPoint points[4];

@implementation VOITriangleTester

+ (void)setUp {
    points[0] = vector2(1.0, 1.0);
    points[1] = vector2(3.0, 4.0);
    points[2] = vector2(5.0, 1.0);
    points[3] = vector2(7.0, -2.0);
}

- (void)setUp {
    [super setUp];
    self.triangle = [[VOITriangle alloc] initWithPoints:points];
    self.degenerate = [[VOITriangle alloc] initWithPoints:&points[1]];
}

- (void)testPoints {
    AssertEqualPoints(points[0], self.triangle.p0);
    AssertEqualPoints(points[1], self.triangle.p1);
    AssertEqualPoints(points[2], self.triangle.p2);
}

- (void)testCentre {
    VOIPoint e = vector2(3.0, 1.5 + 1.0 / 3.0);
    VOIPoint a = self.triangle.centre;
    AssertEqualPoints(e, a);
}

- (void)testCentreDegenerate {
    VOIPoint e = vector2((double)INFINITY, (double)INFINITY);
    VOIPoint a = self.degenerate.centre;
    AssertEqualPoints(e, a);
}

- (void)testRadius {
    double e = 1.5 + 2.0 / 3.0;
    double a = self.triangle.radius;
    XCTAssertEqual(e, a);
}

- (void)testDegenerateRadius {
    double e = (double)INFINITY;
    double a = self.degenerate.radius;
    XCTAssertEqual(e, a);
}

@end
