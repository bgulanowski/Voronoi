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

    if (range.location > self.count) {
        range.location %= self.count;
    }
    
    if (self.count >= NSMaxRange(range)) {
        // No wrapping; fallback to standard behaviour
        [self replaceObjectsInRange:range withObjectsFromArray:objects];
    }
    else {
        // The range wraps around.

        // How many objects are being replaced?
        const NSInteger overflow = (NSInteger)NSMaxRange(range) - (NSInteger)self.count;
        const NSInteger startCount = MAX(0, MIN((NSInteger)self.count, overflow));

        // How many objects are replacing them?
        const NSInteger lastCount = MIN(startCount, objects.count);
        const NSInteger firstCount = objects.count - lastCount;
        
        // Replace the end of the current array with objects[first]
        NSRange end = ClampedRange(range.location, self.count - range.location);
        NSRange first = ClampedRange(0, firstCount);
        [self replaceObjectsInRange:end withObjectsFromArray:objects range:first];
        
        // Replace the start of the current array with objects[last]
        NSRange start = NSMakeRange(0, MIN(startCount, self.count));
        NSRange last = ClampedRange(firstCount, lastCount);
        [self replaceObjectsInRange:start withObjectsFromArray:objects range:last];
    }
}

@end
