//
//  VOIPoint.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-12.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIPoint.h"

#import "VOISegment.h"

const double VOIPi = M_PI;
const double VOIEpsilon = VOI_EPSILON;

VOIPoint VOICentrePoint(VOIPoint points[3]) {
    VOISegment *p0 = [[VOISegment alloc] initWithPoints:&points[0]].perpendicular;
    VOISegment *p1 = [[VOISegment alloc] initWithPoints:&points[1]].perpendicular;
    return [p0 intersectWithSegment:p1];
}

NSString *VOIPointToString(VOIPoint p) {
    return [NSString stringWithFormat:@"(%.2f, %.2f)", p.x, p.y];
}

VOIPoint VOIPointFromString(NSString *s) {
    double elements[2];
    NSScanner *scanner = [NSScanner scannerWithString:s];
    [scanner scanString:@"(" intoString:NULL];
    [scanner scanDouble:&elements[0]];
    [scanner scanString:@", " intoString:NULL];
    [scanner scanDouble:&elements[1]];
    return vector2(elements[0], elements[1]);
}
