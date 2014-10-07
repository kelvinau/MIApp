//
//  TestNewTableViewController.h
//  MIApp
//
//  Created by Gursimran Singh on 2014-04-01.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DisplayQuestionType.h"

@interface DisplayQuestionTypeWithTableType : DisplayQuestionType<UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UIScrollView *tableScrollView;
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (strong, nonatomic) IBOutlet UILabel *errorMessageWhenNotAllAnswered;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *headerHeight;

@end
