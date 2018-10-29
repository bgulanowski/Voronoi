//
//  VOITriangleListTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOITriangle.h"
#import "VOITriangleList.h"

static VOIPoint trianglePoints[9];

@interface VOITriangleListTester : XCTestCase
@property (nonatomic) VOITriangleList *triangleList;
@end

@implementation VOITriangleListTester

+ (void)setUp {
    trianglePoints[0] = vector2(0.0, 0.0);
    trianglePoints[1] = vector2(1.0, 1.0);
    trianglePoints[2] = vector2(2.0, 0.0);
    
    trianglePoints[3] = vector2(3.0, 2.0);
    trianglePoints[4] = vector2(4.0, 3.0);
    trianglePoints[5] = vector2(5.0, 2.0);
    
    trianglePoints[6] = vector2(0.0, 0.0);
    trianglePoints[7] = vector2(-1.0, -1.0);
    trianglePoints[8] = vector2(1.0, -2.0);
}

- (void)setUp {
    [super setUp];
    self.triangleList = [[VOITriangleList alloc] initWithPoints:trianglePoints count:3];
}

- (void)testCount {
    XCTAssertEqual((NSUInteger)3, self.triangleList.count);
    XCTAssertEqual((NSUInteger)9, self.triangleList.pointCount);
}

- (void)testIsEqualToTriangleList {
    XCTAssertTrue([self.triangleList isEqualToTriangleList:self.triangleList]);
}

- (void)testInitWithTriangles {
    NSArray *triangles = @[
                           [[VOITriangle alloc] initWithPoints:&trianglePoints[0]],
                           [[VOITriangle alloc] initWithPoints:&trianglePoints[3]],
                           [[VOITriangle alloc] initWithPoints:&trianglePoints[6]],
                           ];
    VOITriangleList *e = self.triangleList;
    VOITriangleList *a = [[VOITriangleList alloc] initWithTriangles:triangles];
    XCTAssertEqualObjects(e, a);
}

- (void)testTriangleAt {
    VOITriangle *e = [[VOITriangle alloc] initWithPoints:&trianglePoints[6]];
    VOITriangle *a = [self.triangleList triangleAt:2];
    XCTAssertEqualObjects(e, a);
}

- (void)testIterateTriangles {
    __block NSUInteger indexCheck = 0;
    [self.triangleList iterateTriangles:^BOOL(VOITriangle *t, NSUInteger i) {
        XCTAssertEqual(i, indexCheck);
        ++indexCheck;
        XCTAssertNotNil(t);
        return NO;
    }];
    XCTAssertEqual(indexCheck, 3);
}

- (void)testAllTriangles {
    NSArray *e = @[
                   [[VOITriangle alloc] initWithPoints:&trianglePoints[0]],
                   [[VOITriangle alloc] initWithPoints:&trianglePoints[3]],
                   [[VOITriangle alloc] initWithPoints:&trianglePoints[6]]
                   ];
    NSArray *a = [self.triangleList allTriangles];
    
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListAsTriangleList {
    VOITriangleList *e = self.triangleList;
    VOIPointList *pointList = [[VOIPointList alloc] initWithPoints:trianglePoints count:9];
    VOITriangleList *a = [pointList asTriangleList];
    
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListAsTriangleStrip {
    NSArray *triangles = @[
                           [[VOITriangle alloc] initWithPoints:&trianglePoints[0]],
                           [[VOITriangle alloc] initWithPoints:&trianglePoints[1]],
                           [[VOITriangle alloc] initWithPoints:&trianglePoints[2]],
                           ];
    VOITriangleList *e = [[VOITriangleList alloc] initWithTriangles:triangles];
    VOITriangleList *a = [[[VOIPointList alloc] initWithPoints:trianglePoints count:5] asTriangleStrip];
    XCTAssertEqualObjects(e, a);
}

@end
