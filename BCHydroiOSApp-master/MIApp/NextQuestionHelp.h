//
//  NextQuestionHelp.h
//  MIApp
//
//  Created by Gursimran Singh on 2014-04-20.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NextQuestionHelp : NSObject


+(UIViewController*) getNextQuestionViewController: (NSString*)nextQuestionType withStoryBoard:(UIStoryboard*) storyboard;

+(NSString*) getNextSegueName;

@end
