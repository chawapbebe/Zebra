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

/*!
 @brief The Archive Type of the repository. Can be either "deb" or "deb-src"
 @remark Although "deb-src" is a valid option, Zebra does not currently support it.
 */
@property (nonatomic, strong) NSString *archiveType;

/*! @brief The URL of the repository */
@property (nonatomic, strong) NSString *repositoryURL;

/*! @brief The distribution can be either the release code name or the release class. */
@property (nonatomic, strong) NSString *distribution;

/*! @brief A list of areas that the repo supports */
@property (nonatomic, strong) NSArray *components;

/*! @brief The directory that should contain all of the repository's information */
@property (nonatomic, strong) NSURL *mainDirectoryURL;

/*!
 @brief The directory that should contain all of the repository's package files
 @remark This could be the same as mainDirectoryURL if the repository doese not use distributions
 */
@property (nonatomic, strong) NSURL *packagesDirectoryURL;

/*! @brief The URL where the repository's Release file should be contained */
@property (nonatomic, strong) NSURL *releaseURL;

/*!
 @brief The name of the file that will be saved to the device after having downloaded and extracted the Packages file
 @remark The actual file will be located in -[ZBAppDelegate listsLocation]
 */
@property (nonatomic, strong) NSString *packagesSaveName;

/*!
 @brief The name of the file that will be saved to the device after having downloaded the Release file
 @remark The actual file will be located in -[ZBAppDelegate listsLocation]
 */
@property (nonatomic, strong) NSString *releaseSaveName;

/*!
 @brief The original line from sources.list that created this instance
 @remark This could also be a recreation of the line from information stored in the database
 */
@property (nonatomic, strong) NSString *debLine;

/*!
 @brief Creates an array of ZBBaseRepo instances from a sources.list file
 @discussion Reads the file located at sourcesListPath and creates one ZBBaseRepo instance per line if the line is not a comment (or contains an error)
 @param sourceListPath the location of the sources.list to read
 @return An array of ZBBaseRepo instances, one for each repository defined in sourceListPath
 */
+ (NSArray *)baseReposFromSourceList:(NSString *)sourceListPath;

/*!
 @brief Creates a ZBBaseRepo instance
 @discussion Creates a ZBBaseRepo instance and assigns all properties to their respective (or calculated) values.
 @return A ZBBaseRepo instance
 */
- (id)initWithArchiveType:(NSString *)archiveType repositoryURL:(NSString *)repositoryURL distribution:(NSString *)distribution components:(NSArray <NSString *> *)components;

/*!
@brief Creates a ZBBaseRepo instance
@discussion Creates a ZBBaseRepo instance from a line located in sources.list and assigns all properties to their respective (or calculated) values
@return A ZBBaseRepo instance
*/
- (id)initFromDebLine:(NSString *)debLine;
@end

NS_ASSUME_NONNULL_END
