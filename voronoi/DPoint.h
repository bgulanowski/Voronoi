//
//  DPoint.h
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-07.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DRange;

@interface DPoint : NSObject<NSCopying> {
@public
    vector_double2 _p;
}

@property (nonatomic, readonly) double x;
@property (nonatomic, readonly) double y;

- (id)initWithX:(double)x y:(double)y;
- (id)initWithCGPoint:(CGPoint)point;

- (DPoint *)add:(DPoint *)other;
- (DPoint *)subtract:(DPoint *)other;

- (double)distanceTo:(DPoint *)other;
- (double)distanceSquaredTo:(DPoint *)other;
- (double)distanceFromOrigin;

- (CGPoint)CGPoint;

+ (DPoint *)pointWithX:(double)x y:(double)y;
+ (DPoint *)pointWithCGPoint:(CGPoint)point;

@end
