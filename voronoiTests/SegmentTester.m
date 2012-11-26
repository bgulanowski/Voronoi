//
//  SegmentTester.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-08.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "SegmentTester.h"

#import <voronoi/DSegment.h>
#import <voronoi/DPoint.h>


@implementation SegmentTester

- (void)setUp {
    [super setUp];
    _segment = [DSegment segmentWithPoint:[DPoint pointWithX:-2 y:-1]
                                    point:[DPoint pointWithX:1 y:2]];
}

- (void)tearDown {
    [super tearDown];
    _segment = nil;
}

- (void)test01 {
    
    DPoint *p1 = [DPoint pointWithX:2 y:3];
    DPoint *p2 = [DPoint pointWithX:2-3 y:3+3];
    DSegment *e = [DSegment segmentWithPoint:p1 point:p2];
    DSegment *a = [_segment projectToPoint:p1];
    
    STAssertEqualObjects(e, a, @"%@ != %@", e, a);
}

- (void)test02 {
    
    DSegment *s2 = [DSegment segmentWithPoint:[DPoint pointWithX:1 y:0]
                                        point:[DPoint pointWithX:-1 y:2]];
    DPoint *e = [DPoint pointWithX:0 y:1];
    DPoint *a = [_segment intersection:s2];
    
    STAssertEqualObjects(e, a, @"%@ != %@", e, a);
}

@end
