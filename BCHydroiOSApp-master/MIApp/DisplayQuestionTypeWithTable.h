//
//  DisplayQuestionTypeWithTable.h
//  MIApp
//
//  Created by Gursimran Singh on 12/29/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import "DisplayQuestionType.h"

@interface DisplayQuestionTypeWithTable : DisplayQuestionType

@property (strong, nonatomic) IBOutlet UILabel *noAnswerSelectedLabel;
@property (strong, nonatomic) NSMutableArray* selectedAnswersInTable;
@property (strong, nonatomic) IBOutlet UITableView *answerOptionTable;

@end
