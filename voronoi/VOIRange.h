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

- (instancetype)initWithLocation:(NSInteger)location length:(NSInteger)length;

@end

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

@property (readonly, getter=isTailEmpty) BOOL tailEmpty;
@property (readonly, getter=isTailInvalid) BOOL tailInvalid;
@property (readonly, getter=isTailNOOP) BOOL tailNOOP;

@property (readonly, getter=isHeadEmpty) BOOL headEmpty;
@property (readonly, getter=isHeadInvalid) BOOL headInvalid;
@property (readonly, getter=isHeadNOOP) BOOL headNOOP;

- (instancetype)initWithLimit:(NSUInteger)limit size:(NSUInteger)size range:(VOIRange *)range;
+ (instancetype)replacementWithLimit:(NSUInteger)limit size:(NSUInteger)size range:(VOIRange *)range;

@end

@interface NSMutableArray (VOIRange)
- (void)replace:(NSArray *)objects inRange:(NSRange)range;
@end

@interface NSMutableData (VOIRange)
- (void)replace:(NSData *)data inRange:(NSRange)range;
@end
