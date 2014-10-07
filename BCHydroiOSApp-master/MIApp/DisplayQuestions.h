//
//  DisplayQuestions.h
//  MIApp
//
//  Created by Gursimran Singh on 11/12/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisplayQuestions : UIViewController{
    
    NSNumber* id;
    IBOutlet UILabel* question;
    NSMutableDictionary* thisQuestion;
    IBOutlet UIBarButtonItem* nextQuestion;
}

- (IBAction)LoadNextQuestion:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *shortAnswer;
@property (strong, nonatomic) IBOutlet UILabel *ErrorMessageAnswer;
@property (strong, nonatomic) IBOutlet UIScrollView *theScrollView;
@property (strong, nonatomic) IBOutlet UITableView *answerTableView;

@property (weak) UITextField* activeTextField;
@property (strong, nonatomic) IBOutlet UITextView *commentTextField;
@property (strong, nonatomic) UILabel* question;
@property NSNumber* id;
@property (strong, nonatomic) NSMutableDictionary* thisQuestion;
@property (strong, nonatomic) IBOutlet UIBarButtonItem* nextQuestion;
@property NSMutableArray* selectedAnswersInTable;
@end
