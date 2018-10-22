//
//  VOIAdjacencyTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 2018-10-19.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VOIAdjacency.h"
#import "VOISegment.h"
#import "VOITriangle.h"

static VOIPoint points[6] = {
    
};

@interface VOIAdjacencyTester : XCTestCase

@property (nonatomic) VOITriangle *t0;
@property (nonatomic) VOITriangle *t1;
@property (nonatomic) VOITriangle *t2;
@property (nonatomic) VOIAdjacency *adjacency;

@end

@implementation VOIAdjacencyTester

+ (void)setUp {
    points[0] = vector2(0.0, 1.0); // triangle 0
    points[1] = vector2(1.0, 1.0); // triangle 1, adjacent to triangle 0
    points[2] = vector2(0.0, 0.0);
    points[3] = vector2(1.0, 0.0); // triangle 2, no adjacencies
    points[4] = vector2(2.0, 0.0);
    points[5] = vector2(2.0, 1.0);
}

- (void)setUp {
    [super setUp];
    self.t0 = [[VOITriangle alloc] initWithPoints:points];
    self.t1 = [[VOITriangle alloc] initWithPoints:&points[1]];
    self.t2 = [[VOITriangle alloc] initWithPoints:&points[3]];
    self.adjacency = [[VOIAdjacency alloc] initWithTriangle:self.t0 triangle:self.t1];
}

- (void)testProperties {
    XCTAssertEqualObjects(self.t0, self.adjacency.t0);
    XCTAssertEqualObjects(self.t1, self.adjacency.t1);
    XCTAssertEqual(0, self.adjacency.t0Index);
    XCTAssertEqual(2, self.adjacency.t1Index);
}

- (void)testDescription {
    NSString *t0d = @"VOITriangle: <(0.00, 1.00):(1.00, 1.00):(0.00, 0.00)>";
    NSString *t1d = @"VOITriangle: <(1.00, 1.00):(0.00, 0.00):(1.00, 0.00)>";
    NSString *sd = @"VOISegment: [(1.00, 1.00) -> (0.00, 0.00)]";
    NSString *e = [NSString stringWithFormat:@"VOIAdjacency: {%@:0 - %@:2; %@}", t0d, t1d, sd];
    NSString *a = self.adjacency.description;
    XCTAssertEqualObjects(e, a);
}

- (void)testEmpty {
    VOIAdjacency *a1 = [VOIAdjacency emptyAdjacency];
    VOIAdjacency *a2 = [VOIAdjacency emptyAdjacency];
    XCTAssertEqual(a1, a2);
    XCTAssertTrue(a1.empty);
    
    VOIAdjacency *a = [[VOIAdjacency alloc] initWithTriangle:nil triangle:nil];
    XCTAssertTrue(a.empty);
    XCTAssertEqualObjects(a1, a);
    
    a = [[VOIAdjacency alloc] initWithTriangle:self.t0 triangle:nil];
    XCTAssertTrue(a.empty);
    
    a = [[VOIAdjacency alloc] initWithTriangle:nil triangle:self.t1];
    XCTAssertTrue(a.empty);
}

- (void)testIsEqualToAdjacency {
    VOIAdjacency *a = [VOIAdjacency adjacencyWithTriangle:self.t0 triangle:self.t1];
    XCTAssertEqualObjects(self.adjacency, a);
    XCTAssertNotEqualObjects(self.adjacency, [VOIAdjacency emptyAdjacency]);
    a = [VOIAdjacency adjacencyWithTriangle:self.t0 triangle:self.t2];
    XCTAssertNotEqualObjects(self.adjacency, a);
    a = [VOIAdjacency adjacencyWithTriangle:self.t0 triangle:[self.t1 standardize]];
    XCTAssertNotEqualObjects(self.adjacency, a);
}

- (void)testIsEquivalentToAdjacency {
    VOIAdjacency *a = [VOIAdjacency adjacencyWithTriangle:self.t0 triangle:[self.t1 standardize]];
    XCTAssertTrue([self.adjacency isEquivalentToAdjacency:a]);
}

@end