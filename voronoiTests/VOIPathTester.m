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

- (void)testCount {
    XCTAssertEqual(COUNT - 1, self.path.count);
    self.path.closed = YES;
    XCTAssertEqual(COUNT, self.path.count);
}

- (void)testIterateSegments {
    self.path.closed = YES;
    __block NSUInteger lastIndex = 0;
    [self.path iterateSegments:^BOOL(VOISegment *s, NSUInteger i) {
        XCTAssertEqualObjects([VOISegment class], [s class]);
        XCTAssertEqual(lastIndex, i);
        ++lastIndex;
    }];
    XCTAssertEqual(COUNT, lastIndex);
}

- (void)testAsSegmentList {
    
    const NSUInteger SCount = COUNT;
    VOIPoint segmentPoints[SCount * 2] = {
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
    VOISegmentList *e = [[VOISegmentList alloc] initWithPoints:segmentPoints count:SCount];

    self.path.closed = YES;
    VOISegmentList *a = [self.path asSegmentList];
    
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