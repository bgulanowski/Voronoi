//
//  DRegion.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "DRegion.h"

#import "DBoundary.h"
#import "DCircle.h"
#import "DRange.h"
#import "DSegment.h"
#import "DTriad.h"
#import "Voronoi.h"


static __strong NSNumber *notfound;


@interface DTriad (SegmentMaking)
- (DSegment *)sharedEdge:(DTriad *)other points:(NSArray *)points;
@end


@implementation DRegion {
    NSUInteger _inputIndex;
    NSMutableArray *_triads;
    NSMutableArray *_points;
}

#pragma mark - Private
- (void)clip {
    
    DRange *range = _boundary.range;
    DTriad *prev  = [_triads lastObject];
    DPoint *cPrev = prev.circumcircle.centre;
    BOOL pInRange = [range containsPoint:cPrev];
    NSUInteger index = NSNotFound;

    for (DTriad *curr in _triads) {
        
        DPoint *cCurr = curr.circumcircle.centre;
        BOOL cInRange = [range containsPoint:cCurr];

        DSegment *segment = [DSegment segmentWithPoint:cPrev point:cCurr];
        
        if(pInRange || cInRange) {
            if(pInRange)
                index = 0;
            if(!pInRange || !cInRange) {
                DPoint *intersect = [_boundary intersectWithSegment:segment index:&index];
                if(intersect)
                    [self addPoint:intersect];
            }
            if(cInRange)
                [self addPoint:cCurr];
        }
        else {
            
            DSegment *edge = [prev sharedEdge:curr points:_voronoi.points];
            DPoint *intersect = edge ? [segment intersection:edge] : nil;
            DPoint *point;
            
            if(intersect) {
                segment = [DSegment segmentWithPoint:intersect point:cPrev];
                point = [_boundary intersectWithSegment:segment index:&index];
                if(point) [self addPoint:point];
                
                segment = [DSegment segmentWithPoint:intersect point:cCurr];
                point = [_boundary intersectWithSegment:segment index:&index];
                if(point) [self addPoint:point];
            }
        
        }
        
        prev = curr;
        cPrev = cCurr;
        pInRange = cInRange;
    }
}

- (BOOL)close {
    
    DTriad *start = [_triads lastObject];
    Pivot pivot = [start pivotForIndex:_inputIndex];
    
    if(NSNotFound != [start nextIndexForPivot:pivot])
        return NO;
    
    DRange *range = _boundary.range;
    BOOL orInRange = [range containsPoint:start.circumcircle.centre];
    DTriad *trDest = [_triads objectAtIndex:0];
    BOOL destInRange = [range containsPoint:trDest.circumcircle.centre];
    
    while ([_triads count] > 1 && !orInRange) {
        [_triads removeLastObject];
        start = [_triads lastObject];
        orInRange = [range containsPoint:start.circumcircle.centre];
    }
    pivot = [start pivotForIndex:_inputIndex];
        
    while ([_triads count] > 1 && !destInRange) {
        [_triads removeObjectAtIndex:0];
        trDest = [_triads objectAtIndex:0];
        destInRange = [range containsPoint:trDest.circumcircle.centre];
    }
        
    
    NSArray *segments = nil;
    double scale = _boundary.minSizeFactor;
    
    if([_triads count] == 1 && !orInRange) {
        [_triads removeAllObjects];
        segments = [_voronoi.triads perpendicularsForTriad:start
                                                    points:_voronoi.points
                                                     pivot:pivot
                                                     scale:scale];
    }
    else {
        Pivot pivotDest = [start commonPivotForTriad:trDest pivot:pivot];
        segments = @[
        [start perpendicularFromCentreForEdge:(Edge)(pivot+1)%3+1 points:_voronoi.points scale:scale],
        [trDest perpendicularFromCentreForEdge:(Edge)pivotDest points:_voronoi.points scale:scale],
        ];
    }
    
    [_points addObjectsFromArray:[_boundary clipWithSegment:segments[0] segment:segments[1]]];
    
    NSUInteger count = [_triads count];
    
    for (NSUInteger i=0; i<count; ++i)
        [self addPoint:[[_triads objectAtIndex:i] circumcircle].centre];
    
    return YES;
}


#pragma mark - NSObject
- (NSString *)description {
    return [[_points valueForKey:@"description"] componentsJoinedByString:@", "];
}

+ (void)initialize {
    if(self == [DRegion class])
        notfound = @(NSNotFound);
}


#pragma mark - DRegion
- (id)initWithVoronoi:(Voronoi *)voronoi inputIndex:(NSUInteger)index {
    self = [self init];
    if(self) {
        _voronoi = voronoi;
        _boundary = voronoi.boundary;
        _triads = [_voronoi triadsForIndex:index];
        _points = [[NSMutableArray alloc] init];
        _inputIndex = index;
        
        if(![self close])
            [self clip];
    }
    
    return self;
}

- (void)addPoint:(DPoint *)point {
    [_points addObject:point];
}

- (void)addPoints:(NSArray *)points {
    [_points addObjectsFromArray:points];
}

- (DPoint *)pointAtIndex:(NSUInteger)index {
    return [_points objectAtIndex:index];
}

- (NSArray *)edgePoints:(NSUInteger)index {
    DPoint *prev = index ? [_points objectAtIndex:index-1] : [_points lastObject];
    return @[ prev, [_points objectAtIndex:index] ];
}

@end


@implementation DTriad (SegmentMaking)

- (DSegment *)sharedEdge:(DTriad *)other points:(NSArray *)points {
    
    NSUInteger shared[2] = { NSNotFound, NSNotFound };
    
    [self sharedPoints:shared withTriad:other];
    
    if(NSNotFound == shared[0] || NSNotFound == shared[1])
        return nil;
    
    DSegment *edge = [DSegment segmentWithPoint:[points objectAtIndex:shared[0]]
                                          point:[points objectAtIndex:shared[1]]];
    
    return edge;
}

@end
