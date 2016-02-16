//
//  LINQObjC.m
//  Linq
//
//  Created by Tom Bartels on 11/02/16.
//  Copyright © 2016 IceMobile. All rights reserved.
//

#import "LINQObjC.h"

@implementation NSArray (LINQ)

- (BOOL)all:(BOOL (^)(id obj))predicate {
    
    __block BOOL result = YES;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (predicate(obj) == NO) {
            result = NO;
            *stop = YES;
        }
    }];
    return result;
}

- (BOOL)any:(BOOL (^)(id obj))predicate {
    __block BOOL result = NO;
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (predicate(obj) == YES) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

- (BOOL)none:(BOOL (^)(id obj))predicate {
    return [self all:^BOOL(id obj) {
        return !predicate(obj);
    }];
}

- (NSArray *)select:(id (^)(id obj))query {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [result addObject:query(obj)];
    }];
    
    return [NSArray arrayWithArray:result];
}

- (NSArray *)where:(BOOL (^)(id obj))predicate {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (predicate(obj) == YES) {
            [result addObject:obj];
        }
    }];
    
    return [NSArray arrayWithArray:result];
}

@end

@interface Person : NSObject

@property (nonatomic, copy) NSString *firstName;

@end

@implementation Person
@end


@interface Project : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray *teamMembers;

@end

@implementation Project
@end


@interface Company : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSArray <Project *> *projects;

@end

@implementation Company
@end


@interface LINQObjCTest : NSObject

@end

@implementation LINQObjCTest

- (void)start {
    Company *company = [[Company alloc] init];
    
    // Pretty please?
    [company.projects any:^BOOL(Project *obj) {
        return [obj.name isEqualToString:@"Oh shit"];
    }];
    
    [[[company.projects where:^BOOL(Project *obj) {
        return [obj.name isEqualToString:@"ABN"];
    }] select:^id(Project *obj) {
        return obj.teamMembers;
    }] where:^BOOL(Person *obj) {
        return true;
    }];
}

@end



