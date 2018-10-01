//
//  DTriad.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "DTriad.h"

#import "DCircle.h"
#import "DPoint.h"
#import "DRange.h"
#import "DSegment.h"

#import "BABitArray.h"


@implementation DTriad

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"a:%u b:%u c:%u; ab:%d bc:%d ca:%d; %@",
            (unsigned)_a, (unsigned)_b, (unsigned)_c, (int)_ab, (int)_bc, (int)_ca, _circumcircle];
}


#pragma mark - DTriad
- (Pivot)pivotForIndex:(NSUInteger)index {
    if(_a == index)
        return kPivotA;
    if(_b == index)
        return kPivotB;
    if(_c == index)
        return kPivotC;
    return kPivotUndefined;
}

- (NSUInteger)indexForPivot:(Pivot)pivot {
    switch (pivot) {
        case kPivotA: return _a;
        case kPivotB: return _b;
        case kPivotC: return _c;
        case kPivotUndefined:
            [NSException raise:NSInternalInconsistencyException format:@"Cannot determine index for undefined pivot"];
        default: return NSNotFound;
    }
}

- (Pivot)commonPivotForTriad:(DTriad *)other pivot:(Pivot)pivot {
    return [other pivotForIndex:[self indexForPivot:pivot]];
}

- (void)sharedPoints:(NSUInteger[2])points withTriad:(DTriad *)other {
    
    NSUInteger *curr = points;
    
    if(_a == other->_a || _a == other->_b || _a == other->_c) {
        *curr = _a; ++curr;
    }
    if(_b == other->_a || _b == other->_b || _b == other->_c) {
        *curr = _b;
        ++curr;
    }
    if(_c == other->_a || _c == other->_b || _c == other->_c) {
        *curr = _c;
        ++curr;
    }
}

- (NSUInteger)neighbourIndexForEdge:(Edge)edge {
    switch (edge) {
        case kEdgeAB: return _ab; break;
        case kEdgeBC: return _bc; break;
        case kEdgeCA: return _ca; break;
        default: return NSNotFound;
    }
}

- (NSUInteger)previousIndexForPivot:(Pivot)pivot {
    switch (pivot) {
        case kPivotA: return _ab; break;
        case kPivotB: return _bc; break;
        case kPivotC: return _ca; break;
        default: return NSNotFound;
    }
}

- (NSUInteger)nextIndexForPivot:(Pivot)pivot {
    switch (pivot) {
        case kPivotA: return _ca; break;
        case kPivotB: return _ab; break;
        case kPivotC: return _bc; break;
        default: return NSNotFound; break;
    }
}

- (void)reverseWinding {
    NSUInteger temp = _b;
    _b = _c;
    _c = temp;
    temp = _ab;
    _ab = _ca;
    _ca = temp;
}

- (void)changeAdjacent:(NSUInteger)neighbour index:(NSUInteger)index {
    if(_ab == neighbour) _ab = index;
    else if(_bc == neighbour) _bc = index;
    else if(_ca == neighbour) _ca = index;
}

- (AdjacencyInfo)adjacencyForPoint:(NSUInteger)pointIdx neighbour:(NSUInteger)triangleIdx {
    
    AdjacencyInfo adjacency = { NSNotFound, NSNotFound, NSNotFound };
    
    if (_ab == triangleIdx) {
        adjacency.p = _c;
        if (pointIdx == _a) {
            adjacency.t1 = _ca; // indexLeft = ac;
            adjacency.t2 = _bc; // indexRight = bc;
        } else {
            adjacency.t1 = _bc; // indexLeft = bc;
            adjacency.t2 = _ca; // indexRight = ac;
        }
    }
    
    if (_ca == triangleIdx) {
        adjacency.p = _b;
        if (pointIdx == _a) {
            adjacency.t1 = _ab; // indexLeft = ab;
            adjacency.t2 = _bc; // indexRight = bc;
        } else {
            adjacency.t1 = _bc; // indexLeft = bc;
            adjacency.t2 = _ab; // indexRight = ab;
        }
    }
    
    if (_bc == triangleIdx) {
        adjacency.p = _a;
        if (pointIdx == _b) {
            adjacency.t1 = _ab; // indexLeft = ab;
            adjacency.t2 = _ca; // indexRight = ac;
        } else {
            adjacency.t1 = _ca; // indexLeft = ac;
            adjacency.t2 = _ab; // indexRight = ab;
        }
    }

    return adjacency;
}

