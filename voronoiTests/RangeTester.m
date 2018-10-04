//
//  RangeTester.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-08.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "RangeTester.h"

#import <voronoi/DPoint.h>
#import <voronoi/DRange.h>


@implementation RangeTester

- (void)setUp {
    [super setUp];
    _range = [DRange rangeWithPoint:[DPoint pointWithX:-1 y:-1] point:[DPoint pointWithX:1 y:1]];
}

- (void)tearDown {
    [super tearDown];
    _range = nil;
}

- (void)test01 {
    
    double e = 2.0 * sqrt(2.0);
    double a = [_range length];
    
    XCTAssertEqual(e, a, @"%.5f != %.5f", e, a);
    
    e = 8.0;
    a = [_range lengthSquared];
    
    XCTAssertEqual(e, a, @"%.5f != %.5f", e, a);
}

- (void)test02 {
    
    XCTAssertTrue([_range containsPoint:_range.p0], @"%@ contains %@", _range, _range.p0);
    XCTAssertTrue([_range containsPoint:_range.p1], @"%@ contains %@", _range, _range.p1);
    
    DPoint *p = [DPoint pointWithX:0 y:0];
    
    XCTAssertTrue([_range containsPoint:p], @"%@ contains %@", _range, p);
}

@end
