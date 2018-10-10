//
//  VOISegmentListTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOISegment.h"
#import "VOISegmentList.h"
#import "VOITriangle.h"

@interface VOISegmentListTester : XCTestCase
@property VOISegmentList *segmentList;
@end

static VOIPoint points[6];

@implementation VOISegmentListTester

+ (void)setUp {
    points[0] = vector2(0.0, 0.0);
    points[1] = vector2(3.0, 3.0);
    
    points[2] = vector2(1.0, 0.0);
    points[3] = vector2(3.0, 2.0);
    
    points[4] = vector2(2.0, 0.0);
    points[5] = vector2(3.0, 1.0);
}

- (void)setUp {
    [super setUp];
    self.segmentList = [[VOISegmentList alloc] initWithPoints:points count:3];
}

- (void)testInitWithSegments {
    NSArray *segments = @[
                          [[VOISegment alloc] initWithPoints:&points[0]],
                          [[VOISegment alloc] initWithPoints:&points[2]],
                          [[VOISegment alloc] initWithPoints:&points[4]]
                          ];
    VOISegmentList *a = [[VOISegmentList alloc] initWithSegments:segments];
    VOISegmentList *e = self.segmentList;
    XCTAssertEqualObjects(e, a);
}

- (void)testInitWithTriangle {
    VOITriangle *t = [[VOITriangle alloc] initWithPoints:points];
    VOISegmentList *s = [[VOISegmentList alloc] initWithTriangle:t];
    VOIPoint s2[] = { points[2], points[0] };
    NSArray<VOISegment *> *e = @[
                                 [[VOISegment alloc] initWithPoints:&points[0]],
                                 [[VOISegment alloc] initWithPoints:&points[1]],
                                 [[VOISegment alloc] initWithPoints:s2],
                                 ];
    NSArray<VOISegment *> *a = [s allSegments];
    
    XCTAssertEqualObjects(e, a);
}

- (void)testSegmentAt {
    VOISegment *e = [[VOISegment alloc] initWithPoints:&points[4]];
    VOISegment *a = [self.segmentList segmentAt:2];
    XCTAssertEqualObjects(e, a);
}

- (void)testCount {
    XCTAssertEqual(3, self.segmentList.count);
    XCTAssertEqual(6, self.segmentList.pointCount);
}

- (void)testAsSegmentList {
    VOISegmentList *e = self.segmentList;
    VOIPointList *pointList = [[VOIPointList alloc] initWithPoints:points count:6];
    VOISegmentList *a = [pointList asSegmentList];
    
    XCTAssertEqualObjects(e, a);
    
    XCTAssertEqual([self.segmentList asSegmentList], self.segmentList);
}

- (void)testAllSegments {
    NSArray *e = @[
                   [[VOISegment alloc] initWithPoints:&points[0]],
                   [[VOISegment alloc] initWithPoints:&points[2]],
                   [[VOISegment alloc] initWithPoints:&points[4]]
                   ];
    NSArray *a = [self.segmentList allSegments];
    XCTAssertEqualObjects(e, a);
}

- (void)testSortedByLength {
    NSArray *segments = @[
                          [[VOISegment alloc] initWithPoints:&points[4]],
                          [[VOISegment alloc] initWithPoints:&points[2]],
                          [[VOISegment alloc] initWithPoints:&points[0]]
                          ];
    VOISegmentList *e = [[VOISegmentList alloc] initWithSegments:segments];
    VOISegmentList *a = [self.segmentList sortedByLength];
    XCTAssertEqualObjects(e, a);
}

@end
