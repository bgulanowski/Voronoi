//
//  VoronoiTester.h
//  voronoiTests
//
//  Created by Brent Gulanowski on 12-11-08.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import <XCTest/XCTest.h>


@class Voronoi;

@interface VoronoiTester : XCTestCase

+ (NSArray *)points3;
+ (NSArray *)points5;
+ (NSArray *)points7;
+ (NSArray *)points10;

@end
