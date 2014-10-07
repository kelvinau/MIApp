//
//  SelectNewUserToAssignFormTableView.m
//  MIApp
//
//  Created by Gursimran Singh on 2014-03-05.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "SelectNewUserToAssignFormTableView.h"
#import "PerformLdapAuthentication.h"
#import "KeyList.h"

@implementation SelectNewUserToAssignFormTableView
{
    NSArray* listOfUsers;
    NSArray* searchListOfUsers;
}

@synthesize popOver, folderPath, formName;

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    
    //get all users
    [self getAllUsers];
    
    self.title = @"Select new user";

}


//number of sections
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

//title of section
-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"select new user";
}

//number of rows
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //searched list size
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchListOfUsers count];
    }
    
    //all users list
    return [listOfUsers count];
}


//cell for location
-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"userNameToAssignCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userNameToAssignCell"];
    }
    
    //search table
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell.textLabel.text = [searchListOfUsers objectAtIndex:indexPath.row];
    }
    //regular table
    else{
        cell.textLabel.text = [listOfUsers objectAtIndex:indexPath.row];
    }
    return cell;
}

//method called to get list of users from ldap server
-(void) getAllUsers
{
    listOfUsers = [PerformLdapAuthentication getUserList];
}


//method called when user starts performing search
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    
    //match users that match users search characters
    NSPredicate* searchPredicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", searchString];
    searchListOfUsers = [listOfUsers filteredArrayUsingPredicate:searchPredicate];
    return YES;
}

//BUG in iOS 7
//need to set background to white if displayed table in popover
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    tableView.backgroundColor = [UIColor whiteColor];
}


//method called when user selects a new user
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //get new user selected
    NSString* user;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        user = [searchListOfUsers objectAtIndex:indexPath.row];
    }else{
        user = [listOfUsers objectAtIndex:indexPath.row];
    }
    
    //move the form to new user
    [self moveFormToNewUser:user];
    
    //create error message for old user
    [self createErrorMessage];
    
    //dismiss popover
    [self.popOver dismissPopoverAnimated:YES];
    [self.popOver.delegate popoverControllerDidDismissPopover:self.popOver];

}

-(void) createErrorMessage
{
    //get error file path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *errorPath = [documentsDirectory stringByAppendingPathComponent:[[KeyList sharedInstance] errorFolderName]];
    NSString *userErrorFilePath = [errorPath stringByAppendingPathComponent:[[folderPath stringByDeletingLastPathComponent] lastPathComponent]];
    
    
    NSMutableDictionary* errorMessages = [[NSMutableDictionary alloc] init];
    NSMutableArray *listOfMisReassgined = [[NSMutableArray alloc] init];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:userErrorFilePath isDirectory:NO]) {
        NSData *data = [NSData dataWithContentsOfFile:userErrorFilePath];
        errorMessages = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        listOfMisReassgined = [errorMessages objectForKey:[[KeyList sharedInstance] reassignedMisErrorFileKey]];
    }
    [listOfMisReassgined addObject:formName];
    [errorMessages setObject:listOfMisReassgined forKey:[[KeyList sharedInstance] reassignedMisErrorFileKey]];
    [NSKeyedArchiver archiveRootObject:errorMessages toFile:userErrorFilePath];

}


//method to move data to new user
-(void) moveFormToNewUser: (NSString*) newUser
{
    
    //get list of files to move
    NSArray* listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    
    //create new folder
    NSString* newFolderName = [self createDestinationFolder: newUser];
    
    //get new folder path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString* userFolder = [documentsDirectory stringByAppendingPathComponent:newUser];
    NSString* newFolderPath = [userFolder stringByAppendingPathComponent:newFolderName];
    
    
    //move every file over to new destination
    for (NSString* file in listOfFiles) {
        NSString* filePath;
        if ([file isEqualToString:formName]) {
            filePath = [[newFolderPath stringByAppendingString:@"/"] stringByAppendingString:newFolderName];
        }else{
            filePath = [[newFolderPath stringByAppendingString:@"/"] stringByAppendingString:file];
        }
        
        [[NSFileManager defaultManager] moveItemAtPath:[folderPath stringByAppendingPathComponent:file] toPath:filePath error:nil];
    }
    
    //delete old empty folder
    [[NSFileManager defaultManager] removeItemAtPath:folderPath error:nil];
}


//create destination folder for the new user
-(NSString*) createDestinationFolder: (NSString*) newUser
{
    
    //get the new users folder path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString* userFolder = [documentsDirectory stringByAppendingPathComponent:newUser];

    [[NSFileManager defaultManager] createDirectoryAtPath:userFolder withIntermediateDirectories:NO attributes:Nil error:Nil];
    
    //get list of folders in new users' folder
    NSArray* listOfFilesInNewUserFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:userFolder error:nil];


    //get name of folder that needs to be copied without  '(x)'
    NSString* tempFormName = [[formName componentsSeparatedByString:@" ("] objectAtIndex:0];
    NSString* formFolderName = tempFormName;

    
    //check if folder with this name exists for new user
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", formFolderName];
    NSArray* filteredFormArray = [listOfFilesInNewUserFolder filteredArrayUsingPredicate:predicate];
    
    int nextNumber = 2;
    
    //keep incrementing number in folder name til one is available
    while ([filteredFormArray count] > 0) {
        formFolderName= [NSString stringWithFormat:@"%@ (%d)", tempFormName, nextNumber];
        nextNumber++;
        predicate = [NSPredicate predicateWithFormat:@"SELF ==[c] %@", formFolderName];
        filteredFormArray = [listOfFilesInNewUserFolder filteredArrayUsingPredicate:predicate];
    }
    
    //create folder with new name
    NSString *dataPath = [userFolder stringByAppendingPathComponent: formFolderName];
    [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];

    return formFolderName;
}

@end
