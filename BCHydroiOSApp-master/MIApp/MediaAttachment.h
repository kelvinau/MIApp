//
//  MediaAttachment.h
//  MIApp
//
//  Created by Gursimran Singh on 2014-02-25.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKNumberBadgeView.h"
#import "DisplayQuestionType.h"

@interface MediaAttachment : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPopoverControllerDelegate>

-(UIBarButtonItem*) setUpButtonAtOrigin:(CGPoint) origin;
@property (retain) IBOutlet MKNumberBadgeView* mediaBadge;
-(id) initWithId: (NSNumber*) num forView: (DisplayQuestionType*) view;

@property NSNumber* number;
@property (nonatomic, strong) UIPopoverController *popOver;
-(void) updateMediaBadge;
//-(CGFloat) getBottomDistanceOfButton;
@end