- (DSegment *)perpendicularFromCentreForEdge:(Edge)edge points:(NSArray *)points scale:(NSUInteger)scale {
    
    NSUInteger i1, i2;
    switch (edge) {
        case kEdgeAB: i1=_a; i2=_b; break;
        case kEdgeBC: i1=_b; i2=_c; break;
        case kEdgeCA: i1=_c; i2=_a; break;
        case kEdgeUndefined:
            [NSException raise:NSInvalidArgumentException format:@"edge undefined"];
        default: break;
    }

    DPoint *p1 = [points objectAtIndex:i1], *p2 = [points objectAtIndex:i2];
    
    DPoint *edgeVector = [p2 subtract:p1];
    double temp = edgeVector.x;
    
    scale /= [edgeVector distanceFromOrigin];
    edgeVector = [DPoint pointWithX:-edgeVector.y * scale y:temp * scale];

    p1 = _circumcircle.centre;
    p2 = [DPoint pointWithX:p1.x+edgeVector.x y:p1.y+edgeVector.y];
    
    return [DSegment segmentWithPoint:p1 point:p2];
}


#pragma mark - Factories
- (id)initWithIndex:(NSUInteger)a index:(NSUInteger)b index:(NSUInteger)c {
    NSAssert(a != b && b != c && c != a, @"degenerate triad");
    self = [super init];
    if(self) {
        _a = a;
        _b = b;
        _c = c;
        _ab = NSNotFound;
        _bc = NSNotFound;
        _ca = NSNotFound;
    }
    return self;
}

+ (DTriad *)triadWithIndex:(NSUInteger)a index:(NSUInteger)b index:(NSUInteger)c {
    return [[self alloc] initWithIndex:a index:b index:c];
}

+ (DTriad *)triadWithIndices:(NSUInteger[3])indices forPoints:(NSArray *)points {
    DTriad *triad = [self triadWithIndex:indices[0] index:indices[1] index:indices[2]];
    triad->_circumcircle = [points circumCircleForPointsAtIndices:indices];
    return triad;
}

@end


#pragma mark -
@implementation NSArray (TriadWalking)

- (DTriad *)neighbourForIndex:(NSUInteger)index edge:(Edge)edge {
    NSUInteger neighbourIndex = [[self objectAtIndex:index] neighbourIndexForEdge:edge];
    return NSNotFound == neighbourIndex ? nil : [self objectAtIndex:neighbourIndex];
}

- (DTriad *)previousForIndex:(NSUInteger)index pivot:(Pivot)pivot {
    NSUInteger previousIndex = [[self objectAtIndex:index] previousIndexForPivot:pivot];
    return NSNotFound == previousIndex ? nil : [self objectAtIndex:previousIndex];
}

- (DTriad *)nextForIndex:(NSUInteger)index pivot:(Pivot)pivot {
    NSUInteger nextIndex = [[self objectAtIndex:index] nextIndexForPivot:pivot];
    return NSNotFound == nextIndex ? nil : [self objectAtIndex:nextIndex];
}

- (DTriad *)firstForIndex:(NSUInteger)index pivot:(Pivot)pivot {
    
    DTriad *origin = [self objectAtIndex:index];
    DTriad *cursor = origin;
    DTriad *first;
    
    NSUInteger i=100;
    
    do {
        first = cursor;
        index = [cursor previousIndexForPivot:pivot];
        
        if(NSNotFound == index) break;
        
        cursor = [self objectAtIndex:index];
        pivot = [first commonPivotForTriad:cursor pivot:pivot];
        
        NSAssert(--i!=0, @"Stuck searching for first triad");
        
    } while (cursor && cursor!=origin);
        
    return first;
}

