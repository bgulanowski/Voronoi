//
//  DRegion.h
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DPoint, DBoundary, Voronoi;

@interface DRegion : NSObject

@property (readonly) Voronoi *voronoi;
@property (readonly) DBoundary *boundary;
@property (readonly) NSArray *triads;
@property (readonly) NSArray *points;
@property (readonly) NSUInteger count;

- (id)initWithVoronoi:(Voronoi *)voronoi inputIndex:(NSUInteger)index;

- (void)addPoint:(DPoint *)point;
- (void)addPoints:(NSArray *)points;

- (DPoint *)pointAtIndex:(NSUInteger)index;
- (NSArray *)edgePoints:(NSUInteger)index;

@end
