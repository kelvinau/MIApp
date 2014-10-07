//
//  AddRemoveNotifications.m
//  MIApp
//
//  Created by Gursimran Singh on 2014-03-19.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "AddRemoveNotifications.h"
#import "QuestionList.h"
#import "KeyList.h"

@implementation AddRemoveNotifications

//remove notifications for user and form name
+(void) removeNotificationsForForm:(NSString*) formName byUser:(NSString*)user
{
    
    NSMutableArray* notificationsToDelete = [[NSMutableArray alloc] init];
    
    //loop through all notifications for app
    for (UILocalNotification* notification in [[UIApplication sharedApplication] scheduledLocalNotifications]) {
        NSDictionary* infoDict = notification.userInfo;
        
        //check if notification matches search criteria
        if ([[infoDict objectForKey:@"user"] isEqualToString:user] && [[infoDict objectForKey:@"name"] isEqualToString:formName]) {
        
            //add notification to deleet array
            [notificationsToDelete addObject:notification];
        }
    }
    
    //loop through delete array and delete notifications
    for (UILocalNotification* notificationToDelete in notificationsToDelete) {
        [[UIApplication sharedApplication] cancelLocalNotification:notificationToDelete];
    }
}


//setup notifications for new form
+(void) setUpNotificationForNewForm
{
    
    //iterate through all days for which notification needs to be set
    for (NSNumber* day in [[KeyList sharedInstance] sendNotificationAfterDays]) {
        
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        
        //get current date
        NSDate* pickerDate = [NSDate date];
        
        //calculate after how long the notification should appear
        NSDateComponents *dateAddComponents = [[NSDateComponents alloc] init];
        [dateAddComponents setDay:day.intValue];
        [dateAddComponents setHour:(int)(([day floatValue] - [day intValue]) * 24)];
        [dateAddComponents setMinute:(int)(([day floatValue] - [day intValue]) * 24 * 60)];
        [dateAddComponents setSecond:(int)(([day floatValue] - [day intValue]) * 24 * 60 * 60)];
        
        
        //add calculated time to current time to get notification time
        NSDate *itemDate = [calendar
                            dateByAddingComponents:dateAddComponents
                            toDate:pickerDate options:0];
        
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        
        if (localNotif == nil)
            return;
        
        //set notification details
        localNotif.fireDate = itemDate;
        localNotif.timeZone = [NSTimeZone defaultTimeZone];
        
        // Notification details
        localNotif.alertBody = [NSString stringWithFormat:@"Form: %@ \nBy: %@\nWill be deleted in %d day(s).", [[QuestionList sharedInstance] fileNameToBeSavedAs], [[QuestionList sharedInstance] username], [[KeyList sharedInstance] deleteIncompleteFormsAfterDays].intValue - day.intValue];
        
        // Set the action button
        localNotif.alertAction = @"View";
        
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.applicationIconBadgeNumber = 1;
        
        // Specify custom data for the notification
        
        NSMutableDictionary *infoDict = [[NSMutableDictionary alloc] init];
        [infoDict setValue:[[QuestionList sharedInstance]fileNameToBeSavedAs] forKey:@"name"];
        [infoDict setValue:[[QuestionList sharedInstance] username] forKey:@"user"];
        localNotif.userInfo = infoDict;
        
        // Schedule the notification
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
        
    }
}

@end
