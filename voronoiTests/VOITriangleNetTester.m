//
//  VOITriangleNetTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-18.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOIAdjacency.h"
#import "VOISegment.h"
#import "VOITriangle.h"
#import "VOITriangleList.h"
#import "VOITriangleNet.h"

@interface VOITriangleNetTester : XCTestCase

@property (nonatomic) NSArray<VOITriangle *> *triangles;
@property (nonatomic) VOITriangleNet *net012;
@property (nonatomic) VOITriangleNet *net132;
@property (nonatomic) VOITriangleNet *net024;
@property (nonatomic) VOITriangleNet *net051;
@property (nonatomic) VOITriangleNet *net163;
@property (nonatomic) VOITriangleNet *net372;

@end

VOIPoint points[8];
NSUInteger indices[18];

@implementation VOITriangleNetTester

+ (void)setUp {
    [super setUp];
    
    points[0] = vector2( 0.0,  0.0);
    points[1] = vector2( 2.0,  0.0);
    points[2] = vector2( 0.0,  2.0);
    points[3] = vector2( 2.0,  2.0);
    points[4] = vector2(-1.0,  1.0);
    points[5] = vector2( 1.0, -1.0);
    points[6] = vector2( 3.0,  1.0);
    points[7] = vector2( 1.0,  3.0);
    
    indices[ 0] = 0;
    indices[ 1] = 1;
    indices[ 2] = 2;
    
    indices[ 3] = 1;
    indices[ 4] = 3;
    indices[ 5] = 2;
    
    indices[ 6] = 0;
    indices[ 7] = 2;
    indices[ 8] = 4;
    
    indices[ 9] = 0;
    indices[10] = 5;
    indices[11] = 1;
    
    indices[12] = 1;
    indices[13] = 6;
    indices[14] = 3;
    
    indices[15] = 3;
    indices[16] = 7;
    indices[17] = 2;
}

- (void)setUp {
    [super setUp];
    
    NSMutableArray<VOITriangle *> *triangles = [NSMutableArray array];
    for (NSUInteger i = 0; i < 6; ++i) {
        VOIPoint tp[3] = {
            points[indices[i * 3]],
            points[indices[i * 3 + 1]],
            points[indices[i * 3 + 2]]
        };
        [triangles addObject:[[VOITriangle alloc] initWithPoints:tp standardize:YES]];
    }
    self.triangles = triangles;
    
    self.net012 = [VOITriangleNet netWithTriangle:triangles[0]];
    self.net132 = [VOITriangleNet netWithTriangle:triangles[1]];
    self.net024 = [VOITriangleNet netWithTriangle:triangles[2]];
    self.net051 = [VOITriangleNet netWithTriangle:triangles[3]];
    self.net163 = [VOITriangleNet netWithTriangle:triangles[4]];
    self.net372 = [VOITriangleNet netWithTriangle:triangles[5]];
}

- (void)testTriangle {
    VOITriangle *e = [self.triangles[0] standardize];
    VOITriangle *a = self.net012.triangle;
    XCTAssertEqualObjects(e, a);
}

- (void)testAddAdjacentNet {
    [self.net012 addAdjacentNet:self.net132];
    XCTAssertEqualObjects(self.net132, self.net012.n0);
    XCTAssertNil(self.net012.n1);
    XCTAssertNil(self.net012.n2);
    XCTAssertEqualObjects(@[self.net132], self.net012.adjacentNets);
    
    XCTAssertEqualObjects(self.net012, self.net132.n1);
    XCTAssertNil(self.net132.n0);
    XCTAssertNil(self.net132.n2);
    XCTAssertEqualObjects(@[self.net012], self.net132.adjacentNets);

    [self.net012 addAdjacentNet:self.net372];
    XCTAssertEqualObjects(self.net132, self.net012.n0);
    XCTAssertNil(self.net012.n1);
    XCTAssertNil(self.net012.n2);
    XCTAssertEqualObjects(@[self.net132], self.net012.adjacentNets);
    
    XCTAssertNil(self.net372.n0);
    XCTAssertNil(self.net372.n1);
    XCTAssertNil(self.net372.n2);
    XCTAssertEqualObjects(@[], self.net372.adjacentNets);
}

- (void)testAdjacencyAtIndex {
    [self.net012 addAdjacentNet:self.net051];
    VOIAdjacency *adj = [self.net051 adjacencyAtIndex:2];
    VOISegment *e = [[VOISegment alloc] initWithPoint:points[0] otherPoint:points[1]];
    VOISegment *a = adj.s;
    XCTAssertTrue([e isEquivalentToSegment:a]);
}

- (void)testFlipNone {
    XCTAssertNoThrow([self.net012 flipWith:0]);
}

