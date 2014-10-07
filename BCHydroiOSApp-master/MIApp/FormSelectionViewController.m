//
//  FormSelectionViewController.m
//  MIApp
//
//  Created by Gursimran Singh on 2014-02-28.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "FormSelectionViewController.h"
#import "DownloadFormData.h"
#import "QuestionList.h"
#import "FormNameDetailCell.h"
#import "KeyList.h"
#import "FormNameDetailCellSelected.h"
#import "AddRemoveNotifications.h"

@implementation FormSelectionViewController
{
    NSMutableArray *_formIds;
    int formSelectedByUser;
    NSArray *incompleteFormsSearchedByUser;
    NSArray* fileListOfIncompleteForms;
    NSString *tableHeaderOne;
    NSString *tableHeaderTwo;
    NSMutableArray* colors;
    NSIndexPath* selectedRow;
    BOOL inSearch;
}

@synthesize formSearchBar, formList;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set page title
    [self setTitle:@"MI Template List"];
    
    self.navigationController.toolbarHidden = YES;
    
    //get table headers from info.plist
    tableHeaderOne = [[[NSBundle mainBundle].infoDictionary objectForKey:@"TableHeaders"] objectForKey:@"IncompleForms"];
    tableHeaderTwo = [[[NSBundle mainBundle].infoDictionary objectForKey:@"TableHeaders"] objectForKey:@"MIForms"];
    
    //Add logout button
    UIBarButtonItem *logout = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"logout"] style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: logout, Nil];
    
    //selected row is 100,100
    //assumes wont have 100 sections
    selectedRow = [NSIndexPath indexPathForRow:100 inSection:100];
    
    
    //set colors for cell
    [self setColors];
    
    
    //set up pull to refresh
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reloadFormList) forControlEvents:UIControlEventValueChanged];

    
    //set offset to hide search bar
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + 43;
    self.tableView.bounds = newBounds;
    
    //Initialize variables to store data
    _formIds = [[NSMutableArray alloc] init];
    incompleteFormsSearchedByUser = [[NSArray alloc] init];
    
    //set table property to enbale editing
    self.tableView.allowsSelectionDuringEditing = YES;
    
    
    //Display message if any form was deleted for this user
    [self displayDeletedMIError];
    
    //download form list
    [self getNewFormList];

}


//save two types of blue color
-(void)setColors
{
    colors = [[NSMutableArray alloc] init];
    UIColor* blueColor = [UIColor colorWithRed:(0.0/255.0) green:(173/255.0) blue:(238/255.0) alpha:.1];
    UIColor* blueColor2 = [UIColor colorWithRed:(87/255.0) green:(194/255.0) blue:(252/255.0) alpha:.1];
    
    
    [colors addObject:blueColor];
    
    [colors addObject:blueColor2];
    
}


//Display the list of all MIs deleted for this user that were not completed and deleted
-(void) displayDeletedMIError
{
    //get pathof error file for this user
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *errorPath = [documentsDirectory stringByAppendingPathComponent:[[KeyList sharedInstance] errorFolderName]];
    NSString *userErrorFile  = [errorPath stringByAppendingPathComponent:[[QuestionList sharedInstance] username]];
    
    //if error file exists
    if ([[NSFileManager defaultManager] fileExistsAtPath:userErrorFile isDirectory:NO]) {
        
        //get contents of file
        NSData *data = [NSData dataWithContentsOfFile:userErrorFile];
        NSMutableDictionary* errorMessages = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        //get deleted mis list
        NSMutableArray *miDeletedList = [errorMessages objectForKey:[[KeyList sharedInstance] deletedMisErrorFileKey]];
        NSString* errorMessage = @"";
        
        //create string with all files that were deleted
        if ([miDeletedList count] > 0) {
            errorMessage = [errorMessage stringByAppendingString:[NSString stringWithFormat:@"The following MIs were deleted because they were left incomplete for more than %d hours:\n\n", [[KeyList sharedInstance] deleteIncompleteFormsAfterDays].intValue * 24]];
            for (NSString* eachMI in miDeletedList) {
                errorMessage = [[errorMessage stringByAppendingString:eachMI] stringByAppendingString:@"\n"];
            }
        }
        
        //get re assigned mis list
        NSMutableArray* reassignedMis = [errorMessages objectForKey:[[KeyList sharedInstance] reassignedMisErrorFileKey]];
        
        //append this to error message
        //list of file that were re assigned
        if ([reassignedMis count] > 0) {
            if ([miDeletedList count] > 0) {
                errorMessage = [errorMessage stringByAppendingString:@"\n"];
            }
            errorMessage = [errorMessage stringByAppendingString:[NSString stringWithFormat:@"The following MIs were reassigned to someone else:\n\n"] ];
            for (NSString* eachMI in reassignedMis) {
                errorMessage = [[errorMessage stringByAppendingString:eachMI] stringByAppendingString:@"\n"];
            }
        }
        
        //delete error file
        [[NSFileManager defaultManager] removeItemAtPath:userErrorFile error:nil];
        
        //display error
        [self displayErrorWithTitle:@"MIs changed since last login" withMessage:errorMessage cancelButton:@"OK" otherButton:nil];
    }
}



