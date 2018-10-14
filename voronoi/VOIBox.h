//
//  VOIBox.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-05.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VOIPointList;

@interface VOIBox : NSObject

@property (readonly) VOIPoint origin;
@property (readonly) VOISize size;
@property (readonly) VOIPoint centre;

@property (readonly) double minX;
@property (readonly) double midX;
@property (readonly) double maxX;
@property (readonly) double minY;
@property (readonly) double midY;
@property (readonly) double maxY;

@property (readonly) double width;
@property (readonly) double height;

@property (readonly, getter = isDegenerate) BOOL degenerate;

- (instancetype)initWithOrigin:(VOIPoint)origin size:(VOISize)size NS_DESIGNATED_INITIALIZER;
// clockwise starting at origin
- (VOIPointList *)asPointList;
- (BOOL)containsPoint:(VOIPoint)point;
- (VOIPoint)randomPoint;

+ (VOIPoint)regularizeOrigin:(VOIPoint)origin forSize:(VOISize)size;

@end
