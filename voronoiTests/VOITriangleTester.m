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
@end

static VOIPoint points[3];

@implementation VOITriangleTester

+ (void)setUp {
    points[0] = vector2(1.0, 1.0);
    points[1] = vector2(3.0, 4.0);
    points[2] = vector2(5.0, 1.0);
}

- (void)setUp {
    [super setUp];
    self.triangle = [[VOITriangle alloc] initWithPoints:points];
}

- (void)testPoints {
    AssertEqualPoints(points[0], self.triangle.p0);
    AssertEqualPoints(points[1], self.triangle.p1);
    AssertEqualPoints(points[2], self.triangle.p2);
}

- (void)testCentre {
    VOIPoint e = vector2(3.0, 2.0 - 1.0 / 6.0);
    VOIPoint a = self.triangle.centre;
    AssertEqualPoints(e, a);
}

@end
