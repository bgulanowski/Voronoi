//
//  CircleTester.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-08.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "CircleTester.h"

#import <voronoi/DCircle.h>
#import <voronoi/DPoint.h>


@implementation CircleTester

- (void)setUp {
    [super setUp];
    _circle = [DCircle circleWithCentre:[DPoint pointWithX:0 y:0] radius:1];
}

- (void)tearDown {
    [super tearDown];
    _circle = nil;
}

- (void)circleContainsPoint:(CGPoint)p {
    XCTAssertTrue([_circle containsPoint:[DPoint pointWithX:p.x y:p.y]], @"Circle fails test for containing point %@", NSStringFromPoint(p));
}

- (void)circleNotContainsPoint:(CGPoint)p {
    XCTAssertFalse([_circle containsPoint:[DPoint pointWithX:p.x y:p.y]], @"Circle fails test for containing point %@", NSStringFromPoint(p));
}

- (void)test01Contains {
    
    [self circleContainsPoint:(CGPoint) {_circle.centre.x, _circle.centre.y }];
    
    CGPoint inside[4]  = { { 1,0 }, { 0,1 }, { -1,0 } , { 0,-1 } };
    
    for (NSUInteger i=0; i<4; ++i)
        [self circleContainsPoint:inside[i]];

    CGPoint outside[4] = { { 1,1 }, { -1,1 }, { 1,-1 }, { -1,-1 } };
    
    for (NSUInteger i=0; i<4; ++i)
        [self circleNotContainsPoint:outside[i]];
}

@end
