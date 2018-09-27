//
//  NSArray+Voronoi.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "NSArray+Voronoi.h"
#import "DCircle.h"
#import "DHull.h"
#import "DPoint.h"
#import "DRange.h"
#import "DRegion.h"
#import "DSegment.h"
#import "DTriad.h"

#import "BABitArray.h"


@implementation NSArray (Triangulation)

- (DCircle *)findBestPointForTriangleIndices:(NSUInteger *)indices distances:(double *)distances {
    
    NSUInteger mid = NSNotFound;
    NSUInteger count = [self count];
    NSUInteger triangleIndices[3];
    
    DCircle *circle = nil;
    
    double romin2 = CGFLOAT_MAX;
    
    triangleIndices[0] = indices[0];
    triangleIndices[1] = indices[1];
    
    for (NSUInteger i=2; i<count; ++i) {
        triangleIndices[2] = indices[i];
        DCircle *testCircle = [self circumCircleForPointsAtIndices:triangleIndices];
        if(testCircle.r2 < romin2) {
            mid = i;
            romin2 = testCircle.r2;
            circle = testCircle;
        }
        else if(romin2 * romin2 < distances[i])
            break;
    }
    
    if(mid != 2) {
        
        NSUInteger indexTemp = indices[mid];
        
        memmove(indices+3, indices+2, (mid-2)*sizeof(NSUInteger));
        indices[2] = indexTemp;
    }
    
    return circle;
}

