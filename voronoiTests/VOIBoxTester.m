//
//  VOIBoxTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-06.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOIBox.h"
#import "VOIPointList.h"

@interface VOIBox (Testing)
+ (VOIPoint)regularizeOrigin:(VOIPoint)origin forSize:(VOISize)size;
@end

@interface VOIBoxTester : XCTestCase
@property VOIBox *box;
@end

@implementation VOIBoxTester

- (void)setUp {
    [super setUp];
    self.box = [[VOIBox alloc] initWithOrigin:vector2(4.0, -5.0) size:vector2(-3.0, 7.0)];
}

- (void)testIsEqual {
    XCTAssertFalse([self.box isEqual:nil]);
    XCTAssertFalse([self.box isEqual:[NSObject new]]);
}

- (void)testIsEqualToBox {
    VOIBox *other = [[VOIBox alloc] initWithOrigin:vector2(4.0, -5.0) size:vector2(-3.0, 7.0)];
    XCTAssertEqualObjects(self.box, other);
    other = [[VOIBox alloc] initWithOrigin:vector2(1.0, 2.0) size:vector2(3.0, -7.0)];
    XCTAssertEqualObjects(self.box, other);
    other = [[VOIBox alloc] initWithOrigin:vector2(4.0 + DBL_EPSILON, -5.0) size:vector2(-3.0, 7.0)];
    XCTAssertEqualObjects(self.box, other);
    other = [[VOIBox alloc] initWithOrigin:vector2(4.0, 5.0) size:vector2(-3.0, 7.0)];
    XCTAssertNotEqualObjects(self.box, other);
}

- (void)testOrigin {
    VOIPoint e = vector2(1.0, -5.0);
    VOIPoint a = self.box.origin;
    AssertEqualPoints(e, a);
}

- (void)testRegularizeOrigin {
    VOIPoint e = vector2(-1.0, -1.0);
    VOIPoint a = [VOIBox regularizeOrigin:vector2(0.0, 0.0) forSize:vector2(-1.0, -1.0)];
    AssertEqualPoints(e, a);
}

- (void)testSize {
    VOIPoint e = vector2(3.0, 7.0);
    VOIPoint a = self.box.size;
    AssertEqualPoints(e, a);
}

- (void)testCentre {
    VOIPoint e = vector2(2.5, -1.5);
    VOIPoint a = self.box.centre;
    AssertEqualPoints(e, a);
}

- (void)testExtents {
    
    XCTAssertEqual(1.0, self.box.minX);
    XCTAssertEqual(4.0, self.box.maxX);
    XCTAssertEqual(2.5, self.box.midX);
    
    XCTAssertEqual(-5.0, self.box.minY);
    XCTAssertEqual(2.0, self.box.maxY);
    XCTAssertEqual(-1.5, self.box.midY);
    
    XCTAssertEqual(3.0, self.box.width);
    XCTAssertEqual(7.0, self.box.height);
}

- (void)testDegenerate {
    XCTAssertFalse(self.box.degenerate);
    XCTAssertTrue([[VOIBox alloc] init].degenerate);
    XCTAssertTrue([[VOIBox alloc] initWithOrigin:vector2(0.0, 0.0) size:vector2(0.0, 0.0)].degenerate);
    XCTAssertTrue([[VOIBox alloc] initWithOrigin:vector2(0.0, 0.0) size:vector2(0.0, 1.0)].degenerate);
    XCTAssertTrue([[VOIBox alloc] initWithOrigin:vector2(0.0, 0.0) size:vector2(1.0, 0.0)].degenerate);
}

- (void)testAsPointList {
    VOIPoint points[4] = {
        vector2(1.0, -5.0),
        vector2(1.0, 2.0),
        vector2(4.0, 2.0),
        vector2(4.0, -5.0)
    };
    VOIPointList *e = [[VOIPointList alloc] initWithPoints:points count:4];
    VOIPointList *a = [self.box asPointList];
    XCTAssertEqualObjects(e, a);
}

- (void)testContainsPoint {
    XCTAssertTrue([self.box containsPoint:self.box.origin]);
    XCTAssertTrue([self.box containsPoint:(self.box.origin + self.box.size)]);
    XCTAssertTrue([self.box containsPoint:self.box.centre]);
    XCTAssertFalse([self.box containsPoint:self.box.origin - vector2(1.0, 1.0)]);
    XCTAssertFalse([self.box containsPoint:self.box.origin - vector2(1.0, 0.0)]);
    XCTAssertFalse([self.box containsPoint:self.box.origin - vector2(0.0, 1.0)]);
}

- (void)testRandomPoint {
    [self.box randomPoint];
}

@end
