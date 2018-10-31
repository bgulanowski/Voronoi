//
//  VOIArraySubstituteTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-29.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSMutableArray+IndexWrapping.h"

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
    [a replaceObjectsInWrappingRange:NSMakeRange(0, 0) withObjects:@[]];
    XCTAssertEqualObjects(e, a);
}

- (void)testEmptyRange {
    NSArray *e = @[@9, @10, @1, @2, @3, @4, @5, @6];
    NSMutableArray *a = [self.array mutableCopy];
    [a replaceObjectsInWrappingRange:NSMakeRange(0, 0) withObjects:@[@9, @10]];
    XCTAssertEqualObjects(e, a);
}

- (void)testMaxGTCount {
    NSArray *e = @[@9, @2, @3, @4, @5, @8];
    NSMutableArray *a = [self.array mutableCopy];
    [a replaceObjectsInWrappingRange:NSMakeRange(5, 2) withObjects:@[@8, @9]];
    XCTAssertEqualObjects(e, a);
}

- (void)testLocationEqualsCount {
    NSArray *e = @[@8, @9, @3, @4, @5, @6];
    NSMutableArray *a = [self.array mutableCopy];
    [a replaceObjectsInWrappingRange:NSMakeRange(6, 2) withObjects:@[@8, @9]];
    XCTAssertEqualObjects(e, a);
}

- (void)testLengthEqualsCount {
    NSArray *e = @[@9, @8];
    NSMutableArray *a = [self.array mutableCopy];
    [a replaceObjectsInWrappingRange:NSMakeRange(1, 6) withObjects:@[@8, @9]];
    XCTAssertEqualObjects(e, a);
}

- (void)testLocationGTCount {
    NSArray *e = @[@1, @8, @9, @4, @5, @6];
    NSMutableArray *a = [self.array mutableCopy];
    [a replaceObjectsInWrappingRange:NSMakeRange(7, 2) withObjects:@[@8, @9]];
    XCTAssertEqualObjects(e, a);
}

- (void)testLengthGTCount {
    NSArray *e = @[@8, @9];
    NSMutableArray *a = [self.array mutableCopy];
    [a replaceObjectsInWrappingRange:NSMakeRange(3, 7) withObjects:@[@8, @9]];
    XCTAssertEqualObjects(e, a);
}

@end