- (void)triangulate:(NSArray **)pTriads hull:(DHull **)pHull {
    
    NSMutableArray *triads = pTriads ? [NSMutableArray array] : nil;

    DHull *hull = [DHull hullWithPoints:self];
        
    NSUInteger count = [self count];
    
    double  *distances = malloc(sizeof(double)*count); // distances are actually distances^2
    NSUInteger *indices = malloc(sizeof(NSUInteger)*count);
    DPoint *p0 = [self objectAtIndex:0];
    
    distances[0] = 0;
    indices[0] = 0;
    
    for (NSUInteger i=1; i<count; ++i) {
        indices[i] = i;
        distances[i] = [p0 distanceSquaredTo:[self objectAtIndex:i]];
    }
    
    int(^sortBlock)(const void *, const void *) = ^int(const void *pIndex1, const void *pIndex2) {
        NSUInteger index1 = *(NSUInteger*)pIndex1, index2 = *(NSUInteger*)pIndex2;
        double d1 = distances[index1], d2 = distances[index2];
        if(fabs(d1 - d2) < DBL_EPSILON) return 0;
        if(d1 < d2) return -1;
        return 1;
    };
    
    qsort_b(indices, count, sizeof(NSUInteger), sortBlock);

    
    // find the Seed Triad of our Convex Hull
    DCircle *circle = [self findBestPointForTriangleIndices:indices distances:distances];
    DTriad *seed = [DTriad triadWithIndex:indices[0] index:indices[1] index:indices[2]];
    
    seed.circumcircle = circle;
    if([self windingForTriad:seed] != kWindingClockwise)
        [seed reverseWinding];
    
    [triads addObject:seed];
    
    [hull addVerticesObject:[DHullPoint hullPointWithIndex:seed.a]];
    [hull addVerticesObject:[DHullPoint hullPointWithIndex:seed.b]];
    [hull addVerticesObject:[DHullPoint hullPointWithIndex:seed.c]];
    
    
    // Re-calculate distances from circumcentre of Seed for those not on the circle
    p0 = seed.circumcircle.centre;
    for (NSUInteger i=3; i<count; ++i)
        distances[indices[i]] = [p0 distanceSquaredTo:[self objectAtIndex:indices[i]]];
    
    
    // re-sort indices using updated distances - NOTE: first three are IGNORED, wil be out of order
    qsort_b(indices+3, count-3, sizeof(NSUInteger), sortBlock);
    
    if(distances) free(distances);

    for (NSUInteger i=3; i<count; ++i) {
        
        NSUInteger index = indices[i];
        
        DHullPoint *hp0 = [hull objectInVerticesAtIndex:0];
        DHullPoint *ptx = [DHullPoint hullPointWithIndex:index];
        DHullPoint *hp  = nil;

        DPoint *px = [self objectAtIndex:index];
        DPoint *p0 = [self objectAtIndex:hp0.index];
        double dx = px.x - p0.x;
        double dy = px.y - p0.y;
        
        NSUInteger numh = [hull countOfVertices];
        
        NSMutableArray *pidx  = triads ? [NSMutableArray array] : nil;
        NSMutableArray *tridx = triads ? [NSMutableArray array] : nil;
        
        NSUInteger hidx;
        
        if([hull visibleFromX:dx y:dy index:0]) {
                        
            hidx = 0;
            
            if([hull visibleFromX:dx y:dy index:numh-1]) {
                
                DHullPoint *visible = [hull objectInVerticesAtIndex:numh-1];
             
                [pidx addObject:@(visible.index)];
                [tridx addObject:@(visible.triad)];
                
                for (NSUInteger h=0; h<numh-1; ++h) {
                    hp = [hull objectInVerticesAtIndex:h];
                    [pidx addObject:@(hp.index)];
                    [tridx addObject:@(hp.triad)];
                    if([hull visibleFromPoint:px index:h]) {
                        [hull removeObjectFromVerticesAtIndex:h];
                        --h;
                        --numh;
                    }
                    else {
                        [hull insertObject:ptx inVerticesAtIndex:0];
                        ++numh;
                        break;
                    }
                }
                
                for (NSUInteger h=numh-2; h>0; --h) {
                    if([hull visibleFromPoint:px index:h]) {
                        hp = [hull objectInVerticesAtIndex:h];
                        [pidx insertObject:@(hp.index) atIndex:0];
                        [tridx insertObject:@(hp.triad) atIndex:0];
                        [hull removeObjectFromVerticesAtIndex:h+1];
                    }
                    else {
                        break;
                    }
                }
            }
            else { // NO == [hull visibleFromX:dx y:dy index:numh-1]
                hidx = 1; // keep pt hull[0]
                hp = hp0;
                [pidx addObject:@(hp.index)];
                [tridx addObject:@(hp.triad)];
                
                for (NSUInteger h=1; h<numh; ++h) {
                    hp = [hull objectInVerticesAtIndex:h];
                    [pidx addObject:@(hp.index)];
                    [tridx addObject:@(hp.triad)];
                    if([hull visibleFromPoint:px index:h]) {
                        [hull removeObjectFromVerticesAtIndex:h];
                        --h;
                        --numh;
                    }
                    else {
                        [hull insertObject:ptx inVerticesAtIndex:h];
                        break;
                    }
                }
            }
        }
        else { // NO == [hull visibleFromX:dx y:dy index:0]
            
            NSUInteger e1 = NSNotFound, e2 = numh;
            
            for (NSUInteger h=1; h<numh; ++h) {
                if([hull visibleFromPoint:px index:h]) {
                    if(e1 == NSNotFound) e1 = h;
                }
                else if(e1 > 0 && e1 != NSNotFound) {
                    e2 = h;
                    break;
                }
            }
            
            NSAssert(e1 != NSNotFound, @"error!");
            
            // triangle pidx starts at e1 and ends at e2 (inclusive).
            if(triads) {
                NSUInteger term = e2 + (e2 < numh ? 1 : 0);
                
                for (NSUInteger e=e1; e<term; ++e) {
                    hp = [hull objectInVerticesAtIndex:e];
                    [pidx addObject:@(hp.index)];
                    [tridx addObject:@(hp.triad)];
                }
                
                if(e2 >= numh)
                    [pidx addObject:@(hp0.index)];
            }
            
            if(e1 < e2-1)
                [hull removeVerticesAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(e1+1, e2-e1-1)]];
            
            hidx = e1+1;
            [hull insertObject:ptx inVerticesAtIndex:hidx];
        }
        
        
        if(!triads)
            continue;
        
        
        NSUInteger numt = [triads count], T0 = numt;
        NSUInteger npx = [pidx count] - 1;
        
        NSUInteger triadIndices[3];
        triadIndices[0] = index;
        
        for (NSUInteger p=0; p<npx; ++p) {
            
            triadIndices[1] = [[pidx objectAtIndex:p] unsignedIntegerValue];
            triadIndices[2] = [[pidx objectAtIndex:p+1] unsignedIntegerValue];
            
            DTriad *trx = [DTriad triadWithIndices:triadIndices forPoints:self];

            NSUInteger x = [[tridx objectAtIndex:p] unsignedIntegerValue];
            DTriad *txx = [triads objectAtIndex:x];
            
            trx.bc = x;
            if(p > 0) trx.ab = numt-1;
            trx.ca = numt+1;
            
            if ((trx.b == txx.a && trx.c == txx.b)
                | (trx.b == txx.b && trx.c == txx.a))
                txx.ab = numt;
            else if ((trx.b == txx.a && trx.c == txx.c)
                     | (trx.b == txx.c && trx.c == txx.a))
                txx.ca = numt;
            else if ((trx.b == txx.b && trx.c == txx.c)
                     | (trx.b == txx.c && trx.c == txx.b))
                txx.bc = numt;

            [triads addObject:trx];
            ++numt;
        }
        
        [(DTriad *)[triads lastObject] setCa:NSNotFound];
        
        [hull objectInVerticesAtIndex:hidx].triad = numt-1;
        [hull objectInVerticesAtIndex:(hidx ?: [hull countOfVertices])-1].triad = T0;
    }
    
    if(indices) free(indices);
    
    if(pHull) *pHull = hull;
    if(pTriads) *pTriads = triads;
}

