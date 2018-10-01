//
//  Voronoi.h
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DBoundary, DRange, DRegion;

@interface Voronoi : NSObject

@property (readonly) DBoundary *boundary;

@property (readonly) NSArray *points;
@property (readonly) NSArray *triads;
@property (readonly) NSArray *regions;

- (id)initWithPoints:(NSArray *)points range:(DRange *)range;
- (NSMutableArray *)triadsForIndex:(NSUInteger)index;

+ (Voronoi *)voronoiWithPoints:(NSArray *)points range:(DRange *)range;

@end
