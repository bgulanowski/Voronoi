//
//  VOIBox.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-05.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIBox.h"

@implementation VOIBox

- (instancetype)init {
    return [self initWithOrigin:vector2(0.0, 0.0) size:vector2(0.0, 0.0)];
}

- (instancetype)initWithOrigin:(VOIPoint)origin size:(VOISize)size {
    self = [super init];
    if (self) {
        _origin = [[self class] regularizeOrigin:origin forSize:size];
        _size = simd_abs(size);
    }
    return self;
}

+ (VOIPoint)regularizeOrigin:(VOIPoint)origin forSize:(VOISize)size {
    if (size.x < 0) {
        origin.x += size.x;
    }
    if (size.y < 0) {
        origin.y += size.y;
    }
    return origin;
}

- (VOIPoint)centre {
    return _origin + _size / 2.0;
}

- (double)minX {
    return _origin.x;
}

- (double)midX {
    return _origin.x + _size.x / 2.0;
}

- (double)maxX {
    return _origin.x + _size.x;
}

- (double)minY {
    return _origin.y;
}

- (double)midY {
    return _origin.y + _size.y / 2.0;
}

- (double)maxY {
    return _origin.y + _size.y;
}

- (double)width {
    return _size.x;
}

- (double)height {
    return _size.y;
}

- (BOOL)isDegenerate {
    return _size.x <= DBL_EPSILON || _size.y <= DBL_EPSILON;
}

- (VOIPointList *)asPointList {
    VOIPoint points[4] = {
        _origin,
        _origin + vector2(0.0, _size.y),
        _origin + _size,
        _origin + vector2(_size.x, 0.0)
    };
    return [[VOIPointList alloc] initWithPoints:points count:4];
}

@end