//
//  LogInController.m
//  MIApp
//
//  Created by Gursimran Singh on 12/11/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//
//  View to let the user log in using LDAP

#import "LogInController.h"
#import "QuestionList.h"
#include <Foundation/Foundation.h>
#include <stdio.h>
#include "PerformLdapAuthentication.h"




@implementation LogInController
{
    UIAlertView* loginAlertView;
}

@synthesize logInButton, usernameTextField, passwordTextField;

//Login method for when user presses login button on screen
- (IBAction)logInButtonPressed:(id)sender {
    
    [self startLogin];

}


//Set up view for the first time it is displayed
-(void) viewDidLoad
{
  
    [super viewDidLoad];

    [self setTitle:@"Welcome to BCHydro Maintenance Instruction App"];
    [[self usernameTextField] becomeFirstResponder];
    
    UIImageView* background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [background setImage:[UIImage imageNamed:@"Untitled-1"]];
    
    [self.view insertSubview:background belowSubview:logInButton];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

//Set up view for when displayed again
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


//Method called when user presses enter/next in a text field
//password field is selected when pressed from username field
//login started when pressed from password field
-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger currentTag = textField.tag;
    NSInteger nextTag = currentTag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
    } else {
        // start login no more fields to go to
        [self startLogin];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

// Method to set up login
-(void) startLogin
{
    
    //For logging in, first a loading dialog is displayed while user is authenticated.
    [self displayLoginLoading];
    
    // Alert view takes time to be displayed so the login is performed after a 1 second delay.
    [self performSelector:@selector(performLogin) withObject:nil afterDelay:1];
}


//Actual method where user is validated
-(void) performLogin
{
    //Read user details from screen like username and pasword
    [self getUserDetails];
    
    // get message from after login server
    NSString* message = [PerformLdapAuthentication performLDAP];
    
    //Check what type of user logs in (technician or foreman/engineer)
    [self performUserCheckWithMessage:message];
}






//Display loading wheel while authentication in progress
-(void) displayLoginLoading
{
    loginAlertView = [[UIAlertView alloc] initWithTitle:@"Please Wait" message:@"" delegate:self cancelButtonTitle:Nil otherButtonTitles: nil];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 20)];
    UIActivityIndicatorView* loading = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    [loading setColor:[UIColor blackColor]];
    UILabel* message = [[UILabel alloc] initWithFrame:CGRectMake(20, -5, 100, 20)];
    message.text = @"Logging in...";
    [loading startAnimating];
    [view addSubview:loading];
    [view addSubview:message];
    [loginAlertView setValue:view forKey:@"accessoryView"];
    [loginAlertView show];
}

//Get user enter detials
-(void) getUserDetails
{
    [self getUsername];
    [self getPassword];
}

//Read password
-(void) getPassword
{
    NSString* password = [[self passwordTextField] text];
    [[QuestionList sharedInstance] setPassword:password];
    
}

//Read username
-(void) getUsername
{
    NSString* username = [[self usernameTextField] text];
    [[QuestionList sharedInstance] setUsername:username];
}


//Display error message or let user in as their role is supported
-(void)performUserCheckWithMessage:(NSString*) message
{

    if ([message isEqualToString:@"failed"]) {
        [self displayFailMessageWithMessage:@"Please try again."];
        return;
    }else if (([message length] > 0) && ((!([message rangeOfString:@"Invalid credentials"].location == NSNotFound)) || (!([message rangeOfString:@"Invalid DN syntax"].location == NSNotFound)))){
        [self displayFailMessageWithMessage:@"Invalid credentials. Please try again."];
        return;
    }else if([message isEqualToString:@"Can't contact LDAP server"]){
        [self displayFailMessageWithMessage:@"Could not connect to server for authentication."];
        return;
    }
    
    
    //Engineer and technician get the same view (they cannot upload forms) unless the engineer is also a foreman
    if ([message rangeOfString:@"cn:foreman"].location == NSNotFound) {
        if ([message rangeOfString:@"cn:engineer"].location == NSNotFound) {
            if ([message rangeOfString:@"cn:technician"].location == NSNotFound) {
                [self displayFailMessageWithMessage:@"This user is not authorized to use this app. Please try a different login."];
            }else{
                [self performSelector:@selector(letUserInAsTechnician:) withObject:[NSNumber numberWithInt:0] afterDelay:.2];
            }
        }else{
            [self performSelector:@selector(letUserInAsTechnician:) withObject:[NSNumber numberWithInt:0] afterDelay:.2];
        }
    }else{
        [self performSelector:@selector(letUserInAsTechnician:) withObject:[NSNumber numberWithInt:1] afterDelay:.2];
    }
}


//Perform view change and set up user folder
-(void)letUserInAsTechnician:(NSNumber*) technician
{
    [loginAlertView dismissWithClickedButtonIndex:0 animated:YES];
    [self createUserFolder];
    
    //Clear login fields
    [[self usernameTextField] setText:@""];
    [[self passwordTextField] setText:@""];
    [usernameTextField becomeFirstResponder];
    
    if (technician.intValue == 0) {
        [[QuestionList sharedInstance] setEngineerView:NO];
        [self performSegueWithIdentifier:@"Technician" sender:self];
    }else if(technician.intValue == 1){
        [[QuestionList sharedInstance] setEngineerView:YES];
        [self performSegueWithIdentifier:@"Engineer" sender:self];
    }
    
}



//Display message if failed authentication
-(void) displayFailMessageWithMessage:(NSString*) message
{
    UIAlertView *newALert = loginAlertView;
    loginAlertView = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [loginAlertView show];
    [newALert dismissWithClickedButtonIndex:0 animated:YES];
}


//Create a folder for the user logged in and save the path 
-(void) createUserFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:[[QuestionList sharedInstance] username]];
    [[QuestionList sharedInstance] setUserPath:dataPath];
    [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
}


@end
