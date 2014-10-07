//
//  ReviewAnswersTable.h
//  MIApp
//
//  Created by Gursimran Singh on 11/15/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReviewAnswersTable : UITableViewController <UIPrintInteractionControllerDelegate>

- (IBAction)DoneButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneButton;

@end
