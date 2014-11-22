//
//  DisplayTrueFalseQuestionType.m
//  MIApp
//
//  Created by Gursimran Singh on 12/29/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import "DisplayTrueFalseQuestionType.h"
#import "KeyList.h"

@implementation DisplayTrueFalseQuestionType


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    super.selectedAnswersInTable = [[NSMutableArray alloc] init];
    
    //create true and false options
    //web app doesnt ask for options when adding a true/false question
    // 06/10/2014 Changed True/Fasle to Yes/No by Kelvin
    NSString *trueOption = @"Yes";
    NSString *falseOption = @"No";
    NSMutableArray* answersToBeDisplayed = [[NSMutableArray alloc] init];
    [answersToBeDisplayed addObject:trueOption];
    [answersToBeDisplayed addObject:falseOption];
    
    
    //replace in original question dictionary
    NSMutableDictionary* tempAllInfo = [[NSMutableDictionary alloc] init];
    NSString *key;
    for (key in super.thisQuestion){
        [tempAllInfo setObject:[super.thisQuestion objectForKey:key] forKey:key];
    }
    [tempAllInfo removeObjectForKey:[[KeyList sharedInstance] answerListTemplateKey]];
    [tempAllInfo setObject:answersToBeDisplayed forKey:[[KeyList sharedInstance] answerListTemplateKey]];
    super.thisQuestion = tempAllInfo;
    
    [super.answerOptionTable reloadData]; // to reload selected cell
    
}


@end
