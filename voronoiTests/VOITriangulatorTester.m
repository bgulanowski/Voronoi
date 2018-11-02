//
//  VOITriangulatorTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-06.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOIBox.h"
#import "VOIPointList.h"
#import "VOITriangle.h"
#import "VOITriangleList.h"
#import "VOITriangulator.h"

#import "DPoint.h"
#import "DRange.h"
#import "DTriad.h"
#import "Voronoi.h"

@interface VOITriangulatorTester : XCTestCase
@property VOITriangulator *triangulator;
@end

const NSUInteger T_COUNT = 9;

static VOIPoint t_points[T_COUNT];
static VOIPointList *randomPointsList;
static Voronoi *voronoi;

@interface Voronoi (TriangulatorTest)
+ (instancetype)voronoiWithPointList:(VOIPointList *)pList;
- (NSArray<VOITriangle *> *)triangles;
@end

@implementation VOITriangulatorTester

+ (void)setUp {
    [super setUp];
    NSUInteger i = 0;
    // TODO - randomly generate, create triads with old code,
    // convert to triangles, compare to new triangles
    t_points[i++] = vector2(  23.0,  87.0);
    t_points[i++] = vector2( 858.0, 594.0);
    t_points[i++] = vector2(1088.0, 639.0);
    t_points[i++] = vector2( 352.0, 172.0);
    t_points[i++] = vector2(1197.0, 761.0);
    t_points[i++] = vector2(1029.0, 628.0);
    t_points[i++] = vector2( 811.0, 696.0);
    t_points[i++] = vector2(  69.0,  86.0);
    t_points[i++] = vector2( 436.0, 175.0);
    NSAssert(i == T_COUNT, @"Inconsistent start data");
    
    randomPointsList = [self randomPoints];
    voronoi = [Voronoi voronoiWithPointList:randomPointsList];
}

+ (VOIPointList *)randomPoints {
#define pCount 16
    srandom(31415);
    VOIBox *boundary = [[VOIBox alloc] initWithOrigin:vector2(-64.0, -64.0) size:vector2(64.0, 64.0)];
    VOIPoint *points = malloc(pCount * sizeof(VOIPoint));
    for (NSUInteger i = 0; i < 16; ++i) {
        points[i] = round([boundary randomPoint]);
    }
    
    VOIPointList *result = [[VOIPointList alloc] initWithPoints:points count:pCount];
    free(points);
    return result;
}

- (void)setUp {
    [super setUp];
    VOIPointList *pl = [[VOIPointList alloc] initWithPoints:t_points count:T_COUNT];
    self.triangulator = [[VOITriangulator alloc] initWithPointList:pl];
}

//- (void)testTriangulate2 {}

- (void)testTriangulate3 {
    VOIPoint points[3] = {
        vector2(0.0, 0.0),
        vector2(3.0, 1.0),
        vector2(4.0, 4.0)
    };
    NSArray *e = @[[[VOITriangle alloc] initWithPoints:points standardize:YES]];
    VOIPointList *l = [[VOIPointList alloc] initWithPoints:points count:3];
    VOITriangulator *t = [[VOITriangulator alloc] initWithPointList:l];
    NSArray *a = [[t triangulate] allTriangles];
    XCTAssertEqualObjects(e, a);
}

- (void)testTriangulate4NoFlip {
    VOIPoint points[4] = {
        vector2(0.0, 1.0),
        vector2(1.0, 0.0),
        vector2(2.0, 1.0),
        vector2(1.0, 2.0)
    };
    VOIPointList *l = [[VOIPointList alloc] initWithPoints:points count:4];
    VOITriangleList *tList = [l asTriangleFan];
    NSArray *e = [tList orderedTriangles];
    VOITriangulator *t = [[VOITriangulator alloc] initWithPointList:l];
    NSArray *a = [[t triangulate] orderedTriangles];
    XCTAssertEqualObjects(e, a);
}

- (void)testTriangulate4Flip {
    VOIPoint points[4] = {
        vector2(0.0, 1.0),
        vector2(1.0, 3.0),
        vector2(2.0, 1.0),
        vector2(1.0, 0.0)
    };
    VOIPointList *l = [[VOIPointList alloc] initWithPoints:points count:4];
    VOITriangleList *tList = [l asTriangleFan];
    NSArray *e = [tList orderedTriangles];
    VOITriangulator *t = [[VOITriangulator alloc] initWithPointList:l];
    NSArray *a = [[t triangulate] orderedTriangles];
    XCTAssertEqualObjects(e, a);
} 

- (void)testTriangulate6 {
    
    VOIPoint points[6] = {
        vector2(0.0, 0.0),
        vector2(2.0, -2.0),
        vector2(3.0, 2.0),
        vector2(1.0, 4.0),
        vector2(-2.0, -3.0),
        vector2(3.0, -5.0)
    };
    const NSUInteger triCount = 6;
    const VOIPoint triangles[triCount][3] = {
        { points[0], points[1], points[2] },
        { points[0], points[2], points[3] },
        { points[0], points[3], points[4] },
        { points[0], points[4], points[1] },
        { points[1], points[4], points[5] },
        { points[1], points[2], points[5] }
    };
    VOITriangleList *tList = [[VOITriangleList alloc] initWithPoints:(VOIPoint *)triangles count:triCount];
    NSArray *e = [tList orderedTriangles];
    VOIPointList *pList = [[VOIPointList alloc] initWithPoints:points count:6];
    VOITriangulator *t = [[VOITriangulator alloc] initWithPointList:pList];
    NSArray *a = [[t triangulate] orderedTriangles];
    XCTAssertEqualObjects(e, a);
}

