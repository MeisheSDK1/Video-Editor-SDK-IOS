//
//  NveMutableArray.h
//  NveEffectKit
//
//  Created by meishe on 2023/6/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NveMutableArray<__covariant ObjectType> : NSObject

@property(nonatomic, readonly) ObjectType lastObject;

+ (NveMutableArray *)array;

- (NSMutableArray *)array;

- (BOOL)containsObject:(ObjectType)anObject;

- (NSUInteger)count;

- (void)addObjectsFromArray:(NSArray<ObjectType> *)otherArray;

//- (id)objectAtIndex:(NSUInteger)index;

//- (NSEnumerator *)objectEnumerator;

- (void)insertObject:(ObjectType)anObject atIndex:(NSUInteger)index;

- (void)addObject:(ObjectType)anObject;

- (void)removeObjectAtIndex:(NSUInteger)index;

- (void)removeObject:(ObjectType)anObject;

- (void)removeLastObject;

- (void)removeAllObjects;

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(ObjectType)anObject;

//- (NSUInteger)indexOfObject:(id)anObject;

@end

NS_ASSUME_NONNULL_END
