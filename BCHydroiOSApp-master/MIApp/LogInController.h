//
//  LogInController.h
//  MIApp
//
//  Created by Gursimran Singh on 12/11/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogInController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *usernameTextField;

@property (strong, nonatomic) IBOutlet UIButton *logInButton;
@property (strong, nonatomic) IBOutlet UITextField *passwordTextField;


- (IBAction)logInButtonPressed:(id)sender;

@end
