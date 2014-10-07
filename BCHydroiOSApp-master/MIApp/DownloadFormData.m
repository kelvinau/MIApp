//
//  DownloadFormData.m
//  MIApp
//
//  Created by Gursimran Singh on 2/6/2014.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "DownloadFormData.h"
#import "Reachability.h"
#import "QuestionList.h"
#import "KeyList.h"
#import "AddRemoveNotifications.h"

@implementation DownloadFormData


//Download form list
+(FormList*) downloadFormList
{
    FormList* formlist;
    
    //Check for network, if user is not connected then display a message else download the json feed
    
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    if(internetStatus == NotReachable) {
        [self displayErrorAlertViewWithTitle:@"Network Error" message:@"No internet connection found, this application requires an internet connection to gather the data required."  cancelButtonTitle:@"Close"];
    }
    else{
        
        //perform download
        formlist = [self performDownloadFormList];
    }
    
    return formlist;
}


//Display alert with title, message, cancel button title
+(void) displayErrorAlertViewWithTitle:(NSString*) title message:(NSString*) message cancelButtonTitle:(NSString*) cancel
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:nil];
    [alertView show];
}


//Visit the URL and get the json
//If JSON does exist then parse and return different forms
//and versions in FormList object
+(FormList*)performDownloadFormList{
    
    FormList* formlist = [[FormList alloc] init];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    
    NSData* responseData;
    NSArray* allFormsInJson;
    
    @try
    {
        
        //generate url from keys saved in info.plist
        NSString *baseUrl = [[KeyList sharedInstance] baseUrlKey];
        NSString *portUrl = [[KeyList sharedInstance] portUrlKey];
        NSString *templateNamePage = [[KeyList sharedInstance] getTemplateListUrlKey];
        
        NSString *formURL = [NSString stringWithFormat:@"%@:%@/%@",baseUrl, portUrl, templateNamePage];
        
        responseData = [NSData dataWithContentsOfURL:
                        [[NSURL alloc] initWithString:formURL]];
        
        //parse out the json data
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData //1
                              
                              options:kNilOptions
                              error:&error];
        
        allFormsInJson = [[json objectEnumerator] allObjects]; //2
        
        //check if json had any form
        //throw exception if there is none
        if (!([allFormsInJson count] > 0)) {
            [NSException raise:@"Invalid foo value" format:@"foo of %d is invalid", 1];
        }
    }
    @catch(NSException* ex)
    {
        [self displayErrorAlertViewWithTitle:@"Could not get forms" message:@"Failed to download forms, please make sure you a valid internet connection." cancelButtonTitle:@"OK"];
        
        return NULL;
    }
    
    [formlist setFormList:allFormsInJson];
    
    return formlist;
}


//open an incomplete form
//returns teh type of first question
//loads the form in instance of QuestionList
+(NSString*) openIncompleteForm: (NSString*) fileName
{
    
    [self getContentsOfFile: fileName];
    [QuestionList sharedInstance].fileNameToBeSavedAs = fileName;
    NSString* firstQuestionType = [[[[QuestionList sharedInstance] questionList] objectAtIndex:0] objectForKey:[[KeyList sharedInstance] answerTypeTemplateKey]];
    QuestionList.sharedInstance.nextQuestionID = [[NSNumber alloc] initWithInt:0];
    return firstQuestionType;
}


//reads the contents of file for the incomplete form to ope
+(void) getContentsOfFile:(NSString*)fileName
{
    NSString *userDirectory = [[QuestionList sharedInstance] userPath];
    NSString *filePath = [[[userDirectory stringByAppendingPathComponent:fileName] stringByAppendingString:@"/"] stringByAppendingString:fileName];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    [self fetchedQuestionJson:data from:YES];
}


