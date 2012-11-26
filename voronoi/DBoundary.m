//
//  DBoundary.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-09.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "DBoundary.h"

#import "DPoint.h"
#import "DRange.h"
#import "DSegment.h"


@implementation DBoundary

+ (NSMutableArray *)segmentsForRange:(DRange *)range {
    
    NSMutableArray *array = [NSMutableArray array];
    
    DPoint *p1 = [DPoint pointWithX:range.xMin y:range.yMax];
    DPoint *p2 = range.max;
    DPoint *p3 = [DPoint pointWithX:range.xMax y:range.yMin];
    DPoint *p4 = range.min;
    
    [array addObject:[DSegment segmentWithPoint:p1 point:p2]];
    [array addObject:[DSegment segmentWithPoint:p2 point:p3]];
    [array addObject:[DSegment segmentWithPoint:p3 point:p4]];
    [array addObject:[DSegment segmentWithPoint:p4 point:p1]];
    
    return array;
}

- (id)initWithRange:(DRange *)range {
    self = [self init];
    if(self) {
        _range = range;
        _minSizeFactor = range.width + range.height;
        _segments = [DBoundary segmentsForRange:range];
    }
    return self;
}

- (DPoint *)intersectWithSegment:(DSegment *)segment index:(NSUInteger *)pIndex clipPoints:(NSMutableArray *)clipPoints {
    
    DPoint *result;
    NSUInteger start = pIndex && *pIndex != NSNotFound ? (*pIndex) : 0;
    NSUInteger count = [_segments count];
    NSUInteger limit = start == 0 ? count : start+count;
    
    for (NSUInteger i=start; i<limit; ++i) {
        DSegment *edge = [_segments objectAtIndex:i%count];
        if((result = [edge intersection:segment]) != nil) {
            if(pIndex) *pIndex = i;
            return result;
        }
        else if(clipPoints)
            [clipPoints addObject:edge.p1];
    }
    
    return nil;
}

- (DPoint *)intersectWithSegment:(DSegment *)segment index:(NSUInteger *)pIndex {
    return [self intersectWithSegment:segment index:pIndex clipPoints:nil];
}

- (NSArray *)clipWithSegment:(DSegment *)s1 segment:(DSegment *)s2 {
    
    NSMutableArray *array = [NSMutableArray array];
    NSUInteger current = 0, start;
    DPoint *p;
    
    while(nil == (p = [self intersectWithSegment:s1 index:&current])) {
        if(current == 0)
            return array;
    }
    start = current;
    
    [array addObject:p];
    
    p = [self intersectWithSegment:s2 index:&current clipPoints:array];
    
    if(p)
        [array addObject:p];
    
    return array;
}

+ (DBoundary *)boundaryWithRange:(DRange *)range {
    return [[self alloc] initWithRange:range];
}

@end
