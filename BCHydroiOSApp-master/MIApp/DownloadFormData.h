//
//  DownloadFormData.h
//  MIApp
//
//  Created by Gursimran Singh on 2/6/2014.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormList.h"

@interface DownloadFormData : NSObject

+(FormList*) downloadFormList;
+(NSString*) openIncompleteForm: (NSString*) fileName;
+(NSString*) openNewForm : (NSString*) fileName WithIncompleteList:(NSArray*) fileListOfIncompleteForms withFormList:(FormList*) formList selectedForm: (int) formSelectedByUser;

@end
