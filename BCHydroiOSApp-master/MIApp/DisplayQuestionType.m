//
//  DisplayQuestionType.m
//  MIApp
//
//  Created by Gursimran Singh on 12/29/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import "DisplayQuestionType.h"
#import "QuestionList.h"
#import "ManageMediaTableViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "ManageMediaCollectionView.h"
#import "ManageMediaCell.h"
#import "ManageMediaHeaderCollectionView.h"
#import "RecordSound.h"
#import "MediaAttachment.h"
#import "DisplayQuestionHelp.h"
#import "KeyList.h"
#import "DisplayQuestionTypeWithTableType.h"
#import "NextQuestionHelp.h"

@implementation DisplayQuestionType
{
    MediaAttachment* mediaButton;
    UIView *buttonView;
    NSMutableDictionary* thisQuestion;
    bool EditQuestion;
    UIPopoverController *popOver;
    MKNumberBadgeView* mediaBadge;
    NSNumber* qId;
    UIView* infoButtonView;
}

@synthesize theScrollView, nextQuestionButton, commentBoxTextField;



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    //Store id of this question
    qId = [[QuestionList sharedInstance] nextQuestionID];
    
    
    //set up right swipe gestures
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    
    
    
    
    //add boundary to text views
    [self addOutlineToTextView];
    
    
    
    //enable multiple line questions
    self.questionTextField.lineBreakMode = NSLineBreakByCharWrapping;
    self.questionTextField.numberOfLines = 0;
    
    
    //add buttons to toolbar
    [self setToolBarButtons];
}



//Add outline to comment text box
-(void) addOutlineToTextView
{
    [commentBoxTextField.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [commentBoxTextField.layer setBorderWidth:1.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    commentBoxTextField.layer.cornerRadius = 5;
    commentBoxTextField.clipsToBounds = YES;
}


//method called on when swiped right
- (void)swipedRight:(UISwipeGestureRecognizer *)sender
{
    [self.navigationController popViewControllerAnimated:YES];

}

//Hide toolbar before view is dismissed
-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    thisQuestion = nil;

    //hide toolbar
    self.navigationController.toolbarHidden = YES;
}


//adding buttons to toolbar
-(void) setToolBarButtons
{
    
    //get media button
    mediaButton = [[MediaAttachment alloc] initWithId:qId forView:self];
    
    //create barbutton from button to add to toolbar
    UIBarButtonItem* button = [mediaButton setUpButtonAtOrigin:CGPointMake(theScrollView.frame.size.width, commentBoxTextField.frame.origin.y + commentBoxTextField.frame.size.height)];

    //space button to move media button to right side of toolbar
    UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //Setup info button
    infoButtonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 50)];
    UIButton* infoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    infoButton.backgroundColor = [UIColor clearColor];
    infoButton.frame = infoButtonView.frame;
    [infoButton setImage:[UIImage imageNamed:@"info"] forState:UIControlStateNormal];
    [infoButton setImage:[UIImage imageNamed:@"infoFilled"] forState:UIControlStateHighlighted];
    [infoButtonView addSubview:infoButton];
    [infoButton addTarget:self action:@selector(displayHelp:) forControlEvents:UIControlEventTouchUpInside];
    
    
    //create bar button
    UIBarButtonItem* infoBarButton = [[UIBarButtonItem alloc]initWithCustomView:infoButtonView];

    
    //add buttons
    self.toolbarItems = @[infoBarButton, flexibleSpaceLeft, button];
}


//Method called when user presses close button
- (IBAction)saveAndExit:(id)sender {
    
    //end editing to hide keyboard
    [self.view endEditing:YES];
    
    //pop to form list view
    if ([[QuestionList sharedInstance] engineerView]) {
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];

    }
    else{
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
    }
    
}


