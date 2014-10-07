//
//  DisplayQuestionType.h
//  MIApp
//
//  Created by Gursimran Singh on 12/29/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKNumberBadgeView.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface DisplayQuestionType : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) IBOutlet TPKeyboardAvoidingScrollView *theScrollView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextQuestionButton;
@property (strong, nonatomic) IBOutlet UILabel *questionTextField;
- (IBAction)nextQuestionButtonPressed:(id)sender;
- (void) saveData;
- (IBAction)saveAndExit:(id)sender;
@property (strong, nonatomic) IBOutlet UITextView *commentBoxTextField;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *questionHeight;


-(NSArray*) getImageFiles;
-(NSArray*) getSoundFiles;
-(NSArray*) getVideoFiles;
-(NSMutableDictionary*) thisQuestion;
-(void) setThisQuestion:(NSMutableDictionary*) question;
-(void) saveAnswers:(NSMutableDictionary*) questionAnswer;
-(BOOL) editQuestion;
-(void) setEditQuestion: (BOOL)edit;

-(void) saveAnswers;
-(void) addOutlineToTextView;


@end
