//
//  DisplayTrueFalseQuestion.m
//  MIApp
//
//  Created by Gursimran Singh on 11/14/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import "DisplayTrueFalseQuestion.h"
#import "QuestionList.h"

@implementation DisplayTrueFalseQuestion

@synthesize nextQuestionButton, questionTextField, answerOptionTable, commentBoxTextField, thisQuestion, selectedAnswersInTable, noAnswerSelectedLabel, theScrollView, EditQuestion;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"IN HERTEEEEEE");
    
    //Check if this is the last, then change button text
    int next = [[self id]intValue] + 1;
    
    
    if ((EditQuestion == YES) || (next == [[[QuestionList sharedInstance] questionList] count])){
        [[self nextQuestionButton] setTitle:@"Finish Edit"];
        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAndExit:)];
        
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: nextQuestionButton,cancelButton, Nil];
    }else{
        UIView* leftButtonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 50)];
        UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
        leftButton.backgroundColor = [UIColor clearColor];
        leftButton.frame = leftButtonView.frame;
        [leftButton setImage:[UIImage imageNamed:@"forward"] forState:UIControlStateNormal];
        [leftButton setTitle:[NSString stringWithFormat:@"Question %d", next+1] forState:UIControlStateNormal];
        [[leftButton titleLabel] setTextAlignment:NSTextAlignmentLeft];
        [[leftButton titleLabel] setFont:[UIFont systemFontOfSize:17]];
        leftButton.autoresizesSubviews = YES;
        leftButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
        leftButton.titleEdgeInsets = UIEdgeInsetsMake(0, -leftButton.imageView.frame.size.width, 0, leftButton.imageView.frame.size.width);
        leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, leftButton.titleLabel.frame.size.width, 0, -leftButton.titleLabel.frame.size.width);
        [leftButton addTarget:self action:@selector(nextQuestionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        leftButton.frame = CGRectMake(15, leftButtonView.frame.origin.y, leftButton.titleLabel.frame.size.width+leftButton.imageView.frame.size.width, leftButtonView.frame.size.height);
        leftButtonView.frame = leftButton.frame;
        [leftButtonView addSubview:leftButton];
        UIBarButtonItem* rightBarButton = [[UIBarButtonItem alloc]initWithCustomView:leftButtonView];
        
        UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAndExit:)];
        
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: rightBarButton,cancelButton, Nil];
    }
    
    

    if (EditQuestion == YES){
        [self setTitle:[NSString stringWithFormat: @"Edit Question %d", next]];
    }else{
        [self setTitle:[NSString stringWithFormat:@"Question %d", next]];
    }
    
    //Display appropriate UIObjects depending on type of question
    thisQuestion = [[NSMutableDictionary alloc] init];
    thisQuestion = [[[QuestionList sharedInstance] questionList] objectAtIndex:[[self id] intValue]];
    self.questionTextField.text = [thisQuestion objectForKey:@"question"];
    selectedAnswersInTable = [[NSMutableArray alloc] init];
    
    
    NSDictionary *answers = [thisQuestion objectForKey:@"user-answer"];
    commentBoxTextField.text = [answers objectForKey:@"comment"];
    //NSLog(@"%@",[answers objectForKey:@"check-boxes"]);
    
    NSString *trueOption = @"True";
    NSString *falseOption = @"False";
    NSMutableArray* answersToBeDisplayed = [[NSMutableArray alloc] init];
    [answersToBeDisplayed addObject:trueOption];
    [answersToBeDisplayed addObject:falseOption];
    
    NSMutableDictionary* tempAllInfo = [[NSMutableDictionary alloc] init];
    NSString *key;
    //Replace this question from list of questions to this new object where it has question and answer both
    for (key in thisQuestion){
        [tempAllInfo setObject:[thisQuestion objectForKey:key] forKey:key];
    }
    [tempAllInfo removeObjectForKey:@"answers"];
    [tempAllInfo setObject:answersToBeDisplayed forKey:@"answers"];
    thisQuestion = tempAllInfo;

    
    //selectedAnswersInTable = [answers objectForKey:@"check-boxes"];
    [answerOptionTable reloadData]; // to reload selected cell
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
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.

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
    NSDictionary *answersList = [thisQuestion objectForKey:@"user-answer"];
    NSArray *selectedAnswer = [answersList objectForKey:@"check-boxes"];
    NSArray* answers = [thisQuestion objectForKey:@"answers"];
    cell.textLabel.text = [answers objectAtIndex:indexPath.row];

    for (int i =0; i < [selectedAnswer count]; i++){
        if ([[answers objectAtIndex:indexPath.row] isEqualToString:[selectedAnswer objectAtIndex:i]]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [selectedAnswersInTable addObject:[[NSString alloc] initWithString:cell.textLabel.text]];

        }
    }
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

