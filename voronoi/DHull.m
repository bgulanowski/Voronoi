//
//  DHull.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "DHull.h"

#import "DPoint.h"


@implementation DHull

- (NSString *)description {
    return [NSString stringWithFormat:@"[ %@ ]", [[self pointsForVertices] valueForKey:@"description"]];
}

- (id)initWithPoints:(NSArray *)points {
    self = [super init];
    if(self) {
        _points = points;
        _vertices = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSUInteger)countOfVertices {
    return [_vertices count];
}

- (DHullPoint *)objectInVerticesAtIndex:(NSUInteger)index {
    return [_vertices objectAtIndex:index];
}

- (void)addVerticesObject:(DHullPoint *)object {
    [_vertices addObject:object];
}

- (void)insertObject:(DHullPoint *)object inVerticesAtIndex:(NSUInteger)index {
    [_vertices insertObject:object atIndex:index];
}

- (void)removeLastVertex {
    [_vertices removeLastObject];
}

- (void)removeObjectFromVerticesAtIndex:(NSUInteger)index {
    [_vertices removeObjectAtIndex:index];
}

- (void)removeVerticesAtIndexes:(NSIndexSet *)indexes {
    [_vertices removeObjectsAtIndexes:indexes];
}

- (NSArray *)pointsForVertices {
    NSMutableArray *points = [NSMutableArray array];
    for (DHullPoint *hp in _vertices)
        [points addObject:[_points objectAtIndex:hp.index]];
    return points;
}

- (NSUInteger)pointIndexForIndex:(NSUInteger)index {
    if(index == [_vertices count]) index = 0;
    return [[_vertices objectAtIndex:index] index];
}

- (DPoint *)vectorToNext:(NSUInteger)index {
    
    DPoint *curr = [_points objectAtIndex:[self pointIndexForIndex:index]];
    DPoint *next  = [_points objectAtIndex:[self pointIndexForIndex:index+1]];
    
    return [next subtract:curr];
}

- (BOOL)visibleFromX:(double)dx y:(double)dy index:(NSUInteger)index {

    DPoint *vector = [self vectorToNext:index];
    
    return (-dy * vector.x + dx * vector.y) < 0;
}

- (BOOL)visibleFromPoint:(DPoint *)point index:(NSUInteger)index {
    
    NSUInteger pIndex = [[_vertices objectAtIndex:index] index];
    DPoint *curr = [_points objectAtIndex:pIndex];

    double dx = point.x - curr.x;
    double dy = point.y - curr.y;
    
    return [self visibleFromX:dx y:dy index:index];
}

+ (DHull *)hullWithPoints:(NSArray *)points {
    return [[self alloc] initWithPoints:points];
}

@end


@implementation DHullPoint

- (id)initWithIndex:(NSUInteger)index triad:(NSUInteger)triad {
    self = [super init];
    if(self) {
        _index = index;
        _triad = triad;
    }
    return self;
}

+ (DHullPoint *)hullPointWithIndex:(NSUInteger)index triad:(NSUInteger)triad {
    return [[self alloc] initWithIndex:index triad:triad];
}

+ (DHullPoint *)hullPointWithIndex:(NSUInteger)index {
    return [[self alloc] initWithIndex:index triad:0];
}

@end