- (NSArray *)convexHullFilterDuplicates:(BOOL)filter {
    
    NSArray *target = filter ? [[NSSet setWithArray:self] allObjects] : self;
    DHull *hull = nil;
    
    [target triangulate:NULL hull:&hull];
    
    return [hull pointsForVertices];
}

- (NSArray *)convexHull {
    return [self convexHullFilterDuplicates:NO];
}

- (NSArray *)triangulationFilterDuplicates:(BOOL)filter {
    
    NSArray *target = filter ? [[NSSet setWithArray:self] allObjects] : self;
    NSArray *triads = nil;
    
    [target triangulate:&triads hull:NULL];
    
    return triads;
}

- (NSArray *)triangulation {
    return [self triangulationFilterDuplicates:NO];
}

- (double *)rawPoints {
    
    double *rawPoints = malloc(sizeof(double)*2*[self count]);
    NSUInteger i=0;
    
    for (DPoint *point in self) {
        rawPoints[i++] = point.x;
        rawPoints[i++] = point.y;
    }
    
    return rawPoints;
}

@end


@implementation NSArray (TriangleReorienting)

- (NSUInteger)flipTriangle:(NSUInteger)index points:(NSArray *)points {
    
    DTriad *t1 = [self objectAtIndex:index];
    DTriad *t2 = nil;
    
    NSUInteger edge1 = NSNotFound, edge2 = NSNotFound;
    NSUInteger flipped = NSNotFound;
    AdjacencyInfo adjacency = { NSNotFound, NSNotFound, NSNotFound };

    if(t1.ab != NSNotFound) {

        flipped = t1.ab;
        t2 = [self objectAtIndex:flipped];
        adjacency = [t2 adjacencyForPoint:t1.a neighbour:index];
        
        if([t1.circumcircle containsPoint:[points objectAtIndex:adjacency.p]] &&
           [t2.circumcircle containsPoint:[points objectAtIndex:t1.c]]) {
            
            edge1 = t1.ca;
            edge2 = t1.bc;
            
            NSUInteger t1a = t1.a, t1b = t1.b, t1c = t1.c;
            
            t1.a = t1c;
            t1.b = t1a;
            t1.c = adjacency.p;
            t1.ab = edge1;
            t1.bc = adjacency.t1;
            t1.ca = flipped;
            
            t2.a = t1c;
            t2.b = t1b;
            t2.c = adjacency.p;
            t2.ab = edge2;
            t2.bc = adjacency.t2;
            t2.ca = index;
        }
        else
            flipped = NSNotFound;
    }
    
    if(NSNotFound == flipped && t1.bc != NSNotFound) {

        flipped = t1.bc;
        t2 = [self objectAtIndex:flipped];
        adjacency = [t2 adjacencyForPoint:t1.b neighbour:index];

        if([t1.circumcircle containsPoint:[points objectAtIndex:adjacency.p]] &&
           [t2.circumcircle containsPoint:[points objectAtIndex:t1.a]]) {
            
            edge1 = t1.ab;
            edge2 = t1.ca;
            
            NSUInteger t1a = t1.a, t1c = t1.c;
            
            t1.c = adjacency.p;
            t1.ab = edge1;
            t1.bc = adjacency.t1;
            t1.ca = flipped;
            
            t2.a = t1a;
            t2.b = t1c;
            t2.c = adjacency.p;
            t2.ab = edge2;
            t2.bc = adjacency.t2;
            t2.ca = index;
        }
        else
            flipped = NSNotFound;
    }
    
    if(NSNotFound == flipped && t1.ca != NSNotFound) {
        
        flipped = t1.ca;
        t2 = [self objectAtIndex:flipped];
        adjacency = [t2 adjacencyForPoint:t1.a neighbour:index];

        if([t1.circumcircle containsPoint:[points objectAtIndex:adjacency.p]] &&
           [t2.circumcircle containsPoint:[points objectAtIndex:t1.b]]) {

            edge1 = t1.ab;
            edge2 = t1.bc;
            
            NSUInteger t1a = t1.a, t1b = t1.b, t1c = t1.c;
            
            t1.a = t1b;
            t1.b = t1a;
            t1.c = adjacency.p;
            t1.ab = edge1;
            t1.bc = adjacency.t1;
            t1.ca = flipped;
            
            t2.a = t1b;
            t2.b = t1c;
            t2.c = adjacency.p;
            t2.ab = edge2;
            t2.bc = adjacency.t2;
            t2.ca = index;
        }
        else
            flipped = NSNotFound;
    }
    
    if(NSNotFound != flipped) {
        if(NSNotFound != adjacency.t1) {
            DTriad *adj = [self objectAtIndex:adjacency.t1];
            [adj changeAdjacent:flipped index:index];
            NSAssert(([self validateTriad:adj index:adjacency.t1]), @"");
        }
        if(NSNotFound != edge2) {
            DTriad *adj = [self objectAtIndex:edge2];
            [adj changeAdjacent:index index:flipped];
            NSAssert(([self validateTriad:adj index:edge2]), @"");
        }
        
        [points updateCircumcircle:t1];
        [points updateCircumcircle:t2];
        
        NSAssert(([self validateTriad:t1 index:index]), @"");
    }
    
    return flipped;
}

