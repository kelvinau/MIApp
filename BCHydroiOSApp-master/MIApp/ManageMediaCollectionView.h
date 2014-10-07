//
//  ManageMediaCollectionView.h
//  MIApp
//
//  Created by Gursimran Singh on 12/31/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKNumberBadgeView.h"

@interface ManageMediaCollectionView : UICollectionViewController <UIActionSheetDelegate>

@property (nonatomic, strong) NSNumber* currentQuestion;
@property (retain) IBOutlet MKNumberBadgeView* mediaBadge;

@end
