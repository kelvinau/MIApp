//
//  DisplayShortAnswerQuestion.h
//  MIApp
//
//  Created by Gursimran Singh on 11/14/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisplayShortAnswerQuestion : UIViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextQuestionButton;
@property (strong, nonatomic) IBOutlet UILabel *questionTextField;
@property (strong, nonatomic) IBOutlet UITextView *shortAnswertTextField;
- (IBAction)nextQuestionButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *commentBoxTextField;
@property (strong, nonatomic) IBOutlet UIScrollView *theScrollView;
@property NSNumber* id;
@property (strong, nonatomic) IBOutlet UIView *buttonView;
@property (strong, nonatomic) NSMutableDictionary* thisQuestion;
@property bool EditQuestion;
@end
