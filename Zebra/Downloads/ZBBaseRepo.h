//
//  ZBBaseRepo.h
//  Zebra
//
//  Created by Wilson Styres on 12/12/19.
//  Copyright © 2019 Wilson Styres. All rights reserved.
//

@class ZBRepo;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBBaseRepo : NSObject {
    NSString *archiveType;
    NSString *repositoryURL;
    NSString *distribution;
    NSArray *components;
}
+ (NSArray *)baseReposFromSourceList:(NSString *)sourceListPath;
- (id)initWithDebLine:(NSString *)debLine;
- (id)initWithArchiveType:(NSString *)archiveType repositoryURL:(NSString *)repositoryURL distribution:(NSString *)distribution components:(NSArray <NSString *> *)components;
@end

NS_ASSUME_NONNULL_END
