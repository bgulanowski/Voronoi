//
//  VOITriangleTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-06.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOIBox.h"
#import "VOISegment.h"
#import "VOITriangle.h"

@interface VOIBox (VOTriangleTests)
- (VOITriangle *)randomTriangle;
@end

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

- (void)testInitStandardize {
    VOITriangle *t = [[VOITriangle alloc] initWithPoints:points standardize:YES];
    XCTAssertTrue(t.standard);
    XCTAssertTrue(t.leftHanded);
    XCTAssertEqualObjects(self.triangle, t);
}

- (void)testPoints {
    AssertEqualPoints(points[0], self.triangle.p0);
    AssertEqualPoints(points[1], self.triangle.p1);
    AssertEqualPoints(points[2], self.triangle.p2);
}

- (void)testPointAt {
    for (NSUInteger i = 0; i < 3; ++i) {
        AssertEqualPoints(points[0], [self.triangle pointAt:0]);
    }
}

- (void)testAngleAt {
    double e = 0.982793723247329;
    double a = [self.triangle angleAt:0];
    AssertEqualFloats(e, a);
    
    e = M_PI - (2 * e);
    a = [self.triangle angleAt:1];
    AssertEqualFloats(e, a);
}

- (void)testLengthOf {
    double e = 3.605551275463989;
    double a = [self.triangle lengthOfSegmentAt:0];
    AssertEqualFloats(e, a);
    XCTAssertEqual(4.0, [self.triangle lengthOfSegmentAt:1]);
}

- (void)testSquareLengthOf {
    XCTAssertEqual(13.0, [self.triangle squareLengthOfSegmentAt:0]);
    XCTAssertEqual(16.0, [self.triangle squareLengthOfSegmentAt:1]);
}

- (void)testIsEqualToTriangle {
    VOITriangle *other = [[VOITriangle alloc] initWithPoints:points];
    XCTAssertTrue([other isEqualToTriangle:self.triangle]);
    XCTAssertFalse([other isEqualToTriangle:nil]);
}

- (void)testIsEquivalentToTriangle {
    VOIPoint equivalent[3] = {
        points[2],
        points[0],
        points[1]
    };
    VOITriangle *e = [[VOITriangle alloc] initWithPoints:equivalent];
    VOITriangle *a = self.triangle;
    XCTAssertNotEqualObjects(e, a);
    XCTAssertTrue([e isEquivalentToTriangle:a]);
}

- (void)testCompare {
    XCTAssertEqual(NSOrderedSame, [self.triangle compare:self.triangle]);
    XCTAssertEqual(NSOrderedSame, [self.triangle compare:[[VOITriangle alloc] initWithPoints:points]]);
    
    XCTAssertEqual(NSOrderedAscending, [self.triangle compare:self.degenerate]);
}

- (void)testCentre {
    VOIPoint e = vector2(3.0, 1.5 + 1.0 / 3.0);
    VOIPoint a = self.triangle.centre;
    AssertEqualPoints(e, a);
}

- (void)testCentreDegenerate {
    VOIPoint a = self.degenerate.centre;
    XCTAssertTrue(isnan(a.x) && isnan(a.y));
}

- (void)testRadius {
    double e = 1.5 + 2.0 / 3.0;
    double a = self.triangle.radius;
    XCTAssertEqual(e, a);
}

- (void)testDegenerateRadius {
    XCTAssertTrue(isnan(self.degenerate.radius));
}

- (void)testCentroid {
    VOIPoint e = vector2(3.0, 2.0);
    VOIPoint a = self.triangle.centroid;
    AssertEqualPoints(e, a);
}

- (void)testCentroidDegenerate {
    VOIPoint e = vector2(5.0, 1.0);
    VOIPoint a = self.degenerate.centroid;
    AssertEqualPoints(e, a);
}

- (void)testRightHandedness {
    XCTAssertTrue(self.triangle.leftHanded);
    XCTAssertFalse(self.triangle.rightHanded);
    XCTAssertTrue([self.triangle reverseOrder].rightHanded);
}

- (void)testOrdered {
    XCTAssertTrue(self.triangle.ordered);
    VOIPoint scrambled[3] = {
        points[1],
        points[2],
        points[0]
    };
    VOITriangle *t = [[VOITriangle alloc] initWithPoints:scrambled];
    XCTAssertFalse(t.ordered);
}

- (void)testStandard {
    XCTAssertTrue(self.triangle.standard);
    VOITriangle *t = [self.triangle reverseOrder];
    XCTAssertFalse(t.standard);
    t = [t standardize];
    XCTAssertTrue(t.standard);

    XCTAssertEqualObjects(self.triangle, t);

    AssertEqualPoints(self.triangle.p0, t.p0);
    AssertEqualPoints(self.triangle.p1, t.p1);
    AssertEqualPoints(self.triangle.p2, t.p2);
}

