//
//  KeyList.m
//  MIApp
//
//  Created by Gursimran Singh on 2014-03-09.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "KeyList.h"

@implementation KeyList

@synthesize tableQuestionTypeTemplateKey, multipleChoiceQuestionTypeTemplateKey, trueFalseQuestionTypeTemplateKey, shortAnswerQuestionTypeTemplateKey, commentToBeSavedTemplateKey, imagesToBeSavedTemplateKey, videosToBeSavedTemplateKey, voiceToBeSavedTemplateKey, listOfQuestionsTemplateKey, answerTypeTemplateKey, userAnswerToBeSavedTemplateKey, questionTemplateKey, answerListTemplateKey, maxAnswersTemplateKey, tableAnswerToBeSavedTemplateKey, textRowTypeTemplateKey, checkBoxRowTypeTemplateKey, rowInputTypeTemplateKey, rowSizeTemplateKey, columnSizeTemplateKey, firstColumnTemplateKey, firstRowTemplateKey, noCellsTemplateKey, helpInfoTemplateKey, helpImagesImageTemplateKey, helpImagesTemplateKey, helpImageTextTemplateKey, helpTextTemplateKey, versionTemplateKey, titleTemplateKey, disciplineTemplateKey, insructionNumberTemplateKey, equipmentTemplateKey, idTemplateKey, userNameToBeSavedTemplateKey, foremanUserTemplateKey, foremanTemplateKey, foremanCommentTemplateKey, mediaToBeSavedTemplateKey, baseUrlKey, portUrlKey, getTemplateByNameUrlKey, getTemplateListUrlKey, uploadMiUrlKey, basednLdapKey, uriSslExternalLdapKey, uriSslLdapKey, filterSearchQueryByGroupLdadKey, engineerGroupNameLdapKey, filterSearchQueryByUserLdapKey, foremanGroupNameLdapKey, sslLdapModeKey, technicianGroupNameLdapKey, versionLdapKey, binddnLdapKey, disciplineTemplateListKey, equipmentTemplateListKey, idTemplateListKey, insructionNumberTemplateListKey, titleTemplateListKey, versionTemplateListKey, deleteIncompleteFormsAfterDays, sendNotificationAfterDays, completedMiFolderName, errorFolderName, deletedMisErrorFileKey, reassignedMisErrorFileKey, acceptedByTemplateKey, acceptedByTemplateListKey, acceptedByTitleTemplateKey, acceptedByTitleTemplateListKey, eorTemplateKey, eorTemplateListKey, fileNumberTemplateKey, fileNumberTemplateListKey, originalIssueDateTemplateKey, originalIssueDateTemplateListKey, preparedByTemplateKey, preparedByTemplateListKey, preparedByTitleTemplateKey, preparedByTitleTemplateListKey, referencesTemplateKey, referencesTemplateListKey, revisedByTemplateKey, revisedByTemplateListKey, revisionDateTemplateKey, revisionDateTemplateListKey, supersedesTemplateKey, supersedesTemplateListKey, revisionHistoryTemplateListKey, revisionHistoryTemplateKey, sectionTitleKey, numberInputKey, submittedDateKey, completedDateKey, engineerUsers, foremanUsers, technicianUsers, useLDAP;


+ (KeyList *)sharedInstance
{
    // the instance of this class is stored here
    static KeyList *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance) {
        myInstance  = [[[self class] alloc] init];
        
        // initialize variables here
    }
    // return the instance of this class
    return myInstance;
}

-(id)init
{
    if (self = [super init]) {
        [self getAllKeys];
        return self;
    }
    return  nil;
}


-(void) getAllKeys
{
    [self getTemplateKeys];
    [self getURLKeys];
    [self getLdapKeys];
    [self getTemplateListKeys];
    [self getAllOtherKeys];
}

