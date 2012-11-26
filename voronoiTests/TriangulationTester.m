//
//  TriangulationTester.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-08.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "TriangulationTester.h"

#import <voronoi/DPoint.h>
#import <voronoi/DTriad.h>
#import <voronoi/NSArray+Voronoi.h>

#import "VoronoiTester.h"


@implementation TriangulationTester

- (void)_test01 {
    
    NSArray *hull, *e;
    
    hull = [[VoronoiTester points3] convexHull];
    e = [VoronoiTester points3];
    
    STAssertEqualObjects(hull, e, @"hull doesn't match");
    
    hull = [[VoronoiTester points5] convexHull];
    e = @[
    [DPoint pointWithX:-6 y: 4],
    [DPoint pointWithX: 5 y: 5],
    [DPoint pointWithX: 2 y:-3],
    ];
    STAssertEqualObjects(hull, e, @"hull doesn't match");

    e = @[
    [DPoint pointWithX:-2 y: 5],
    [DPoint pointWithX: 5 y: 3],
    [DPoint pointWithX: 6 y:-3],
    [DPoint pointWithX:-1 y:-7],
    [DPoint pointWithX:-9 y:-1],
    ];
    hull = [[VoronoiTester points7] convexHull];
    STAssertEqualObjects(hull, e, @"hull doesn't match");
    
    e = @[
    [DPoint pointWithX: 3 y:-5],
    [DPoint pointWithX:-6 y:-4],
    [DPoint pointWithX:-8 y: 5],
    [DPoint pointWithX:-2 y: 6],
    [DPoint pointWithX: 7 y: 7],
    ];
    hull = [[VoronoiTester points10] convexHull];
    STAssertEqualObjects(hull, e, @"hull doesn't match");
}

//- (void)test02 {
//    
//    NSArray *pointSets = @[
//    [VoronoiTester points3],
//    [VoronoiTester points5],
//    [VoronoiTester points7],
//    [VoronoiTester points10]
//    ];
//    
//    for (NSArray *points in pointSets) {
//        
//        NSArray *tris = [points triangulation];
//        STAssertNotNil(tris, @"erm");
//        
//        STAssertTrue([tris validateTriads], @"triad validation");
//        
//        BABitArray *flipped = [tris reorientTrianglesWithPoints:points];
//        STAssertNotNil(flipped, @"whee");
//    }
//}

@end
