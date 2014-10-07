//
//  UploadForm.h
//  MIApp
//
//  Created by Gursimran Singh on 2/3/2014.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadForm : NSObject <NSURLConnectionDataDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UINavigationController* parentNavigation;

-(id)init;
-(BOOL) uploadForm;

@end