//Method to display alerts
//with title and message and cancel button and other button names passed in
-(void) displayErrorWithTitle:(NSString*) errorTitle  withMessage: (NSString*) errorMessage cancelButton:(NSString*) cancelButton otherButton: (NSString*) otherButtons
{
    UIAlertView *errorView;
    errorView = [[UIAlertView alloc]
                 initWithTitle: errorTitle
                 message: @""
                 delegate: self
                 cancelButtonTitle:cancelButton otherButtonTitles:otherButtons, nil];
    
    //Display the body in a textview to better allign the text
    CGSize size = [errorMessage sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:12]}];
    CGRect frame = CGRectMake(0, 0, 260, size.height);
    UITextView* message = [[UITextView alloc] initWithFrame:frame];
    [message setEditable:NO];
    [message setSelectable:NO];
    [message setBackgroundColor:[UIColor clearColor]];
    message.text = errorMessage;
    [message setFont:[UIFont systemFontOfSize:14]];
    message.scrollEnabled = NO;
    [message sizeToFit];
    [errorView setValue:message forKey:@"accessoryView"];
    [errorView show];
    
}


//Set up view for every subsequent times it is displayed
- (void)viewWillAppear:(BOOL)animated {
    formList = [[FormList alloc] initFromTemporaryFile];
    selectedRow = [NSIndexPath indexPathForRow:100 inSection:100];

    if ([self.searchDisplayController isActive]) {
        [self.searchDisplayController setActive:NO];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:animated];
    [self deleteFolder];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

//Delete all other folders that are empty in the directory structure
-(void) deleteFolder{
    NSString *userPath = [[QuestionList sharedInstance] userPath];
    NSArray* listOfFolders = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:userPath error:nil];
    for (NSString* folder in listOfFolders){
        NSString *folderPath = [[userPath stringByAppendingPathComponent:folder] stringByAppendingString:@"/"];
        NSString *filePath = [folderPath stringByAppendingString:folder];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            [[NSFileManager defaultManager] removeItemAtPath:folderPath error:Nil];
        }
    }
}


//Logout from the current user
-(void) logout : (id) sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


//Reload form list, called by pull to refresh of the table
- (void)reloadFormList
{
    //Download happens in stop which is called after 1 second
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:1];
}


//Stop loading wheel in pull to refresh
- (void)stopRefresh
{
    
    //Actual download occurs here
    [self performSelectorOnMainThread:@selector(getNewFormList)
                           withObject:NULL waitUntilDone:YES];
    [self.refreshControl endRefreshing];
    
    //view is moved up to hide search bar
    [self performSelector:@selector(hideSearch) withObject:nil afterDelay:.3];
}


//Move view content to hide search bar
-(void) hideSearch{
    CGPoint contentOffset=self.tableView.contentOffset;
    contentOffset.y=self.tableView.bounds.origin.y + 43;
    [self.tableView setContentOffset:contentOffset animated:YES];
}

//Method to download the form list
-(void) getNewFormList
{
    FormList* list = [DownloadFormData downloadFormList];
    
    if (list == NULL) {
        return;
    }
    
    [self setFormList:list];
    
    [[self tableView] reloadData];
}




//TABLE VIEW DELEGATE METHODS
//The table view has a search bar attached to it
//Same delegate methods are called when the search results are populated or
//actual table contents are displayed.
//Every delegate method checks which table view called the method (search or regular)
//Depending on who called it the results are returned


//return the number of sections
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger section = 0;
    
    
    //If no incomplete forms are in search results then return 1 else 2
    //return sections if table is search results
    if (tableView == self.searchDisplayController.searchResultsTableView){
        if ([incompleteFormsSearchedByUser count] == 0) {
            section = 1;
        }
        else{
            section = 2;
        }
    }
    //return section for table view
    else{
        if ([self incompletedForms] == 0){
            section = 1;
        }else{
            section = 2;
        }
    }
    
    //If there is no incomplete forms then set disable the edit button in the navigation controller
    if (section == 1) {
        [self.editButton setStyle:UIBarButtonItemStylePlain];
        [self.editButton setTitle:@"Edit"];
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
    else
    {
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
    
    return section;
    
}




//Return the number of rows in each section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //If search results
    //Check how many sections table has
    //if just one section then return search matched count
    //else return incomplete count first and then new forms
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if ([incompleteFormsSearchedByUser count] == 0){
            return [_formIds count];
        }
        else{
            if (section == 0){
                return [incompleteFormsSearchedByUser count];
                //return 0;
            }
            else if (section == 1){
                return [_formIds count];
            }
        }
    }
    //for actual table results
    else {
        if ([fileListOfIncompleteForms count] > 0) {
            if (section == 0){
                return [self incompletedForms];
                //return 0;
            }
            else if (section == 1){
                return [formList getFormCount];
            }
        }
        else{
            return [formList getFormCount];
        }
    }
    return 0;
}



