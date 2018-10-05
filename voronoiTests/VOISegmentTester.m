//
//  VOISegmentTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-05.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

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

@end
