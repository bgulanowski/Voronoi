//
//  VOIRangeTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-31.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOIRange.h"

#define AssertEqualRanges( a_, e_ ) {\
XCTAssertEqual(a_.location, e_.location);\
XCTAssertEqual(a_.length, e_.length);\
}

@interface VOIRangeTester : XCTestCase

@end

@implementation VOIRangeTester

- (void)setUp {
    [super setUp];

}

- (void)testPositive {
    VOIRange *range = [[VOIRange alloc] initWithLocation:4 length:8];
    XCTAssertEqual(range.min, 4);
    XCTAssertEqual(range.max, 12);
    XCTAssertEqual(range.absoluteLength, 8);
    NSRange e = NSMakeRange(4, 8);
    NSRange a = range.NSRange;
    AssertEqualRanges(a, e);
}

- (void)testInverted {
    VOIRange *range = [[VOIRange alloc] initWithLocation:12 length:-8];
    XCTAssertEqual(range.min, 4);
    XCTAssertEqual(range.max, 12);
    XCTAssertEqual(range.absoluteLength, 8);
    NSRange e = NSMakeRange(4, 8);
    NSRange a = range.NSRange;
    AssertEqualRanges(a, e);
}

- (void)testZeros {
    VOIRange *range = [[VOIRange alloc] initWithLocation:0 length:0];
    XCTAssertEqual(range.min, 0);
    XCTAssertEqual(range.max, 0);
    XCTAssertEqual(range.absoluteLength, 0);
    NSRange e = NSMakeRange(0, 0);
    NSRange a = range.NSRange;
    AssertEqualRanges(a, e);
}

- (void)testNegativeLocation {
    VOIRange *range = [[VOIRange alloc] initWithLocation:-4 length:8];
    XCTAssertEqual(range.min, -4);
    XCTAssertEqual(range.max, 4);
    XCTAssertEqual(range.absoluteLength, 8);
    NSRange e = NSMakeRange(NSNotFound, 8);
    NSRange a = range.NSRange;
    AssertEqualRanges(a, e);
}

- (void)testNegativeLength {
    VOIRange *range = [[VOIRange alloc] initWithLocation:4 length:-8];
    XCTAssertEqual(range.min, -4);
    XCTAssertEqual(range.max, 4);
    XCTAssertEqual(range.absoluteLength, 8);
    NSRange e = NSMakeRange(NSNotFound, 8);
    NSRange a = range.NSRange;
    AssertEqualRanges(a, e);
}

- (void)testDoubleNegative {
    VOIRange *range = [[VOIRange alloc] initWithLocation:-4 length:-8];
    XCTAssertEqual(range.min, -12);
    XCTAssertEqual(range.max, -4);
    XCTAssertEqual(range.absoluteLength, 8);
    NSRange e = NSMakeRange(NSNotFound, 8);
    NSRange a = range.NSRange;
    AssertEqualRanges(a, e);
}

- (void)testReplacementNoWrap {
    VOIRange *range = [[VOIRange alloc] initWithLocation:2 length:4];
    VOIReplacementRange *vr = [VOIReplacementRange replacementWithLimit:8
                                                                   size:4
                                                                  range:range];
    
    NSRange a = vr.source;
    NSRange e = NSMakeRange(0, 4);
    AssertEqualRanges(a, e);
    
    a = vr.destination;
    e = NSMakeRange(2, 4);
    AssertEqualRanges(a, e);

    a = vr.destTail;
    AssertEqualRanges(a, VOINullRange);
    
    a = vr.sourceHead;
    AssertEqualRanges(a, VOINullRange);
    
    a = vr.destHead;
    AssertEqualRanges(a, VOINullRange);

    a = vr.sourceTail;
    AssertEqualRanges(a, VOINullRange);
}

- (void)testReplacementWrap {
    VOIRange *range = [[VOIRange alloc] initWithLocation:5 length:4];
    VOIReplacementRange *vr = [VOIReplacementRange replacementWithLimit:8
                                                                   size:4
                                                                  range:range];
    
    NSRange a = vr.source;
    NSRange e = VOINullRange;
    AssertEqualRanges(a, e);
    
    a = vr.destination;
    AssertEqualRanges(a, e);
    
    a = vr.destTail;
    e = NSMakeRange(5, 3);
    AssertEqualRanges(a, e);
    
    a = vr.sourceHead;
    e = NSMakeRange(0, 3);
    AssertEqualRanges(a, e);
    
    a = vr.destHead;
    e = NSMakeRange(0, 1);
    AssertEqualRanges(a, e);
    
    a = vr.sourceTail;
    e = NSMakeRange(3, 1);
    AssertEqualRanges(a, e);
}

@end