//Return the cell at each index
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *formCell = @"formCell";
    NSString *formCellSelected = @"formCellSelected";
    BOOL detailView = NO;
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:formCell];
    
    //if cell is selected then the cell is different\
    //has more details than other cells
    if ((indexPath.row == selectedRow.row) && (indexPath.section == selectedRow.section)) {
        detailView = YES;
        cell = [self.tableView dequeueReusableCellWithIdentifier:formCellSelected];
    }
    
    
    if (cell == nil) {
        if (detailView) {
            cell = [[FormNameDetailCellSelected alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:formCellSelected];
        }else{
            cell = [[FormNameDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:formCell];
        }
    }
    
    //If search results
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        //check is no incomplete forms is part of the search
        if ([incompleteFormsSearchedByUser count] == 0) {
            //get new form cell
            cell = [self fillCell:cell withNewTemplate:[formList getFormDetailsById:[_formIds objectAtIndex:indexPath.row]] detailView:detailView];
        }
        else{
            if (indexPath.section == 0){
                //get incomplete form cell that matched search text
                cell = [self fillCell:cell withIncompleteTemplate:[incompleteFormsSearchedByUser objectAtIndex:indexPath.row] detailView:detailView];
            }
            else if (indexPath.section == 1){
                //get new form cell
                cell = [self fillCell:cell withNewTemplate:[formList getFormDetailsById:[_formIds objectAtIndex:indexPath.row]] detailView:detailView];
            }
        }
    }
    else{
        if ([fileListOfIncompleteForms count] > 0){
            if (indexPath.section == 0) {
                cell = [self fillCell:cell withIncompleteTemplate:[fileListOfIncompleteForms objectAtIndex:indexPath.row] detailView:detailView];
            }
            else{
                //get new form cell
                cell = [self fillCell:cell withNewTemplate:[formList getFormDetailsAtPosition:indexPath.row] detailView:detailView];
            }
        }
        else
        {
            //get new form cell
            cell = [self fillCell:cell withNewTemplate:[formList getFormDetailsAtPosition:indexPath.row] detailView:detailView];
        }
    }
    
    
    //if cell is not selected cell then set color of cell
    if (!detailView) {
        cell.editingAccessoryView =[[UIView alloc] init];
        cell.editingAccessoryView.backgroundColor = [UIColor clearColor];
    
        cell.contentView.backgroundColor = [colors objectAtIndex:(indexPath.row % ([colors count]))];
    }
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


//set background color of cell
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = cell.contentView.backgroundColor;
}

//show details of form that the user clicks on
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //if in search then set bool
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        inSearch = YES;
    }else{
        inSearch = NO;
    }
    
    //set new selected row
    //if user taps on already selected cell then collapse it
    //and set selected row to 100,100
    NSIndexPath* oldSelectedRow;
    if (selectedRow.row == indexPath.row && selectedRow.section == indexPath.section) {
        oldSelectedRow = [NSIndexPath indexPathForRow:100 inSection:100];
        selectedRow = oldSelectedRow;
    }else{
        oldSelectedRow = selectedRow;
        selectedRow = indexPath;

    }
    
    //start updating the table
    [tableView beginUpdates];
    
    //reload cells
    if (oldSelectedRow.row == 100 && oldSelectedRow.section == 100) {
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else{
        [tableView reloadRowsAtIndexPaths:@[indexPath, oldSelectedRow] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [tableView endUpdates];
    
    
    return;
    
}


//method called whenever user presses open on the detailed view of form
-(void) openFormButtonPressed:(id)sender
{
    //set bool if foreman starts to edit a MI
    if ([[QuestionList sharedInstance] engineerView]) {
        [[QuestionList sharedInstance] setEngineerNewMI:YES];
    }
    
    //If search results
    if(inSearch) {
        //if no incomplete forms
        if ([incompleteFormsSearchedByUser count] == 0) {
            //Download new form and open it
            formSelectedByUser = [formList getPositionOfFormById:[_formIds objectAtIndex:selectedRow.row]];
            [self openNewForm:[formList getNameAtPosition:formSelectedByUser]];
        }
        else{
            if (selectedRow.section == 0) {
                //Load file from memory and display to user
                [self openIncompleteForm:[[incompleteFormsSearchedByUser objectAtIndex:selectedRow.row] objectForKey:[[KeyList sharedInstance] titleTemplateKey]]];
            }
            else{
                //Download new form
                formSelectedByUser = [formList getPositionOfFormById:[_formIds objectAtIndex:selectedRow.row]];
                [self openNewForm:[formList getNameAtPosition:formSelectedByUser]];
            }
        }
    }else{
        formSelectedByUser = (int)selectedRow.row;
        //if there is incomplete form section
        if ([fileListOfIncompleteForms count] > 0) {
            if (selectedRow.section == 0) {
                //open file from memory to load form
                [self openIncompleteForm:[[fileListOfIncompleteForms objectAtIndex:selectedRow.row] objectForKey:[[KeyList sharedInstance] titleTemplateKey]]];
            }
            else{
                //download new form
                [self openNewForm:[formList getNameAtPosition:(int)selectedRow.row]];
            }
            
        }else {
            //download new form
            [self openNewForm:[formList getNameAtPosition:(int)selectedRow.row]];
        }
    }

}

//Return header size
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return 43.0;
    }
    
    if (section == 0) {
        return 43.0;
    }
    return 33.0;
}

//Return row height
-(CGFloat) tableView:(UITableView*) tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedRow.row == indexPath.row && selectedRow.section == indexPath.section) {
        return 329;
    }
    return 86;
}

//Return header title
-(NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView){
        if ([incompleteFormsSearchedByUser count] == 0){
            return tableHeaderTwo;
        }
        else{
            if (section == 0) {
                return  tableHeaderOne;
            }
            else if (section == 1){
                return tableHeaderTwo;
            }
        }
    }
    else{
        if ([fileListOfIncompleteForms count] == 0){
            return tableHeaderTwo;
        }
        else{
            if (section == 0) {
                return tableHeaderOne;
            }
            else if (section == 1){
                return  tableHeaderTwo;
            }
            
        }
    }
    return NULL;
}

