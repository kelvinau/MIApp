//
//  DisplayMultipleChoiceQuestionType.m
//  MIApp
//
//  Created by Gursimran Singh on 12/29/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import "DisplayMultipleChoiceQuestionType.h"

@implementation DisplayMultipleChoiceQuestionType


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    [super.answerOptionTable reloadData];
}

@end