//If keyboard if shown, raise the view by height of keyboard only if comment box is selected
- (void)keyboardWasShown:(NSNotification *)notification
{
    
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.1, 0.1, keyboardSize.height, 0.1);
    theScrollView.contentInset = contentInsets;
    theScrollView.scrollIndicatorInsets = contentInsets;
    
    // Step 3: Scroll the target text field into view.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    if(commentBoxTextField.isFirstResponder){
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


- (IBAction)nextQuestionButtonPressed:(id)sender {
    
    [self.view endEditing:YES];
    
    if ([selectedAnswersInTable count] == 0){
        noAnswerSelectedLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
        noAnswerSelectedLabel.text = @"Please choose at least one option";
        return;
    }
    
    [self saveAnswers];
    
    if ([[nextQuestionButton title] isEqualToString:@"Finish Edit"]){
        if (EditQuestion == YES){
            [[self navigationController] popToViewController:[[[self navigationController] viewControllers] objectAtIndex:[[[QuestionList sharedInstance] questionList] count]+1] animated:YES];
        }else{
            [self performSegueWithIdentifier:@"ShowAnswers" sender:self];
        }

    }
    else if (![[nextQuestionButton title] isEqualToString:@"Save and Finish"]){
        int nextQuestionIndex = [[self id] intValue]+1;
        NSString *nextQuestionType = [[[[QuestionList sharedInstance] questionList] objectAtIndex:nextQuestionIndex] objectForKey:@"answer-type"];
        UIViewController *displayQuestion;
        
        if ([nextQuestionType isEqualToString:@"short-answer"]){
            
            displayQuestion = [self.storyboard instantiateViewControllerWithIdentifier:@"DisplayShortAnswerQuestion"];
            
        }else if ([nextQuestionType isEqualToString:@"true/false"]){
            
            
            displayQuestion = [self.storyboard instantiateViewControllerWithIdentifier:@"DisplayTrueFalseQuestion"];
            
        }else if ([nextQuestionType isEqualToString:@"multiple-choice"]){
            
            
            displayQuestion = [self.storyboard instantiateViewControllerWithIdentifier:@"DisplayMultipleChoiceQuestion"];
            
            
        }
        int next = [[self id]intValue] + 2;
        displayQuestion.title = [NSString stringWithFormat:@"Question %@", [[NSNumber alloc] initWithInt:next]];
        QuestionList.sharedInstance.nextQuestionID = [[NSNumber alloc] initWithInt:next-1];
        [self.navigationController pushViewController:displayQuestion animated:YES];
    }
    
}


- (void) saveData:(NSArray*) questionData{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectoryPath stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]];
    NSMutableDictionary* tempMI = [[NSMutableDictionary alloc] init];
    [tempMI setValue:questionData forKey:@"questions"];
    
    NSString* key;
    for (key in [[QuestionList sharedInstance] justAnswers]){
        [tempMI setValue:[[[QuestionList sharedInstance] justAnswers] objectForKey:key] forKey:key];
    }
    [NSKeyedArchiver archiveRootObject:tempMI toFile:filePath];
}

- (IBAction)saveAndExit:(id)sender {
    [self.view endEditing:YES];
    [self saveAnswers];
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
}

-(void) saveAnswers
{

    //Create temp variables needed to save
    NSMutableDictionary* questionAnswer = [[NSMutableDictionary alloc] init];
    NSString* extraComment = [[self commentBoxTextField] text];
    NSMutableDictionary* tempAllInfo = [[NSMutableDictionary alloc] init];
    NSString *key;
    
    //Save comment box
    [questionAnswer setObject:extraComment forKey:@"comment"];
    
    [questionAnswer setObject:selectedAnswersInTable forKey:@"check-boxes"];
    
    //Replace this question from list of questions to this new object where it has question and answer both
    for (key in thisQuestion){
        [tempAllInfo setObject:[thisQuestion objectForKey:key] forKey:key];
    }
    [tempAllInfo setObject:questionAnswer forKey:@"user-answer"];
    thisQuestion = tempAllInfo;
    [[[QuestionList sharedInstance] questionList] replaceObjectAtIndex:[[self id] intValue] withObject:thisQuestion];
    
    [self saveData:[[QuestionList sharedInstance] questionList]];

}

@end
