//
//  VOIBox.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-05.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIBox.h"

@implementation VOIBox

- (instancetype)initWithOrigin:(VOIPoint)origin size:(VOISize)size {
    self = [super init];
    if (self) {
        _origin = origin;
        _size = size;
        [self regularize];
    }
    return self;
}

- (void)regularize {
    if (_size.x < 0) {
        _origin.x += _size.x;
        _size.x = ABS(_size.x);
    }
    if (_size.y < 0) {
        _origin.y += _size.y;
        _size.y = ABS(_size.y);
    }
}

- (VOIPoint)centre {
    return (_origin + _size) / 2.0;
}

- (double)minX {
    return _origin.x;
}

- (double)midX {
    return (_origin.x + _size.x) / 2.0;
}

- (double)maxX {
    return _origin.x + _size.x;
}

- (double)minY {
    return _origin.y;
}

- (double)midY {
    return (_origin.y + _size.y) / 2.0;
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
