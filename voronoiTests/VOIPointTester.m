//
//  VOIPointTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-24.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOIPoint.h"

typedef void(^FibonacciBlock)(double f);

static void IterateFibonacci(NSUInteger count, FibonacciBlock block) {
    double p[2] = { 1.0, 1.0 };
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger i1 = i%2, i2 = (i+1)%2;
        block(p[i1]);
        p[i2] += p[i1];
    }
}

@interface VOIPointTester : XCTestCase

@end

@implementation VOIPointTester

- (void)testEqualDoubles {
    IterateFibonacci(100, ^(double a) {
        double ra = sqrt(a);
        double b = ra * ra;
        BOOL r = VOIDoublesEqual(a, b);
        XCTAssertTrue(r, @"x != sqrt(x)^2 (%f != %f)", a, b);
    });
}

- (void)testCompareDoubles {
    double a = 1.0;
    double b = 1.0 + VOIEpsilon * 2;
    XCTAssertEqual(NSOrderedSame, VOICompareDoubles(a, b));
    
    b += VOIEpsilon;
    XCTAssertEqual(NSOrderedAscending, VOICompareDoubles(a, b));
    XCTAssertEqual(NSOrderedDescending, VOICompareDoubles(b, a));
}

- (void)testPointsEqual {
    IterateFibonacci(32, ^(double f) {
        double ts = sqrt(f);
        double t = ts * ts;
        VOIPoint p0 = vector2(f, f);
        VOIPoint p1 = vector2(t, t);
        BOOL r = VOIPointsEqual(p0, p1);
        XCTAssertTrue(r);
    });
}

- (void)testComparePoints {
    VOIPoint p0 = vector2(0.0, 0.0);
    VOIPoint p1 = vector2(1.0, 0.0);
    VOIPoint p2 = vector2(0.0, 1.0);
    VOIPoint p3 = vector2(1.0, 1.0);
    
    XCTAssertEqual(NSOrderedSame, VOIComparePoints(p0, p0));
    XCTAssertEqual(NSOrderedSame, VOIComparePoints(p1, p1));

    XCTAssertEqual(NSOrderedAscending, VOIComparePoints(p0, p1));
    XCTAssertEqual(NSOrderedAscending, VOIComparePoints(p0, p2));
    XCTAssertEqual(NSOrderedAscending, VOIComparePoints(p0, p3));

    XCTAssertEqual(NSOrderedDescending, VOIComparePoints(p1, p0));
    XCTAssertEqual(NSOrderedDescending, VOIComparePoints(p1, p2));
    XCTAssertEqual(NSOrderedAscending, VOIComparePoints(p1, p3));
}

@end