//If row can be edited then set property
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    //Incomplete forms is always section 0 and this lets any cell in section 0 to have slide to delete functionality
    if ([fileListOfIncompleteForms count] > 0){
        if (indexPath.section == 0){
            return YES;
        }
    }
    return NO;
}


//If cell can be deleted then delete that incomplete MI from list
- (void)tableView: (UITableView *)tableView commitEditingStyle: (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath: (NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString* userPath = [[QuestionList sharedInstance] userPath];
        NSString *filePath;
        NSString* fileName;
        
        //Get path of file depending on if in search
        if(tableView == self.searchDisplayController.searchResultsTableView){
            fileName = [[incompleteFormsSearchedByUser objectAtIndex:indexPath.row] objectForKey:[[KeyList sharedInstance] titleTemplateKey]];
            filePath = [userPath stringByAppendingPathComponent:fileName];
        }
        else {
            fileName = [[fileListOfIncompleteForms objectAtIndex:indexPath.row] objectForKey:[[KeyList sharedInstance] titleTemplateKey]];
            filePath = [userPath stringByAppendingPathComponent:fileName];
        }
        
        //Remove file
        [AddRemoveNotifications removeNotificationsForForm:fileName byUser:[[QuestionList sharedInstance] username]];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:Nil];
        
        //Update incomplete form list
        [self incompletedForms];
        
        
        //Delete form from search result array
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            NSMutableArray *tempIncompleteList = [[NSMutableArray alloc] initWithArray:incompleteFormsSearchedByUser];
            [tempIncompleteList removeObjectAtIndex:indexPath.row];
            incompleteFormsSearchedByUser = tempIncompleteList;
        }
        
        //If this is the last incomplete then delete section in table
        if ([fileListOfIncompleteForms count] == 0 ) {
            NSMutableIndexSet *indexes = [NSMutableIndexSet indexSet];
            [indexes addIndex:indexPath.section];
            if (tableView == self.searchDisplayController.searchResultsTableView){
                [self.searchDisplayController.searchResultsTableView deleteSections:indexes withRowAnimation:UITableViewRowAnimationFade];
            }
            else{
                [self.tableView deleteSections:indexes withRowAnimation:UITableViewRowAnimationFade];
            }
            
            [self.tableView setEditing:NO];
            
        }
        //Else only delete selected row
        else{
            if (tableView == self.searchDisplayController.searchResultsTableView){
                [self.searchDisplayController.searchResultsTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }else{
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            }
        }
        
        selectedRow = [NSIndexPath indexPathForRow:100 inSection:100];
        
        //reload table to show cahnges
        [self.tableView reloadData];
    }
}
////// END TABLE VIEW DELEGATES


-(void)loadFirstQuestion:(NSString*) firstQuestionType
{
    if ([firstQuestionType isEqualToString:[[KeyList sharedInstance] shortAnswerQuestionTypeTemplateKey]]){
        
        [self performSegueWithIdentifier:@"ShortAnswer" sender:self];
        
    }else if ([firstQuestionType isEqualToString:[[KeyList sharedInstance] trueFalseQuestionTypeTemplateKey]]){
        
        [self performSegueWithIdentifier:@"TrueFalse" sender:self];
        
    }else if ([firstQuestionType isEqualToString:[[KeyList sharedInstance] multipleChoiceQuestionTypeTemplateKey]]){
        
        [self performSegueWithIdentifier:@"MultipleChoice" sender:self];
        
    }else if ([firstQuestionType isEqualToString:[[KeyList sharedInstance] tableQuestionTypeTemplateKey]]){
        
        [self performSegueWithIdentifier:@"twoDimensionalTableTest" sender:self];
    
    }
}


//Get all incomplete forms for current user
-(int)incompletedForms
{
    //Get list of folders for this user
    NSString* userPath = [[QuestionList sharedInstance] userPath];
    NSArray* listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:userPath error:nil];
    NSMutableArray* filesWithInfo = [[NSMutableArray alloc]init];
    
    //Iterate over all
    for (NSString* fileName in listOfFiles){
        //check if the file name is not ".DS_Store"
        if (![fileName isEqualToString:@".DS_Store"]){
            [filesWithInfo addObject:[self getFormDetailsOfForm:fileName]];
        }
    }
    
    //Sort list with decending mod date
    fileListOfIncompleteForms = filesWithInfo;
    NSSortDescriptor* testing = [NSSortDescriptor sortDescriptorWithKey:@"modDate" ascending:NO] ; // 1
    fileListOfIncompleteForms = [fileListOfIncompleteForms sortedArrayUsingDescriptors:
                                 [NSArray arrayWithObject:testing]];
    return (int)[fileListOfIncompleteForms count] ;
}


