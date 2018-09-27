//
//  DTriad.h
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef struct {
    NSUInteger p;
    NSUInteger t1;
    NSUInteger t2;
} AdjacencyInfo;


typedef enum {
    kPivotUndefined = 0,
    kPivotA = 1,
    kPivotB = 2,
    kPivotC = 3
} Pivot;



#define NextPivot(p) p%3+1
#define PrevPivot(p) (p+1)%3+1


typedef enum {
    kEdgeUndefined = 0,
    kEdgeAB = 1,
    kEdgeBC = 2,
    kEdgeCA = 3,
} Edge;

typedef enum {
    kWindingUndefined = 0,
    kWindingClockwise = 1,
    kWindingCounterCW = 2,
} Winding;


@class DCircle, DPoint, DSegment;

@interface DTriad : NSObject {
    DCircle *_circumcircle;
    NSUInteger _ab; // _ab, _bc, and _cd are indices to adjacent edges in neighbouring triangles (I think)
    NSUInteger _bc;
    NSUInteger _ca;
    NSUInteger _a; // _a, _b, and _c are indices into a list of points maintained elsewhere
    NSUInteger _b;
    NSUInteger _c;
}

@property (strong) DCircle *circumcircle;

@property NSUInteger a;
@property NSUInteger b;
@property NSUInteger c;

@property NSUInteger ab;
@property NSUInteger bc;
@property NSUInteger ca;

@property (readonly) double r2; // circumcircle.radius^2

- (id)initWithIndex:(NSUInteger)a index:(NSUInteger)b index:(NSUInteger)c;

- (Pivot)pivotForIndex:(NSUInteger)index;
- (NSUInteger)indexForPivot:(Pivot)pivot;

- (Pivot)commonPivotForTriad:(DTriad *)other pivot:(Pivot)pivot;
- (void)sharedPoints:(NSUInteger[2])points withTriad:(DTriad *)other;

- (NSUInteger)neighbourIndexForEdge:(Edge)edge;
- (NSUInteger)previousIndexForPivot:(Pivot)pivot;
- (NSUInteger)nextIndexForPivot:(Pivot)pivot;

- (void)reverseWinding;

- (void)changeAdjacent:(NSUInteger)neighbour index:(NSUInteger)index;
- (AdjacencyInfo)adjacencyForPoint:(NSUInteger)pointIdx neighbour:(NSUInteger)triangleIdx;

- (DSegment *)perpendicularFromCentreForEdge:(Edge)edge points:(NSArray *)points scale:(NSUInteger)scale;

+ (DTriad *)triadWithIndex:(NSUInteger)a index:(NSUInteger)b index:(NSUInteger)c;
+ (DTriad *)triadWithIndices:(NSUInteger[3])indices forPoints:(NSArray *)points;

@end


@interface NSArray (TriadWalking)

- (DTriad *)neighbourForIndex:(NSUInteger)index edge:(Edge)edge;
- (DTriad *)previousForIndex:(NSUInteger)index pivot:(Pivot)pivot;
- (DTriad *)nextForIndex:(NSUInteger)index pivot:(Pivot)pivot;

// loop through previous triads until the end
- (DTriad *)firstForIndex:(NSUInteger)index pivot:(Pivot)pivot;
- (NSMutableArray *)triadsAdjacentToIndex:(NSUInteger)index pivot:(Pivot)pivot;

- (NSArray *)perpendicularsForTriad:(DTriad *)triad points:(NSArray *)points pivot:(Pivot)pivot scale:(double)scale;

// Debugging
- (BOOL)validateTriad:(DTriad *)triad index:(NSUInteger)index;
- (BOOL)validateTriads;

@end


@interface NSArray (PointInspecting)

- (Winding)windingForPoints:(NSArray *)points;
- (Winding)windingForPointsAtIndices:(NSUInteger[3])indices;
- (Winding)windingForTriad:(DTriad *)triad;
- (DCircle *)circumCircleForPointsAtIndices:(NSUInteger[3])indices;
- (void)updateCircumcircle:(DTriad *)triad;
- (DTriad *)triadWithIndices:(NSUInteger[3])indices;

@end
