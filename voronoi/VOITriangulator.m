//
//  VOITriangulator.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-05.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOITriangulator.h"

#import "VOIAdjacency.h"
#import "VOIPath.h"
#import "VOIPointList.h"
#import "VOISegment.h"
#import "VOITriangle.h"
#import "VOITriangleList.h"
#import "VOITriangleNet.h"

#import "VOIRange.h"

@interface VOITriangulator ()

@property VOITriangleList *triangulation;
@property VOIPath *convexHull;
@property VOIPath *oldHull;
@property NSMutableSet<VOITriangleNet *> *nets;
// indexed by segment.hashKey
@property NSArray<VOITriangleNet *> *borderNets;

@property NSUInteger fileNumber;

@end

@implementation VOITriangulator

- (BOOL)minimized {
    return [_nets count] > 0 && ![[_nets valueForKey:@"minimized"] containsObject:@NO];
}

- (instancetype)initWithPointList:(VOIPointList *)pointList {
    self = [super init];
    if (self) {
        _pointList = pointList;
        _nets = [NSMutableSet set];
    }
    return self;
}

- (VOITriangleList *)triangulate {
    return _triangulation ?: [self generateTriangulation];
}

- (VOITriangleList *)generateTriangulation {
    
    NSMutableIndexSet *indices = [NSMutableIndexSet indexSet];
    VOITriangle *seedTriangle = [self seedTriangleIndices:indices];
    [self registerSeedTriangle:seedTriangle];

    VOIPointList *remaining = [_pointList deleteIndices:indices];
    remaining = [remaining sortedByDistanceFrom:seedTriangle.centre];
    [self addTrianglesFromPoints:remaining];

    _triangulation = [[VOITriangleList alloc] initWithTriangles:[self.nets valueForKey:@"triangle"]];
    return _triangulation;
}

- (VOITriangle *)seedTriangleIndices:(NSMutableIndexSet *)indices {
    
    VOIPoint points[3];
    NSUInteger index = NSNotFound;
    
#if 1
    points[0] = [_pointList pointAtIndex:0];
    [indices addIndex: 0];
#else
    // The first point is arbitrary. Chose the closest to centre for aesthetic reasons.
    points[0] = [_pointList pointClosestToPoint:_pointList.centre index:&index ignoreIfEqual:NO];
    [indices addIndex:index];
#endif
    // The second point is the closest to the first point
    points[1] = [_pointList pointClosestToPoint:points[0] index:&index];
    [indices addIndex:index];
    
    VOIPoint *pPoints = points;
    __block NSUInteger index3 = NSNotFound;
    __block double delta = (double)INFINITY;
    // Find a third point that creates the triangle with the smallest circumcircle (centre)
    // All other points will be outside of this circle, seeding our triangulation
    [_pointList iteratePoints:^(const VOIPoint *p, const NSUInteger i) {
        if (![indices containsIndex:i]) {
            pPoints[2] = *p;
            VOIPoint c = VOICentrePoint(pPoints);
            double d = simd_distance_squared(*p, c);
            if (d < delta) {
                delta = d;
                index3 = i;
            }
        }
        return NO;
    }];
    
    [indices addIndex:index3];

    return [_pointList triangleForIndexSet:indices];
}

// Points should already be sorted by distance from seed triangle
- (void)addTrianglesFromPoints:(VOIPointList *)points {
    [points iteratePoints:^BOOL(const VOIPoint *p, const NSUInteger i) {
        [self addPointToHull:*p];
        
        if (self.exportTriangles) {
            [self writeTriangles:[self.nets valueForKey:@"triangle"]];
        }

        return NO;
    }];
}

- (void)addPointToHull:(VOIPoint)point {
    
    VOITriangleList *tList;
    NSUInteger index;
    VOIPath *newHull = [self.convexHull convexHullByAddingPoint:point triangles:&tList segment:&index];
    
    __block VOITriangleNet *prev = nil;
    NSMutableOrderedSet *newNets = [NSMutableOrderedSet orderedSet];
    NSUInteger borderLength = _borderNets.count;
    [tList iterateTriangles:^(VOITriangle *t, NSUInteger i) {
        VOITriangleNet *old = self.borderNets[(index + i) % borderLength];
        NSArray *adjacent = prev ? @[prev, old] : @[old];
        VOITriangleNet *net = [[VOITriangleNet alloc] initWithTriangle:t adjacentNets:adjacent];
        [newNets addObject:[net minimize]];
        [newNets addObject:net];
        prev = net;
        return NO;
    }];
    
    VOITriangleNet *border0 = newNets.firstObject;
    VOITriangleNet *border1 = newNets.lastObject;

    self.oldHull = _convexHull;
    self.convexHull = newHull;
    [self.nets unionSet:[newNets set]];
    [self replaceBorderNetsInRange:NSMakeRange(index, tList.count) withNets:@[border0, border1]];
}

- (void)registerSeedTriangle:(VOITriangle *)triangle {
    VOITriangleNet *net = [[VOITriangleNet alloc] initWithTriangle:triangle adjacentNets:nil];
    self.convexHull = [triangle asPath];
    self.borderNets = @[net, net, net];
    [_nets addObject:net];
}

- (void)replaceBorderNetsInRange:(NSRange)range withNets:(NSArray<VOITriangleNet *> *)nets {
    // carefully handle range wrapping
    NSMutableArray *newBorderNets = [self.borderNets mutableCopy];
    [newBorderNets substitute:nets inRange:range bias:VOIBalanced];
    
#if DEEP_VERIFY
    NSUInteger failed = [self verifyBorderNets:newBorderNets];
    NSAssert(failed == NSNotFound, @"border net at %td does not match convex hull.", failed);
#else
    NSAssert(_convexHull.count == newBorderNets.count, @"Border nets out of sync");
#endif

    self.borderNets = newBorderNets;
}

- (NSUInteger)verifyBorderNets:(NSArray<VOITriangleNet *> *)nets {
    NSEnumerator *iter = [nets objectEnumerator];
    __block NSUInteger index = NSNotFound;
    [_convexHull iterateSegments:^(VOISegment *s, NSUInteger i) {
        VOITriangle *t = [[iter nextObject] triangle];
        if (t == nil || [t indexForSegment:s] == NSNotFound) {
            index = i;
            return YES;
        }
        return NO;
    }];
    return index;
}

- (void)writeTriangles:(NSArray<VOITriangle *> *)triangles {
    VOITriangleList *list = [[VOITriangleList alloc] initWithTriangles:triangles];
    NSString *string = [list tabDelimitedString];
    NSError *error = nil;
    NSURL *url = [self nextFilePath];
    if (![string writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:&error]) {
        NSLog(@"Couldn't write to path '%@'. Error: '%@'", url, error);
    }
}

- (NSURL *)nextFilePath {
    NSString *name = [NSString stringWithFormat:@"Triangles %td.txt", self.fileNumber++];
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *url = [NSURL fileURLWithPath:dir isDirectory:YES];
    return [NSURL fileURLWithPath:name relativeToURL:url];
}

@end
