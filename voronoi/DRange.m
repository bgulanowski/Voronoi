//
//  DRange.m
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import "DRange.h"
#import "DPoint.h"
#import "DSegment.h"


@implementation DRange

#pragma mark - NSObject
- (NSString *)description {
    return [NSString stringWithFormat:@"[%@ - %@]", [_p0 description], [_p1 description]];
}

- (BOOL)isEqual:(id)object {
    if(![object isKindOfClass:[self class]])
        return NO;
    
    DRange *other = (DRange *)object;
    
    return [_p0 isEqual:other->_p0] && [_p1 isEqual:other->_p1];
}


#pragma mark - DRange
- (id)initWithPoint:(DPoint *)p0 point:(DPoint *)p1 {
    self = [super init];
    if(self) {
        _p0 = p0;
        _p1 = p1;
        if(_p0.x < _p1.x)
            _xMin = _p0.x, _xMax = _p1.x;
        else
            _xMin = _p1.x, _xMax = _p0.x;
        if(_p0.y < _p1.y)
            _yMin = _p0.y, _yMax = _p1.y;
        else
            _yMin = _p1.y, _yMax = _p0.y;
    }
    return self;
}

- (double)lengthSquared {
    return [_p1 distanceSquaredTo:_p0];
}

- (double)length {
    return [_p1 distanceTo:_p0];
}

- (double)width {
    return fabs(_xMax - _xMin);
}

- (double)height {
    return fabs(_yMax - _yMin);
}

- (DPoint *)min {
    return [DPoint pointWithX:_xMin y:_yMin];
}

- (DPoint *)max {
    return [DPoint pointWithX:_xMax y:_yMax];
}

- (NSArray *)boundary {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [array addObject:[DPoint pointWithX:_p0.x y:_p1.y]];
    [array addObject:[_p1 copy]];
    [array addObject:[DPoint pointWithX:_p1.x y:_p0.x]];
    [array addObject:[_p0 copy]];
    
    NSArray *points = [array copy];
    
    [array removeAllObjects];
    
    for (NSUInteger i=0; i<4; ++i)
        [array addObject:[DSegment segmentWithPoint:[points objectAtIndex:i] point:[points objectAtIndex:i%4]]];
    
    return [array copy];
}

- (BOOL)containsPoint:(DPoint *)point {
    double x = (float)point.x, y = (float)point.y;
    return x >= _xMin && x <= _xMax && y >= _yMin && y <= _yMax;
}

+(DRange *)rangeWithPoint:(DPoint *)p0 point:(DPoint *)p1 {
    return [[[self class] alloc] initWithPoint:p0 point:p1];
}

@end
