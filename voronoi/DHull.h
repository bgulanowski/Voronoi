//
//  DHull.h
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DPoint, DHullPoint;

@interface DHull : NSObject {
    __strong NSMutableArray *_vertices; // DHullPoints
    __strong NSArray *_points;   // all DPoints
}

@property (readonly) NSArray *vertices;
@property NSArray *points;

// points is an array of DPoints, not DHullPOints
- (id)initWithPoints:(NSArray *)points;

- (NSUInteger)countOfVertices;

- (DHullPoint *)objectInVerticesAtIndex:(NSUInteger)index;

- (void)addVerticesObject:(DHullPoint *)object;
- (void)insertObject:(DHullPoint *)object inVerticesAtIndex:(NSUInteger)index;

- (void)removeLastVertex;
- (void)removeObjectFromVerticesAtIndex:(NSUInteger)index;
- (void)removeVerticesAtIndexes:(NSIndexSet *)indexes;

- (NSArray *)pointsForVertices;

- (BOOL)visibleFromX:(double)x y:(double)y index:(NSUInteger)index;
- (BOOL)visibleFromPoint:(DPoint *)point index:(NSUInteger)index;

+ (DHull *)hullWithPoints:(NSArray *)points;

@end


@interface DHullPoint : NSObject {
@public
    NSUInteger _index;
    NSUInteger _triad;
}

@property NSUInteger index;
@property NSUInteger triad;

// triad is also an index
- (id)initWithIndex:(NSUInteger)index triad:(NSUInteger)triad;

+ (DHullPoint *)hullPointWithIndex:(NSUInteger)index triad:(NSUInteger)triad;
+ (DHullPoint *)hullPointWithIndex:(NSUInteger)index;

@end