//extract form from nsdata
//json conversation is different if converting from file or downloaded from internet
+ (void)fetchedQuestionJson:(NSData *)responseData from:(Boolean)file{
    //parse out the json data
    NSError* error;
    NSDictionary* json;
    
    
    //cnvert nsdata to json
    if (file){
        json = [NSKeyedUnarchiver unarchiveObjectWithData:responseData];
    }
    else{
        json = [NSJSONSerialization
                JSONObjectWithData:responseData //1
                
                options:kNilOptions
                error:&error];
    }
    
    NSMutableDictionary* tempEntireMI = [[NSMutableDictionary alloc] init];
    NSMutableArray* tempQuestionList = [[NSMutableArray alloc] init];
    
    
    //Save all data from json to QuestionList variables
    NSString *key;
    for (key in json){
        [tempEntireMI setValue:[json objectForKey:key] forKey:key];
    }
    
    //set username
    [tempEntireMI setValue:[[QuestionList sharedInstance] username] forKey:[[KeyList sharedInstance] userNameToBeSavedTemplateKey]];
    
    
    NSArray* allQuestions = [json objectForKey:[[KeyList sharedInstance] listOfQuestionsTemplateKey]];
    for (int i=0; i < [allQuestions count]; i++) {
        [tempQuestionList addObject:[allQuestions objectAtIndex:i]];
    }
    
    [[QuestionList sharedInstance] setEntireMITemplate:tempEntireMI];
    [[QuestionList sharedInstance] setQuestionList:tempQuestionList];
    
}


//Download new form pressed by user
+(NSString* ) openNewForm : (NSString*) fileName WithIncompleteList:(NSArray*) fileListOfIncompleteForms withFormList:(FormList*) formList selectedForm: (int) formSelectedByUser
{
    
    //get first question type
    NSString* firstQuestionType = [self ViewFormButtonPressed:formList selectedForm:formSelectedByUser];
    
    if (firstQuestionType == NULL) {
        return NULL;
    }
    
    //get filename to save as for this form
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MM-yyyy";
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    [QuestionList sharedInstance].fileNameToBeSavedAs = [NSString stringWithFormat:@"%@ %@", fileName, timeStamp];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.%@ ==[c] %@", [[KeyList sharedInstance] titleTemplateKey], [[QuestionList sharedInstance] fileNameToBeSavedAs]];
    NSArray* filteredFormArray = [fileListOfIncompleteForms filteredArrayUsingPredicate:predicate];
    int nextNumber = 2;
    while ([filteredFormArray count] > 0) {
        [QuestionList sharedInstance].fileNameToBeSavedAs = [NSString stringWithFormat:@"%@ %@ (%d)", fileName, timeStamp, nextNumber];
        nextNumber++;
        predicate = [NSPredicate predicateWithFormat:@"SELF.%@ ==[c] %@", [[KeyList sharedInstance] titleTemplateKey], [[QuestionList sharedInstance] fileNameToBeSavedAs]];
        filteredFormArray = [fileListOfIncompleteForms filteredArrayUsingPredicate:predicate];
    }
    
    
    //set up notifications
    [AddRemoveNotifications setUpNotificationForNewForm];
    
    //create folder for this form to save all data in
    NSString *dataPath = [[[QuestionList sharedInstance] userPath] stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]];
    [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    
    return firstQuestionType;
}


//Download form and get first question type. Exception is thrown if first question type is not valid
+ (NSString*) ViewFormButtonPressed :(FormList*) formList selectedForm:(int)formSelectedByUser{
    NSString *firstQuestionType;
    @try
    {
        //perform actual download
        [self DownloadQuestionJson:formList selectedForm:formSelectedByUser];
        
        firstQuestionType = [[[[QuestionList sharedInstance] questionList] objectAtIndex:0] objectForKey:[[KeyList sharedInstance] answerTypeTemplateKey]];
        QuestionList.sharedInstance.nextQuestionID = [[NSNumber alloc] initWithInt:0];
    }
    @catch(NSException* ex)
    {
        
        [self displayErrorAlertViewWithTitle:@"Could not get form" message:@"Failed to download form, please make sure you a valid internet connection." cancelButtonTitle:@"OK"];
        
        return NULL;
    }
    
    return firstQuestionType;
}


//Download form
+(void) DownloadQuestionJson:(FormList*) formList selectedForm:(int)formSelectedByUser{
    //Create form url from teh selected choice
    NSString* titleOfForm = [formList getNameAtPosition:formSelectedByUser];
    NSString *baseUrl = [[KeyList sharedInstance] baseUrlKey];
    NSString *portUrl = [[KeyList sharedInstance] portUrlKey];
    NSString *templateDownloadPage = [[KeyList sharedInstance] getTemplateByNameUrlKey];
        
    NSString* urlToVisit = [[NSString stringWithFormat:@"%@:%@/%@/%@",baseUrl, portUrl, templateDownloadPage, titleOfForm] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
    //get json of questions
    NSData* data = [NSData dataWithContentsOfURL:
                    [[NSURL alloc] initWithString:urlToVisit]];
    
    //extract data
    [self fetchedQuestionJson:data from:NO];
}


@end
