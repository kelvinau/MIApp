//
//  FormNameDetailCell.h
//  MIApp
//
//  Created by Gursimran Singh on 2014-02-28.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormNameDetailCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *versionLabel;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *instructionNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *equipmentLabel;
@property (strong, nonatomic) IBOutlet UILabel *disciplineLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastModifiedLabel;

@end