//Get incomplete form details to display in table by reading the contents of file
-(NSDictionary*) getFormDetailsOfForm: (NSString*) fileName
{
    //Get file attributes like name and mod date and add them to a dictionary
    NSString* userPath = [[QuestionList sharedInstance] userPath];
    NSMutableDictionary* file = [[NSMutableDictionary alloc]init];
    NSString *filePath = [[userPath stringByAppendingPathComponent:fileName] stringByAppendingPathComponent:fileName];
    NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    NSDate *result = [fileAttribs fileModificationDate];
    [file setValue:result forKey:@"modDate"];
    
    //to get other details, need to read the contents of file
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSDictionary* json = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString* version = [json objectForKey:[[KeyList sharedInstance] versionTemplateKey]];
    NSString* discipline = [json objectForKey:[[KeyList sharedInstance] disciplineTemplateKey]];
    NSString* equipment = [json objectForKey:[[KeyList sharedInstance] equipmentTemplateKey]];
    NSString* instructionNumber = [json objectForKey:[[KeyList sharedInstance] insructionNumberTemplateKey]];
    NSString* references = [json objectForKey:[[KeyList sharedInstance] referencesTemplateKey]];
    NSString* preparedBy = [json objectForKey:[[KeyList sharedInstance] preparedByTemplateKey]];
    NSString* preparedByTitle = [json objectForKey:[[KeyList sharedInstance] preparedByTitleTemplateKey]];
    NSString* acceptedBy = [json objectForKey:[[KeyList sharedInstance] acceptedByTemplateKey]];
    NSString* acceptedByTitle = [json objectForKey:[[KeyList sharedInstance] acceptedByTitleTemplateKey]];
    NSString* revisedBy = [json objectForKey:[[KeyList sharedInstance] revisedByTemplateKey]];
    NSString* revisionDate = [json objectForKey:[[KeyList sharedInstance] revisionDateTemplateKey]];
    NSString* eor = [json objectForKey:[[KeyList sharedInstance] eorTemplateKey]];
    NSString* fileNumber = [json objectForKey:[[KeyList sharedInstance] fileNumberTemplateKey]];
    NSString* originalIssueDate = [json objectForKey:[[KeyList sharedInstance] originalIssueDateTemplateKey]];
    NSString* supersedes = [json objectForKey:[[KeyList sharedInstance] supersedesTemplateKey]];
    NSString* revisionHistory = [json objectForKey:[[KeyList sharedInstance] revisionHistoryTemplateKey]];

    
    [file setValue:fileName forKey:[[KeyList sharedInstance] titleTemplateKey]];
    [file setValue:version forKey:[[KeyList sharedInstance] versionTemplateKey]];
    [file setValue:discipline forKey:[[KeyList sharedInstance] disciplineTemplateKey]];
    [file setValue:equipment forKey:[[KeyList sharedInstance] equipmentTemplateKey]];
    [file setValue:instructionNumber forKey:[[KeyList sharedInstance] insructionNumberTemplateKey]];
    [file setValue:references forKey:[[KeyList sharedInstance] referencesTemplateKey]];
    [file setValue:preparedBy forKey:[[KeyList sharedInstance] preparedByTemplateKey]];
    [file setValue:preparedByTitle forKey:[[KeyList sharedInstance] preparedByTemplateListKey]];
    [file setValue:acceptedBy forKey:[[KeyList sharedInstance] acceptedByTemplateKey]];
    [file setValue:acceptedByTitle forKey:[[KeyList sharedInstance] acceptedByTitleTemplateKey]];
    [file setValue:revisedBy forKey:[[KeyList sharedInstance] revisedByTemplateKey]];
    [file setValue:revisionDate forKey:[[KeyList sharedInstance] revisionDateTemplateKey]];
    [file setValue:eor forKey:[[KeyList sharedInstance] eorTemplateKey]];
    [file setValue:fileNumber forKey:[[KeyList sharedInstance] fileNumberTemplateKey]];
    [file setValue:originalIssueDate forKey:[[KeyList sharedInstance] originalIssueDateTemplateKey]];
    [file setValue:supersedes forKey:[[KeyList sharedInstance] supersedesTemplateKey]];
    [file setObject:revisionHistory forKey:[[KeyList sharedInstance] revisionHistoryTemplateKey]];
    
    return file;
}


//Toggle between table editing if edit button is pressed
- (IBAction)deleteIncompleteMIs:(id)sender {
    if ([fileListOfIncompleteForms count] > 0) {
        if (self.tableView.editing == YES){
            [self.editButton setStyle:UIBarButtonItemStylePlain];
            [self.editButton setTitle:@"Edit"];
            [self.tableView setEditing:NO animated:YES];
        }else{
            [self.editButton setStyle:UIBarButtonItemStyleDone];
            [self.editButton setTitle:@"Done"];
            [self.tableView setEditing:YES animated:YES];
        }
    }
}


