//
//  DisplayShortAnswerQuestionType.h
//  MIApp
//
//  Created by Gursimran Singh on 12/29/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisplayQuestionType.h"

@interface DisplayShortAnswerQuestionType : DisplayQuestionType <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView *shortAnswertTextField;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;


@end
