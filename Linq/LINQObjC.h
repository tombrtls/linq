//
//  LINQObjC
//  Linq
//
//  Created by Tom Bartels on 11/02/16.
//  Copyright © 2016 IceMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray <ObjectType> (LINQ)

- (BOOL)all:(BOOL (^)(ObjectType obj))predicate;
- (BOOL)any:(BOOL (^)(ObjectType obj))predicate;
- (BOOL)none:(BOOL (^)(ObjectType obj))predicate;

- (NSArray *)select:(id (^)(ObjectType obj))query;
- (NSArray <ObjectType> *)where:(BOOL (^)(ObjectType obj))predicate;

@end
