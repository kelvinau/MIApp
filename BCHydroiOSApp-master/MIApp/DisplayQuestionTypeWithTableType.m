//
//  TestNewTableViewController.m
//  MIApp
//
//  Created by Gursimran Singh on 2014-04-01.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "DisplayQuestionTypeWithTableType.h"
#import "KeyList.h"
#import "TableQuestionViewLogic.h"

@implementation DisplayQuestionTypeWithTableType
{
    TableQuestionViewLogic* logic;
    float tableWidth;
}

@synthesize tableScrollView, errorMessageWhenNotAllAnswered, headerView, headerHeight;

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
    
    //add swipe left gesture
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    // Do any additional setup after loading the view.
    
}


//method called when swiped left
- (void)swipedLeft:(UISwipeGestureRecognizer *)sender
{
    [self nextQuestionButtonPressed:nil];
}



-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //get table width
    tableWidth = [self.tableScrollView frame].size.width;
    
    //get an object of logic for the table
    logic = [[TableQuestionViewLogic alloc] initWithQuestion:[super thisQuestion] collectionViewWidth:984 sizeForPrint:NO scrollView:tableScrollView headerView:headerView];

    //display table
    [logic displayTable];
    
    //set scrollview constent size to add scroll bars
    [tableScrollView  setContentSize:CGSizeMake(tableScrollView.frame.size.width, [logic getTotalHeight])];
    
    //set header height
    [headerHeight setConstant:[logic getHeaderHeight]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//display next question when next question button pressed
- (IBAction)nextQuestionButtonPressed:(id)sender {
    
    [self.view endEditing:YES];
    
    
    //check if every cell in table has been answered
    BOOL validate = [logic checkUserAnswersValid];
    
    //if user hasnt enetered all answers then display error message and ask them to fill in all fields
    if ((!validate)  && (self.commentBoxTextField.text.length == 0)) {
        errorMessageWhenNotAllAnswered.text = @"Please answer all fields";
        errorMessageWhenNotAllAnswered.textColor = [UIColor redColor];
        return;
    }else{
        errorMessageWhenNotAllAnswered.text = @"";
    }
    
    //save answer
    [self saveAnswers];
    
    
    //call super
    [super nextQuestionButtonPressed:sender];
}


//method called to save answers to file
-(void) saveAnswers
{
    //Create temp variables needed to save
    NSMutableDictionary* questionAnswer = [[NSMutableDictionary alloc] init];
    
    
    [questionAnswer setObject:[logic getUserAnswers] forKey:[[KeyList sharedInstance] tableQuestionTypeTemplateKey]];
    
    //call super
    [super saveAnswers:questionAnswer];
    
}

//quit form but save answers first
- (IBAction)saveAndExit:(id)sender {
    [self.view endEditing:YES];
    [self saveAnswers];
    [super saveAndExit:sender];
}

@end