- (void)testFlipTwo {
    VOIPoint tp[4] = {
        points[2],
        points[0],
        points[3],
        points[1]
    };

    [self.net012 addAdjacentNet:self.net132];
    [self.net012 flipWith:0];
    
    VOITriangle *e = [[VOITriangle alloc] initWithPoints:tp standardize:YES];
    VOITriangle *a = self.net012.triangle;
    XCTAssertEqualObjects(e, a);
    
    e = [[VOITriangle alloc] initWithPoints:&tp[1] standardize:YES];
    a = self.net132.triangle;
    XCTAssertEqualObjects(e, a);
}

- (void)testFlipTwoOpposite {
    VOIPoint tp[4] = {
        points[2],
        points[0],
        points[3],
        points[1]
    };
    
    [self.net132 addAdjacentNet:self.net012];
    [self.net132 flipWith:1];
    
    VOITriangle *e = [[VOITriangle alloc] initWithPoints:tp standardize:YES];
    VOITriangle *a = self.net012.triangle;
    XCTAssertEqualObjects(e, a);
    
    e = [[VOITriangle alloc] initWithPoints:&tp[1] standardize:YES];
    a = self.net132.triangle;
    XCTAssertEqualObjects(e, a);
}

- (void)testFlipThree {
    [self.net132 addAdjacentNet:self.net012];
    [self.net012 addAdjacentNet:self.net051];
    [self.net012 flipWith:0];
    
    XCTAssertEqualObjects(@[self.net132], self.net012.adjacentNets);
    NSArray *nets = @[self.net051, self.net012];
    XCTAssertEqualObjects(nets, self.net132.adjacentNets);
}

- (void)testFlip {

    [self.net012 addAdjacentNets:@[self.net024, self.net051, self.net132]];
    [self.net132 addAdjacentNets:@[self.net163, self.net372]];
    
    // net012.n0 is adjacent to net132
    [self.net012 flipWith:0];

    VOIPoint tp[4] = {
        points[2],
        points[0],
        points[3],
        points[1]
    };
    VOITriangle *e = [[VOITriangle alloc] initWithPoints:tp standardize:YES];
    VOITriangle *a = self.net012.triangle;
    XCTAssertEqualObjects(e, a);
    
    e = [[VOITriangle alloc] initWithPoints:&tp[1] standardize:YES];
    a = self.net132.triangle;
    XCTAssertEqualObjects(e, a);
    
    XCTAssertEqualObjects(self.net372, self.net012.n0);
    XCTAssertEqualObjects(self.net132, self.net012.n1);
    XCTAssertEqualObjects(self.net024, self.net012.n2);
    
    XCTAssertEqualObjects(self.net163, self.net132.n0);
    XCTAssertEqualObjects(self.net051, self.net132.n1);
    XCTAssertEqualObjects(self.net012, self.net132.n2);
}

- (void)testMinimize {
    
    [self.net012 addAdjacentNets:@[self.net024, self.net051, self.net132]];
    [self.net132 addAdjacentNets:@[self.net163, self.net372]];

    XCTAssertTrue(self.net012.minimized);
    // net012.n2 is adjacent to net024
    [self.net012 flipWith:2];
    XCTAssertFalse(self.net012.minimized);

    VOIPoint tp[3] = { points[4], points[1], points[0] };
    VOITriangle *e = [[VOITriangle alloc] initWithPoints:tp];
    VOITriangle *a = self.net012.triangle;
    XCTAssertEqualObjects(e, a);
    
    tp[0] = points[4]; tp[1] = points[2]; tp[2] = points[1];
    e = [[VOITriangle alloc] initWithPoints:tp];
    a = self.net024.triangle;
    XCTAssertEqualObjects(e, a);
    
    XCTAssertTrue(self.net132.minimized);
    // net132.n2 is adjacent to net372
    [self.net132 flipWith:2];
    XCTAssertFalse(self.net132.minimized);
    
    tp[0] = points[2]; tp[1] = points[7]; tp[2] = points[1];
    e = [[VOITriangle alloc] initWithPoints:tp];
    a = self.net132.triangle;
    XCTAssertEqualObjects(e, a);

    tp[0] = points[7]; tp[1] = points[3]; tp[2] = points[1];
    e = [[VOITriangle alloc] initWithPoints:tp];
    a = self.net372.triangle;
    XCTAssertEqualObjects(e, a);
    
    [self.net012 minimize];
    [self.net132 minimize];
    
    NSArray *et = [[self.triangles valueForKey:@"standardize"] sortedArrayUsingSelector:@selector(compare:)];
    NSArray *nets = @[self.net012, self.net132, self.net024, self.net051, self.net163, self.net372];
    NSArray *at = [[nets valueForKey:@"triangle"] sortedArrayUsingSelector:@selector(compare:)];
    
    XCTAssertEqualObjects(et, at);
}

@end