- (NSMutableArray *)triadsAdjacentToIndex:(NSUInteger)index pivot:(Pivot)pivot {
    
    NSMutableArray *result = [NSMutableArray array];

    DTriad *triad = [self objectAtIndex:index];
    DTriad *first = [self firstForIndex:index pivot:pivot];
    
    Pivot newPivot;
    DTriad *new = first;
    NSUInteger nextIndex;
    
    do {
        [result addObject:new];
        newPivot = [triad commonPivotForTriad:new pivot:pivot];
        nextIndex = [new nextIndexForPivot:newPivot];
        new = (NSNotFound != nextIndex) ? [self objectAtIndex:nextIndex] : nil;
    } while (new && new != first);
    
    return result;
}

- (NSArray *)perpendicularsForTriad:(DTriad *)start points:(NSArray *)points pivot:(Pivot)pivot scale:(double)scale {
    
    NSArray *result = nil;
    
    NSUInteger endIndex = [start nextIndexForPivot:pivot];
    DTriad *end = NSNotFound == endIndex ? nil : [self objectAtIndex:endIndex];
        
    DPoint *pPivot = [points objectAtIndex:[start indexForPivot:pivot]];
    DPoint *pCommon = [points objectAtIndex:[start indexForPivot:PrevPivot(pivot)]];
    DPoint *pOpp1 = [points objectAtIndex:[start indexForPivot:NextPivot(pivot)]];
    DPoint *pOpp2 = nil;
    
    if(end) {
        Pivot commonPivot = [start commonPivotForTriad:end pivot:pivot];
        pOpp2 = [points objectAtIndex:[end indexForPivot:PrevPivot(commonPivot)]];
    }
        
    double longitude1 = [pPivot distanceTo:pOpp1];
    double longitude2 = [pPivot distanceTo:pCommon];
    double longitude3 = longitude2;
    
    if(end)
        longitude3 = [pPivot distanceTo:pOpp2];
    
    if(longitude1 < longitude2 && longitude1 < longitude3)
        result = [[DSegment segmentWithPoint:pPivot point:pOpp1] perpendicularsThroughPoint:start.circumcircle.centre scale:scale];
    else if(longitude3 < longitude1 && longitude2)
        result = [[DSegment segmentWithPoint:pPivot point:pOpp2] perpendicularsThroughPoint:end.circumcircle.centre scale:scale];
    else
        result = [[DSegment segmentWithPoint:pPivot point:pCommon] perpendicularsThroughPoint:start.circumcircle.centre scale:scale];
    
    return result;
}

- (BOOL)validateTriad:(DTriad *)triad index:(NSUInteger)index {
    
    for(NSUInteger i=kPivotA; i<=kPivotC; ++i) {
        
        NSUInteger otherIndex = [triad nextIndexForPivot:(Pivot)i];
        
        if(otherIndex == NSNotFound)
            continue;
        
        
        DTriad *other = [self objectAtIndex:otherIndex];
        NSUInteger points[2], otherPoints[2];
        Pivot common = [triad commonPivotForTriad:other pivot:(Pivot)i];
        
        if([other previousIndexForPivot:common] != index &&
           [other nextIndexForPivot:common] != index)
            return NO;
        
        [triad sharedPoints:points withTriad:other];
        [other sharedPoints:otherPoints withTriad:triad];
        
        if(!((points[0] == otherPoints[0] && points[1] == otherPoints[1]) ||
             (points[1] == otherPoints[0] && points[0] == otherPoints[1])))
            return NO;
        
    }
    
    return YES;
}

- (BOOL)validateTriads {
    
    BABitArray *ba = [BABitArray bitArrayWithLength:[self count]];
    NSUInteger i = 0;
    
    for (DTriad *triad in self) {
        
        if(![ba bit:i] && ![self validateTriad:triad index:0])
            return NO;
        if(triad.ab != NSNotFound) [ba setBit:triad.ab];
        if(triad.bc != NSNotFound) [ba setBit:triad.bc];
        if(triad.ca != NSNotFound) [ba setBit:triad.ca];
        [ba setBit:i++];
    }
    
    return YES;
}

