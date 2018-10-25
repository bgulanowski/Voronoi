//
//  NSValue+VOIPoint.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-25.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "NSValue+VOIPoint.h"

@implementation NSValue (VOIPoint)

- (VOIPoint)point {
    double v[2];
    [self getValue:&v];
    return vector2(v[0], v[1]);
}

- (VOIPoints2)points2 {
    double v[4];
    [self getValue:&v];
    return (VOIPoints2) { vector2(v[0], v[1]), vector2(v[2], v[3]) };
}

- (VOIPoints3)points3 {
    double v[6];
    [self getValue:&v];
    return (VOIPoints3) { vector2(v[0], v[1]), vector2(v[2], v[3]), vector2(v[4], v[5]) };
}

+ (instancetype)valueWithPoint:(VOIPoint)point {
    double v[2] = { point.x, point.y };
    return [self valueWithBytes:v objCType:@encode(double[2])];
}

+ (instancetype)valueWithPoints2:(VOIPoints2)points2 {
    double v[4] = {
        points2.pair.p0.x, points2.pair.p0.y,
        points2.pair.p1.x, points2.pair.p1.y
        
    };
    return [self valueWithBytes:v objCType:@encode(double[4])];
}

+ (instancetype)valueWithPoints3:(VOIPoints3)points3 {
    double v[6] = {
        points3.triple.p0.x, points3.triple.p0.y,
        points3.triple.p1.x, points3.triple.p1.y,
        points3.triple.p2.x, points3.triple.p2.y
    };
    return [self valueWithBytes:v objCType:@encode(double[6])];
}
@end