-(void) getTemplateKeys
{
    NSDictionary* templateKeyDictionary = [[NSBundle mainBundle].infoDictionary objectForKey:@"TemplateKeys"];
    tableQuestionTypeTemplateKey = [templateKeyDictionary objectForKey:@"tableQuestion"];
    multipleChoiceQuestionTypeTemplateKey = [templateKeyDictionary objectForKey:@"multipleChoiceQuestion"];
    trueFalseQuestionTypeTemplateKey = [templateKeyDictionary objectForKey:@"trueFalseQuestion"];
    shortAnswerQuestionTypeTemplateKey = [templateKeyDictionary objectForKey:@"shortAnswerQuestion"];
    commentToBeSavedTemplateKey = [templateKeyDictionary objectForKey:@"commentToBeSaved"];
    imagesToBeSavedTemplateKey = [templateKeyDictionary objectForKey:@"imagesToBeSaved"];
    videosToBeSavedTemplateKey = [templateKeyDictionary objectForKey:@"videosToBeSaved"];
    voiceToBeSavedTemplateKey = [templateKeyDictionary objectForKey:@"voiceToBeSaved"];
    listOfQuestionsTemplateKey = [templateKeyDictionary objectForKey:@"listOfQuestions"];
    answerTypeTemplateKey = [templateKeyDictionary objectForKey:@"answerType"];
    userAnswerToBeSavedTemplateKey = [templateKeyDictionary objectForKey:@"userAnswerToBeSaved"];
    questionTemplateKey = [templateKeyDictionary objectForKey:@"actualQuestion"];
    helpInfoTemplateKey = [templateKeyDictionary objectForKey:@"helpInfo"];
    answerListTemplateKey = [templateKeyDictionary objectForKey:@"answerList"];
    maxAnswersTemplateKey = [templateKeyDictionary objectForKey:@"maxAnswers"];
    tableAnswerToBeSavedTemplateKey = [templateKeyDictionary objectForKey:@"oneDimensionalTableToBeSaved"];
    checkBoxRowTypeTemplateKey = [templateKeyDictionary objectForKey:@"rowTypeCheckBoxes"];
    textRowTypeTemplateKey = [templateKeyDictionary objectForKey:@"rowTypeText"];
    rowSizeTemplateKey = [templateKeyDictionary objectForKey:@"numberOfRows"];
    columnSizeTemplateKey = [templateKeyDictionary objectForKey:@"numberOfColumns"];
    firstColumnTemplateKey = [templateKeyDictionary objectForKey:@"firstColumn"];
    firstRowTemplateKey = [templateKeyDictionary objectForKey:@"firstRow"];
    noCellsTemplateKey = [templateKeyDictionary objectForKey:@"cellsThatAreNotAnswerable"];
    rowInputTypeTemplateKey = [templateKeyDictionary objectForKey:@"rowInputType"];
    helpTextTemplateKey = [templateKeyDictionary objectForKey:@"helpInfoText"];
    helpImageTextTemplateKey = [templateKeyDictionary objectForKey:@"helpInfoImagesText"];
    helpImagesTemplateKey = [templateKeyDictionary objectForKey:@"helpInfoImages"];
    helpImagesImageTemplateKey = [templateKeyDictionary objectForKey:@"helpInfoImagesImage"];
    versionTemplateKey = [templateKeyDictionary objectForKey:@"version"];
    titleTemplateKey = [templateKeyDictionary objectForKey:@"title"];
    disciplineTemplateKey = [templateKeyDictionary objectForKey:@"discipline"];
    insructionNumberTemplateKey = [templateKeyDictionary objectForKey:@"instructionNumber"];
    equipmentTemplateKey = [templateKeyDictionary objectForKey:@"equipment"];
    userNameToBeSavedTemplateKey = [templateKeyDictionary objectForKey:@"usernameToBeSaved"];
    foremanTemplateKey = [templateKeyDictionary objectForKey:@"foremanSection"];
    foremanUserTemplateKey = [templateKeyDictionary objectForKey:@"foremanUsername"];
    foremanCommentTemplateKey = [templateKeyDictionary objectForKey:@"foremanComment"];
    mediaToBeSavedTemplateKey = [templateKeyDictionary objectForKey:@"mediaToBeSaved"];
    idTemplateKey = [templateKeyDictionary objectForKey:@"id"];
    originalIssueDateTemplateKey = [templateKeyDictionary objectForKey:@"originalIssueDate"];
    preparedByTitleTemplateKey = [templateKeyDictionary objectForKey:@"PreparedByTitle"];
    preparedByTemplateKey = [templateKeyDictionary objectForKey:@"preparedBy"];
    acceptedByTitleTemplateKey = [templateKeyDictionary objectForKey:@"acceptedByTitle"];
    acceptedByTemplateKey = [templateKeyDictionary objectForKey:@"acceptedBy"];
    revisedByTemplateKey = [templateKeyDictionary objectForKey:@"revisedBy"];
    revisionDateTemplateKey = [templateKeyDictionary objectForKey:@"revisionDate"];
    eorTemplateKey = [templateKeyDictionary objectForKey:@"eor"];
    supersedesTemplateKey = [templateKeyDictionary objectForKey:@"supersedes"];
    referencesTemplateKey = [templateKeyDictionary objectForKey:@"references"];
    fileNumberTemplateKey = [templateKeyDictionary objectForKey:@"fileNumber"];
    revisionHistoryTemplateKey = [templateKeyDictionary objectForKey:@"revisionHistory"];
    sectionTitleKey = [templateKeyDictionary objectForKey:@"section"];
    numberInputKey = [templateKeyDictionary objectForKey:@"numberInput"];
    submittedDateKey = [templateKeyDictionary objectForKey:@"submittedDate"];
    completedDateKey = [templateKeyDictionary objectForKey:@"completedDate"];
}

