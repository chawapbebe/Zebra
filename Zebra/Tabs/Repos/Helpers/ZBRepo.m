//
//  ZBRepo.m
//  Zebra
//
//  Created by Wilson Styres on 11/30/18.
//  Copyright © 2018 Wilson Styres. All rights reserved.
//

#import "ZBRepo.h"
#import "ZBRepoManager.h"
#import "UICKeyChainStore.h"
#import <ZBAppDelegate.h>
#import <Database/ZBDatabaseManager.h>
#import <Database/ZBColumn.h>

@implementation ZBRepo

@synthesize origin;
@synthesize label;
@synthesize version;
@synthesize codename;
@synthesize architecture;
@synthesize repoDescription;
@synthesize baseFilename;
@synthesize secure;
@synthesize repoID;

@synthesize supportSileoPay;
@synthesize iconURL;
@synthesize supportsFeaturedPackages;
@synthesize checkedSupportFeaturedPackages;
@synthesize displayableURL;

+ (ZBRepo *)repoMatchingRepoID:(int)repoID {
    return [[ZBRepoManager sharedInstance] repos][@(repoID)];
}

+ (ZBRepo *)localRepo:(int)repoID {
    ZBRepo *local = [[ZBRepo alloc] init];
    [local setOrigin:NSLocalizedString(@"Local Repository", @"")];
    [local setRepoDescription:NSLocalizedString(@"Locally installed packages", @"")];
    [local setRepoID:repoID];
    [local setBaseFilename:@"/var/lib/dpkg/status"];
    return local;
}

+ (ZBRepo *)repoFromBaseURL:(NSString *)baseURL {
    return [[ZBDatabaseManager sharedInstance] repoFromBaseURL:baseURL];
}

+ (BOOL)exists:(NSString *)urlString {
    ZBDatabaseManager *databaseManager = [ZBDatabaseManager sharedInstance];
    NSRange dividerRange = [urlString rangeOfString:@"://"];
    NSUInteger divide = NSMaxRange(dividerRange);
    NSString *baseURL = divide > [urlString length] ? urlString : [urlString substringFromIndex:divide];
    
    return [databaseManager repoIDFromBaseURL:baseURL] > 0;
}