//Method called when next question button pressed
- (IBAction)nextQuestionButtonPressed:(id)sender {

    //check if there is any more question
    //if not then next view should be review page and not another question
    if ([[nextQuestionButton title] isEqualToString:@"Finish Edit"]){
        
        //if user is editing a question, pop view controllers to get back to review page
        if (EditQuestion == YES){
            if ([[QuestionList sharedInstance] engineerNewMI]) {
                [[self navigationController] popToViewController:[[[self navigationController] viewControllers] objectAtIndex:[[[QuestionList sharedInstance] questionList] count]+3] animated:YES];
            }else if ([[QuestionList sharedInstance] engineerView]) {
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [[self navigationController] popToViewController:[[[self navigationController] viewControllers] objectAtIndex:[[[QuestionList sharedInstance] questionList] count]+2] animated:YES];
            }
            
        }
        //if user just finished answering questions then load review page for the first time
        else{
            [self performSegueWithIdentifier:@"ShowAnswers" sender:self];
        }
    }
    
    //display next question
    else if (![[nextQuestionButton title] isEqualToString:@"Save and Finish"]){
        
        int nextQuestionIndex = [qId intValue]+1;
        
        //get next question view controller
        NSString *nextQuestionType = [[[[QuestionList sharedInstance] questionList] objectAtIndex:nextQuestionIndex] objectForKey:[[KeyList sharedInstance] answerTypeTemplateKey]];
        UIViewController *displayQuestion = [NextQuestionHelp getNextQuestionViewController:nextQuestionType withStoryBoard:self.storyboard];
        
        //set properties of view controller
        int next = [qId intValue] + 2;
        displayQuestion.title = [NSString stringWithFormat:@"Question %@", [[NSNumber alloc] initWithInt:next]];
        QuestionList.sharedInstance.nextQuestionID = [[NSNumber alloc] initWithInt:next-1];
        
        //display
        [self.navigationController pushViewController:displayQuestion animated:YES];
    }
    
}


//save answers
-(void) saveAnswers:(NSMutableDictionary*) questionAnswer
{
    //Create temp variables needed to save
    NSString* extraComment = [[self commentBoxTextField] text];
    NSMutableDictionary* tempAllInfo = [[NSMutableDictionary alloc] init];
    NSString *key;
    
    //Save comment box
    [questionAnswer setObject:extraComment forKey:[[KeyList sharedInstance] commentToBeSavedTemplateKey]];
    
    
    //save media
    NSArray* images = [self getImageFiles];
    NSArray* videos = [self getVideoFiles];
    NSArray* voice = [self getSoundFiles];
    
    //
    if ([images count] > 0){
        NSMutableArray* imageWithOutExtension = [[NSMutableArray alloc] init];
        for (NSString* each in images) {
            NSString* withOutExtension = [[each componentsSeparatedByString:@"."] objectAtIndex:0];
            [imageWithOutExtension addObject:withOutExtension];
        }
    [questionAnswer setObject:imageWithOutExtension forKey:[[KeyList sharedInstance] imagesToBeSavedTemplateKey]];
    }
    if ([voice count] > 0){
        NSMutableArray* voiceWithOutExtension = [[NSMutableArray alloc] init];
        for (NSString* each in voice) {
            NSString* withOutExtension = [[each componentsSeparatedByString:@"."] objectAtIndex:0];
            [voiceWithOutExtension addObject:withOutExtension];
        }
    [questionAnswer setObject:voiceWithOutExtension forKey:[[KeyList sharedInstance] voiceToBeSavedTemplateKey]];
    }
    if ([videos count] > 0){
        NSMutableArray* videosWithOutExtension = [[NSMutableArray alloc] init];
        for (NSString* each in videos) {
            NSString* withOutExtension = [[each componentsSeparatedByString:@"."] objectAtIndex:0];
            [videosWithOutExtension addObject:withOutExtension];
        }
        [questionAnswer setObject:videosWithOutExtension forKey:[[KeyList sharedInstance] videosToBeSavedTemplateKey]];
    }
    
    
    //Add question and answer to new dictionary
    for (key in thisQuestion){
        [tempAllInfo setObject:[thisQuestion objectForKey:key] forKey:key];
    }
    [tempAllInfo setObject:questionAnswer forKey:[[KeyList sharedInstance] userAnswerToBeSavedTemplateKey]];
    thisQuestion = tempAllInfo;
    
    //Replace this question from list of questions to this new object where it has question and answer both
    NSMutableArray* tempQuestionList = [[QuestionList sharedInstance] questionList];
    [tempQuestionList replaceObjectAtIndex:[qId intValue] withObject:thisQuestion];
    [[QuestionList sharedInstance] setQuestionList:tempQuestionList];
    
    
    //save form to disk
    [self saveData];
}

