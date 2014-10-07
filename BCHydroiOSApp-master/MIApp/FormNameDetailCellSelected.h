//
//  FormNameDetailCellSelected.h
//  MIApp
//
//  Created by Gursimran Singh on 2014-03-15.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormNameDetailCellSelected : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) IBOutlet UILabel *disciplineLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastModifiedLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *equipmentLabel;
@property (strong, nonatomic) IBOutlet UILabel *instructionNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *issueDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *supersedesLabel;
@property (strong, nonatomic) IBOutlet UILabel *fileNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *referencesLabel;
@property (strong, nonatomic) IBOutlet UILabel *preparedByLabel;
@property (strong, nonatomic) IBOutlet UILabel *titlePreparedLabel;
@property (strong, nonatomic) IBOutlet UILabel *acceptedByLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleAcceptedLabel;
@property (strong, nonatomic) IBOutlet UILabel *eorLabel;
@property (strong, nonatomic) IBOutlet UITextView *revisionTextView;
@property (strong, nonatomic) IBOutlet UILabel *revisedByLabel;
@property (strong, nonatomic) IBOutlet UILabel *revisionDateLabel;
@property (strong, nonatomic) IBOutlet UIButton *openFormButton;

@end