@end


#pragma mark -
@implementation NSArray (PointInspecting)

- (Winding)windingForPoints:(NSArray *)points {
    
    DPoint *pa = [points objectAtIndex:0];
    DPoint *pb = [points objectAtIndex:1];
    DPoint *pc = [points objectAtIndex:2];

    double pax = pa.x;
    double pay = pa.y;
    double pbx = pb.x;
    double pby = pb.y;
    double pcx = pc.x;
    double pcy = pc.y;
    double centroidX = (pax + pbx + pcx) / 3.0;
    double centroidY = (pay + pby + pcy) / 3.0;
    
    double dr0 = pax - centroidX;
    double dc0 = pay - centroidY;
    double dx01 = pbx - pax;
    double dy01 = pby - pay;
    
    double df = -dx01 * dc0 + dy01 * dr0;
    
    return df > 0 ? kWindingCounterCW : kWindingClockwise;
}

- (Winding)windingForPointsAtIndices:(NSUInteger [3])indices {
    NSArray *points = @[
    [self objectAtIndex:indices[0]],
    [self objectAtIndex:indices[1]],
    [self objectAtIndex:indices[2]],
    ];
    return [self windingForPoints:points];
}

- (Winding)windingForTriad:(DTriad *)triad {
    NSArray *points = @[
    [self objectAtIndex:triad.a],
    [self objectAtIndex:triad.b],
    [self objectAtIndex:triad.c],
    ];
    return [self windingForPoints:points];
}

- (DCircle *)circumCircleForPointsAtIndices:(NSUInteger [3])indices {
    
    // TODO: make function and put into BASceneUtilities
    
    // ???: Should we check that these points are all different?
    
    DPoint *pa = [self objectAtIndex:indices[0]];
    DPoint *pb = [self objectAtIndex:indices[1]];
    DPoint *pc = [self objectAtIndex:indices[2]];
    
    double x1 = pa.x;
    double y1 = pa.y;
    double x2 = pb.x;
    double y2 = pb.y;
    double x3 = pc.x;
    double y3 = pc.y;
    double m1, m2, mx1, mx2, my1, my2;
    double dx, dy;
    double xc, yc;
    
    if (fabs(y2 - y1) < DBL_EPSILON) {
        m2 = -(x3 - x2) / (y3 - y2);
        mx2 = (x2 + x3) / 2.0;
        my2 = (y2 + y3) / 2.0;
        xc = (x2 + x1) / 2.0;
        yc = m2 * (xc - mx2) + my2;
    } else if (fabs(y3 - y2) < DBL_EPSILON) {
        m1 = -(x2 - x1) / (y2 - y1);
        mx1 = (x1 + x2) / 2.0;
        my1 = (y1 + y2) / 2.0;
        xc = (x3 + x2) / 2.0;
        yc = m1 * (xc - mx1) + my1;
    } else {
        m1 = -(x2 - x1) / (y2 - y1);
        m2 = -(x3 - x2) / (y3 - y2);
        mx1 = (x1 + x2) / 2.0;
        mx2 = (x2 + x3) / 2.0;
        my1 = (y1 + y2) / 2.0;
        my2 = (y2 + y3) / 2.0;
        xc = (m1 * mx1 - m2 * mx2 + my2 - my1) / (m1 - m2);
        yc = m1 * (xc - mx1) + my1;
    }
    
    dx = x2 - xc;
    dy = y2 - yc;
                  
    return [DCircle circleWithCentre:[DPoint pointWithX:xc y:yc] radius:sqrt(dx * dx + dy * dy)];
}

- (void)updateCircumcircle:(DTriad *)triad {
    NSUInteger indices[3];
    indices[0] = triad.a;
    indices[1] = triad.b;
    indices[2] = triad.c;
    triad.circumcircle = [self circumCircleForPointsAtIndices:indices];
}

- (DTriad *)triadWithIndices:(NSUInteger[3])indices {
    return [DTriad triadWithIndices:indices forPoints:self];
}

@end