- (void)_testHashKey {
    // Using the hash value as the hash key (NSNumber) results in around a 2.5% collision rate :P
    __block NSUInteger collisionCount = 0;
    __block NSUInteger runCount = 0;
    const NSUInteger trials = 1 << 20;
    VOIBox *box = [[VOIBox alloc] initWithOrigin:vector2(0.0, 0.0) size:vector2(32.0, 32.0)];
    NSMutableDictionary *triangles = [NSMutableDictionary dictionary];
    [self measureBlock:^{
        ++runCount;
        [triangles removeAllObjects];
        for (NSUInteger i = 0; i < trials; ++i) {
            VOITriangle *t = [box randomTriangle];
            id<NSCopying> h = t.hashKey;
            VOITriangle *e = triangles[h];
            if (e) {
                ++collisionCount;
            }
//            XCTAssertNil(e, @"hash collistion: %@", h);
            triangles[h] = t;
        }
    }];
//    XCTAssertLessThan(collisionCount, 100);
    NSUInteger averageCollisions = collisionCount / runCount;
    
    NSLog(@"Random hash key collisions: %td in %td runs (%td trials per run)", averageCollisions, runCount, trials);
}

- (void)testSegments {
    VOISegment *e = [[VOISegment alloc] initWithPoint:points[1] otherPoint:points[2]];
    XCTAssertEqualObjects(e, self.triangle.s0);
    e = [[VOISegment alloc] initWithPoint:points[2] otherPoint:points[0]];
    XCTAssertEqualObjects(e, self.triangle.s1);
    e = [[VOISegment alloc] initWithPoint:points[0] otherPoint:points[1]];
    XCTAssertEqualObjects(e, self.triangle.s2);
}

- (void)testSegmentAt {
    VOISegment *e = [[VOISegment alloc] initWithPoint:points[1] otherPoint:points[2]];
    VOISegment *a = [self.triangle segmentAt:0];
    XCTAssertEqualObjects(e, a);
}

- (void)testIndexForSegment {
    XCTAssertEqual(NSNotFound, [self.triangle indexForSegment:nil]);
    VOISegment *s = [[VOISegment alloc] initWithPoint:points[0] otherPoint:points[1]];
    XCTAssertEqual(2, [self.triangle indexForSegment:s]);
    s = [[VOISegment alloc] initWithPoint:points[2] otherPoint:points[3]];
    XCTAssertEqual(NSNotFound, [self.triangle indexForSegment:s]);
}

- (void)testSegmentInCommon {
    VOISegment *e = [[VOISegment alloc] initWithPoint:points[1] otherPoint:points[2]];
    NSUInteger indices[2];
    VOISegment *a = [self.triangle segmentInCommonWith:self.degenerate indices:indices];
    XCTAssertTrue([a isEquivalentToSegment:e]);
    XCTAssertEqual(0, indices[0]);
    XCTAssertEqual(2, indices[1]);
}

- (void)testReverseOrder {
    VOIPoint other[3] = {
        points[0],
        points[2],
        points[1]
    };
    VOITriangle *e = [[VOITriangle alloc] initWithPoints:other];
    VOITriangle *a = [self.triangle reverseOrder];
    XCTAssertEqualObjects(e, a);
}

- (void)testStandardize {
    VOIPoint other[3] = {
        points[2],
        points[1],
        points[0]
    };
    VOITriangle *e = self.triangle;
    VOITriangle *a = [[[VOITriangle alloc] initWithPoints:other] standardize];
    XCTAssertEqualObjects(e, a);
}

- (void)testStandardizeInverted {
    VOIPoint inverted[3] = {
        points[0],
        points[2],
        vector2(points[1].x, -points[1].y)
    };
    VOITriangle *e = [[VOITriangle alloc] initWithPoints:inverted];
    XCTAssertFalse(e.rightHanded);
    
    VOIPoint irregular[3] = {
        inverted[2],
        inverted[1],
        inverted[0]
    };
    VOITriangle *a = [[[VOITriangle alloc] initWithPoints:irregular] standardize];
    XCTAssertEqualObjects(e, a);
}

@end

@implementation VOIBox (VOITriangleTester)

- (VOITriangle *)randomTriangle {
    VOIPoint points[3] = {
        [self randomPoint],
        [self randomPoint],
        [self randomPoint]
    };
    return [[VOITriangle alloc] initWithPoints:points];
}

@end
