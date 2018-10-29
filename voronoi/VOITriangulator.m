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

#import "NSMutableArray+IndexWrapping.h"

@interface VOITriangulator ()

@property VOITriangleList *triangulation;
@property VOIPath *convexHull;
@property NSMutableArray<VOITriangleNet *> *nets;
// indexed by segment.hashKey
@property NSArray<VOITriangleNet *> *borderNets;

@property NSUInteger fileNumber;

@end

@implementation VOITriangulator

- (BOOL)minimized {
    return [_nets count] > 0 && ![[NSSet setWithArray:[_nets valueForKey:@"minimized"]] containsObject:@NO];
}

- (instancetype)initWithPointList:(VOIPointList *)pointList {
    self = [super init];
    if (self) {
        _pointList = pointList;
        _nets = [NSMutableArray array];
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
    
    // The first point is arbitrary. Chose the closest to centre for aesthetic reasons.
    points[0] = [_pointList pointClosestToPoint:_pointList.centre index:&index ignoreIfEqual:NO];
    [indices addIndex:index];
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
    VOIPath *newHull = [self.convexHull convexHullByAddingPoint:point triangles:&tList affectedPoint:&index];
    
    __block VOITriangleNet *prev = nil;
    NSMutableArray *newNets = [NSMutableArray array];
    NSUInteger borderLength = _borderNets.count;
    [tList iterateTriangles:^(VOITriangle *t, NSUInteger i) {
        VOITriangleNet *old = self.borderNets[(index + i) % borderLength];
        NSArray *adjacent = prev ? @[prev, old] : @[old];
        VOITriangleNet *net = [[VOITriangleNet alloc] initWithTriangle:t adjacentNets:adjacent];
        [newNets addObject:net];
        prev = net;
        return NO;
    }];

    VOITriangleNet *last = [newNets lastObject];
    for (VOITriangleNet *net in newNets) {
        [net minimize];
    }
    VOISegment *lastSegment = [newHull segmentAt:index + 1];
    if ([last.triangle indexForSegment:lastSegment] == NSNotFound) {
        last = [last netForSegment:lastSegment];
    }
    
    [self replaceNetsInRange:NSMakeRange(index, tList.count) withNets:@[newNets.firstObject, newNets.lastObject]];
    NSAssert(_borderNets.count == newHull.count, @"inconsistent segments and border nets");
    
    [self.nets addObjectsFromArray:newNets];
    self.convexHull = newHull;
}

- (void)registerSeedTriangle:(VOITriangle *)triangle {
    VOITriangleNet *net = [[VOITriangleNet alloc] initWithTriangle:triangle adjacentNets:nil];
    self.convexHull = [triangle asPath];
    self.borderNets = @[net, net, net];
    [_nets addObject:net];
}

- (void)replaceNetsInRange:(NSRange)range withNets:(NSArray<VOITriangleNet *> *)nets {
    // carefully handle range wrapping
    NSMutableArray *newBorderNets = [self.borderNets mutableCopy];
    [newBorderNets replaceObjectsInWrappingRange:range withObjects:nets];
    self.borderNets = newBorderNets;
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