-(void) saveAnswers
{
    
}


//save form to disk
- (void) saveData 
{
    //get path to folder where this form is to be saved
    NSString *filePath;
    if (([[QuestionList sharedInstance] engineerView]) && (![[QuestionList sharedInstance] engineerNewMI])) {
        filePath = [[[QuestionList sharedInstance] completedFilePathToBeUploaded] stringByAppendingPathComponent:[[QuestionList sharedInstance] completedFileNameToBeUploaded]];
    }else{
    filePath = [[[[[QuestionList sharedInstance] userPath] stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"] stringByAppendingString:[[QuestionList sharedInstance] fileNameToBeSavedAs]];
    }
    
    //new dictionary with all info (including the new answers)
    NSMutableDictionary* tempMI = [[NSMutableDictionary alloc] init];
    [tempMI setValue:[[QuestionList sharedInstance] questionList] forKey:[[KeyList sharedInstance] listOfQuestionsTemplateKey]];
    
    NSString* key;
    for (key in [[QuestionList sharedInstance] entireMITemplate]){
        if (![key isEqualToString:[[KeyList sharedInstance] listOfQuestionsTemplateKey]]) {
            [tempMI setValue:[[[QuestionList sharedInstance] entireMITemplate] objectForKey:key] forKey:key];
        }
    }
    
    //save to disk
    [NSKeyedArchiver archiveRootObject:tempMI toFile:filePath];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //display toolbar
    self.navigationController.toolbarHidden = NO;
    
    //space between two buttons
    UIBarButtonItem* space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:Nil];
    space.width = 100.0f;


    //'X' button
    UIBarButtonItem* cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(saveAndExit:)];
    

    int next = [qId intValue] + 1;
    
    //title of next question if user is editing a question
    if ((EditQuestion == YES) || (next == [[[QuestionList sharedInstance] questionList] count])){
        [[self nextQuestionButton] setTitle:@"Finish Edit"];
        
    }
    //Create custom view for next question, with arrow and title of next question
    else{
        
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
        leftButton.frame = CGRectMake(18, leftButtonView.frame.origin.y, leftButton.titleLabel.frame.size.width+leftButton.imageView.frame.size.width, leftButtonView.frame.size.height);
        leftButtonView.frame = leftButton.frame;
        [leftButtonView addSubview:leftButton];
        
        [self.nextQuestionButton setCustomView:leftButtonView];
    }
    
    //Add buttons to navigation bar
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects: nextQuestionButton,space, cancelButton, Nil];

    
    //set thisQuestion to question information
    thisQuestion = [[NSMutableDictionary alloc] init];
    thisQuestion = [[[QuestionList sharedInstance] questionList] objectAtIndex:[qId intValue]];
    
    
    //change color to red if help is present
    if ((![[[thisQuestion objectForKey:[[KeyList sharedInstance] helpInfoTemplateKey]] objectForKey:[[KeyList sharedInstance] helpTextTemplateKey]] isEqualToString:@""]) && ([[[thisQuestion objectForKey:[[KeyList sharedInstance] helpInfoTemplateKey]] objectForKey:[[KeyList sharedInstance] helpImagesTemplateKey]] count] > 0) ) {
        infoButtonView.tintColor = [UIColor redColor];
    }

    

    
    
    //Calculate the expected height of question
    CGSize maximumLabelSize = CGSizeMake(984, FLT_MAX);
    
    CGSize expectedLabelSize = [[thisQuestion objectForKey:[[KeyList sharedInstance] questionTemplateKey]] sizeWithFont:self.questionTextField.font constrainedToSize:maximumLabelSize lineBreakMode:self.questionTextField.lineBreakMode];
    
    //set question height
    self.questionHeight.constant = expectedLabelSize.height;

    
    self.questionTextField.text = [thisQuestion objectForKey:[[KeyList sharedInstance] questionTemplateKey]];
    
    
    //set title
    if (EditQuestion == YES){
        self.title = [NSString stringWithFormat:@"Edit Question %d - %@",next, [thisQuestion objectForKey:[[KeyList sharedInstance] sectionTitleKey]]];
    }else{
        self.title = [NSString stringWithFormat:@"Question %d - %@",next, [thisQuestion objectForKey:[[KeyList sharedInstance] sectionTitleKey]]];
    }
    
    
    //fill comment box with user answer
    NSDictionary *answers = [thisQuestion objectForKey:[[KeyList sharedInstance] userAnswerToBeSavedTemplateKey]];
    commentBoxTextField.text = [answers objectForKey:[[KeyList sharedInstance] commentToBeSavedTemplateKey]];

    [mediaButton updateMediaBadge];
}


