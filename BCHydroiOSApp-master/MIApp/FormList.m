//
//  FormList.m
//  MIApp
//
//  Created by Gursimran Singh on 2013-10-19.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//
//  Class that deals with form list

#import "FormList.h"
#import "KeyList.h"

@implementation FormList


//Create an object of FormList from temporary file (assumes temporary file already has data in it).
-(id) initFromTemporaryFile
{
    self = [super init];
    if(self){
        return self;
    }
    return nil; 
}


//Create an object of FormList from array
-(id) initWithFormList:(NSArray *) formList
{
    self = [super init];
    
    if(self){
        [self setNamesToFile:formList];
        return self;
    }
    return nil;
}

//Create empty FormList object
- (id) init
{
    self = [self initWithFormList:[[NSArray alloc]init ]];
    return self;
}


//Get form details by form id
- (NSDictionary*) getFormDetailsById:(NSString*) formForId
{
    NSArray* tempNames = [self getNamesFromFile];
    
    //iterate through all forms and find required one
    for(int i = 0; i < [tempNames count]; i++){
        NSString* formId = [[tempNames objectAtIndex:i] objectForKey:[[KeyList sharedInstance] idTemplateListKey]];
        if ([formId isEqualToString:formForId]){
            return [tempNames objectAtIndex:i];
        }
    }
    
    return NULL;
}

//Get name of form by ID
- (NSString*) getNameById:(NSString *)formForId
{
    NSArray* tempNames = [self getNamesFromFile];
    for(int i = 0; i < [tempNames count]; i++){
        NSString* formId = [[tempNames objectAtIndex:i] objectForKey:[[KeyList sharedInstance] idTemplateListKey]];
        if ([formId isEqualToString:formForId]){
            return [[tempNames objectAtIndex:i] objectForKey:[[KeyList sharedInstance] titleTemplateListKey]];
        }
    }
    return NULL;
}


//Get largest version of form by ID
- (NSNumber*) getVersionById:(NSString *)versionForId
{
    NSArray* tempNames = [self getNamesFromFile];
    for(int i = 0; i < [tempNames count]; i++){
        NSString* formId = [[tempNames objectAtIndex:i] objectForKey:[[KeyList sharedInstance] idTemplateListKey]];
        
        if ([formId isEqualToString:versionForId]){
            
            //from array of versions get largest version
            NSArray* versionsForForm = [[tempNames objectAtIndex:i] objectForKey:[[KeyList sharedInstance] versionTemplateListKey]];
            return [[[[versionsForForm sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects] firstObject];
        }
    }
    return NULL;
}


//get position of form by id (relative position from list of forms)
//return -1 if not found
- (int) getPositionOfFormById:(NSString *)id
{
    NSArray* tempNames = [self getNamesFromFile];
    for(int i = 0; i < [tempNames count]; i++){
        NSString* formId = [[tempNames objectAtIndex:i] objectForKey:[[KeyList sharedInstance] idTemplateListKey]];
        
        if ([formId isEqualToString:id]){
            return i;
        }
    }
    return -1;
}

//get count of forms
- (NSUInteger) getFormCount
{
    NSArray* tempNames = [self getNamesFromFile];
    return [tempNames count];
}


//Sort forms
//Sort order: title, instructionNumber, equipment, discipline
- (void) sortFormsByName: (NSArray*) unsortedList
{
    NSSortDescriptor* title = [[NSSortDescriptor alloc] initWithKey:[[KeyList sharedInstance] titleTemplateListKey]
                                                            ascending:YES selector:@selector(caseInsensitiveCompare:)] ; // 1
    NSSortDescriptor* instructionNumber = [[NSSortDescriptor alloc] initWithKey:[[KeyList sharedInstance] insructionNumberTemplateListKey]
                                                            ascending:YES selector:@selector(caseInsensitiveCompare:)] ; // 1
    NSSortDescriptor* equipment = [[NSSortDescriptor alloc] initWithKey:[[KeyList sharedInstance] equipmentTemplateListKey]
                                                            ascending:YES selector:@selector(caseInsensitiveCompare:)] ; // 1
    NSSortDescriptor* discipline = [[NSSortDescriptor alloc] initWithKey:[[KeyList sharedInstance] disciplineTemplateListKey]
                                                            ascending:YES selector:@selector(caseInsensitiveCompare:)] ; // 1
    [self setNamesToFile:[unsortedList sortedArrayUsingDescriptors:
                          [NSArray arrayWithObjects:title, instructionNumber, equipment, discipline, Nil]]];
    
}

//Save array as formlist
- (void) setFormList: (NSArray*) formList
{
    NSMutableArray* mutableFormList = [[NSMutableArray alloc] initWithArray:formList];
    NSMutableArray *listWithValidNameAndVersions = [[NSMutableArray alloc]init];
    for (NSMutableDictionary* eachForm in mutableFormList){
        if ([[eachForm objectForKey:[[KeyList sharedInstance] titleTemplateListKey]] length] > 0){
            if ([[eachForm objectForKey:[[KeyList sharedInstance] versionTemplateListKey]] count] > 0) {
                NSMutableDictionary* mutableEachForm = [[NSMutableDictionary alloc] initWithDictionary:eachForm];
                for (NSString* key in eachForm) {
                        [mutableEachForm setObject:[eachForm objectForKey:key] forKey:key];
                }
                [mutableEachForm setObject:[[[[[eachForm objectForKey:[[KeyList sharedInstance] versionTemplateListKey]] sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects] firstObject] forKey:@"version"];
                [listWithValidNameAndVersions addObject:mutableEachForm];
            }
        }
    }
    [self sortFormsByName:listWithValidNameAndVersions];
}


//get details of form by at position
-(NSDictionary*) getFormDetailsAtPosition:(int) position
{
    NSArray* tempNames = [self getNamesFromFile];
    return [tempNames objectAtIndex:position];
}


//get name of form at position
- (NSString*) getNameAtPosition:(int)position
{
    NSArray* tempNames = [self getNamesFromFile];
    NSString* name = [[tempNames objectAtIndex:position] objectForKey:[[KeyList sharedInstance] titleTemplateListKey]];
    if ([name length] > 0){
        return name;
    }
    return NULL;
}


//get version of form at position. (highest version)
- (NSNumber*) getVersionAtPosition:(int)position
{
    NSArray* tempNames = [self getNamesFromFile];
    NSArray* versionsForForm = [[tempNames objectAtIndex:position] objectForKey:[[KeyList sharedInstance] versionTemplateListKey]];
    
    if ([versionsForForm count] > 0) {
        return [[[[versionsForForm sortedArrayUsingSelector:@selector(compare:)] reverseObjectEnumerator] allObjects] firstObject];
    }
    
    return NULL;
}


//get all forms
- (NSArray*) getFormList
{
    return [self getNamesFromFile];
}


//save forms to temporary form
-(void) setNamesToFile: (NSArray*) formList
{
    NSString* fileLocation = [NSTemporaryDirectory() stringByAppendingString:@"formList"];
    [NSKeyedArchiver archiveRootObject:formList toFile:fileLocation];
}


//get forms from temporary file
-(NSArray*) getNamesFromFile
{
    NSString* fileLocation = [NSTemporaryDirectory() stringByAppendingString:@"formList"];
    NSData *data = [NSData dataWithContentsOfFile:fileLocation];
    NSArray* temp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return temp;
}
@end
