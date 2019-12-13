//
//  ZBDownloadManager.h
//  Zebra
//
//  Created by Wilson Styres on 4/14/19.
//  Copyright © 2019 Wilson Styres. All rights reserved.
//

@class ZBQueue;
@class ZBBaseRepo;

#import <Foundation/Foundation.h>
#import "ZBDownloadDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZBDownloadManager : NSObject <NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate>
@property (nonatomic, weak) id <ZBDownloadDelegate> downloadDelegate;
@property (nonatomic, strong) NSURLSession *session;
- (id)initWithDownloadDelegate:(id <ZBDownloadDelegate>)delegate;
- (void)downloadRepo:(ZBBaseRepo *_Nonnull)repo ignoreCaching:(BOOL)ignore;
- (void)downloadRepos:(NSArray <ZBBaseRepo *> *_Nonnull)repos ignoreCaching:(BOOL)ignore;
- (void)downloadPackage:(ZBPackage *)package;
- (void)downloadPackages:(NSArray <ZBPackage *> *)packages;
- (void)stopAllDownloads;
@end

NS_ASSUME_NONNULL_END
