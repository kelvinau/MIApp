//
//  CheckCompletedMITable.m
//  MIApp
//
//  Created by Gursimran Singh on 1/12/2014.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "CheckCompletedMITable.h"
#import "QuestionList.h"
#import "SelectNewUserToAssignFormTableView.h"
#import "FormNameDetailCell.h"
#import "KeyList.h"

@implementation CheckCompletedMITable
{
    NSMutableArray* listOfCompletedForms;
    NSMutableArray* listOfincompleteForms;
    
    BOOL displayedAlertView;
}

@synthesize popOver;

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    listOfCompletedForms = [[NSMutableArray alloc] init];
    listOfincompleteForms = [[NSMutableArray alloc] init];
    
    
    displayedAlertView = NO;
    
    
    
    [self setTitle:@"Completed Forms"];
    
    [[self navigationItem] setHidesBackButton:YES];
    
    
    //add buttons
    
    //logout button
    UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logout"] style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
    
    //create new mi button
    UIBarButtonItem* displayMIList = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(displayMIList:)];
    
    //space between two buttons
    UIBarButtonItem *emptySPace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    emptySPace.width = 50;
    
    
    [[self navigationItem] setRightBarButtonItems:@[logout, emptySPace, displayMIList]];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[self tableView] reloadData];
}

//called when user clicks new MI button
-(void) displayMIList : (id) sender
{
    [self performSegueWithIdentifier:@"MIFormListView" sender:self];
}


//called when user presses logout button
-(void) logout : (id) sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


//number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //get completed formlist
    [self getCompletedFileList];
    
    //get incomplete forms for all users
    [self getIncompleteFormList];
    
    
    //check how many sections to add
    if (([listOfCompletedForms count] == 0) && [listOfincompleteForms count] == 0) {
        [self displayNoCompletedFormError];
        return 0;
    }else if (([listOfCompletedForms count] > 0) && [listOfincompleteForms count] > 0){
        return 2;
    }else{
        return 1;
    }
}


//number of rows in sections
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ((section == 0) && ([listOfCompletedForms count]> 0)) {
        return [listOfCompletedForms count];
    }else {
        return [listOfincompleteForms count];
    }
}


//title for each section
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ((section == 0) && ([listOfCompletedForms count] > 0)) {
        return @"Completed Forms";
    }else {
        return @"Incomplete Forms";
    }
}

//cell for each row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"formCell";
    
    FormNameDetailCell *cell = (FormNameDetailCell*)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[FormNameDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:simpleTableIdentifier];
    }
    
    NSDictionary* file;
    
    //if completed form then display arrow
    if ((indexPath.section == 0)  && ([listOfCompletedForms count]> 0) ) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        file = [listOfCompletedForms objectAtIndex:indexPath.row];
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        file = [listOfincompleteForms objectAtIndex:indexPath.row];
    }
    
    //set cell labels
    cell.titleLabel.text = [file objectForKey:@"fileName"];
    NSString* userDetails = [NSString stringWithFormat:@"User: %@",[file objectForKey:@"username"]];
    NSString* modDetails = [self getDate:file];
    cell.lastModifiedLabel.text = [modDetails stringByAppendingString:userDetails];
    
    NSString* version = [NSString stringWithFormat:@"Version: %@",[file objectForKey:[[KeyList sharedInstance] versionTemplateKey]]];
    NSString* instructionNumber = [NSString stringWithFormat:@"Instruction Number: %@",[file objectForKey:[[KeyList sharedInstance] insructionNumberTemplateKey]]];
    NSString* equipment = [NSString stringWithFormat:@"Applied to Equipment: %@",[file objectForKey:[[KeyList sharedInstance] equipmentTemplateKey]]];
    NSString* discipline = [NSString stringWithFormat:@"MI Discipline: %@",[file objectForKey:[[KeyList sharedInstance] disciplineTemplateKey]]];
    
    cell.versionLabel.text = version;
    cell.instructionNumberLabel.text = instructionNumber;
    cell.equipmentLabel.text = equipment;
    cell.disciplineLabel.text = discipline;
    
    return cell;
}


//called when user selects a form
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //can only select when completed form
    if ((indexPath.section == 0)  && ([listOfCompletedForms count]> 0) ){
        [self getContentsOfFile:[listOfCompletedForms objectAtIndex:indexPath.row]];
        
        //save parameters to be used later
        [[QuestionList sharedInstance] setCompletedFilePathToBeUploaded:[[listOfCompletedForms objectAtIndex:indexPath.row] objectForKey:@"path"]];
        [[QuestionList sharedInstance] setCompletedFileNameToBeUploaded:[[listOfCompletedForms objectAtIndex:indexPath.row] objectForKey:@"fileName"]];
        
        
        //open review page
        [self performSegueWithIdentifier:@"reviewAnswers" sender:self];
    }
}

//only delete editing is allowed for rows that support editing
-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

