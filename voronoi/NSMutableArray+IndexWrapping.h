//
//  NSMutableArray+IndexWrapping.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-29.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_INLINE NSRange ClampedRange(NSInteger location, NSInteger length) {
    return NSMakeRange(MAX(-1, location), MAX(0, length));
}

@interface NSMutableArray (IndexWrapping)

- (void)replaceObjectsInWrappingRange:(NSRange)range withObjects:(NSArray *)objects;

@end
