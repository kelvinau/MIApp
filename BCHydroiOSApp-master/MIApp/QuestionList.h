//
//  QuestionList.h
//  MIApp
//
//  Created by Gursimran Singh on 11/12/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestionList : NSObject

//@property (strong, nonatomic) NSMutableArray *questionList;
@property NSNumber *nextQuestionID;
//@property (strong, nonatomic) NSMutableDictionary *entireMITemplate;
//@property (strong, nonatomic) NSMutableDictionary *justAnswers;
@property (strong, nonatomic) NSArray* navigationStackAfterCompletingAllQuestions;
@property (strong, nonatomic) NSString* fileNameToBeSavedAs;
@property (strong, nonatomic) NSString* username;
@property (strong, nonatomic) NSString* completedPath;
@property (strong, nonatomic) NSString* password;
@property BOOL engineerView;
@property (strong, nonatomic) NSString* userPath;
@property (strong, nonatomic) NSString* completedFilePathToBeUploaded;
@property (strong, nonatomic) NSString* completedFileNameToBeUploaded;
@property BOOL engineerNewMI;

+ (QuestionList *)sharedInstance;

-(void) freeMemory;
//-(void) setJustAnswers: (NSMutableDictionary*) justAnswers;
//-(NSMutableDictionary*) justAnswers;
-(void) setEntireMITemplate: (NSMutableDictionary*) entireMITemplate;
-(NSMutableDictionary*) entireMITemplate;
-(void) setQuestionList: (NSMutableArray*) questionList;
-(NSMutableArray*) questionList;
-(void) setCompletedMIPath;

@end
