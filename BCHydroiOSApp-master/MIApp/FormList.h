//
//  FormList.h
//  MIApp
//
//  Created by Gursimran Singh on 2013-10-19.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormList : NSObject {

}


//- (NSString*) formNameAt: (int)location;
//- (NSArray*) versionsForForm: (int)location;
//- (void) addForm:(NSString*) name version:(NSArray*) versionList;

- (NSString*) getNameById:(NSString*) formForId;
- (NSNumber*) getVersionById:(NSString *)versionForId;
- (NSUInteger) getFormCount;
- (void) sortFormsByName:(NSArray*) unsortedList;
- (void) setFormList: (NSArray*) formList;
- (NSString*) getNameAtPosition:(int)position;
- (NSNumber*) getVersionAtPosition:(int)position;
- (NSArray*) getFormList;
- (int) getPositionOfFormById:(NSString *)id;
- (NSDictionary*) getFormDetailsAtPosition:(int) position;
- (NSDictionary*) getFormDetailsById:(NSString*) formForId;
- (id) initFromTemporaryFile;

@end