-(void) getURLKeys
{
    NSDictionary* bchURLS = [[NSBundle mainBundle].infoDictionary objectForKey:@"BCHUrls"];
    baseUrlKey = [bchURLS objectForKey:@"BCHServerBase"];
    portUrlKey = [bchURLS objectForKey:@"BCHServerPort"];
    getTemplateListUrlKey = [bchURLS objectForKey:@"TemplateNamePage"];
    uploadMiUrlKey = [bchURLS objectForKey:@"UploadMI"];
    getTemplateByNameUrlKey = [bchURLS objectForKey:@"TemplateDownloadPage"];
}

-(void) getLdapKeys
{
    NSDictionary* ldapInfo = [[NSBundle mainBundle].infoDictionary objectForKey:@"LDAPLoginDetails"];
    basednLdapKey = [ldapInfo objectForKey:@"basedn"];
    uriSslLdapKey = [ldapInfo objectForKey:@"uris"];
    uriSslExternalLdapKey = [ldapInfo objectForKey:@"urise"];
    versionLdapKey = [ldapInfo objectForKey:@"version"];
    filterSearchQueryByGroupLdadKey = [ldapInfo objectForKey:@"filterByGroup"];
    binddnLdapKey = [ldapInfo objectForKey:@"binddn"];
    foremanGroupNameLdapKey = [ldapInfo objectForKey:@"foremanGroup"];
    engineerGroupNameLdapKey = [ldapInfo objectForKey:@"enginnerGroup"];
    technicianGroupNameLdapKey = [ldapInfo objectForKey:@"technicianGroup"];
    filterSearchQueryByUserLdapKey = [ldapInfo objectForKey:@"filterByUser"];
    sslLdapModeKey = [ldapInfo objectForKey:@"ssl"];
    NSNumber * n = [ldapInfo objectForKey:@"useLDAP"];
    useLDAP = [n boolValue];
    NSDictionary* userInfo = [[NSBundle mainBundle].infoDictionary objectForKey:@"usernames"];
    technicianUsers = [userInfo objectForKey:@"technician"];
    foremanUsers = [userInfo objectForKey:@"foreman"];
    engineerUsers = [userInfo objectForKey:@"engineer"];
    
}

-(void) getTemplateListKeys
{
    NSDictionary* templateKeyDictionary = [[NSBundle mainBundle].infoDictionary objectForKey:@"TemplateListKeys"];
    versionTemplateListKey = [templateKeyDictionary objectForKey:@"version"];
    disciplineTemplateListKey = [templateKeyDictionary objectForKey:@"discipline"];
    titleTemplateListKey = [templateKeyDictionary objectForKey:@"title"];
    insructionNumberTemplateListKey = [templateKeyDictionary objectForKey:@"instructionNumber"];
    equipmentTemplateListKey = [templateKeyDictionary objectForKey:@"equipment"];
    idTemplateListKey = [templateKeyDictionary objectForKey:@"id"];
    originalIssueDateTemplateListKey = [templateKeyDictionary objectForKey:@"originalIssueDate"];
    preparedByTitleTemplateListKey = [templateKeyDictionary objectForKey:@"preparedByTitle"];
    preparedByTemplateListKey = [templateKeyDictionary objectForKey:@"preparedBy"];
    acceptedByTitleTemplateListKey = [templateKeyDictionary objectForKey:@"acceptedByTitle"];
    acceptedByTemplateListKey = [templateKeyDictionary objectForKey:@"acceptedBy"];
    revisedByTemplateListKey = [templateKeyDictionary objectForKey:@"revisedBy"];
    revisionDateTemplateListKey = [templateKeyDictionary objectForKey:@"revisionDate"];
    eorTemplateListKey = [templateKeyDictionary objectForKey:@"eor"];
    supersedesTemplateListKey = [templateKeyDictionary objectForKey:@"supersedes"];
    referencesTemplateListKey = [templateKeyDictionary objectForKey:@"references"];
    fileNumberTemplateListKey = [templateKeyDictionary objectForKey:@"fileNumber"];
    revisionHistoryTemplateListKey = [templateKeyDictionary objectForKey:@"revisionHistory"];

}

-(void) getAllOtherKeys
{
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    sendNotificationAfterDays = [infoDictionary objectForKey:@"SendNotificationAfterDays"];
    deleteIncompleteFormsAfterDays = [infoDictionary objectForKey:@"DeleteAfterDays"];
    completedMiFolderName = [infoDictionary objectForKey:@"CompletedMIFolderName"];
    errorFolderName = [infoDictionary objectForKey:@"ErrorFolderName"];
    deletedMisErrorFileKey = [infoDictionary objectForKey:@"DeletedMisErrorFileKey"];
    reassignedMisErrorFileKey = [infoDictionary objectForKey:@"ReassignedMisErrorFileKey"];
}
@end
