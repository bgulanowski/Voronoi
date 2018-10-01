//
//  DSegment.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "DSegment.h"

#import "DPoint.h"


@implementation DSegment

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"%@ a:%.4f b:%.4f c:%.4f",
            [super description], _a, _b, _c];
}

#pragma mark - DRange
- (id)initWithPoint:(DPoint *)p0 point:(DPoint *)p1 {
    self = [super initWithPoint:p0 point:p1];
    if(self) {
        _a = p1.x - p0.x;
        _b = p1.y - p0.y;
        _c = p1.x * p0.y - p1.y * p0.x;
    }
    return self;
}

+ (DRange *)rangeWithPoint:(DPoint *)p0 point:(DPoint *)p1 {
    return [super rangeWithPoint:p0 point:p1];
}



#pragma mark - DSegment
- (DSegment *)projectToPoint:(DPoint *)point {
    
    DPoint *p1;
    
    if(_a)
        p1 = [DPoint pointWithX:point.x-_b y:point.y+_a];
    else
        p1 = [DPoint pointWithX:point.x+_b y:point.y];

    return [[self class] segmentWithPoint:point point:p1];
}

- (DPoint *)intersection:(DSegment *)segment restrictToRange:(BOOL)flag {
    
    double det = _a * segment->_b - _b * segment->_a;
    
    if(!det) return nil;
    
    double x = (_c * segment->_a - _a * segment->_c) / det;
    double y = (_c * segment->_b - _b * segment->_c) / det;
    
    DPoint *intersection = [DPoint pointWithX:x y:y];
    
    if(!flag || ([self containsPoint:intersection] && [segment containsPoint:intersection]))
        return intersection;

    return nil;
}

- (DPoint *)intersection:(DSegment *)segment {
    return [self intersection:segment restrictToRange:YES];
}

- (NSArray *)perpendicularsThroughPoint:(DPoint *)point scale:(double)scale {
    
    DSegment *projection = [self projectToPoint:point];
    DPoint *projectedPoint = [self intersection:projection restrictToRange:NO];
    DPoint *edgeVector = [self.p1 subtract:self.p0];
    
    double temp = edgeVector.x;

    scale /= [edgeVector distanceFromOrigin];
    edgeVector.x = -edgeVector.y * scale;
    edgeVector.y = temp * scale;
    
    DPoint *p1 = [DPoint pointWithX:projectedPoint.x-edgeVector.x
                                  y:projectedPoint.y-edgeVector.y];
    DPoint *p2 = [DPoint pointWithX:projectedPoint.x+edgeVector.x
                                  y:projectedPoint.y+edgeVector.y];
    return @[
    [DSegment segmentWithPoint:projectedPoint point:p1],
    [DSegment segmentWithPoint:projectedPoint point:p2],
    ];
}

+ (DSegment *)segmentWithPoint:(DPoint *)p0 point:(DPoint *)p1 {
    return (DSegment *) [super rangeWithPoint:p0 point:p1];
}

@end