- (id)initWithSQLiteStatement:(sqlite3_stmt *)statement {
    self = [super init];
    
    if (self) {
        const char *originChars =        (const char *)sqlite3_column_text(statement, ZBRepoColumnOrigin);
        const char *labelChars =         (const char *)sqlite3_column_text(statement, ZBRepoColumnLabel);
        const char *suiteChars =         (const char *)sqlite3_column_text(statement, ZBRepoColumnSuite);
        const char *versionChars =       (const char *)sqlite3_column_text(statement, ZBRepoColumnVersion);
        const char *codenameChars =      (const char *)sqlite3_column_text(statement, ZBRepoColumnCodename);
        const char *architecturesChars = (const char *)sqlite3_column_text(statement, ZBRepoColumnArchitectures);
        const char *componentsChars =    (const char *)sqlite3_column_text(statement, ZBRepoColumnComponents);
        const char *descriptionChars =   (const char *)sqlite3_column_text(statement, ZBRepoColumnDescription);
        const char *baseFilenameChars =  (const char *)sqlite3_column_text(statement, ZBRepoColumnBaseFilename);
        BOOL secure =                                  sqlite3_column_int(statement, ZBRepoColumnSecure);
        const char *baseURLChars =       (const char *)sqlite3_column_text(statement, ZBRepoColumnBaseURL);
        int repoID =                                   sqlite3_column_int(statement, ZBRepoColumnRepoID);
        
        NSURL *iconURL;
        NSString *baseURL = baseURLChars != 0 ? [[NSString alloc] initWithUTF8String:baseURLChars] : NULL;
        NSArray *separate = [baseURL componentsSeparatedByString:@"dists"];
        NSString *shortURL = separate[0];
        
        NSString *url = [baseURL stringByAppendingPathComponent:@"CydiaIcon.png"];
        if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
            iconURL = [NSURL URLWithString:url];
        } else if (secure) {
            iconURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@", url]];
        } else {
            iconURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", url]];
        }
        
        [self setOrigin:originChars != 0 ? [[NSString alloc] initWithUTF8String:originChars] : (baseURL ?: NSLocalizedString(@"Unknown", @""))];
        [self setLabel:labelChars != 0 ? [[NSString alloc] initWithUTF8String:labelChars] : NULL];
        [self setVersion:versionChars != 0 ? [[NSString alloc] initWithUTF8String:versionChars] : NULL];
        [self setCodename:codenameChars != 0 ? [[NSString alloc] initWithUTF8String:codenameChars] : NULL];
        [self setArchitecture:architecturesChars != 0 ? [[NSString alloc] initWithUTF8String:architecturesChars] : NULL];
        [self setRepoDescription:descriptionChars != 0 ? [[NSString alloc] initWithUTF8String:descriptionChars] : NULL];
        [self setBaseFilename:baseFilenameChars != 0 ? [[NSString alloc] initWithUTF8String:baseFilenameChars] : NULL];
        [self setRepositoryURL:baseURL];
        [self setSecure:secure];
        [self setRepoID:repoID];
        [self setIconURL:iconURL];
        [self setDistribution:suiteChars != 0 ? [[NSString alloc] initWithUTF8String:suiteChars] : NULL];
        
        NSString *componentsLine = componentsChars != 0 ? [[NSString alloc] initWithUTF8String:componentsChars] : NULL;
        if (componentsLine) {
            [self setComponents:[componentsLine componentsSeparatedByString:@" "]];
        }
        [self setDisplayableURL:shortURL];
        
        if (secure) {
            NSString *requestURL;
            if ([baseURL hasSuffix:@"/"]) {
                requestURL = [NSString stringWithFormat:@"https://%@payment_endpoint", baseURL];
            } else {
                requestURL = [NSString stringWithFormat:@"https://%@/payment_endpoint", baseURL];
            }
            NSURL *url = [NSURL URLWithString:requestURL];
            NSURLSession *session = [NSURLSession sharedSession];
            [[session dataTaskWithURL:url
                    completionHandler:^(NSData *data,
                                        NSURLResponse *response,
                                        NSError *error) {
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                        NSString *endpoint = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        if ([endpoint length] != 0 && (long)[httpResponse statusCode] == 200) {
                            UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:[ZBAppDelegate bundleID] accessGroup:nil];
                            keychain[baseURL] = endpoint;
                            [self setSupportSileoPay:YES];
                        }
                    }] resume];
        }
        // prevent constant network spam
        if (!self.checkedSupportFeaturedPackages) {
            // Check for featured string
            NSString *requestURL;
            if ([baseURL hasSuffix:@"/"]) {
                requestURL = [NSString stringWithFormat:@"https://%@sileo-featured.json", baseURL];
            } else {
                requestURL = [NSString stringWithFormat:@"https://%@/sileo-featured.json", baseURL];
            }
            NSURL *checkingURL = [NSURL URLWithString:requestURL];
            NSURLSession *session = [NSURLSession sharedSession];
            [[session dataTaskWithURL:checkingURL
                    completionHandler:^(NSData *data,
                                        NSURLResponse *response,
                                        NSError *error) {
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                        if (data != nil && (long)[httpResponse statusCode] != 404) {
                            [self setSupportsFeaturedPackages:YES];
                        }
                    }] resume];
            [self setCheckedSupportFeaturedPackages:YES];
        }
    }
    
    return self;
}

- (BOOL)isSecure {
    return secure;
}

- (BOOL)canDelete {
    return ![[self baseFilename] isEqualToString:@"getzbra.com_repo_."];
}

- (BOOL)isEqual:(ZBRepo *)object {
    if (self == object)
        return YES;
    
    if (![object isKindOfClass:[ZBRepo class]])
        return NO;
    
    return [[object baseFilename] isEqual:[self baseFilename]];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ %@ %d", origin, displayableURL, repoID];
}

@end