//create new incomplete cell
-(UITableViewCell*) fillCell:(UITableViewCell*)cell withIncompleteTemplate:(NSDictionary*)template detailView:(BOOL)detailView
{
    
    //get strings
    NSString* title = [NSString stringWithFormat:@"Title: %@",[template objectForKey:[[KeyList sharedInstance] titleTemplateKey]]];
    NSString* lastModified = [self getDateOfFile:[template objectForKey:@"modDate"]];
    NSString* version = [NSString stringWithFormat:@"Version: %@",[template objectForKey:[[KeyList sharedInstance] versionTemplateKey]]];
    NSString* instructionNumber = [NSString stringWithFormat:@"Instruction Number: %@",[template objectForKey:[[KeyList sharedInstance] insructionNumberTemplateKey]]];
    NSString* equipment = [NSString stringWithFormat:@"Applied to Equipment: %@",[template objectForKey:[[KeyList sharedInstance] equipmentTemplateKey]]];
    NSString* discipline = [NSString stringWithFormat:@"MI Discipline: %@",[template objectForKey:[[KeyList sharedInstance] disciplineTemplateKey]]];
    
    //if not detail view cell
    //user has not selected the cell
    if (!detailView) {
        
        //set labels
        ((FormNameDetailCell*)cell).titleLabel.text = title;
        ((FormNameDetailCell*)cell).lastModifiedLabel.text = lastModified;
        ((FormNameDetailCell*)cell).versionLabel.text = version;
        ((FormNameDetailCell*)cell).instructionNumberLabel.text = instructionNumber;
        ((FormNameDetailCell*)cell).equipmentLabel.text = equipment;
        ((FormNameDetailCell*)cell).disciplineLabel.text = discipline;
    }
    
    //set labels for detail view cell
    else{
        NSString* references = [NSString stringWithFormat:@"Reference: %@",[template objectForKey:[[KeyList sharedInstance] referencesTemplateKey]]];
        NSString* preparedBy = [NSString stringWithFormat:@"Prepared By:\n%@",[template objectForKey:[[KeyList sharedInstance] preparedByTemplateKey]]];
        NSString* preparedByTitle = [NSString stringWithFormat:@"Title:\n%@",[template objectForKey:[[KeyList sharedInstance] preparedByTitleTemplateKey]]];
        NSString* acceptedBy = [NSString stringWithFormat:@"Accepted By:\n%@",[template objectForKey:[[KeyList sharedInstance] acceptedByTemplateKey]]];
        NSString* acceptedByTitle = [NSString stringWithFormat:@"Title:\n%@",[template objectForKey:[[KeyList sharedInstance] acceptedByTitleTemplateKey]]];
        NSString* revisedBy = [NSString stringWithFormat:@"Revised By: %@",[template objectForKey:[[KeyList sharedInstance] revisedByTemplateKey]]];
        NSString* revisionDate = [NSString stringWithFormat:@"Revision Date: %@",[template objectForKey:[[KeyList sharedInstance] revisionDateTemplateKey]]];
        NSString* eor = [NSString stringWithFormat:@"EOR:\n%@",[template objectForKey:[[KeyList sharedInstance] eorTemplateKey]]];
        NSString* fileNumber = [NSString stringWithFormat:@"File #: %@",[template objectForKey:[[KeyList sharedInstance] fileNumberTemplateKey]]];
        NSString* originalIssueDate = [NSString stringWithFormat:@"Original Issue Date: %@",[template objectForKey:[[KeyList sharedInstance] originalIssueDateTemplateKey]]];
        NSString* supersedes = [NSString stringWithFormat:@"Supersedes: %@",[template objectForKey:[[KeyList sharedInstance] supersedesTemplateKey]]];
        NSString* revisionHistory = [template objectForKey:[[KeyList sharedInstance] revisionHistoryTemplateKey]];

        ((FormNameDetailCellSelected*)cell).titleLabel.text = title;
        ((FormNameDetailCellSelected*)cell).lastModifiedLabel.text = lastModified;
        ((FormNameDetailCellSelected*)cell).versionLabel.text = version;
        ((FormNameDetailCellSelected*)cell).instructionNumberLabel.text = instructionNumber;
        ((FormNameDetailCellSelected*)cell).equipmentLabel.text = equipment;
        ((FormNameDetailCellSelected*)cell).disciplineLabel.text = discipline;
        
        ((FormNameDetailCellSelected*)cell).referencesLabel.text = references;
        ((FormNameDetailCellSelected*)cell).preparedByLabel.text = preparedBy;
        ((FormNameDetailCellSelected*)cell).titlePreparedLabel.text = preparedByTitle;
        ((FormNameDetailCellSelected*)cell).acceptedByLabel.text = acceptedBy;
        ((FormNameDetailCellSelected*)cell).titleAcceptedLabel.text = acceptedByTitle;
        ((FormNameDetailCellSelected*)cell).eorLabel.text = eor;
        
        ((FormNameDetailCellSelected*)cell).revisedByLabel.text = revisedBy;
        ((FormNameDetailCellSelected*)cell).revisionDateLabel.text = revisionDate;
        ((FormNameDetailCellSelected*)cell).supersedesLabel.text = supersedes;
        ((FormNameDetailCellSelected*)cell).issueDateLabel.text = originalIssueDate;
        ((FormNameDetailCellSelected*)cell).fileNumberLabel.text = fileNumber;
        ((FormNameDetailCellSelected*)cell).revisionTextView.text = revisionHistory;
        ((FormNameDetailCellSelected*)cell).revisionTextView.textColor = [UIColor colorWithRed:142/255 green:142/255 blue:142/255 alpha:1];
        [((FormNameDetailCellSelected*)cell).openFormButton addTarget:self action:@selector(openFormButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
    
}


//create cell fro new form
-(UITableViewCell*) fillCell:(UITableViewCell*)cell withNewTemplate:(NSDictionary*)template detailView:(BOOL)detailView
{
    //get strings
    NSString* title = [NSString stringWithFormat:@"Title: %@",[template objectForKey:[[KeyList sharedInstance] titleTemplateListKey]]];
    NSString* version = [NSString stringWithFormat:@"Version: %@",[template objectForKey:@"version"]];
    NSString* instructionNumber = [NSString stringWithFormat:@"Instruction Number: %@",[template objectForKey:[[KeyList sharedInstance] insructionNumberTemplateListKey]]];
    NSString* equipment = [NSString stringWithFormat:@"Applied to Equipment: %@",[template objectForKey:[[KeyList sharedInstance] equipmentTemplateListKey]]];
    NSString* discipline = [NSString stringWithFormat:@"MI Discipline: %@",[template objectForKey:[[KeyList sharedInstance] disciplineTemplateListKey]]];
    
    //if not detail view cell
    //user has not selected the cell
    if (!detailView) {
        ((FormNameDetailCell*)cell).titleLabel.text = title;
        ((FormNameDetailCell*)cell).lastModifiedLabel.text = @"";
        ((FormNameDetailCell*)cell).versionLabel.text = version;
        ((FormNameDetailCell*)cell).instructionNumberLabel.text = instructionNumber;
        ((FormNameDetailCell*)cell).equipmentLabel.text = equipment;
        ((FormNameDetailCell*)cell).disciplineLabel.text = discipline;
    }
    
    //set labels for detail view cell
    else{
       
        NSString* references = [NSString stringWithFormat:@"Reference: %@",[template objectForKey:[[KeyList sharedInstance] referencesTemplateListKey]]];
        NSString* preparedBy = [NSString stringWithFormat:@"Prepared By:\n%@",[template objectForKey:[[KeyList sharedInstance] preparedByTemplateListKey]]];
        NSString* preparedByTitle = [NSString stringWithFormat:@"Title:\n%@",[template objectForKey:[[KeyList sharedInstance] preparedByTitleTemplateListKey]]];
        NSString* acceptedBy = [NSString stringWithFormat:@"Accepted By:\n%@",[template objectForKey:[[KeyList sharedInstance] acceptedByTemplateListKey]]];
        NSString* acceptedByTitle = [NSString stringWithFormat:@"Title:\n%@",[template objectForKey:[[KeyList sharedInstance] acceptedByTitleTemplateListKey]]];
        NSString* revisedBy = [NSString stringWithFormat:@"Revised By: %@",[template objectForKey:[[KeyList sharedInstance] revisedByTemplateListKey]]];
        NSString* revisionDate = [NSString stringWithFormat:@"Revision Date: %@",[template objectForKey:[[KeyList sharedInstance] revisionDateTemplateListKey]]];
        NSString* eor = [NSString stringWithFormat:@"EOR:\n%@",[template objectForKey:[[KeyList sharedInstance] eorTemplateListKey]]];
        NSString* fileNumber = [NSString stringWithFormat:@"File #: %@",[template objectForKey:[[KeyList sharedInstance] fileNumberTemplateListKey]]];
        NSString* originalIssueDate = [NSString stringWithFormat:@"Original Issue Date: %@",[template objectForKey:[[KeyList sharedInstance] originalIssueDateTemplateListKey]]];
        NSString* supersedes = [NSString stringWithFormat:@"Supersedes: %@",[template objectForKey:[[KeyList sharedInstance] supersedesTemplateListKey]]];
        NSString* revisionHistory = [template objectForKey:[[KeyList sharedInstance] revisionHistoryTemplateListKey]];
        
        ((FormNameDetailCellSelected*)cell).titleLabel.text = title;
        ((FormNameDetailCellSelected*)cell).lastModifiedLabel.text = @"";
        ((FormNameDetailCellSelected*)cell).versionLabel.text = version;
        ((FormNameDetailCellSelected*)cell).instructionNumberLabel.text = instructionNumber;
        ((FormNameDetailCellSelected*)cell).equipmentLabel.text = equipment;
        ((FormNameDetailCellSelected*)cell).disciplineLabel.text = discipline;
        
        ((FormNameDetailCellSelected*)cell).referencesLabel.text = references;
        ((FormNameDetailCellSelected*)cell).preparedByLabel.text = preparedBy;
        ((FormNameDetailCellSelected*)cell).titlePreparedLabel.text = preparedByTitle;
        ((FormNameDetailCellSelected*)cell).acceptedByLabel.text = acceptedBy;
        ((FormNameDetailCellSelected*)cell).titleAcceptedLabel.text = acceptedByTitle;
        ((FormNameDetailCellSelected*)cell).eorLabel.text = eor;
        
        ((FormNameDetailCellSelected*)cell).revisedByLabel.text = revisedBy;
        ((FormNameDetailCellSelected*)cell).revisionDateLabel.text = revisionDate;
        ((FormNameDetailCellSelected*)cell).supersedesLabel.text = supersedes;
        ((FormNameDetailCellSelected*)cell).issueDateLabel.text = originalIssueDate;
        ((FormNameDetailCellSelected*)cell).fileNumberLabel.text = fileNumber;
        ((FormNameDetailCellSelected*)cell).revisionTextView.text = revisionHistory;
        ((FormNameDetailCellSelected*)cell).revisionTextView.textColor = [UIColor colorWithRed:142/255 green:142/255 blue:142/255 alpha:1];

        [((FormNameDetailCellSelected*)cell).openFormButton addTarget:self action:@selector(openFormButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
    
}



//Get user readable date format
-(NSString*) getDateOfFile:(NSDate*)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"'Last Modified:' EEE, MMM d, yyyy 'at' h:mm a";
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:date];
    return timeStamp;
}


//Get user readable date format
-(NSString*) getDateOfFile:(int)index search:(BOOL)seacrh
{
    NSDate* result;
    if (seacrh){
        result = [[incompleteFormsSearchedByUser objectAtIndex:index] objectForKey:@"modDate"];
    }
    else{
        result = [[fileListOfIncompleteForms objectAtIndex:index] objectForKey:@"modDate"]; //or fileModificationDate
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"'Last Modified:' EEE, MMM d, yyyy 'at' h:mm a";
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:result];
    return timeStamp;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


-(void)filterContentForSearchText:(NSString*)searchString scope:(NSString*)scope {
    //set selected to 100
    selectedRow = [NSIndexPath indexPathForRow:100 inSection:100];
    
    // Update the filtered array based on the search text and scope.
    
    // Remove all objects from the filtered search array
    NSArray *filteredFormArray = [[NSArray alloc]init];
    [_formIds removeAllObjects];
    
    NSPredicate *predicate;
    NSPredicate *predicateIncompleteFormList;
    
    // Filter the array using NSPredicate
    //filter new form list
    if ([scope isEqualToString:@"All"]) {
        predicate = [NSPredicate predicateWithFormat:@"SELF.%@ contains[c] %@ OR SELF.%@ contains[c] %@ OR SELF.%@ contains[c] %@ OR SELF.%@ contains[c] %@",[[KeyList sharedInstance] titleTemplateListKey], searchString, @"version", searchString,[[KeyList sharedInstance] disciplineTemplateListKey], searchString,[[KeyList sharedInstance] equipmentTemplateListKey], searchString];
        predicateIncompleteFormList = [NSPredicate predicateWithFormat:@"SELF.%@ contains[c] %@ OR SELF.%@ contains[c] %@ OR SELF.%@ contains[c] %@ OR SELF.%@ contains[c] %@",[[KeyList sharedInstance] titleTemplateKey], searchString, [[KeyList sharedInstance] versionTemplateKey], searchString, [[KeyList sharedInstance] disciplineTemplateKey], searchString, [[KeyList sharedInstance] equipmentTemplateKey], searchString];
    }else{
        if ([scope isEqualToString:@"Title"]) {
            predicate = [NSPredicate predicateWithFormat:@"SELF.%@ contains[c] %@", [[KeyList sharedInstance] titleTemplateListKey], searchString];
            predicateIncompleteFormList = [NSPredicate predicateWithFormat:@"SELF.%@ contains[c] %@", [[KeyList sharedInstance] titleTemplateKey], searchString];

        }else if ([scope isEqualToString:@"Discipline"]) {
            predicate = [NSPredicate predicateWithFormat:@"SELF.%@ contains[c] %@", [[KeyList sharedInstance] disciplineTemplateListKey], searchString];
            predicateIncompleteFormList = [NSPredicate predicateWithFormat:@"SELF.%@ contains[c] %@", [[KeyList sharedInstance] disciplineTemplateKey], searchString];

        }else if ([scope isEqualToString:@"Equipment"]) {
            predicate = [NSPredicate predicateWithFormat:@"SELF.%@ contains[c] %@", [[KeyList sharedInstance] equipmentTemplateListKey], searchString];
            predicateIncompleteFormList = [NSPredicate predicateWithFormat:@"SELF.%@ contains[c] %@", [[KeyList sharedInstance] equipmentTemplateKey], searchString];

        }else if ([scope isEqualToString:@"Instruction Number"]) {
            predicate = [NSPredicate predicateWithFormat:@"SELF.%@ contains[c] %@", [[KeyList sharedInstance] insructionNumberTemplateKey], searchString];
            predicateIncompleteFormList = [NSPredicate predicateWithFormat:@"SELF.%@ contains[c] %@", [[KeyList sharedInstance] insructionNumberTemplateListKey], searchString];

        }else if ([scope isEqualToString:@"Version"]) {
            predicate = [NSPredicate predicateWithFormat:@"SELF.%@ contains[c] %@", @"version", searchString];
            predicateIncompleteFormList = [NSPredicate predicateWithFormat:@"SELF.%@ contains[c] %@", [[KeyList sharedInstance] versionTemplateKey], searchString];

        }
    }

    filteredFormArray = [[formList getFormList] filteredArrayUsingPredicate:predicate];
    
    //filter incomplete form list
    
    incompleteFormsSearchedByUser = [fileListOfIncompleteForms filteredArrayUsingPredicate:predicateIncompleteFormList];
    
    
    for (NSDictionary* form in filteredFormArray){
        [_formIds addObject:[form objectForKey:[[KeyList sharedInstance] idTemplateListKey]]];
    }
    
}


-(void) openIncompleteForm: (NSString*) fileName
{

    NSString* firstQuestionType = [DownloadFormData openIncompleteForm:fileName];
    if (firstQuestionType == NULL){
        [self displayErrorWithTitle:@"Error" withMessage:@"Could not open saved form. Please try again. It may be a result of corrupt data." cancelButton:@"OK" otherButton:nil];
    }else{
        NSLog(@"%@", firstQuestionType);
        [self loadFirstQuestion:firstQuestionType];
    }
}



-(void) openNewForm : (NSString*) fileName
{
    
    NSString* firstQuestionType = [DownloadFormData openNewForm:fileName WithIncompleteList:fileListOfIncompleteForms withFormList:formList selectedForm:formSelectedByUser];
    if (firstQuestionType == NULL){
        [self displayErrorWithTitle:@"Error" withMessage:@"Could not download form. Please make sure the device has an internet connection" cancelButton:@"OK" otherButton:nil];
    }else{
        NSLog(@"%@", firstQuestionType);

        [self loadFirstQuestion:firstQuestionType];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    formList = nil;
    
}
@end
