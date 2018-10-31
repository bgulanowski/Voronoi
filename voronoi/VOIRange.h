//
//  VOIRange.h
//  voronoi
//
//  Created by Brent Gulanowski on 2018-10-31.
//  Copyright © 2018 Lichen Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_INLINE BOOL VOINSRangeInvalid(NSRange range) {
    return range.location == NSNotFound;
}

NS_INLINE BOOL VOINSRangeValid(NSRange range) {
    return !VOINSRangeInvalid(range);
}

NS_INLINE BOOL VOINSRangeEmpty(NSRange range) {
    return range.length == 0;
}

extern NSRange VOINullRange;

NS_INLINE BOOL VOINSRangeNull(NSRange range) {
    return VOINSRangeInvalid(range) || VOINSRangeEmpty(range);
}

@interface VOIRange : NSObject

@property (readonly) NSInteger location;
@property (readonly) NSInteger length;

@property (readonly) NSInteger min;
@property (readonly) NSInteger max;
@property (readonly) NSInteger absoluteLength;

@property (readonly) NSRange NSRange;

- (instancetype)rangeWithLimit:(NSUInteger)limit;

- (instancetype)initWithLocation:(NSInteger)location length:(NSInteger)length;

@end

typedef enum {
    VOIReplacementNone,
    VOIReplacementReplace,
    VOIReplacementRemove
} VOIReplacementType;

@interface VOIReplacementRange : NSObject

@property (readonly) NSRange source;
@property (readonly) NSRange destination;

@property (readonly) NSRange sourceHead;
@property (readonly) NSRange sourceTail;
@property (readonly) NSRange destHead;
@property (readonly) NSRange destTail;

// If wraps is YES, source/destination are Null
// otherwise, *(Head|Tail) properties are Null
@property (readonly) BOOL wraps;

@property (readonly, getter=isTailInvalid) BOOL tailInvalid;
@property (readonly, getter=isTailNOOP) BOOL tailNOOP;

@property (readonly, getter=isHeadInvalid) BOOL headInvalid;
@property (readonly, getter=isHeadNOOP) BOOL headNOOP;
@property (readonly) VOIReplacementType headType;
@property (readonly) VOIReplacementType tailType;

- (instancetype)initWithLimit:(NSUInteger)limit size:(NSUInteger)size range:(VOIRange *)range;
+ (instancetype)replacementWithLimit:(NSUInteger)limit size:(NSUInteger)size range:(VOIRange *)range;

@end

@interface NSMutableArray (VOIRange)
- (void)substitute:(NSArray *)objects inRange:(NSRange)range;
@end

@interface NSMutableData (VOIRange)
- (void)substitute:(NSData *)data inRange:(NSRange)range;
@end
