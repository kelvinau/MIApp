//
//  QuestionList.m
//  MIApp
//
//  Created by Gursimran Singh on 11/12/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import "QuestionList.h"
#import "KeyList.h"

@implementation QuestionList


@synthesize  nextQuestionID, fileNameToBeSavedAs, username, completedPath, engineerView, userPath, completedFilePathToBeUploaded, password, engineerNewMI, completedFileNameToBeUploaded;


//get global instance
//if instance exists, return that else init and return
+ (QuestionList *)sharedInstance
{
    // the instance of this class is stored here
    static QuestionList *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance) {
        myInstance  = [[[self class] alloc] init];
        // initialize variables here
    }
    // return the instance of this class
    return myInstance;
}


//initialize a questionlist object
-(id)init
{
    if (self = [super init]) {
        [self setCompletedMIPath];
        [self setEngineerView:NO];
        [self setEngineerNewMI:NO];
    }
    return  self;
}


//save just answers to temporary file
-(void) setJustAnswers: (NSMutableDictionary*) justAnswers
{
    NSString* fileLocation = [NSTemporaryDirectory() stringByAppendingString:@"justAnswers"];
    [NSKeyedArchiver archiveRootObject:justAnswers toFile:fileLocation];
}

//get answers from temporary file
-(NSMutableDictionary*) justAnswers
{
    NSString* fileLocation = [NSTemporaryDirectory() stringByAppendingString:@"justAnswers"];
    NSData *data = [NSData dataWithContentsOfFile:fileLocation];
    NSMutableDictionary* temp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return temp;
}


//save entire form to temporary file
-(void) setEntireMITemplate: (NSMutableDictionary*) entireMITemplate
{
    NSString* fileLocation = [NSTemporaryDirectory() stringByAppendingString:@"entireMITemplate"];
    [NSKeyedArchiver archiveRootObject:entireMITemplate toFile:fileLocation];
}

//get entire form from temporary file
-(NSMutableDictionary*) entireMITemplate
{
    NSString* fileLocation = [NSTemporaryDirectory() stringByAppendingString:@"entireMITemplate"];
    NSData *data = [NSData dataWithContentsOfFile:fileLocation];
    NSMutableDictionary* temp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return temp;
}

//save question list to temporary file
-(void) setQuestionList: (NSMutableArray*) questionList
{
    NSString* fileLocation = [NSTemporaryDirectory() stringByAppendingString:@"questionList"];
    [NSKeyedArchiver archiveRootObject:questionList toFile:fileLocation];
}

//get question list from temporary file
-(NSMutableArray*) questionList
{
    NSString* fileLocation = [NSTemporaryDirectory() stringByAppendingString:@"questionList"];
    NSData *data = [NSData dataWithContentsOfFile:fileLocation];
    NSMutableArray* temp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return temp;
}


//get completed folder path
-(void) setCompletedMIPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [[documentsDirectory stringByAppendingPathComponent:[[KeyList sharedInstance] completedMiFolderName]] stringByAppendingString:@"/"];
    [self setCompletedPath:dataPath];
}


//free memory
-(void) freeMemory
{
    [self setNextQuestionID:Nil];
    [self setFileNameToBeSavedAs:Nil];
}


@end