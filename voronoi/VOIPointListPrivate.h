//
//  VOIPointListPrivate.h
//  Voronoi
//
//  Created by Brent Gulanowski on 2018-10-04.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

@interface VOIPointList (VOIPointListPrivate)
- (instancetype)_initWithData:(NSMutableData *)data;
@property (nonatomic, readonly) NSMutableData *pointsData;
@end
