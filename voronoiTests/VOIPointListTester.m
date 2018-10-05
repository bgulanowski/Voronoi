//
//  VOIPointListTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOIPointList.h"

VOIPoint points[4];

@interface VOIPointListTester : XCTestCase

@property VOIPointList *pointList;

@end

@implementation VOIPointListTester

+ (void)setUp {
    points[0] = vector2(3.0, 0.0);
    points[1] = vector2(1.0, 0.5);
    points[2] = vector2(0.0, 4.0);
    points[3] = vector2(0.5, 2.0);
}

- (void)setUp {
    [super setUp];
    _pointList = [[VOIPointList alloc] initWithPoints:points count:4];
}

- (void)testIsEqualClass {
    XCTAssertFalse([self.pointList isEqual:@0]);
}

- (void)testIsEqualNil {
    XCTAssertFalse([self.pointList isEqual:nil]);
}

- (void)testCount {
    XCTAssertEqual((NSUInteger)4, _pointList.count);
}

- (void)testDescription {
    NSString *e = @"VOIPointList: points: [(3.00, 0.00), (1.00, 0.50), (0.00, 4.00), (0.50, 2.00), ...] count: 4";
    NSString *a = [_pointList description];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointAtIndex {
    for (NSUInteger i = 0; i < 4; ++i) {
        VOIPoint e = points[i];
        VOIPoint a = [_pointList pointAtIndex:i];
        XCTAssertEqual(e.x, a.x);
        XCTAssertEqual(e.y, a.y);
    }
}

- (void)testAdd {
    VOIPointList *a = [[VOIPointList alloc] initWithPoints:points count:2];
    VOIPointList *b = [[VOIPointList alloc] initWithPoints:&points[2] count:2];
    a = [a add:b];
    VOIPointList *e = self.pointList;
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListWithRangeEmpty {
    VOIPointList *a = [self.pointList pointListWithRange:NSMakeRange(0, 0)];
    VOIPointList *e = [VOIPointList new];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListWithRangeAll {
    VOIPointList *e = self.pointList;
    VOIPointList *a = [self.pointList pointListWithRange:NSMakeRange(0, _pointList.count)];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListWithRangeInsetStart {
    VOIPointList *e = [[VOIPointList alloc] initWithPoints:&points[2] count:2];
    VOIPointList *a = [self.pointList pointListWithRange:NSMakeRange(2, 2)];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListWithRangeShort {
    VOIPointList *e = [[VOIPointList alloc] initWithPoints:points count:2];
    VOIPointList *a = [self.pointList pointListWithRange:NSMakeRange(0, 2)];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListWithRangeInsetBothEnds {
    VOIPointList *e = [[VOIPointList alloc] initWithPoints:&points[1] count:2];
    VOIPointList *a = [self.pointList pointListWithRange:NSMakeRange(1, 2)];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListWithRangeExtended {
    
    const NSUInteger Location = 2;
    const NSUInteger Length = 10;
    NSRange range = NSMakeRange(Location, Length);
    
    VOIPoint repeating[Length];
    for (NSUInteger i = 0; i < Length; ++i) {
        repeating[i] = points[(i + Location) % 4];
    }
    
    VOIPointList *e = [[VOIPointList alloc] initWithPoints:repeating count:10];
    VOIPointList *a = [self.pointList pointListWithRange:range];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListWithRangeLocationBeyondEnd {
    VOIPointList *e = [[VOIPointList alloc] initWithPoints:&points[1] count:3];
    VOIPointList *a = [self.pointList pointListWithRange:NSMakeRange(5, 3)];
    XCTAssertEqualObjects(e, a);
}

- (void)testSortedByLength {
    
    VOIPoint sorted[] = {
        points[1],
        points[3],
        points[0],
        points[2]
    };
    
    VOIPointList *e = [[VOIPointList alloc] initWithPoints:sorted count:4];
    VOIPointList *a = [_pointList sortedByLength];
    
    XCTAssertEqualObjects(e, a);
}

- (void)testSortedByDistance {
    VOIPoint from = vector2(1.0, 1.0);
    VOIPoint sorted[] = {
        points[1],
        points[3],
        points[0],
        points[2]
    };
    
    VOIPointList *e = [[VOIPointList alloc] initWithPoints:sorted count:4];
    VOIPointList *a = [_pointList sortedByDistanceFrom:from];
    
    XCTAssertEqualObjects(e, a);
}

@end
