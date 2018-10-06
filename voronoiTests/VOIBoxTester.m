//
//  VOIBoxTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-06.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOIBox.h"

@interface VOIBoxTester : XCTestCase
@property VOIBox *box;
@end

@implementation VOIBoxTester

- (void)setUp {
    [super setUp];
    self.box = [[VOIBox alloc] initWithOrigin:vector2(4.0, -5.0) size:vector2(-3.0, 7.0)];
}

- (void)testOrigin {
    VOIPoint e = vector2(1.0, -5.0);
    VOIPoint a = self.box.origin;
    XCTAssertEqual(e.x, a.x);
    XCTAssertEqual(e.y, a.y);
}

- (void)testSize {
    VOIPoint e = vector2(3.0, 7.0);
    VOIPoint a = self.box.size;
    XCTAssertEqual(e.x, a.x);
    XCTAssertEqual(e.y, a.y);
}

- (void)testCentre {
    VOIPoint e = vector2(2.5, -1.5);
    VOIPoint a = self.box.centre;
    XCTAssertEqual(e.x, a.x);
    XCTAssertEqual(e.y, a.y);
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
    XCTAssertTrue([[VOIBox alloc] init]);
    XCTAssertTrue([[VOIBox alloc] initWithOrigin:vector2(0.0, 0.0) size:vector2(0.0, 0.0)]);
    XCTAssertTrue([[VOIBox alloc] initWithOrigin:vector2(0.0, 0.0) size:vector2(0.0, 1.0)]);
    XCTAssertTrue([[VOIBox alloc] initWithOrigin:vector2(0.0, 0.0) size:vector2(1.0, 0.0)]);
}

@end
