//
//  DBoundary.h
//  Voronoi
//
//  Created by Brent Gulanowski on 12-11-09.
//  Copyright (c) 2012 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@class DPoint, DRange, DSegment;

@interface DBoundary : NSObject {
    DRange *_range;
    NSMutableArray *_segments;
    double _minSizeFactor;
}

@property DRange *range;
@property double minSizeFactor;

@property (readonly) NSArray *segments;

- (id)initWithRange:(DRange *)range;

- (DPoint *)intersectWithSegment:(DSegment *)segment index:(NSUInteger *)pIndex;
- (NSArray *)clipWithSegment:(DSegment *)s1 segment:(DSegment *)s2;

+ (DBoundary *)boundaryWithRange:(DRange *)range;

@end
