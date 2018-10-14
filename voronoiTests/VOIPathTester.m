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

#define ALIGN_UNIT 0x1p+32
#define ALIGN_UNIT_INV 0x1p-32

static inline double Align(double f) {
    return round(f * ALIGN_UNIT) * ALIGN_UNIT_INV;
}

static const NSUInteger COUNT = 12;
static VOIPoint pathPoints[COUNT];

@interface VOIPathTester : XCTestCase

@property (nonatomic) VOIPath *path;

@end

@implementation VOIPathTester

+ (void)setUp {
    const double length = 2.0;
    for (NSUInteger i = 0; i < COUNT; ++i) {
        double radians = (30.0 * (double)i * VOIPi / 180.0);
        double x = Align(cos(radians));
        double y = Align(sin(radians));
        pathPoints[i] = vector2(x, y) * length;
    }
}

- (void)setUp {
    [super setUp];
    self.path = [[VOIPath alloc] initWithPoints:pathPoints count:COUNT];
}

- (void)testConvex {
    
    XCTAssertFalse(self.path.convex);
    
    VOIPath *closedPath = [self.path closedPath];
    XCTAssertTrue(closedPath.convex);
    
    VOIPath *reversePath = (VOIPath *)[closedPath reverseList];
    XCTAssertTrue(reversePath.convex);
    
    VOIPointList *pointList = [[VOIPointList alloc] initWithPoints:pathPoints count:COUNT];
    VOIPointList *reverseList = [pointList reverseList];
    VOIPath *listPath = [reverseList asClosedPath];
    XCTAssertTrue(listPath.convex);
    
    VOIPath *line = [[VOIPath alloc] initWithPoints:pathPoints count:2 close:YES];
    XCTAssertFalse(line.convex);
    
    VOIPath *triangle = [[VOIPath alloc] initWithPoints:pathPoints count:3 close:YES];
    XCTAssertTrue(triangle.convex);

    VOIPoint concavePoints[5] = {
        vector2(0.0, 0.0),
        vector2(1.0, 1.0),
        vector2(1.0, 0.0),
        vector2(2.0, 1.0),
        vector2(0.0, 0.0)
    };
    
    // orientation reverses on second point
    VOIPath *concave = [[VOIPath alloc] initWithPoints:concavePoints count:4 close:YES];
    XCTAssertFalse(concave.convex);
    
    // orientation reverses on third point
    concave = [[VOIPath alloc] initWithPoints:&concavePoints[1] count:4 close:YES];
    XCTAssertFalse(concave.convex);

    VOIPoint colinearPoints[4] = {
        vector2(0.0, 0.0),
        vector2(1.0, 0.0),
        vector2(2.0, 0.0),
        vector2(1.0, 1.0)
    };
    
    VOIPath *colinear = [[VOIPath alloc] initWithPoints:colinearPoints count:4 close:YES];
    XCTAssertTrue(colinear.convex);
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

- (void)testClosedPath {
    VOIPath *path = [self.path closedPath];
    XCTAssertTrue(path.closed);
    path = [path openPath];
    XCTAssertFalse(path.closed);
    XCTAssertEqualObjects(self.path, path);
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
    VOIPoint segmentPoints[COUNT * 2];
    for (NSUInteger i = 0; i < COUNT; ++i) {
        segmentPoints[i * 2] = pathPoints[i];
        segmentPoints[i * 2 + 1] = pathPoints[(i + 1) % COUNT];
    }
    
    return [[VOISegmentList alloc] initWithPoints:segmentPoints count:(closed ? COUNT : COUNT - 1)];
}

- (void)testPointListAsPath {
    VOIPath *e = self.path;
    VOIPointList *list = [[VOIPointList alloc] initWithPoints:pathPoints count:COUNT];
    VOIPath *a = [list asPath];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointListAsClosedPath {
    VOIPath *e = [self.path closedPath];
    VOIPointList *list = [[VOIPointList alloc] initWithPoints:pathPoints count:COUNT];
    VOIPath *a = [list asClosedPath];
    XCTAssertEqualObjects(e, a);
}

- (void)testInitTriangleWithPath {
    VOITriangle *e = [[VOITriangle alloc] initWithPoints:pathPoints];
    VOIPath *path = [[self.path pointListWithRange:NSMakeRange(0, 3)] asClosedPath];
    VOITriangle *a = [[VOITriangle alloc] initWithPath:path];
    XCTAssertEqualObjects(e, a);
}

- (void)testTriangleAsPath {
    VOIPath *e = [[self.path pointListWithRange:NSMakeRange(0, 3)] asClosedPath];
    VOITriangle *triangle = [[VOITriangle alloc] initWithPoints:pathPoints];
    VOIPath *a = [triangle asPath];
    XCTAssertEqualObjects(e, a);
}

- (void)testPointInside {

    XCTAssertFalse([self.path pointInside:vector2(0.0, 0.0)]);

    VOIBox *box = [[VOIBox alloc] initWithOrigin:vector2(-2.0, -2.0) size:vector2(4.0, 4.0)];
    NSArray<VOIPath *> *paths = @[[box asPath], [self.path closedPath]];

    for (VOIPath *path in paths) {
        for (double i = -1.0; i < 2.0; i += 1.0) {
            for (double j = -1.0; j < 2.0; j += 1.0) {
                VOIPoint p = vector2(j, i);
                XCTAssertTrue([path pointInside:p], @"%@: %@", path, VOIPointToString(p));
                if (i != 0.0 || j != 0.0) {
                    p = vector2(j * 3.0, i * 3.0);
                    XCTAssertFalse([path pointInside:p], @"%@: %@", path, VOIPointToString(p));
                }
            }
        }
    }
}

@end
