//
//  AppDelegate.m
//  MIApp
//
//  Created by Gursimran Singh on 2013-10-18.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import "AppDelegate.h"
#import "KeyList.h"
#import "AddRemoveNotifications.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        [self deleteMIsOlderThan48Hours];
        [self deleteEmptyFolders];
    }
    else
    {
        // This is the first launch ever
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    [self createCompletedFolder];
    [self createErrorFolder];
    
    application.applicationIconBadgeNumber = 0;
    
    //Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


//Go through all completed folders for every user to delete mis older than certain time (stored in info.plist)
-(void) deleteMIsOlderThan48Hours
{
    //get how many days after to delete file
    NSNumber *deleteAfterDays = [[KeyList sharedInstance] deleteIncompleteFormsAfterDays];
    
    NSDate* date = [NSDate date];
    
    //list fo all users
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSArray* listOfFolders = [self arrayOfFoldersInFolder:documentsDirectory];
    
    //cycle through all users
    for (NSString* user in listOfFolders) {
        NSString* userPath = [documentsDirectory stringByAppendingPathComponent:user];
        if ((![user isEqualToString:[[KeyList sharedInstance] completedMiFolderName]]) && (![user isEqualToString:[[KeyList sharedInstance] errorFolderName]])) {
            
            //get list of mis for this user
            NSArray* miFolders = [self arrayOfFoldersInFolder:userPath];
            for (NSString* miFile in miFolders) {
                NSString* miFilePath = [[userPath stringByAppendingPathComponent:miFile] stringByAppendingPathComponent:miFile];
                
                //get last modified date of mi
                NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:miFilePath error:nil];
                NSDate *result = [fileAttribs fileCreationDate];
                NSTimeInterval secondsBetween = [date timeIntervalSinceDate:result];
                double noOfDays = secondsBetween/86400;
                
                //if modified date is greater than allowed date, then delete mi, add error file and remove all notifications for this mi
                if (noOfDays > deleteAfterDays.intValue) {
                    [self deleteFolder:[userPath stringByAppendingPathComponent:miFile]];
                    [self writeErrorFile:user :miFile];
                    [AddRemoveNotifications removeNotificationsForForm:miFile byUser:user];
                }
            }
        }
    }
}



//Delete folder
-(void) deleteFolder: (NSString*) folderPath
{
    NSArray* listOfFilesToBeDeleted = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    for (NSString* eachFile in listOfFilesToBeDeleted) {
        NSString* pathToFile = [folderPath stringByAppendingPathComponent:eachFile];
        [[NSFileManager defaultManager] removeItemAtPath:pathToFile error:nil];
    }
    [[NSFileManager defaultManager] removeItemAtPath:folderPath error:nil];
}


//Write/Modify error file
//If file exists, append file name to list else create file and add file name
-(void) writeErrorFile: (NSString*) user : (NSString*) file
{
    //get error fole path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *errorPath = [documentsDirectory stringByAppendingPathComponent:[[KeyList sharedInstance] errorFolderName]];
    NSString *userErrorFilePath = [errorPath stringByAppendingPathComponent:user];
    
    //dictionary to save error file contents
    NSMutableDictionary* errorMessages = [[NSMutableDictionary alloc] init];
    NSMutableArray *listOfMIsDeleted = [[NSMutableArray alloc] init];
    
    //if file exits, get data and save to dictionary
    if ([[NSFileManager defaultManager] fileExistsAtPath:userErrorFilePath isDirectory:NO]) {
        NSData *data = [NSData dataWithContentsOfFile:userErrorFilePath];
        errorMessages = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        listOfMIsDeleted = [errorMessages objectForKey:[[KeyList sharedInstance] deletedMisErrorFileKey]];
        NSLog(@"%@", errorMessages);
    }
    
    //add file name to dictionary and save to file
    [listOfMIsDeleted addObject:file];
    [errorMessages setObject:listOfMIsDeleted forKey:[[KeyList sharedInstance] deletedMisErrorFileKey]];
    [NSKeyedArchiver archiveRootObject:errorMessages toFile:userErrorFilePath];
}


//create error folder
-(void) createErrorFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[[KeyList sharedInstance] errorFolderName]];
    [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
}


//create completed folder
-(void) createCompletedFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[[KeyList sharedInstance] completedMiFolderName]];
    [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
}

//delete emplty folders in directory hierarchy
-(void) deleteEmptyFolders
{
    [self deleteCompletedUserFolders];
    [self deleteEmptyUSerFolders];
}


//delete empty completed folders
-(void) deleteCompletedUserFolders
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString* completedPath = [documentsDirectory stringByAppendingPathComponent:[[KeyList sharedInstance] completedMiFolderName]];
    NSArray* listOfFolders = [self arrayOfFoldersInFolder:completedPath];
    for (NSString* folder in listOfFolders) {
        NSString* folderPath = [completedPath stringByAppendingPathComponent:folder];
        if ([self isEmptyDirectoryAtURL:folderPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:folderPath error:nil];
        }
    }
}


//delete empty user folders
-(void) deleteEmptyUSerFolders
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSArray* listOfFolders = [self arrayOfFoldersInFolder:documentsDirectory];
    for (NSString* folder in listOfFolders) {
        NSString* folderPath = [documentsDirectory stringByAppendingPathComponent:folder];
        if ((![folder isEqualToString:[[KeyList sharedInstance] completedMiFolderName]]) && (![folder isEqualToString:[[KeyList sharedInstance] errorFolderName]])) {
            if ([self isEmptyDirectoryAtURL:folderPath]) {
                [[NSFileManager defaultManager] removeItemAtPath:folderPath error:nil];
            }
        }
    }
}


//check if passed path is directory or not
//returns true of empty else false
- (BOOL)isEmptyDirectoryAtURL:(NSString*)url
{
    NSArray* list = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:url error:nil];
    if ([list count] > 0) {
        if ([list count] == 1) {
            if ([[list objectAtIndex:0] isEqualToString:@".DS_Store"]) {
                return YES;
            }
        }
    }else{
        return YES;
    }
    return NO;
}

//Returns a list of folders inside a folder
-(NSArray*)arrayOfFoldersInFolder:(NSString*) folder {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSArray* files = [fm contentsOfDirectoryAtPath:folder error:nil];
	NSMutableArray *directoryList = [[NSMutableArray alloc] init];
	for(NSString *file in files) {
		NSString *path = [folder stringByAppendingPathComponent:file];
		BOOL isDir = NO;
		[fm fileExistsAtPath:path isDirectory:(&isDir)];
		if(isDir) {
			[directoryList addObject:file];
		}
	}
	return directoryList;
}


@end


//REMOVE THIS OTHERWISE SSL CERTIFICATES ARE NOT CHECKED
@implementation NSURLRequest(DataController)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}
@end

