//
//  VoronoiTester.m
//  voronoiTests
//
//  Created by Brent Gulanowski on 12-11-08.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "VoronoiTester.h"

#import <voronoi/DPoint.h>
#import <voronoi/DRange.h>
#import <voronoi/DTriad.h>
#import <voronoi/Voronoi.h>
#import <voronoi/NSArray+Voronoi.h>


static NSArray *_points3;
static NSArray *_points5;
static NSArray *_points7;
static NSArray *_points10;


@implementation VoronoiTester

+ (void)initialize {
    if(self == [VoronoiTester class]) {
        
        CGPoint points3[3] = { { 0,0 }, { 1,0 }, { 0,1 } };
        CGPoint points5[5] = { {-6,4 }, { 3,1 }, { 2,-3}, {-2,2 }, { 5,5 } };
        
        _points3 = @[
        [DPoint pointWithCGPoint:points3[0]],
        [DPoint pointWithCGPoint:points3[1]],
        [DPoint pointWithCGPoint:points3[2]]
        ];
        _points5 = @[
        [DPoint pointWithCGPoint:points5[0]],
        [DPoint pointWithCGPoint:points5[1]],
        [DPoint pointWithCGPoint:points5[2]],
        [DPoint pointWithCGPoint:points5[3]],
        [DPoint pointWithCGPoint:points5[4]],
        ];
        
        CGPoint points7[7] = { {2,2}, {-2,5}, {6,-3}, {-1,-7}, {-9,-1}, {5,3}, {-3,-1} };
        NSMutableArray *array = [NSMutableArray array];
        for (NSUInteger i=0; i<7; ++i)
            [array addObject:[DPoint pointWithCGPoint:points7[i]]];
        _points7 = [array copy];
        
        CGPoint points[10] = { {-1,2},{7,7},{-6,4},{1,-3},{3,-5},{3,4},{-8,5},{-6,-4},{-2,6},{4,-1} };
        array = [NSMutableArray array];
        
        for (NSUInteger i=0; i<10; ++i)
            [array addObject:[DPoint pointWithCGPoint:points[i]]];
        _points10 = [array copy];
    }
}


#pragma mark - SenTestCase
//- (void)setUp {}

//- (void)tearDown {}


#pragma mark - VoronoiTester
+ (NSArray *)points3 {
    return [_points3 copy];
}

+ (NSArray *)points5 {
    return [_points5 copy];
}

+ (NSArray *)points7 {
    return [_points7 copy];
}

+ (NSArray *)points10 {
    return [_points10 copy];
}


#pragma mark - Tests
- (void)test01 {
    
    NSArray *pointSets = @[
    [VoronoiTester points5],
    [VoronoiTester points7],
    [VoronoiTester points10]
    ];
    
    DRange *range = [DRange rangeWithPoint:[DPoint pointWithX:-10 y:-10]
                                     point:[DPoint pointWithX: 10 y: 10]];
    
    for (NSArray *points in pointSets) {
        
        Voronoi *voronoi = [Voronoi voronoiWithPoints:points range:range];
        
        NSArray *regions = [voronoi regions];
        
        STAssertEquals([regions count], [points count], @"crash");
    }
}

@end
