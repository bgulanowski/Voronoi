 //
//  NSMutableArray+IndexWrapping.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-29.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "NSMutableArray+IndexWrapping.h"

@implementation NSMutableArray (IndexWrapping)

- (void)replaceObjectsInWrappingRange:(NSRange)range withObjects:(NSArray *)objects {

    const NSUInteger count = self.count;
    if (range.location >= count) {
        range.location %= count;
    }
    
    NSUInteger last = NSMaxRange(range);
    if (range.length > count) {
        [self replaceObjectsInRange:NSMakeRange(0, count) withObjectsFromArray:objects];
    }
    else if (last > count) {
        NSRange frontRange = NSMakeRange(0, last - count);
        NSRange endRange = NSMakeRange(range.location, count - range.location);
        [self replaceObjectsInRange:endRange withObjectsFromArray:objects];
        [self removeObjectsInRange:frontRange];
    }
    else {
        [self replaceObjectsInRange:range withObjectsFromArray:objects];
    }
}

@end
