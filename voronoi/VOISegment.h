//
//  VOISegment.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    VOILineSideRight,
    VOILineSideOn,
    VOILineSideLeft
} VOILineSide;

typedef enum {
    VOIAbove,
    VOIBelow,
    VOIUpward,
    VOIDownward,
    VOIHorizontalUpon
} VOIVerticalPosition;

typedef enum {
    VOILeft,
    VOIRight,
    VOILeftward,
    VOIRightward,
    VOIVerticalUpon
} VOIHorizontalPosition;

@class VOIBox;

@interface VOISegment : NSObject

@property (readonly) VOIPoint a;
@property (readonly) VOIPoint b;
@property (readonly) VOIPoint midpoint;
@property (readonly) VOIBox *boundingBox;

- (instancetype)initWithPoint:(VOIPoint)point otherPoint:(VOIPoint)other NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithPoints:(const VOIPoint[2])points;
- (BOOL)isEqualToSegment:(VOISegment *)other;
- (VOISegment *)perpendicular;
// Treat point b like a vector
- (VOIPoint)intersectWithSegment:(VOISegment *)other;
// distance from midpoint
- (double)distanceFromPoint:(VOIPoint)point;
- (double)distanceSquaredFromPoint:(VOIPoint)point;
- (BOOL)pointBetween:(VOIPoint)point;

// Forward is the direction of the vector b - a
- (VOILineSide)sideForPoint:(VOIPoint)point;

- (VOIVerticalPosition)verticalPosition:(double)y;
- (VOIHorizontalPosition)horizontalPosition:(double)x;

@end