//called to check if row supports editing
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //only incomplete forms support editing
    if ((indexPath.section == 0) && ([listOfCompletedForms count] > 0)) {
        return NO;
    }
    return YES;
}


//display popover to select new user
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get view controller for user list from storyboard
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    //set parameters
    SelectNewUserToAssignFormTableView* selectNewUserViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"selectNewUser"];
    selectNewUserViewController.folderPath = [[listOfincompleteForms objectAtIndex:indexPath.row] objectForKey:@"path"];
    selectNewUserViewController.formName = [[listOfincompleteForms objectAtIndex:indexPath.row] objectForKey:@"fileName"];
    
    //set size of popover
    selectNewUserViewController.preferredContentSize = CGSizeMake(300, 350);
    
    //initialzze new popover
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:selectNewUserViewController];
    
    popover.delegate = self;
    
    //get rect of row that was selected
    CGRect temp = [self.tableView rectForRowAtIndexPath:indexPath];
    
    //create rect to display popover from
    CGRect temp2 = CGRectMake(915, temp.origin.y, 300, temp.size.height);
    
    //present poover
    [popover presentPopoverFromRect:temp2 inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionRight|UIPopoverArrowDirectionLeft animated:YES];
    
    //save popover reference
    self.popOver = popover;
    
    selectNewUserViewController.popOver = self.popOver;
    selectNewUserViewController.popOver.delegate = self;
    
}


//instead of displaying "delete" when row swiped "assign to" is displayed
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"Assign To";
}

//Return row height
-(CGFloat) tableView:(UITableView*) tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 86;
}

//get contents of file
//called when user selects to open a completed form
-(void) getContentsOfFile:(NSDictionary*) file
{
    
    //get file path
    NSString* filePath = [[file objectForKey:@"path"] stringByAppendingPathComponent:[file objectForKey:@"fileName"]];
    
    //convert file data to json
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* json = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSMutableDictionary* tempEntireMI = [[NSMutableDictionary alloc] init];
    NSMutableArray* tempQuestionList = [[NSMutableArray alloc] init];
    
    //convert to mutable dictionary
    NSString *key;
    for (key in json){
        [tempEntireMI setValue:[json objectForKey:key] forKey:key];
    }
    
    
    //get question list
    NSArray* allQuestions = [json objectForKey:[[KeyList sharedInstance] listOfQuestionsTemplateKey]];
    for (int i=0; i < [allQuestions count]; i++) {
        [tempQuestionList addObject:[allQuestions objectAtIndex:i]];
    }
    
    //save template details
    [[QuestionList sharedInstance] setEntireMITemplate:tempEntireMI];
    [[QuestionList sharedInstance] setQuestionList:tempQuestionList];
    
}


//get date of completed form and by user
-(NSString*) getDate: (NSDictionary*) fileInfo
{
    NSDate* result = [fileInfo objectForKey:@"modDate"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"'Completed:' MMM d, yyyy  h:mm a 'By '";
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:result];
    return timeStamp;
}


//called when no completed form exists
//error message displayed and taken to new MI creation page
-(void) displayNoCompletedFormError
{
    if (!displayedAlertView) {
        
        displayedAlertView = YES;
        
        UIAlertView *errorView;
        
        errorView = [[UIAlertView alloc]
                     initWithTitle: NSLocalizedString(@"No Form", @"No Form")
                     message: NSLocalizedString(@"There is no completed form for you to check.", @"Network error")
                     delegate: self
                     cancelButtonTitle: NSLocalizedString(@"OK", @"Network error") otherButtonTitles: nil];
        
        [errorView show];
    }
}


