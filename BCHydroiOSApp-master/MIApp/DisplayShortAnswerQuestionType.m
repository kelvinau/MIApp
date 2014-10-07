//
//  DisplayShortAnswerQuestionType.m
//  MIApp
//
//  Created by Gursimran Singh on 12/29/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import "DisplayShortAnswerQuestionType.h"
#import "QuestionList.h"
#import "KeyList.h"

@implementation DisplayShortAnswerQuestionType
{
    BOOL isNumber;
}
@synthesize shortAnswertTextField, heightConstraint, widthConstraint;

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
    
    //add left gesture
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    shortAnswertTextField.delegate = self;
    
}

//add outine to short answer box
-(void) addOutlineToTextView
{
    [super addOutlineToTextView];
    
    [shortAnswertTextField.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [shortAnswertTextField.layer setBorderWidth:1.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    shortAnswertTextField.layer.cornerRadius = 5;
    shortAnswertTextField.clipsToBounds = YES;
}


//method when swiped left
- (void)swipedLeft:(UISwipeGestureRecognizer *)sender
{
    [self nextQuestionButtonPressed:nil];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //fill user answer
    NSDictionary *answers = [[super thisQuestion] objectForKey:[[KeyList sharedInstance] userAnswerToBeSavedTemplateKey]];
    shortAnswertTextField.text = [answers objectForKey:[[KeyList sharedInstance] shortAnswerQuestionTypeTemplateKey]];
    
    //check if numerical answer was requested
    if ([[[super thisQuestion] objectForKey:[[KeyList sharedInstance] numberInputKey]] intValue] == 1) {
        isNumber = YES;
        widthConstraint.constant = 100;
        heightConstraint.constant = 30;
        [shortAnswertTextField setKeyboardType:UIKeyboardTypeNamePhonePad];
    }else{
        isNumber = NO;
    }
}


-(void)textViewDidBeginEditing:(UITextView *)textView{
    
    //change color of text view back to black when user begins editing
    [self changeTextColorBackToBlack];
    
}


//next question button pressed
- (IBAction)nextQuestionButtonPressed:(id)sender {
    
    //end editing
    [self.view endEditing:YES];
    
    //save user answer
    NSString* shortAnswerText = [[self shortAnswertTextField] text];
    
    //check if user entered an answer
    //if empty or if error message in text view and no comment entered
    //do not let user continue
    if ((([shortAnswerText length] == 0) || ([shortAnswerText isEqualToString:@"Please enter your answer here"])) && (self.commentBoxTextField.text.length == 0)){
        shortAnswertTextField.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0];
        shortAnswertTextField.text = @"Please enter your answer here";
        return;
    }
    
    //if comment was entered but error message alrady displayed then hide it
    [self changeTextColorBackToBlack];
    
    //save answer
    [self saveAnswers];
    
    //call super
    [super nextQuestionButtonPressed:sender];
}

-(void) changeTextColorBackToBlack{
    
    //if contents of text view is error message then set it to empty and set color to black
    if ([shortAnswertTextField.text isEqualToString:@"Please enter your answer here"]){
        shortAnswertTextField.text = @"";
        shortAnswertTextField.textColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
    }
}


//delegate for text view
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    //check if text view is short answer and number answer to be entered
    if (textView == self.shortAnswertTextField && isNumber)
    {
        
        //check if character typed is allowed or not
        NSString *newString = [textView.text stringByReplacingCharactersInRange:range withString:text];
        
        NSString *expression = @"^([0-9]+)?(\\.([0-9]{1,6})?)?$";
        
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSUInteger numberOfMatches = [regex numberOfMatchesInString:newString
                                                            options:0
                                                              range:NSMakeRange(0, [newString length])];
        
        //typed character is not allowed
        if (numberOfMatches == 0){
            return NO;
        }
    }
    
    //typed character is allwoed
    return YES;
}



-(void) saveAnswers
{
    //Create temp variables needed to save
    NSMutableDictionary* questionAnswer = [[NSMutableDictionary alloc] init];
    
    NSString* shortAnswerText = [[self shortAnswertTextField] text];
    
    //save short answer to dictionary
    [questionAnswer setObject:shortAnswerText forKey:[[KeyList sharedInstance] shortAnswerQuestionTypeTemplateKey]];
    
    
    //call super
    [super saveAnswers:questionAnswer];
}


//save and exit when user clicks 'X'
- (IBAction)saveAndExit:(id)sender {
    [self.view endEditing:YES];
    [self saveAnswers];
    [super saveAndExit:sender];
}

@end