- (void)testTriangulate {
    
    VOITriangleList *aList = [self.triangulator triangulate];
    XCTAssertTrue(self.triangulator.minimized);
    
    NSArray *e = [[Voronoi voronoiWithPointList:_triangulator.pointList] triangles];
    NSArray *a = [aList orderedTriangles];
    
    XCTAssertEqualObjects(e, a);
}

- (void)testTriangulateRandom16 {
    VOITriangulator *triangulator = [[VOITriangulator alloc] initWithPointList:randomPointsList];
    XCTAssertNoThrow([triangulator triangulate]);
    XCTAssertTrue(triangulator.minimized);
    
    NSArray *triangles = [[triangulator triangulate] orderedTriangles];
    NSArray *e = [[Voronoi voronoiWithPointList:randomPointsList] triangles];
    
    XCTAssertEqualObjects(e, triangles);
}

- (void)_testTriangulateRandom16Loops {
    
    const NSUInteger Count = 16;
    BOOL fail = NO;
    VOIBox *box = [[VOIBox alloc] initWithOrigin:0.0 size:2.0 * Count];
    for (NSUInteger n = 0; n < 8; ++n) {
        VOIPointList *points = [VOIPointList randomPointsInBox:box count:Count integral:YES];
        for (NSUInteger i = 11; i < Count; ++i) {
            
            VOIPointList *selection = [points selectRange:NSMakeRange(0, i)];
            NSArray *e = [[Voronoi voronoiWithPointList:selection] triangles];
            
            VOITriangulator *t = [[VOITriangulator alloc] initWithPointList:selection];
            XCTAssertNoThrow([t triangulate]);
            XCTAssertTrue(t.minimized);
            
            NSArray *a = [[t triangulate] orderedTriangles];
            NSEnumerator *iter = [e objectEnumerator];
            for (VOITriangle *ta in a) {
                VOITriangle *te = [iter nextObject];
                if (![ta isEqualToTriangle:te]) {
                    XCTFail(@"Discrepancy at %td: %@ vs %@", i, ta, te);
                    fail = YES;
                    break;
                }
            }
            if (fail) break;
            
        }
        if (fail) break;
    }
}

- (void)_testTriangulateNext {
    const NSUInteger Count = 16;
    VOIBox *box = [[VOIBox alloc] initWithOrigin:0.0 size:2.0 * Count];
    VOIPointList *pl = [VOIPointList randomPointsInBox:box count:Count integral:YES];
    
    VOITriangulator *triangulator = [[VOITriangulator alloc] initWithPointList:pl];
    XCTAssertNoThrow([triangulator triangulate]);
    XCTAssertTrue(triangulator.minimized);
    
    NSArray *a = [[triangulator triangulate] orderedTriangles];
    NSArray *e = [[Voronoi voronoiWithPointList:pl] triangles];
    
//    XCTAssertEqualObjects(e, triangles);
    for (NSUInteger i = 0; i < Count; ++i) {
        VOITriangle *ta = a[i];
        VOITriangle *te = e[i];
        if (![ta isEqualToTriangle:te]) {
            XCTFail(@"Discrepancy at %td: %@ vs %@", i, ta, te);
            break;
        }
    }
}

// Disabled because not enough points working yet
- (void)_testTriangulationPerformance {
    VOIBox *box = [[VOIBox alloc] initWithOrigin:0.0 size:128.0];
    VOIPointList *pl = [VOIPointList randomPointsInBox:box count:128 integral:YES];
    [self measureBlock:^{
        VOITriangulator *t = [[VOITriangulator alloc] initWithPointList:pl];
        [t triangulate];
    }];
}

@end

@implementation Voronoi (VOTriangleTester)

+ (instancetype)voronoiWithPointList:(VOIPointList *)pList {
    
    NSMutableArray *dPoints = [NSMutableArray array];
    [pList iteratePoints:^(const VOIPoint *p, const NSUInteger i) {
        DPoint *dp = [DPoint pointWithX:p->x y:p->y];
        [dPoints addObject:dp];
        return NO;
    }];
    
    VOIBox *box = pList.boundingBox;
    
    DPoint *ll = [DPoint pointWithX:box.minX y:box.minY];
    DPoint *ur = [DPoint pointWithX:box.maxX y:box.maxY];
    DRange *r = [DRange rangeWithPoint:ll point:ur];
    
    return [Voronoi voronoiWithPoints:dPoints range:r];
}

- (NSArray<VOITriangle *> *)triangles {
    
    NSArray<DPoint *> *dPoints = [self points];

    NSMutableArray *triangles = [NSMutableArray array];
    for (DTriad *triad in [self triads]) {
        DPoint *a = dPoints[triad.a];
        DPoint *b = dPoints[triad.b];
        DPoint *c = dPoints[triad.c];
        VOIPoint tp[3] = {
            vector2(a.x, a.y),
            vector2(b.x, b.y),
            vector2(c.x, c.y)
        };
        VOITriangle *t = [[VOITriangle alloc] initWithPoints:tp standardize:YES];
        [triangles addObject:t];
    }

    [triangles sortUsingSelector:@selector(compare:)];
    
    return triangles;
}

@end
