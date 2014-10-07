//
//  DisplayQuestionTypeWithTable.m
//  MIApp
//
//  Created by Gursimran Singh on 12/29/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import "DisplayQuestionTypeWithTable.h"
#import "QuestionList.h"
#import "KeyList.h"

@implementation DisplayQuestionTypeWithTable
{
    NSMutableArray* selectedAnswers;
}

@synthesize answerOptionTable, selectedAnswersInTable, noAnswerSelectedLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    selectedAnswersInTable = [[NSMutableArray alloc] init];
    
    selectedAnswers = [[NSMutableArray alloc] init];
    
    
    //add left gesture
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
}

//called when swiped left
- (void)swipedLeft:(UISwipeGestureRecognizer *)sender
{
    [self nextQuestionButtonPressed:nil];
}


//next question button pressed
- (IBAction)nextQuestionButtonPressed:(id)sender {
    
    
    //end editing
    [self.view endEditing:YES];

    //check if at least one answer selected and no comment enetered
    //if no answer selected then display error
    if (([selectedAnswers count] == 0) && (self.commentBoxTextField.text.length == 0)){
        noAnswerSelectedLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
        noAnswerSelectedLabel.text = @"Please choose at least one option";
        return;
    }
    
    noAnswerSelectedLabel.text = @"";
    
    //save answers
    [self saveAnswers];
    
    //call super
    [super nextQuestionButtonPressed:sender];
}


-(void) saveAnswers
{
    
    //sort user answers in ascending order of row selected
    NSSortDescriptor *rowDescriptor = [[NSSortDescriptor alloc] initWithKey:@"row" ascending:YES];
    [selectedAnswers sortedArrayUsingDescriptors:@[rowDescriptor]];
    
    //get list of answers
    NSArray* answers = [super.thisQuestion objectForKey:[[KeyList sharedInstance] answerListTemplateKey]];
    
    //save index of users' answers
    [selectedAnswersInTable removeAllObjects];
    for (NSIndexPath* indexPath in selectedAnswers) {
        [selectedAnswersInTable addObject:[answers objectAtIndex:indexPath.row]];
    }

    
    //delete all duplicat enetries
    NSMutableArray* removeDuplicates = [[NSMutableArray alloc] init];
    
    for (NSString* eachAnswer in selectedAnswersInTable) {
        BOOL inList = NO;
        for (NSString* eachIn in removeDuplicates) {
            if ([eachIn isEqualToString:eachAnswer]) {
                inList = YES;
                break;
            }
        }
        if (inList == NO) {
            [removeDuplicates addObject:eachAnswer];
        }
    }
    
    //Create temp variables needed to save
    NSMutableDictionary* questionAnswer = [[NSMutableDictionary alloc] init];

    [questionAnswer setObject:removeDuplicates forKey:[[KeyList sharedInstance] tableAnswerToBeSavedTemplateKey]];
    
    //call super
    [super saveAnswers:questionAnswer];
    
}

// method called when 'X' prssed
- (IBAction)saveAndExit:(id)sender {
    [self.view endEditing:YES];
    [self saveAnswers];
    [super saveAndExit:sender];
}

//TABLE METHODS


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


//return number of rows
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray* answers = [super.thisQuestion objectForKey:[[KeyList sharedInstance] answerListTemplateKey]];
    return [answers count];
}


//return option at row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AZ";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    //get option for this cell location
    NSDictionary *answersList = [super.thisQuestion objectForKey:[[KeyList sharedInstance] userAnswerToBeSavedTemplateKey]];
    NSArray *selectedSavedAnswer = [answersList objectForKey:[[KeyList sharedInstance] tableAnswerToBeSavedTemplateKey]];
    NSArray* answers = [super.thisQuestion objectForKey:[[KeyList sharedInstance] answerListTemplateKey]];
    cell.textLabel.text = [answers objectAtIndex:indexPath.row];
    
    //check if this check box was selected by user previously
    for (int i =0; i < [selectedSavedAnswer count]; i++){
        if ([[answers objectAtIndex:indexPath.row] isEqualToString:[selectedSavedAnswer objectAtIndex:i]]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [selectedAnswers addObject:indexPath];
        }
    }
    return cell;
}

//return height of section header
-(CGFloat)tableView:(UITableView*) tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

//Called everytime users selects a row.
//Save all rows with checkmarks, that are later used as users response.
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    //if user wants to uncheck this answer
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark){
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        //remove this answer from user answer list
        NSArray* temp = [[NSArray alloc] initWithArray:selectedAnswers];
        for (int i =0 ; i < [temp count]; i++) {
            NSIndexPath* indexP = [temp objectAtIndex:i];
            if ([indexPath compare:indexP] == NSOrderedSame) {
                [selectedAnswers removeObjectAtIndex:i];
            }
        }

        return;
    }
    
    
    //if user wants to select the current row
    
    //if only one answer can be selected
    if ([[super.thisQuestion objectForKey:[[KeyList sharedInstance] maxAnswersTemplateKey]] intValue] == 1){
        
        //remove all other checkboxes
        for (NSIndexPath* indexP in selectedAnswers) {
            UITableViewCell* cellSelected = [tableView cellForRowAtIndexPath:indexP];
            cellSelected.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [selectedAnswers removeAllObjects];
        [selectedAnswers addObject:indexPath];
    }
    //since multiple answers can be added
    //just add this row
    else{
        [selectedAnswers addObject:indexPath];
         cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
}
@end
