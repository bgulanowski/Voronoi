//
//  VOITriangle.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-03.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOITriangle.h"

#import "VOIBox.h"
#import "VOISegment.h"
#import "VOISegmentList.h"

typedef enum {
    DegenerateUnknown,
    DegenerateYes,
    DegenerateNo
} Degeneracy;

@implementation VOITriangle {
    VOIPoint _points[3];
    VOIPoint _centre;
    Degeneracy _degeneracy;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: <(%.2f, %.2f) - (%.2f, %.2f) - (%.2f, %.2f)>",
            [self className],
            _points[0].x, _points[0].y,
            _points[1].x, _points[1].y,
            _points[2].x, _points[2].y
            ];
}

- (VOIPoint)p0 {
    return _points[0];
}

- (VOIPoint)p1 {
    return _points[1];
}

- (VOIPoint)p2 {
    return _points[2];
}

- (VOIPoint)centre {
    return (!self.degenerate && isnan(_centre.x)) ? [self calculateCentre] : _centre;
}

- (BOOL)isDegenerate {
    if (_degeneracy == DegenerateUnknown) {
        [self calculateDegeneracy];
    }
    return _degeneracy == DegenerateYes;
}

- (BOOL)isEqual:(id)object {
    return [object isKindOfClass:[self class]];
}

- (instancetype)initWithPoints:(const VOIPoint *)points {
    self = [super init];
    if (self) {
        _points[0] = points[0];
        _points[1] = points[1];
        _points[2] = points[2];
        _centre = vector2((double)NAN, (double)NAN);
    }
    return self;
}

- (BOOL)isEqualToTriangle:(VOITriangle *)other {
    return (
            simd_equal(_points[0], other->_points[0]) &&
            simd_equal(_points[1], other->_points[1]) &&
            simd_equal(_points[2], other->_points[2])
            );
}

- (VOIPoint)pointAt:(NSUInteger)index {
    return _points[index%3];
}

- (void)calculateDegeneracy {
    BOOL degenerate = [[VOIPointList alloc] initWithPoints:_points count:3].boundingBox.degenerate;
    _degeneracy = degenerate ? DegenerateYes : DegenerateNo;
}

- (VOIPoint)calculateCentre {
    VOISegmentList *segmentList = [[[VOISegmentList alloc] initWithTriangle:self] sortedByLength];
    VOISegment *l0 = [[segmentList segmentAt:0] perpendicular];
    VOISegment *l1 = [[segmentList segmentAt:1] perpendicular];
    
    _centre = [l0 intersectWithSegment:l1];
    
    return _centre;
}

@end
