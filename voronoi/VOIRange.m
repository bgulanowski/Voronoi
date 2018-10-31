//
//  VOIRange.m
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-31.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import "VOIRange.h"

NSRange VOINullRange = { .location = NSNotFound, .length = 0 };

@implementation VOIRange

- (NSInteger)min {
    return MIN(_location, _location + _length);
}

- (NSInteger)max {
    return MAX(_location, _location + _length);
}

- (NSInteger)absoluteLength {
    return ABS(_length);
}

- (NSRange)NSRange {
    return NSMakeRange(self.min < 0 ? NSNotFound : self.min, MAX(0, self.absoluteLength));
}

- (instancetype)rangeWithLimit:(NSUInteger)limit {
    return [[[self class] alloc] initWithLocation:_location % limit length:MIN(_length, limit)];
}

- (instancetype)initWithLocation:(NSInteger)location length:(NSInteger)length {
    self = [super init];
    if (self) {
        _location = location;
        _length = length;
    }
    return self;
}

+ (instancetype)rangeWithNSRange:(NSRange)range {
    return [[self alloc] initWithLocation:range.location length:range.length];
}

+ (NSRange)NSRangeWithLocation:(NSInteger)location length:(NSInteger)length {
    return [[[self alloc] initWithLocation:location length:length] NSRange];
}

@end

@implementation VOIReplacementRange {
    NSInteger _limit;
    NSInteger _size;
    VOIRange *_range;
}

- (NSRange)source {
    return self.wraps ? VOINullRange : NSMakeRange(0, _size);
}

- (NSRange)destination {
    return self.wraps ? VOINullRange : _range.NSRange;
}

- (BOOL)isTailInvalid {
    return (
            VOINSRangeInvalid(self.destTail) ||
            VOINSRangeInvalid(self.sourceHead)
            );
}

- (BOOL)isTailNOOP {
    return VOINSRangeEmpty(self.destTail) || [self isTailInvalid];
}

- (BOOL)isHeadInvalid {
    return (
            VOINSRangeInvalid(self.destHead) ||
            VOINSRangeInvalid(self.sourceTail)
            );
}

- (BOOL)isHeadNOOP {
    return VOINSRangeEmpty(self.destHead) || [self isHeadInvalid];
}

- (VOIReplacementType)headType {
    if ([self isHeadNOOP]) {
        return VOIReplacementNone;
    }
    else if (VOINSRangeEmpty(self.sourceTail)) {
        return VOIReplacementRemove;
    }
    else {
        return VOIReplacementReplace;
    }
}

- (VOIReplacementType)tailType {
    if ([self isTailNOOP]) {
        return VOIReplacementNone;
    }
    else if (VOINSRangeEmpty(self.sourceHead)) {
        return VOIReplacementRemove;
    }
    else {
        return VOIReplacementReplace;
    }
}

- (BOOL)wraps {
    return _range.max > _limit;
}

- (instancetype)initWithLimit:(NSUInteger)limit size:(NSUInteger)size range:(VOIRange *)range {
    self = [super init];
    if (self) {
        _limit = limit;
        _size = size;
        _range = [range rangeWithLimit:limit];
        if (self.wraps) {
            [self calculateWrapping];
        }
        else {
            _sourceHead = VOINullRange;
            _sourceTail = VOINullRange;
            _destHead = VOINullRange;
            _destTail = VOINullRange;
        }
    }
    return self;
}

- (void)calculateWrapping {
    
    NSInteger limit = _limit;
    
    // How many elements are being replaced?
    const NSInteger overflow = _range.max - limit;
    const NSInteger dhLen = MAX(0, MIN(limit, overflow));
    const NSInteger dtLen = limit - _range.location;
    
    // How many elements are replacing them?
    const NSInteger stLen = MIN(dhLen, _size);
    const NSInteger shLen = _size - stLen;

    _destTail = [VOIRange NSRangeWithLocation:_range.location length:dtLen];
    _sourceHead = [VOIRange NSRangeWithLocation:0 length:shLen];
    
    // If destTail > sourceHead, limit will shrink
    limit += _sourceHead.length - _destTail.length;
    
    _destHead = [VOIRange NSRangeWithLocation:0 length:MIN(dhLen, limit)];
    _sourceTail = [VOIRange NSRangeWithLocation:shLen length:stLen];
}

+ (instancetype)replacementWithLimit:(NSUInteger)limit size:(NSUInteger)size range:(VOIRange *)range {
    return [[self alloc] initWithLimit:limit size:size range:range];
}

@end

@implementation NSMutableArray (VOIRange)

- (void)substitute:(NSArray *)objects inRange:(NSRange)range {
    VOIRange *voirange = [VOIRange rangeWithNSRange:range];
    VOIReplacementRange *vr = [VOIReplacementRange replacementWithLimit:self.count
                                                                   size:objects.count
                                                                  range:voirange];
    if (vr.wraps) {
        switch (vr.tailType) {
            case VOIReplacementReplace:
                [self replaceObjectsInRange:vr.destTail withObjectsFromArray:objects range:vr.sourceHead];
                break;
            case VOIReplacementRemove:
                [self removeObjectsInRange:vr.destTail];
                break;
            case VOIReplacementNone:
            default:
                break;
        }
        switch (vr.headType) {
            case VOIReplacementReplace:
                [self replaceObjectsInRange:vr.destHead withObjectsFromArray:objects range:vr.sourceTail];
                break;
            case VOIReplacementRemove:
                [self removeObjectsInRange:vr.destHead];
            case VOIReplacementNone:
            default:
                break;
        }
    }
    else {
        if (objects.count) {
            [self replaceObjectsInRange:vr.destination withObjectsFromArray:objects range:vr.source];
        }
        else {
            [self removeObjectsInRange:vr.destination];
        }
    }
}

@end

@implementation NSMutableData (VOIRange)

-(void)substitute:(NSData *)data inRange:(NSRange)range {
    VOIRange *voirange = [VOIRange rangeWithNSRange:range];
    VOIReplacementRange *vr = [VOIReplacementRange replacementWithLimit:self.length
                                                                   size:data.length
                                                                  range:voirange];
    const void *bytes = data.bytes;
    if (vr.wraps) {
        if (vr.tailType != VOIReplacementNone) {
            [self replaceBytesInRange:vr.destTail
                            withBytes:bytes
                               length:vr.sourceHead.length];
        }
        if (vr.headType != VOIReplacementNone) {
                [self replaceBytesInRange:vr.destHead
                                withBytes:&bytes[vr.sourceTail.location]
                                   length:vr.destTail.length];
        }
    }
    else {
        [self replaceBytesInRange:vr.destination withBytes:bytes length:data.length];
    }
}

@end
