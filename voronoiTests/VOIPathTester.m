//
//  VOIPathTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOIPath.h"
#import "VOISegment.h"

@interface NSMeasurement (DegreesToRadians)

+ (instancetype)angleInDegrees:(double)degrees;
+ (instancetype)angleInRadians:(double)radians;
- (NSMeasurement *)inDegress;
- (NSMeasurement *)inRadians;
+ (double)radiansForDegrees:(double)degrees;
+ (double)degreesForRadians:(double)radians;

@end

static const NSUInteger COUNT = 6;
static VOIPoint pathPoints[COUNT];

@interface VOIPathTester : XCTestCase

@property (nonatomic) VOIPath *path;

@end

@implementation VOIPathTester

+ (void)setUp {
    const double length = 2.0;
    for (NSUInteger i = 0; i < COUNT; ++i) {
        double radians = [NSMeasurement radiansForDegrees:30.0 * (double)i];
        double x = sin(radians);
        double y = cos(radians);
        pathPoints[i] = vector2(x, y) * length;
    }
}

- (void)setUp {
    [super setUp];
    self.path = [[VOIPath alloc] initWithPoints:pathPoints count:COUNT];
}

- (void)testIsEqual {
    VOIPath *e = self.path;
    VOIPath *a = [[VOIPath alloc] initWithPoints:pathPoints count:COUNT];
    
    for (NSUInteger i = 0; i < COUNT; ++i) {
        AssertEqualPoints([e pointAtIndex:i], [a pointAtIndex:i]);
    }
    
    XCTAssertEqual(e.closed, a.closed);
}

- (void)testIsEqualToPath {
    VOIPath *other = [[VOIPath alloc] initWithPoints:pathPoints count:COUNT];
    XCTAssertEqualObjects(self.path, other);
    
    other = [self.path openPath];
    XCTAssertEqualObjects(self.path, other);

    other = [[VOIPath alloc] initWithPoints:pathPoints count:COUNT close:NO];
    XCTAssertEqualObjects(self.path, other);

    other = [[VOIPath alloc] initWithPoints:pathPoints count:COUNT close:YES];
    XCTAssertNotEqualObjects(self.path, other);

    other = [[VOIPath alloc] initWithPoints:pathPoints count:COUNT - 1];
    XCTAssertNotEqualObjects(self.path, other);
}

- (void)testCount {
    XCTAssertEqual(COUNT - 1, self.path.count);
    VOIPath *closedPath = [self.path closedPath];
    XCTAssertEqual(COUNT, closedPath.count);
}

- (void)testSegmentAt {
    VOIPath *closedPath = [self.path closedPath];
    VOISegmentList *segmentList = [self segmentListClosed:YES];
    for (NSUInteger i = 0; i < COUNT; ++i) {
        XCTAssertEqualObjects([segmentList segmentAt:i], [closedPath segmentAt:i]);
    }
}

- (void)testIterateSegments {
    VOIPath *closedPath = [self.path closedPath];
    VOISegmentList *segmentList = [self segmentListClosed:YES];
    __block NSUInteger lastIndex = 0;
    [closedPath iterateSegments:^BOOL(VOISegment *s, NSUInteger i) {
        XCTAssertEqualObjects([segmentList segmentAt:i], s, @"index: %td", i);
        XCTAssertEqual(lastIndex, i);
        ++lastIndex;
    }];
    XCTAssertEqual(COUNT, lastIndex);
}

- (void)testAsSegmentList {
    VOISegmentList *e = [self segmentListClosed:YES];
    VOIPath *closedPath = [self.path closedPath];
    VOISegmentList *a = [closedPath asSegmentList];
    XCTAssertEqualObjects(e, a);
}

- (void)testAllSegmentsOpen {
    NSArray *e = [[self segmentListClosed:NO] allSegments];
    NSArray *a = [self.path allSegments];
    XCTAssertEqualObjects(e, a);
}

- (void)testAllSegmentsClosed {
    NSArray *e = [[self segmentListClosed:YES] allSegments];
    NSArray *a = [[self.path closedPath] allSegments];
    XCTAssertEqualObjects(e, a);
}

- (VOISegmentList *)segmentListClosed:(BOOL)closed {
    VOIPoint segmentPoints[COUNT * 2] = {
        pathPoints[0],
        pathPoints[1],
        pathPoints[1],
        pathPoints[2],
        pathPoints[2],
        pathPoints[3],
        pathPoints[3],
        pathPoints[4],
        pathPoints[4],
        pathPoints[5],
        pathPoints[5],
        pathPoints[0]
    };
    
    return [[VOISegmentList alloc] initWithPoints:segmentPoints count:(closed ? COUNT : COUNT - 1)];
}

- (void)testPointListAsPath {
    VOIPath *e = self.path;
    VOIPointList *list = [[VOIPointList alloc] initWithPoints:pathPoints count:COUNT];
    VOIPath *a = [list asPath];
    XCTAssertEqualObjects(e, a);
}

@end

static NSUnit *Degrees;
static NSUnit *Radians;
static NSUnitAngle *AngleUnit;

@implementation NSMeasurement (DegreesToRadians)

+ (void)load {
    @autoreleasepool {
        Degrees = [NSUnitAngle degrees];
        Radians = [NSUnitAngle radians];
        AngleUnit = [NSUnitAngle baseUnit];
    }
}

+ (instancetype)angleInDegrees:(double)degrees {
    return [[NSMeasurement alloc] initWithDoubleValue:degrees unit:Degrees];
}

+ (instancetype)angleInRadians:(double)radians {
    return [[NSMeasurement alloc] initWithDoubleValue:radians unit:Radians];
}

- (NSMeasurement *)inDegress {
    return [self measurementByConvertingToUnit:Radians];
}

- (NSMeasurement *)inRadians {
    return [self measurementByConvertingToUnit:Radians];
}

+ (double)radiansForDegrees:(double)degrees {
    return [[self angleInDegrees:degrees] inRadians].doubleValue;
}

+ (double)degreesForRadians:(double)radians {
    return [[self angleInRadians:radians] inDegress].doubleValue;
}

@end
