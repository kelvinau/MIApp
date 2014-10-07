//
//  UploadForm.m
//  MIApp
//
//  Created by Gursimran Singh on 2/3/2014.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "UploadForm.h"
#import "QuestionList.h"
#import "KeyList.h"

@implementation UploadForm
{
    NSString* completedJson;
    UIActivityIndicatorView *loadingWhileUpload;
    UIAlertView* alertView;
    BOOL success;
    BOOL complete;
}


@synthesize parentNavigation;


//initialize
-(id)init
{
    if (self = [super init]) {
        loadingWhileUpload = [[UIActivityIndicatorView alloc] init];
        alertView = [[UIAlertView alloc] init];
        success = NO;
        complete = NO;
    }
    return  self;
}


//upload form
-(BOOL) uploadForm
{
    //display uploading aletr view while data is being uploaded
    [self displayAlertForUploading];
    
    //do actual upload
    [self performSelectorInBackground:@selector(setupAndPostForm) withObject:nil];
    
    //wait till data is uploaded in background thread
    while (complete == NO) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];

    }
    
    //return
    return success;
}



-(void) setupAndPostForm
{
    
    //setup json with base64 endoded media
    [self setupJSON];
    
    //post form
    [self postForm];
}


//converts nsdictionary to json and adds all media in base64 encoded form to the json
-(void) setupJSON
{
    
    //get mi template
    NSMutableDictionary* tempEntireMI = [[QuestionList sharedInstance] entireMITemplate];
    [tempEntireMI setValue:[[QuestionList sharedInstance]questionList] forKey:[[KeyList sharedInstance] listOfQuestionsTemplateKey]];
    [[QuestionList sharedInstance] setEntireMITemplate:tempEntireMI];
    
    //remove 'id' object
    [tempEntireMI removeObjectForKey:[[KeyList sharedInstance] idTemplateKey]];
    
    NSError *error;
    
    //set media
    [tempEntireMI setValue:[self getMediaData] forKey:[[KeyList sharedInstance] mediaToBeSavedTemplateKey]];
    
    
    //convert to json
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:tempEntireMI
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    //convert json to string
    NSString *completeMIWithForm = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    completedJson = completeMIWithForm;
}



//perform actual upload
-(void) postForm
{
    
    //get url from components saved in info.plist
    NSString *baseUrl = [[KeyList sharedInstance] baseUrlKey];
    NSString *portUrl = [[KeyList sharedInstance] portUrlKey];
    NSString *uploadMIPage = [[KeyList sharedInstance] uploadMiUrlKey];
    
    NSString *formURL = [NSString stringWithFormat:@"%@:%@/%@",baseUrl, portUrl, uploadMIPage];

    //create a new request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]
                                    initWithURL:[NSURL
                                                 URLWithString:formURL]];
    
    
    
    //convert string to upload to nsdata
    NSData *postData = [completedJson dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    //set request properties
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"content-type"];
    
    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/31.0.1650.57 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    
    [request setHTTPBody: postData];
    
    [request setValue:[NSString stringWithFormat:@"%lu",
                       [postData length]]
     
   forHTTPHeaderField:@"Content-length"];

    
    //create a new response
    NSURLResponse* response = [[NSURLResponse alloc] init];
    
    NSError* error;
    
    //upload
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    //check response received
    [self checkResponse:response];
    
    complete = YES;
}


//returns a dictionary of all media in base 64
-(NSDictionary*) getMediaData
{
    NSMutableDictionary* data = [[NSMutableDictionary alloc] init];
    [data setValue:[self getDictionaryForMediaType:@".jpg"] forKey:[[KeyList sharedInstance] imagesToBeSavedTemplateKey]];
    [data setValue:[self getDictionaryForMediaType:@".mov"] forKey:[[KeyList sharedInstance] videosToBeSavedTemplateKey]];
    [data setValue:[self getDictionaryForMediaType:@".m4a"] forKey:[[KeyList sharedInstance] voiceToBeSavedTemplateKey]];
    
    return data;
}