//compute list of completed mis
-(void) getCompletedFileList
{
    //get list of users who have completed forms
    NSArray* listOfUsersFolders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[[QuestionList sharedInstance] completedPath] error:nil];
    
    NSMutableArray* filesWithInfo = [[NSMutableArray alloc] init];
    
    
    //for every user repeat
    for (NSString* user in listOfUsersFolders) {
        if (![user isEqualToString:@".DS_Store"]){
            
            //get list of folders for user
            NSString* userCompletedPath = [[[QuestionList sharedInstance] completedPath] stringByAppendingPathComponent:user];
            NSArray* listOfFolders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:userCompletedPath error:nil];
            
            //for every folder repeat
            for (NSString* folder in listOfFolders) {
                if (![folder isEqualToString:@".DS_Store"]){
                    
                    //get file path
                    NSString* pathToFolder = [userCompletedPath stringByAppendingPathComponent:folder];
                    NSString* fileName = [self getContentsOfFolder:pathToFolder];
                    NSString *filePath = [pathToFolder stringByAppendingPathComponent:fileName];
                    
                    NSMutableDictionary* file = [[NSMutableDictionary alloc]init];
                    
                    //get file attributes
                    NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
                    NSDate *result = [fileAttribs fileModificationDate];
                    
                    //save file details
                    [file setValue:result forKey:@"modDate"];
                    [file setValue:fileName forKey:@"fileName"];
                    [file setValue:user forKey:@"username"];
                    [file setValue:pathToFolder forKey:@"path"];
                    
                    //to get other details, need to read the contents of file
                    NSData *data = [NSData dataWithContentsOfFile:filePath];
                    NSDictionary* json = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    NSString* version = [json objectForKey:[[KeyList sharedInstance] versionTemplateKey]];
                    NSString* discipline = [json objectForKey:[[KeyList sharedInstance] disciplineTemplateKey]];
                    NSString* equipment = [json objectForKey:[[KeyList sharedInstance] equipmentTemplateKey]];
                    NSString* instructionNumber = [json objectForKey:[[KeyList sharedInstance] insructionNumberTemplateKey]];
                    
                    [file setValue:fileName forKey:[[KeyList sharedInstance] titleTemplateKey]];
                    [file setValue:version forKey:[[KeyList sharedInstance] versionTemplateKey]];
                    [file setValue:discipline forKey:[[KeyList sharedInstance] disciplineTemplateKey]];
                    [file setValue:equipment forKey:[[KeyList sharedInstance] equipmentTemplateKey]];
                    [file setValue:instructionNumber forKey:[[KeyList sharedInstance] insructionNumberTemplateKey]];
                    
                    
                    //add this file to list of files
                    [filesWithInfo addObject:file];
                }
            }
        }
    }
    listOfCompletedForms = filesWithInfo;
}


//get list of all incomplete files for every user
-(void) getIncompleteFormList
{
    NSMutableArray* filesWithInfo = [[NSMutableArray alloc] init];
    
    //get list of users path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSArray* documentFolders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    //repeat for every user
    for (NSString* folder in documentFolders) {
        if (!([folder isEqualToString:@".DS_Store" ] || [folder isEqualToString:[[KeyList sharedInstance] completedMiFolderName] ] || [folder isEqualToString:[[KeyList sharedInstance] errorFolderName]])){
           
            //get list of folders in user
            NSString* userFolder = [documentsDirectory stringByAppendingPathComponent:folder];
            NSArray* formsForUser = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:userFolder error:nil];
            
            //repeat for every user
            for (NSString* form in formsForUser) {
                if (![form isEqualToString:@".DS_Store"]){
                    
                    //get file path
                    NSString* pathToFolder = [userFolder stringByAppendingPathComponent:form];
                    NSString* fileName = [self getContentsOfFolder:pathToFolder];
                    NSString *filePath = [pathToFolder stringByAppendingPathComponent:fileName];
                    
                    NSMutableDictionary* file = [[NSMutableDictionary alloc]init];
                    
                    //get file attributes
                    NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
                    NSDate *result = [fileAttribs fileModificationDate];
                    [file setValue:result forKey:@"modDate"];
                    [file setValue:fileName forKey:@"fileName"];
                    [file setValue:folder forKey:@"username"];
                    [file setValue:pathToFolder forKey:@"path"];
                    
                    
                    //to get other details, need to read the contents of file
                    NSData *data = [NSData dataWithContentsOfFile:filePath];
                    NSDictionary* json = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    NSString* version = [json objectForKey:[[KeyList sharedInstance] versionTemplateKey]];
                    NSString* discipline = [json objectForKey:[[KeyList sharedInstance] disciplineTemplateKey]];
                    NSString* equipment = [json objectForKey:[[KeyList sharedInstance] equipmentTemplateKey]];
                    NSString* instructionNumber = [json objectForKey:[[KeyList sharedInstance] insructionNumberTemplateKey]];
                    
                    [file setValue:version forKey:[[KeyList sharedInstance] versionTemplateKey]];
                    [file setValue:discipline forKey:[[KeyList sharedInstance] disciplineTemplateKey]];
                    [file setValue:equipment forKey:[[KeyList sharedInstance] equipmentTemplateKey]];
                    [file setValue:instructionNumber forKey:[[KeyList sharedInstance] insructionNumberTemplateKey]];
                    
                    
                    //add file to list
                    [filesWithInfo addObject:file];
                }
                
            }
        }
    }
    listOfincompleteForms = filesWithInfo;
    
}


//since every mi folder has media
//return the name of file that has form data
//in folder
-(NSString*) getContentsOfFolder:(NSString*)fileName
{
    NSString* fileToDisplay;
    NSArray* listOFfiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fileName error:nil];
    for (NSString* file in listOFfiles) {
        if ([file rangeOfString:@"."].location == NSNotFound) {
            fileToDisplay = file;
        }
    }
    return fileToDisplay;
}

//if no completed error message displayed
//display new mi page
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    displayedAlertView = NO;
    [self displayMIList:nil];
}


-(void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self.tableView reloadData];
}

@end
