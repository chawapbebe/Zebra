//
//  ZBBaseRepo.m
//  Zebra
//
//  Created by Wilson Styres on 12/12/19.
//  Copyright © 2019 Wilson Styres. All rights reserved.
//

#import "ZBBaseRepo.h"

@implementation ZBBaseRepo

+ (NSArray *)baseReposFromSourceList:(NSString *)sourceListPath {
    NSError *readError;
    NSString *sourceListContents = [NSString stringWithContentsOfFile:sourceListPath encoding:NSUTF8StringEncoding error:&readError];
    if (readError) {
        NSLog(@"[Zebra] Could not read sources list contents located at %@ reason: %@", sourceListPath, readError.localizedDescription);
        [NSException raise:NSObjectNotAvailableException format:@"Could not read sources list contents located at %@ reason: %@", sourceListPath, readError.localizedDescription];
        
        return NULL;
    }
    
    NSArray *debLines = [sourceListContents componentsSeparatedByString:@"\n"];
    NSMutableArray *baseRepos = [NSMutableArray new];
    for (NSString *debLine in debLines) {
        if ([debLine characterAtIndex:0] == '#') continue;
        if (![debLine isEqualToString:@""] && [debLine characterAtIndex:0]) {
            [baseRepos addObject:[[ZBBaseRepo alloc] initWithDebLine:debLine]];
        }
    }
    
    return baseRepos;
}

- (id)initWithArchiveType:(NSString *)archiveType repositoryURL:(NSString *)repositoryURL distribution:(NSString *)distribution components:(NSArray <NSString *> *)components {
    self = [super init];
    
    if (self) {
        self->archiveType = archiveType;
        self->repositoryURL = repositoryURL;
        self->distribution = distribution;
        self->components = components;
    }
    
    return self;
}

- (id)initWithDebLine:(NSString *)debLine {
    
    NSMutableArray *lineComponents = [[debLine componentsSeparatedByString:@" "] mutableCopy];
    [lineComponents removeObject:@""]; //Remove empty strings from the line which exist for some reason
    if ([debLine characterAtIndex:0] == '#') return NULL;
    
    if ([lineComponents count] >= 3) {
        NSString *archiveType = lineComponents[0];
        NSString *repositoryURL = lineComponents[1];
        NSString *distribution = lineComponents[2];
        
        //Group all of the components into the components array
        NSMutableArray *sourceComponents = [NSMutableArray new];
        for (int i = 3; i < [lineComponents count]; i++) {
            NSString *component = lineComponents[i];
            if (component)  {
                [sourceComponents addObject:component];
            }
        }
        
        return [self initWithArchiveType:archiveType repositoryURL:repositoryURL distribution:distribution components:(NSArray *)sourceComponents];
    }
    
    return [super init];
}


- (NSString *)debLineFromRepo:(ZBRepo *)repo {
}

- (id)initFromRepo:(ZBRepo *)repo {
    NSMutableString *output = [NSMutableString string];
    if ([repo defaultRepo]) {
        NSString *debLine = [self knownDebLineFromURLString:[repo baseURL]];
        if (debLine) {
            [output appendString:debLine];
        } else {
            NSString *repoURL = [[repo baseURL] stringByDeletingLastPathComponent];
            repoURL = [repoURL stringByDeletingLastPathComponent]; // Remove last two path components
            [output appendFormat:@"deb %@%@/ %@ %@\n", [repo isSecure] ? @"https://" : @"http://", repoURL, [repo suite], [repo components]];
        }
    } else {
        [output appendFormat:@"deb %@%@ ./\n", [repo isSecure] ? @"https://" : @"http://", [repo baseURL]];
    }
    return output;
}

@end
