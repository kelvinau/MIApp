//
//  KeyList.h
//  MIApp
//
//  Created by Gursimran Singh on 2014-03-09.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyList : NSObject

+ (KeyList *)sharedInstance;

@property (strong, nonatomic) NSString* tableQuestionTypeTemplateKey;
@property (strong, nonatomic) NSString* multipleChoiceQuestionTypeTemplateKey;
@property (strong, nonatomic) NSString* trueFalseQuestionTypeTemplateKey;
@property (strong, nonatomic) NSString* shortAnswerQuestionTypeTemplateKey;
@property (strong, nonatomic) NSString* commentToBeSavedTemplateKey;
@property (strong, nonatomic) NSString* imagesToBeSavedTemplateKey;
@property (strong, nonatomic) NSString* videosToBeSavedTemplateKey;
@property (strong, nonatomic) NSString* voiceToBeSavedTemplateKey;
@property (strong, nonatomic) NSString* listOfQuestionsTemplateKey;
@property (strong, nonatomic) NSString* answerTypeTemplateKey;
@property (strong, nonatomic) NSString* userAnswerToBeSavedTemplateKey;
@property (strong, nonatomic) NSString* questionTemplateKey;
@property (strong, nonatomic) NSString* answerListTemplateKey;
@property (strong, nonatomic) NSString* maxAnswersTemplateKey;
@property (strong, nonatomic) NSString* tableAnswerToBeSavedTemplateKey;
@property (strong, nonatomic) NSString* textRowTypeTemplateKey;
@property (strong, nonatomic) NSString* checkBoxRowTypeTemplateKey;
@property (strong, nonatomic) NSString* rowSizeTemplateKey;
@property (strong, nonatomic) NSString* columnSizeTemplateKey;
@property (strong, nonatomic) NSString* firstRowTemplateKey;
@property (strong, nonatomic) NSString* firstColumnTemplateKey;
@property (strong, nonatomic) NSString* noCellsTemplateKey;
@property (strong, nonatomic) NSString* rowInputTypeTemplateKey;
@property (strong, nonatomic) NSString* helpTextTemplateKey;
@property (strong, nonatomic) NSString* helpImageTextTemplateKey;
@property (strong, nonatomic) NSString* helpImagesImageTemplateKey;
@property (strong, nonatomic) NSString* helpImagesTemplateKey;
@property (strong, nonatomic) NSString* helpInfoTemplateKey;
@property (strong, nonatomic) NSString* versionTemplateKey;
@property (strong, nonatomic) NSString* titleTemplateKey;
@property (strong, nonatomic) NSString* disciplineTemplateKey;
@property (strong, nonatomic) NSString* insructionNumberTemplateKey;
@property (strong, nonatomic) NSString* equipmentTemplateKey;
@property (strong, nonatomic) NSString* idTemplateKey;
@property (strong, nonatomic) NSString* userNameToBeSavedTemplateKey;
@property (strong, nonatomic) NSString* foremanTemplateKey;
@property (strong, nonatomic) NSString* foremanCommentTemplateKey;
@property (strong, nonatomic) NSString* foremanUserTemplateKey;
@property (strong, nonatomic) NSString* mediaToBeSavedTemplateKey;
@property (strong, nonatomic) NSString* originalIssueDateTemplateKey;
@property (strong, nonatomic) NSString* referencesTemplateKey;
@property (strong, nonatomic) NSString* preparedByTemplateKey;
@property (strong, nonatomic) NSString* preparedByTitleTemplateKey;
@property (strong, nonatomic) NSString* acceptedByTemplateKey;
@property (strong, nonatomic) NSString* acceptedByTitleTemplateKey;
@property (strong, nonatomic) NSString* eorTemplateKey;
@property (strong, nonatomic) NSString* supersedesTemplateKey;
@property (strong, nonatomic) NSString* revisedByTemplateKey;
@property (strong, nonatomic) NSString* revisionDateTemplateKey;
@property (strong, nonatomic) NSString* fileNumberTemplateKey;
@property (strong, nonatomic) NSString* revisionHistoryTemplateKey;
@property (strong, nonatomic) NSString* sectionTitleKey;
@property (strong, nonatomic) NSString* numberInputKey;
@property (strong, nonatomic) NSString* submittedDateKey;
@property (strong, nonatomic) NSString* completedDateKey;


@property (strong, nonatomic) NSString* baseUrlKey;
@property (strong, nonatomic) NSString* portUrlKey;
@property (strong, nonatomic) NSString* getTemplateByNameUrlKey;
@property (strong, nonatomic) NSString* uploadMiUrlKey;
@property (strong, nonatomic) NSString* getTemplateListUrlKey;



@property (strong, nonatomic) NSString* basednLdapKey;
@property (strong, nonatomic) NSString* uriSslLdapKey;
@property (strong, nonatomic) NSString* uriSslExternalLdapKey;
@property (strong, nonatomic) NSNumber* versionLdapKey;
@property (strong, nonatomic) NSString* filterSearchQueryByGroupLdadKey;
@property (strong, nonatomic) NSString* engineerGroupNameLdapKey;
@property (strong, nonatomic) NSString* foremanGroupNameLdapKey;
@property (strong, nonatomic) NSString* technicianGroupNameLdapKey;
@property (strong, nonatomic) NSString* filterSearchQueryByUserLdapKey;
@property (strong, nonatomic) NSString* sslLdapModeKey;
@property (strong, nonatomic) NSString* binddnLdapKey;
@property BOOL useLDAP;
@property (strong, nonatomic) NSDictionary* technicianUsers;
@property (strong, nonatomic) NSDictionary* foremanUsers;
@property (strong, nonatomic) NSDictionary* engineerUsers;


@property (strong, nonatomic) NSString* versionTemplateListKey;
@property (strong, nonatomic) NSString* disciplineTemplateListKey;
@property (strong, nonatomic) NSString* insructionNumberTemplateListKey;
@property (strong, nonatomic) NSString* equipmentTemplateListKey;
@property (strong, nonatomic) NSString* idTemplateListKey;
@property (strong, nonatomic) NSString* titleTemplateListKey;
@property (strong, nonatomic) NSString* originalIssueDateTemplateListKey;
@property (strong, nonatomic) NSString* referencesTemplateListKey;
@property (strong, nonatomic) NSString* preparedByTemplateListKey;
@property (strong, nonatomic) NSString* preparedByTitleTemplateListKey;
@property (strong, nonatomic) NSString* acceptedByTemplateListKey;
@property (strong, nonatomic) NSString* acceptedByTitleTemplateListKey;
@property (strong, nonatomic) NSString* eorTemplateListKey;
@property (strong, nonatomic) NSString* supersedesTemplateListKey;
@property (strong, nonatomic) NSString* revisedByTemplateListKey;
@property (strong, nonatomic) NSString* revisionDateTemplateListKey;
@property (strong, nonatomic) NSString* fileNumberTemplateListKey;
@property (strong, nonatomic) NSString* revisionHistoryTemplateListKey;


@property (strong, nonatomic) NSArray* sendNotificationAfterDays;
@property (strong, nonatomic) NSNumber* deleteIncompleteFormsAfterDays;
@property (strong, nonatomic) NSString* completedMiFolderName;
@property (strong, nonatomic) NSString* errorFolderName;
@property (strong, nonatomic) NSString* deletedMisErrorFileKey;
@property (strong, nonatomic) NSString* reassignedMisErrorFileKey;
@end
