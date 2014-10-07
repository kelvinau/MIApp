//
//  AddRemoveNotifications.h
//  MIApp
//
//  Created by Gursimran Singh on 2014-03-19.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddRemoveNotifications : NSObject

+(void) removeNotificationsForForm:(NSString*) formName byUser:(NSString*)user;
+(void) setUpNotificationForNewForm;

@end