//display help popover
-(void) displayHelp: (UIButton*)sender
{
    //do not display a popover if one is already displayed
    if ([popOver isPopoverVisible]){
        return;
    }
    
    //load view from storyboard
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    DisplayQuestionHelp* displayHelp = [mainStoryboard instantiateViewControllerWithIdentifier:@"questionHelp"];
    displayHelp.helpInfo = [thisQuestion objectForKey:[[KeyList sharedInstance] helpInfoTemplateKey]];
    displayHelp.preferredContentSize = CGSizeMake(300, 350);
    
    //display popover
    UIPopoverController* popover = [[UIPopoverController alloc] initWithContentViewController:displayHelp];
    popOver = popover;
    [popover presentPopoverFromRect:sender.bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}


//get video files in array
-(NSArray*) getVideoFiles
{
    NSArray* videoFiles = [self getfile:@".mov"];
    return videoFiles;
}

//get array of sound files
-(NSArray*) getSoundFiles
{
    NSArray* soundFiles = [self getfile:@".m4a"];
    return soundFiles;
}


//get list of images
-(NSArray*) getImageFiles
{
    NSArray* imageFiles = [self getfile:@".jpg"];
    return imageFiles;
}

//list of files with passed extension
-(NSArray*) getfile:(NSString*) ofType
{
    NSString *userDirectory = [[QuestionList sharedInstance] userPath];
    NSString *folderPath;
    
    //folder path of form being filled
    if (([[QuestionList sharedInstance] engineerView]) && (![[QuestionList sharedInstance] engineerNewMI])) {
        folderPath = [[QuestionList sharedInstance] completedFilePathToBeUploaded];
    }else{
        folderPath = [[userDirectory stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
    }
    
    //get all files in folder
    NSArray* listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    
    //get all files with extension
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", ofType];
    NSArray* listOfFilesForCurrentType = [listOfFiles filteredArrayUsingPredicate:predicate];
    
    //get all files for this question after getting files of extension
    NSPredicate *predicateForCurrentQuestion = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", [NSString stringWithFormat:@"Qid%@", qId.stringValue]];
    return [listOfFilesForCurrentType filteredArrayUsingPredicate:predicateForCurrentQuestion];
}


//getter for thisquestion
-(NSMutableDictionary*) thisQuestion
{
    return thisQuestion;
}

//setter for this question
-(void) setThisQuestion:(NSMutableDictionary*) question
{
    thisQuestion = question;
}

//getter for editquestion
-(BOOL) editQuestion
{
    return EditQuestion;
}

//setter for this question
-(void) setEditQuestion: (BOOL)edit
{
    EditQuestion = edit;
}


@end
