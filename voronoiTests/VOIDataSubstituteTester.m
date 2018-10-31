//
//  VOIDataSubstituteTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-31.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOIRange.h"

const NSUInteger NUM_PTS = 6;

static VOIPoint d_points[NUM_PTS];
static VOIPoint otherPoints[2];

void InitializePoints(VOIPoint *points, const NSUInteger count);

NS_INLINE NSRange MakeDataRange(NSUInteger location, NSUInteger length) {
    return NSMakeRange(location * sizeof(VOIPoint), length * sizeof(VOIPoint));
}

@interface VOIDataSubstituteTester : XCTestCase

@property NSMutableData *data;
@property NSMutableData *otherData;

@end

@implementation VOIDataSubstituteTester

+ (void)setUp {
    [super setUp];
    otherPoints[0] = vector2(9.0, 9.0);
    otherPoints[1] = vector2(10.0, 10.0);
    InitializePoints(d_points, NUM_PTS);
}

- (void)setUp {
    [super setUp];
    self.data = [NSMutableData dataWithBytes:d_points length:sizeof(VOIPoint) * NUM_PTS];
    self.otherData = [NSMutableData dataWithBytes:otherPoints length:sizeof(VOIPoint) * 2];
}

- (void)testAllEmpty {
    NSMutableData *e = self.data;
    NSMutableData *a = [self.data mutableCopy];
    [a substitute:[NSData data] inRange:NSMakeRange(0, 0)];
    XCTAssertEqualObjects(a, e);
}

- (void)testEmptyRange {
    VOIPoint pts[NUM_PTS + 2] = {
        otherPoints[0],
        otherPoints[1],
        d_points[0],
        d_points[1],
        d_points[2],
        d_points[3],
        d_points[4],
        d_points[5]
    };
    NSData *e = [NSData dataWithBytes:pts length:sizeof(pts)];
    NSMutableData *a = [self.data mutableCopy];
    [a substitute:self.otherData inRange:NSMakeRange(0, 0)];
    XCTAssertEqualObjects(a, e);
}

- (void)testMaxGTCount {
    VOIPoint pts[NUM_PTS] = {
        otherPoints[1],
        d_points[1],
        d_points[2],
        d_points[3],
        d_points[4],
        otherPoints[0]
    };
    NSData *e = [NSData dataWithBytes:pts length:sizeof(pts)];
    NSMutableData *a = [self.data mutableCopy];
    [a substitute:self.otherData inRange:MakeDataRange(NUM_PTS - 1, 2)];
    XCTAssertEqualObjects(a, e);
}

- (void)testLocationEqualsCount {
    VOIPoint pts[NUM_PTS] = {
        otherPoints[0],
        otherPoints[1],
        d_points[2],
        d_points[3],
        d_points[4],
        d_points[5]
    };
    NSData *e = [NSData dataWithBytes:pts length:sizeof(VOIPoint) * NUM_PTS];
    NSMutableData *a = [self.data mutableCopy];
    [a substitute:self.otherData inRange:MakeDataRange(NUM_PTS, 2)];
    XCTAssertEqualObjects(a, e);
}

- (void)testLengthEqualsCount {
    VOIPoint pts[2] = { otherPoints[1], otherPoints[0] };
    NSData *e = [NSData dataWithBytes:pts length:sizeof(VOIPoint) * 2];
    NSMutableData *a = [self.data mutableCopy];
    [a substitute:self.otherData inRange:MakeDataRange(1, NUM_PTS)];
    XCTAssertEqualObjects(a, e);
}

- (void)testLocationGTCount {
    VOIPoint pts[NUM_PTS] = {
        d_points[0],
        otherPoints[0],
        otherPoints[1],
        d_points[3],
        d_points[4],
        d_points[5]
    };
    NSData *e = [NSData dataWithBytes:pts length:sizeof(VOIPoint) * NUM_PTS];
    NSMutableData *a = [self.data mutableCopy];
    [a substitute:self.otherData inRange:MakeDataRange(7, 2)];
    XCTAssertEqualObjects(e, a);
}

- (void)testLengthGTCount {
    NSData *e = self.otherData;
    NSMutableData *a = [self.data mutableCopy];
    [a substitute:self.otherData inRange:MakeDataRange(3, 7)];
    XCTAssertEqualObjects(e, a);
}

@end

void InitializePoints(VOIPoint *pts, const NSUInteger count) {
    
    VOIPoint point = vector2(1.0, -1.0);
    NSUInteger signIndex = 0;
    double scale = 2.0;
    
    for (NSUInteger i = 0; i < count; ++i) {
        pts[i] = point * scale;
        point[signIndex] *= -1;
        signIndex = signIndex ? 0 : 1;
        scale *= 1.25;
    }
}
