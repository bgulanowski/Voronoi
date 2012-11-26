//
//  PointTester.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-08.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "PointTester.h"

#import <voronoi/DPoint.h>


@implementation PointTester

- (void)setUp {
    [super setUp];
    _point = [DPoint pointWithX:0 y:0];
}

- (void)tearDown {
    [super tearDown];
    _point = nil;
}

- (void)test01Equality {
    
    DPoint *p1 = [DPoint pointWithCGPoint:CGPointZero];
    DPoint *p2 = [DPoint pointWithX:0 y:0];
    DPoint *p3 = [_point copy];
    
    STAssertEqualObjects(_point, p1, @"%@ != %@", _point, p1);
    STAssertEqualObjects(_point, p2, @"%@ != %@", _point, p2);
    STAssertEqualObjects(_point, p3, @"%@ != %@", _point, p3);
    STAssertEqualObjects(p1, p2, @"%@ != %@", p1, p2);
}

- (void)test02Addition {
    
    DPoint *p1 = [_point copy];
    DPoint *p2 = [DPoint pointWithX:4 y:4];
    
    DPoint *p3 = [_point add:p1];
    
    STAssertEqualObjects(_point, p3, @"%@ != %@", _point, p3);
    
    p3 = [_point add:p2];
    
    STAssertEqualObjects(p2, p3, @"%@ != %@", p2, p3);
    
    p3 = [p2 add:p2];
    
    STAssertTrue(p3.x == 8 && p3.y == 8, @"%@ should be (8,8)", p3);
}

@end
