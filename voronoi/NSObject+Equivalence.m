//
//  NSObject+Equivalence.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-19.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "NSObject+Equivalence.h"

@implementation NSObject (Equivalence)

- (BOOL)isEquivalent:(id)object {
    return [self isEqual:object];
}

@end
