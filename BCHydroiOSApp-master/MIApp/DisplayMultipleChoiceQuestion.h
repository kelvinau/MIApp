//
//  DisplayMultipleChoiceQuestion.h
//  MIApp
//
//  Created by Gursimran Singh on 11/14/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisplayMultipleChoiceQuestion : UIViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextQuestionButton;
@property (strong, nonatomic) IBOutlet UILabel *questionTextField;
- (IBAction)nextQuestionButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *commentBoxTextField;
@property (strong, nonatomic) IBOutlet UITableView *answerOptionTable;
@property (strong, nonatomic) IBOutlet UIScrollView *theScrollView;
@property (strong, nonatomic) IBOutlet UILabel *noAnswerSelectedLabel;
@property NSNumber* id;
@property (strong, nonatomic) NSMutableDictionary* thisQuestion;
@property (strong, nonatomic) NSMutableArray* selectedAnswersInTable;
@property bool EditQuestion;

@end
