//
//  ZBRepo.h
//  Zebra
//
//  Created by Wilson Styres on 11/30/18.
//  Copyright © 2018 Wilson Styres. All rights reserved.
//

#import "ZBBaseRepo.h"

#import <Foundation/Foundation.h>
#import <sqlite3.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZBRepo : ZBBaseRepo
@property (nonatomic, strong) NSString *origin;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *codename;
@property (nonatomic, strong) NSString *architecture;
@property (nonatomic, strong) NSString *repoDescription;
@property (nonatomic, strong) NSString *baseFilename;
@property (nonatomic) BOOL secure;
@property (nonatomic) int repoID;

@property (nonatomic) BOOL supportSileoPay;
@property (nonatomic, strong) NSURL *iconURL;
@property (nonatomic) BOOL supportsFeaturedPackages;
@property (nonatomic) BOOL checkedSupportFeaturedPackages;
@property (nonatomic, strong) NSString *displayableURL;

+ (ZBRepo *)repoMatchingRepoID:(int)repoID;
+ (ZBRepo *)localRepo:(int)repoID;
+ (ZBRepo *)repoFromBaseURL:(NSString *)baseURL;
+ (BOOL)exists:(NSString *)urlString;
- (id)initWithSQLiteStatement:(sqlite3_stmt *)statement;
- (BOOL)isSecure;
- (BOOL)canDelete;
@end

NS_ASSUME_NONNULL_END
