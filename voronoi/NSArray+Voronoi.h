//
//  NSArray+Voronoi.h
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@class BABitArray, DHull;

@interface NSArray (Triangulation)

- (NSArray *)convexHullFilterDuplicates:(BOOL)filter;
- (NSArray *)convexHull; // filter == NO

- (NSArray *)triangulationFilterDuplicates:(BOOL)filter;
- (NSArray *)triangulation; // filter == NO

- (Float64 *)rawPoints;

@end


@interface NSArray (TriangleReorienting)

- (NSUInteger)flipTriangle:(NSUInteger)index points:(NSArray *)points;
- (BABitArray *)reorientTrianglesWithPoints:(NSArray *)points;

- (NSString *)triangleDescriptionForPoints:(NSArray *)points;

- (NSUInteger *)rawTriangleIndices;

@end
