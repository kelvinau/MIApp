//
//  CheckCompletedMITable.h
//  MIApp
//
//  Created by Gursimran Singh on 1/12/2014.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckCompletedMITable : UITableViewController <UIAlertViewDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) IBOutlet UILabel* modLabel;
@property (nonatomic, strong) UIPopoverController* popOver;
@end
