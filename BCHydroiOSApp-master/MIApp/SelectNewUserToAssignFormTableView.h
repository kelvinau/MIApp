//
//  SelectNewUserToAssignFormTableView.h
//  MIApp
//
//  Created by Gursimran Singh on 2014-03-05.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckCompletedMITable.h"

@interface SelectNewUserToAssignFormTableView : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) IBOutlet UISearchBar *userNameSearchBar;

@property (strong, nonatomic) UIPopoverController *popOver;

@property (strong, nonatomic) NSString* folderPath;
@property (strong, nonatomic) NSString* formName;
@property BOOL inSearchMode;
@end
