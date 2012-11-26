//
//  SegmentTester.h
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-08.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>


@class DSegment;

@interface SegmentTester : SenTestCase {
    __strong DSegment *_segment;
}

@end
