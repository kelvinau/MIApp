//
//  FormSelectionViewController.h
//  MIApp
//
//  Created by Gursimran Singh on 2014-02-28.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormList.h"

@interface FormSelectionViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

@property (strong, nonatomic) FormList *formList;
@property (strong, nonatomic) IBOutlet UITableView *formSearchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *editButton;

- (IBAction)deleteIncompleteMIs:(id)sender;
@end
