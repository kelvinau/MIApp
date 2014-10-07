//
//  EngineerComments.m
//  MIApp
//
//  Created by Gursimran Singh on 1/21/2014.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "ForemanComments.h"
#import "QuestionList.h"
#import "UploadForm.h"
#import "KeyList.h"

@implementation ForemanComments

@synthesize commentTextFiled;

-(void) viewDidLoad{
    [super viewDidLoad];
    
    self.title = @"Add Comment";
    
    //draw box around comment box
    [commentTextFiled.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [commentTextFiled.layer setBorderWidth:1.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    commentTextFiled.layer.cornerRadius = 5;
    commentTextFiled.clipsToBounds = YES;
    
    self.commentTextFiled.contentInset = UIEdgeInsetsMake(-66.0,1.0,0,0.0); // set value as per your requirement.

    //add submit button
    UIBarButtonItem* submitButton = [[UIBarButtonItem alloc] initWithTitle:@"Submit" style:UIBarButtonItemStyleDone target:self action:@selector(submitForm:)];
    
    self.navigationItem.rightBarButtonItem = submitButton;
}

//called when user wants to submit form
-(void) submitForm: (id) sender
{
    //save the comment
    [self saveComment];

    //create upload form object
    UploadForm* uploadForm = [[UploadForm alloc] init];
    uploadForm.parentNavigation = [self navigationController];
    
    //perform uplaod
    BOOL success = [uploadForm uploadForm];
    
    //display message
    if (success) {
        [self showSuccessAlert];
    }else{
        [self showErrorAlert];
    }
}


//show error message
-(void) showErrorAlert
{
    UIAlertView* alertView;
    alertView = [[UIAlertView alloc] initWithTitle:@"Upload Failed" message:@"The form could not be uploaded successfully. Please make sure you have a valid internet connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}


//show success message
-(void) showSuccessAlert
{
    UIAlertView* alertView;
    alertView = [[UIAlertView alloc] initWithTitle:@"Form Uploaded" message:@"The form was uploaded successfully." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}


//pop back after dismissing successful upload message
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
}


//save comment
-(void) saveComment
{
    

    NSMutableDictionary* tempMITemplate = [[QuestionList sharedInstance] entireMITemplate];
    NSMutableDictionary* commentData = [[NSMutableDictionary alloc] init];
    
    //save comment, foreman username
    [commentData setObject:commentTextFiled.text forKey:[[KeyList sharedInstance] foremanCommentTemplateKey]];
    [commentData setObject:[[QuestionList sharedInstance] username] forKey:[[KeyList sharedInstance] foremanUserTemplateKey]];
    [tempMITemplate setObject:commentData forKey:[[KeyList sharedInstance] foremanTemplateKey]];

    //save upload date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM d, yyyy";
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
    [dateFormatter setTimeZone:gmt];
    NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
    [tempMITemplate setObject:timeStamp forKey:[[KeyList sharedInstance] submittedDateKey]];
    
    
    //replace template with this new one
    [[QuestionList sharedInstance] setEntireMITemplate:tempMITemplate];
}


@end
