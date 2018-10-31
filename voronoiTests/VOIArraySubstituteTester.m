//
//  VOIArraySubstituteTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-29.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOIRange.h"

@interface VOIArraySubstituteTester : XCTestCase

@property NSArray *array;

@end

@implementation VOIArraySubstituteTester

- (void)setUp {
    [super setUp];
    self.array = @[@1, @2, @3, @4, @5, @6];
}

- (void)testEmptyRangeEmptyInsert {
    NSArray *e = self.array;
    NSMutableArray *a = [e mutableCopy];
    [a substitute:@[] inRange:NSMakeRange(0, 0)];
    XCTAssertEqualObjects(e, a);
}

- (void)testEmptyRange {
    NSArray *e = @[@9, @10, @1, @2, @3, @4, @5, @6];
    NSMutableArray *a = [self.array mutableCopy];
    [a substitute:@[@9, @10] inRange:NSMakeRange(0, 0)];
    XCTAssertEqualObjects(e, a);
}

- (void)testMaxGTCount {
    NSArray *e = @[@9, @2, @3, @4, @5, @8];
    NSMutableArray *a = [self.array mutableCopy];
    [a substitute:@[@8, @9] inRange:NSMakeRange(5, 2)];
    XCTAssertEqualObjects(e, a);
}

- (void)testLocationEqualsCount {
    NSArray *e = @[@8, @9, @3, @4, @5, @6];
    NSMutableArray *a = [self.array mutableCopy];
    [a substitute:@[@8, @9] inRange:NSMakeRange(6, 2)];
    XCTAssertEqualObjects(e, a);
}

- (void)testLengthEqualsCount {
    NSArray *e = @[@9, @8];
    NSMutableArray *a = [self.array mutableCopy];
    [a substitute:@[@8, @9] inRange:NSMakeRange(1, 6)];
    XCTAssertEqualObjects(e, a);
}

- (void)testLocationGTCount {
    NSArray *e = @[@1, @8, @9, @4, @5, @6];
    NSMutableArray *a = [self.array mutableCopy];
    [a substitute:@[@8, @9] inRange:NSMakeRange(7, 2)];
    XCTAssertEqualObjects(e, a);
}

- (void)testLengthGTCount {
    NSArray *e = @[@8, @9];
    NSMutableArray *a = [self.array mutableCopy];
    [a substitute:@[@8, @9] inRange:NSMakeRange(3, 7)];
    XCTAssertEqualObjects(e, a);
}

@end
