//
//  NextQuestionHelp.m
//  MIApp
//
//  Created by Gursimran Singh on 2014-04-20.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "NextQuestionHelp.h"
#import "KeyList.h"
#import "QuestionList.h"

@implementation NextQuestionHelp


//method that returns a new uiviewcontroller initialized depending on what type of question is to be displayed
+(UIViewController*) getNextQuestionViewController: (NSString*)nextQuestionType withStoryBoard:(UIStoryboard*) storyboard
{
    UIViewController *displayQuestion;
    
    if ([nextQuestionType isEqualToString:[[KeyList sharedInstance] shortAnswerQuestionTypeTemplateKey]]){
        
        displayQuestion = [storyboard instantiateViewControllerWithIdentifier:@"DisplayShortAnswerQuestion"];
        
    }else if ([nextQuestionType isEqualToString:[[KeyList sharedInstance] trueFalseQuestionTypeTemplateKey]]){
        
        
        displayQuestion = [storyboard instantiateViewControllerWithIdentifier:@"DisplayTrueFalseQuestion"];
        
    }else if ([nextQuestionType isEqualToString:[[KeyList sharedInstance] multipleChoiceQuestionTypeTemplateKey]]){
        
        
        displayQuestion = [storyboard instantiateViewControllerWithIdentifier:@"DisplayMultipleChoiceQuestion"];
        
        
    }else if ([nextQuestionType isEqualToString:[[KeyList sharedInstance] tableQuestionTypeTemplateKey]]){
        
        displayQuestion = [storyboard instantiateViewControllerWithIdentifier:@"twoDimensionalTableTest"];
    }

    return displayQuestion;
}

+(NSString*) getNextSegueName
{
    NSString *firstQuestionType = [[[[QuestionList sharedInstance] questionList] objectAtIndex:[[QuestionList sharedInstance] nextQuestionID].intValue] objectForKey:[[KeyList sharedInstance] answerTypeTemplateKey]];
    
    if ([firstQuestionType isEqualToString:[[KeyList sharedInstance] shortAnswerQuestionTypeTemplateKey]]){
        
        return @"ShortAnswer";
        
    }else if ([firstQuestionType isEqualToString:[[KeyList sharedInstance] trueFalseQuestionTypeTemplateKey]]){
        
        return @"TrueFalse";
        
    }else if ([firstQuestionType isEqualToString:[[KeyList sharedInstance] multipleChoiceQuestionTypeTemplateKey]]){
        
        return @"MultipleChoice";
        
    }else if ([firstQuestionType isEqualToString:[[KeyList sharedInstance] tableQuestionTypeTemplateKey]]){
        
        return @"twoDimensionalTableTest";
        
    }

    return NULL;
}
@end