//dictionary of media for type
-(NSDictionary*) getDictionaryForMediaType: (NSString*) type
{
    //get list of media of type
    NSArray* mediaFiles = [self getfile:type];
    
    //folder path for this completed MI
    NSString* folderPath = [[QuestionList sharedInstance] completedFilePathToBeUploaded];
    NSMutableDictionary* mediaTypeData = [[NSMutableDictionary alloc] init];
    
    //add every media to dictionary
    //value is base 64 data of media and key is name of file without extension
    for (NSString* file in mediaFiles) {
        [mediaTypeData setValue:[self getDataForFile:[folderPath stringByAppendingPathComponent:file]] forKey:[file substringWithRange:NSMakeRange(0, [file length] - 4)]];
    }
    
    return mediaTypeData;
}


//return list of files of type
-(NSArray*) getfile:(NSString*) ofType
{
    NSString *folderPath = [[QuestionList sharedInstance] completedFilePathToBeUploaded];
    NSArray* listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", ofType];
    return [listOfFiles filteredArrayUsingPredicate:predicate];
}


//return the data for file
-(NSString*) getDataForFile:(NSString*) mediaFile
{
    NSString* type = [self getMediaType:mediaFile];
    if ([type isEqualToString:@"image"]) {
        return [self getImageData:mediaFile];
    }else if ([type isEqualToString:@"movie"]) {
        return [self getVideoData:mediaFile];
    }else if ([type isEqualToString:@"voice"]) {
        return [self getSoundData:mediaFile];
    }
    return nil;
}

//returns base 64 encoded string of video
-(NSString*) getVideoData:(NSString*) videoFile
{
    NSData *videoData = [NSData dataWithContentsOfFile:videoFile];
    NSString *base64String = [videoData base64EncodedStringWithOptions:0];
    
    return base64String;
}

//returns base 64 encoded string of audio
-(NSString*) getSoundData:(NSString*) soundFile
{
    
    NSData *soundData = [NSData dataWithContentsOfFile:soundFile];
    NSString *base64String = [soundData base64EncodedStringWithOptions:0];
    
    return base64String;
}


//returns base 64 encoded string of image
-(NSString*) getImageData:(NSString*) imageFile
{
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageWithContentsOfFile:imageFile], .5);
    NSString *base64String = [imageData base64EncodedStringWithOptions:0];
    return base64String;
}


//returns the type of media depending on file extension
-(NSString*) getMediaType:(NSString*) mediaFile
{
    if (!([mediaFile rangeOfString:@".jpg"].location == NSNotFound)) {
        return @"image";
    }else if (!([mediaFile rangeOfString:@".mov"].location == NSNotFound)) {
        return @"movie";
    }else if (!([mediaFile rangeOfString:@".m4a"].location == NSNotFound)) {
        return @"voice";
    }
    return nil;
}

//message displayed while uploading is taking place
//prevents the user from using the app
-(void) displayAlertForUploading
{
    
    //alert view to be displayed
    alertView = [[UIAlertView alloc] initWithTitle:@"Uploading form..." message:@"Please wait while the form is being uploaded." delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [loadingWhileUpload setFrame:CGRectMake(0, 0, 25, 25)];
    [alertView setValue:loadingWhileUpload forKey:@"accessoryView"];
    [loadingWhileUpload setColor:[UIColor grayColor]];
    [loadingWhileUpload startAnimating];
    [alertView show];
    
}


//check response receieved from upload
-(void) checkResponse:(NSURLResponse*) response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    NSInteger code = [httpResponse statusCode];
    NSLog(@"%lu", (long)code);
    //if code is 200 then delete copy and display success
    if (code == 200) {
        [self deleteLocalCompletedCopy];
        success = YES;
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
    //else display error message
    else{
        success = NO;
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    }

}


//delete all file associated with this MI after it has been uploaded
-(void) deleteLocalCompletedCopy
{
    NSString* folderPath = [[QuestionList sharedInstance] completedFilePathToBeUploaded];
    NSArray* listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    for (NSString* file in listOfFiles) {
        NSString* filePath = [folderPath stringByAppendingPathComponent:file];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    [[NSFileManager defaultManager] removeItemAtPath:folderPath error:nil];
}

@end
