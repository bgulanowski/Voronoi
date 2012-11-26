//
//  Voronoi.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "Voronoi.h"

#import "NSArray+Voronoi.h"
#import "DBoundary.h"
#import "DCircle.h"
#import "DPoint.h"
#import "DRange.h"
#import "DRegion.h"
#import "DSegment.h"
#import "DTriad.h"


@implementation Voronoi

#pragma mark - Private

- (void)indexTriads {
    
    NSUInteger remain = [_points count];
    
    if(_indexedTriads) free(_indexedTriads);
        
    // Because kPivotUndefined == 0, the pivots are already initialized by calloc()
    size_t count = [_points count];
    _indexedTriads = calloc(count*2,sizeof(NSUInteger));
    for(NSUInteger i=0; i<count; ++i)
        _indexedTriads[i*2] = NSNotFound;
    
    NSUInteger i=0;
    
    for (DTriad *triad in _triads) {
        if(_indexedTriads[2*triad.a] == NSNotFound) {
            _indexedTriads[2*triad.a] = i;
            _indexedTriads[2*triad.a+1] = kPivotA;
            --remain;
        }
        if(_indexedTriads[2*triad.b] == NSNotFound) {
            _indexedTriads[2*triad.b] = i;
            _indexedTriads[2*triad.b+1] = kPivotB;
            --remain;
        }
        if(_indexedTriads[2*triad.c] == NSNotFound) {
            _indexedTriads[2*triad.c] = i;
            _indexedTriads[2*triad.c + 1] = kPivotC;
            --remain;
        }
        
        if(!remain) break;
        
        ++i;
    }
}

- (DRegion *)regionForPointIndex:(NSUInteger)index {
    
    if(_regions)
        return [_regions objectAtIndex:index];
    
    return [[DRegion alloc] initWithVoronoi:self inputIndex:index];
}


#pragma mark - Accessors
- (NSArray *)regions {
    
    if(!_regions) {
        
        NSMutableArray *regions = [NSMutableArray array];
        NSUInteger pCount = [_points count];
        
        for (NSUInteger i=0; i<pCount; ++i)
            [regions addObject:[self regionForPointIndex:i]];
        
        _regions = [regions copy];
    }
    
    return [_regions copy];
}

- (NSArray *)triads {
    if(!_triads) {
        _triads = [_points triangulation];
        [_triads reorientTrianglesWithPoints:_points];
        [self indexTriads];
    }
    return [_triads copy];
}


#pragma mark - NSObject
- (void)dealloc {
    if(_indexedTriads) free(_indexedTriads);
}

-(NSString *)description {
    return [NSString stringWithFormat:@"Voronoi (range: %@):\n\tPoints:\n%@\n\tTriads:\n%@\n\tRegions:\n%@", _boundary.range, _points, _triads, _regions];
}


#pragma mark - Voronoi
- (id)initWithPoints:(NSArray *)points range:(DRange *)range {
    self = [self init];
    if(self) {
        _boundary = [DBoundary boundaryWithRange:range];
        _points = [points copy];
    }
    return self;
}

- (NSMutableArray *)triadsForIndex:(NSUInteger)index {
    
    NSMutableArray *triads;
    
    if([self.triads count] == 1)
        triads = [self.triads mutableCopy];
    else
        triads = [self.triads triadsAdjacentToIndex:_indexedTriads[2*index]
                                              pivot:(Pivot)_indexedTriads[2*index+1]];
    
    if([self.triads count] > 1)
        NSAssert([triads count] > 1, @"invalid number of triads for region");
    
    return triads;
}

+ (Voronoi *)voronoiWithPoints:(NSArray *)points range:(DRange *)range {
    return [[self alloc] initWithPoints:points range:range];
}

@end
