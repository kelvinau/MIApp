//
//  DisplayQuestions.m
//  MIApp
//
//  Created by Gursimran Singh on 11/12/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import "DisplayQuestions.h"
#import "QuestionList.h"
#import "DisplayCompletedJson.h"

@implementation DisplayQuestions

@synthesize id, question, thisQuestion, nextQuestion, theScrollView, activeTextField, answerTableView, shortAnswer, selectedAnswersInTable, commentTextField, ErrorMessageAnswer;

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
    
    //Create notifications for when keyboard is displayed and hidden.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //Store id of this question
    [self setId:[[QuestionList sharedInstance] nextQuestionID]];
    
    //Check if this is the last, then change button text
    int next = [[self id]intValue] + 1;
    if(next == [[[QuestionList sharedInstance] questionList] count]){
        [[self nextQuestion] setTitle:@"Save and Finish"];
    }
    
    //Display appropriate UIObjects depending on type of question
    thisQuestion = [[NSMutableDictionary alloc] init];
    thisQuestion = [[[QuestionList sharedInstance] questionList] objectAtIndex:[[self id] intValue]];
    self.question.text = [thisQuestion objectForKey:@"question"];
    if([[thisQuestion objectForKey:@"answer-type"] isEqualToString:@"short-answer"]){
        answerTableView.hidden = YES;
    }else{
        shortAnswer.hidden = YES;
    }
    selectedAnswersInTable = [[NSMutableArray alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated{
    
    
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    //Release keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//Called everytime 'Next Question' or 'Save and Finish' button is called.
//Again button name depends on whether this is the last question or not.
//If this is not the last question, then save the user answers i.e - Comment box text,
//if table then selected options or answer box is a short-answer type question.
-(IBAction)LoadNextQuestion:(id)sender{
    
    //Create temp variables needed to save
    NSMutableDictionary* questionAnswer = [[NSMutableDictionary alloc] init];
    NSString* extraComment = [[self commentTextField] text];
    NSMutableDictionary* tempAllInfo = [[NSMutableDictionary alloc] init];
    NSString *key;
    
    //Save comment box
    [questionAnswer setObject:extraComment forKey:@"comment"];
    
    //If user did not select a row in table or enter any text, then display error
    //else save the user selected rows or user entered text
    if([[thisQuestion objectForKey:@"answer-type"] isEqualToString:@"short-answer"]){
        NSString* shortAnswerText = [[self shortAnswer] text];
        if ([shortAnswerText length] == 0){
            ErrorMessageAnswer.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
            ErrorMessageAnswer.text = @"Please enter your answer below.";
            return;
        }
        [questionAnswer setObject:shortAnswerText forKey:@"short-answer"];
    }else{
        if ([selectedAnswersInTable count] == 0){
            ErrorMessageAnswer.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
            ErrorMessageAnswer.text = @"Please choose at least one option.";
            return;
        }
        [questionAnswer setObject:selectedAnswersInTable forKey:@"check-boxes"];
    }
    
    //Replace this question from list of questions to this new object where it has question and answer both
    for (key in thisQuestion){
        [tempAllInfo setObject:[thisQuestion objectForKey:key] forKey:key];
    }
    [tempAllInfo setObject:questionAnswer forKey:@"user-answer"];
    thisQuestion = tempAllInfo;
    [[[QuestionList sharedInstance] questionList] replaceObjectAtIndex:[[self id] intValue] withObject:thisQuestion];
    
    //If this is the last question, then save just all the answers to a new
    //dictionary. These are without questions for future use.
    if ([[nextQuestion title] isEqualToString:@"Save and Finish"]){
        [[[QuestionList sharedInstance] entireMITemplate] setValue:[[QuestionList sharedInstance]questionList] forKey:@"questions"];
        NSMutableArray *tempAllAnswers = [[NSMutableArray alloc] init];
        for (int i=0; i < [[[QuestionList sharedInstance] questionList] count] ; i++){
            NSDictionary *temp = [[[QuestionList sharedInstance] questionList] objectAtIndex:i];
            NSMutableDictionary* answerDetails = [[NSMutableDictionary alloc] init];
            [answerDetails setObject:[[NSNumber alloc] initWithInt:[[temp objectForKey:@"id"] intValue]] forKey:@"id"];
            [answerDetails setObject:[temp objectForKey:@"user-answer"] forKey:@"answer"];
            [tempAllAnswers addObject:answerDetails];
            
        }
        [[[QuestionList sharedInstance] justAnswers] setObject:tempAllAnswers forKey:@"user-answer"];
    }
    
    
    //Depending on if this is last question or not, load next page into view
    if (![[nextQuestion title] isEqualToString:@"Save and Finish"]){
        UIViewController *displayQuestion = [self.storyboard instantiateViewControllerWithIdentifier:@"DisplayQuestion"];
        int next = [[self id]intValue] + 2;
        displayQuestion.title = [NSString stringWithFormat:@"Question %@", [[NSNumber alloc] initWithInt:next]];
        QuestionList.sharedInstance.nextQuestionID = [[NSNumber alloc] initWithInt:next-1];
        [self.navigationController pushViewController:displayQuestion animated:YES];
    }else{
        [self performSegueWithIdentifier:@"Done" sender:self];
    }
}


//If keyboard if shown, raise the view by height of keyboard only if comment box is selected
- (void)keyboardWasShown:(NSNotification *)notification
{
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    theScrollView.contentInset = contentInsets;
    theScrollView.scrollIndicatorInsets = contentInsets;
    
    // Step 3: Scroll the target text field into view.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    if(commentTextField.isFirstResponder){
        CGPoint scrollPoint = CGPointMake(0.1, 150);
        [theScrollView setContentOffset:scrollPoint animated:YES];
    }
}

//Hide Keyboard
- (void) keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    theScrollView.contentInset = contentInsets;
    theScrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSArray* answers = [thisQuestion objectForKey:@"answers"];
    return [answers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AZ";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    NSArray* answers = [thisQuestion objectForKey:@"answers"];
    cell.textLabel.text = [answers objectAtIndex:indexPath.row];
    return cell;
}

//Called everytime users selects a row.
//Save all rows with checkmarks, that are later used as users response.
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    //Empty the selection
    [selectedAnswersInTable removeAllObjects];
    
    //If the user can only select one answer then, uncheck all rows and select the new selected row.
    if ([[thisQuestion objectForKey:@"max-answers"] intValue] == 1){
        for (UITableViewCell *cell in [tableView visibleCells]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
         UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [selectedAnswersInTable addObject:[[NSString alloc] initWithString:cell.textLabel.text]];
    }
    //Else check if the user meant to check or uncheck the row.
    //If the user wanted to check then, mark that row with a checkmark else remove it.
    //Then go through every row and check if it is marked, if so, add it to user selected response
    else{
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark){
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        for (UITableViewCell *cell in [tableView visibleCells]) {
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark){
                [selectedAnswersInTable addObject:[[NSString alloc] initWithString:cell.textLabel.text]];
            }
        }
    }
}
@end
