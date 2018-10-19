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

@property (nonatomic) VOITriangleList *triangles;
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
        [triangles addObject:[[VOITriangle alloc] initWithPoints:tp]];
    }
    
    VOITriangleList *triangleList = [[VOITriangleList alloc] initWithTriangles:triangles];
    self.triangles = triangleList;
    
    VOITriangleNet *net012 = [VOITriangleNet netWithTriangle:triangles[0]];
    VOITriangleNet *net132 = [VOITriangleNet netWithTriangle:triangles[1]];
    VOITriangleNet *net024 = [VOITriangleNet netWithTriangle:triangles[2]];
    VOITriangleNet *net051 = [VOITriangleNet netWithTriangle:triangles[3]];
    VOITriangleNet *net163 = [VOITriangleNet netWithTriangle:triangles[4]];
    VOITriangleNet *net372 = [VOITriangleNet netWithTriangle:triangles[5]];
    
    [net372 setNet:net132 atIndex:1];
    [net132 setNet:net372 atIndex:0];

    [net163 setNet:net132 atIndex:0];
    [net132 setNet:net163 atIndex:2];

    [net051 setNet:net012 atIndex:1];
    [net012 setNet:net051 atIndex:2];

    [net024 setNet:net012 atIndex:1];
    [net012 setNet:net024 atIndex:2];
    
    [net132 setNet:net012 atIndex:1];
    [net012 setNet:net132 atIndex:1];
    
    self.net012 = net012;
    self.net132 = net132;
    self.net024 = net024;
    self.net051 = net051;
    self.net163 = net163;
    self.net372 = net372;
}

- (void)testAdjacencyAtIndex {
    VOIAdjacency *adj = [self.net051 adjacencyAtIndex:1];
    VOISegment *e = [[VOISegment alloc] initWithPoint:points[0] otherPoint:points[1]];
    VOISegment *a = adj.s;
    XCTAssertTrue([e isEquivalentToSegment:a]);
}

@end
