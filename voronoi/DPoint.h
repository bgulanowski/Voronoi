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
    Float64 _x;
    Float64 _y;
}

@property Float64 x;
@property Float64 y;

- (id)initWithX:(Float64)x y:(Float64)y;
- (id)initWithCGPoint:(CGPoint)point;

- (DPoint *)add:(DPoint *)other;
- (DPoint *)subtract:(DPoint *)other;

- (Float64)distanceTo:(DPoint *)other;
- (Float64)distanceSquaredTo:(DPoint *)other;
- (Float64)distanceFromOrigin;

- (CGPoint)CGPoint;

+ (DPoint *)pointWithX:(Float64)x y:(Float64)y;
+ (DPoint *)pointWithCGPoint:(CGPoint)point;

@end
