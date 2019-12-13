//
//  ZBBaseRepo.h
//  Zebra
//
//  Created by Wilson Styres on 12/12/19.
//  Copyright © 2019 Wilson Styres. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBBaseRepo : NSObject
@property (nonatomic, strong) NSString *archiveType;
@property (nonatomic, strong) NSString *repositoryURL;
@property (nonatomic, strong) NSString *distribution;
@property (nonatomic, strong) NSArray *components;
+ (NSArray *)baseReposFromSourceList:(NSString *)sourceListPath;
- (id)initWithDebLine:(NSString *)debLine;
- (id)initWithArchiveType:(NSString *)archiveType repositoryURL:(NSString *)repositoryURL distribution:(NSString *)distribution components:(NSArray <NSString *> *)components;
@end

NS_ASSUME_NONNULL_END