- (BABitArray *)reorientTrianglesWithPoints:(NSArray *)points {

    NSUInteger triadCount = [self count];
    BABitArray *flips = [BABitArray bitArrayWithLength:triadCount];
    NSUInteger bailCount = 3000;
    
    for (NSUInteger i=0; i<triadCount; ++i) {
        
        NSUInteger other = [self flipTriangle:i points:points];
        
        if(NSNotFound != other) {
            [flips setBit:other];
            [flips setBit:i];
        }
    }
    
    
    NSUInteger totalFlips = [flips count];

    do {
        
        BABitArray *newFlips = [BABitArray bitArrayWithLength:triadCount];
        
        [flips enumerate:^(NSUInteger bit) {
            
            NSUInteger other = [self flipTriangle:bit points:points];
            
            if(NSNotFound != other) {
                [newFlips setBit:other];
                [newFlips setBit:bit];
            }
        }];
        
        if([newFlips isEqual:flips])
            break;
        
//        NSAssert(--bailCount > 0, @"Caught in loop!");
        if(--bailCount == 0)
            break;
        
        totalFlips += [newFlips count];
        flips = newFlips;
        
    } while([flips count]);
    
    for (DTriad *triad in self) {
        if([points windingForTriad:triad] != kWindingClockwise)
            [triad reverseWinding];
    }
    
    return flips;
}

- (NSString *)triangleDescriptionForPoints:(NSArray *)points {
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (DTriad *triad in self) {
        
        NSString *string = [NSString stringWithFormat:@"[%@|%@|%@]",
                            [points objectAtIndex:triad.a],
                            [points objectAtIndex:triad.b],
                            [points objectAtIndex:triad.c]];
        [array addObject:string];
    }
    
    return [array componentsJoinedByString:@", "];
}

- (NSUInteger *)rawTriangleIndices {
    
    NSUInteger *rawIndices = malloc(sizeof(NSUInteger)*3*[self count]);
    NSUInteger i=0;
    
    for (DTriad *triad in self) {
        rawIndices[i++] = triad.a;
        rawIndices[i++] = triad.b;
        rawIndices[i++] = triad.c;
    }
    
    return rawIndices;
}

@end
