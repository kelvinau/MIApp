//
//  tableQuestionViewLogic.h
//  MIApp
//
//  Created by Gursimran Singh on 2014-04-01.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableQuestionViewLogic : NSObject <UITextViewDelegate>

-(id) initWithQuestion:(NSDictionary*) question collectionViewWidth:(float) width sizeForPrint:(BOOL)print scrollView:(UIScrollView*)scollView headerView:(UIView*)header;
-(void) displayTable;
-(float) getTotalHeight;
-(BOOL) checkUserAnswersValid;
-(NSMutableDictionary*) getUserAnswers;
-(float)getHeaderHeight;

@end
