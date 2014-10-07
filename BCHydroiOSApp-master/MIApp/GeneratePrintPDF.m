//
//  GeneratePrintPDF.m
//  MIApp
//
//  Created by Gursimran Singh on 2014-03-15.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "GeneratePrintPDF.h"
#import "QuestionList.h"
#import "KeyList.h"
#import "TableQuestionViewLogic.h"
#import "DrawRectUIView.h"


@implementation GeneratePrintPDF
{
    UICollectionView* collectionViewPrint;
    TableQuestionViewLogic* logic;
}

//initialize
-(id)init
{
    self = [super init];
    if (self) {
        [self generatePDF];
    }
    return self;
}

-(NSData*) getPrintData
{
    return [NSData dataWithContentsOfFile:[NSTemporaryDirectory() stringByAppendingString:@"print.pdf"]];
}


//generate pdf and save to temparory location
-(void) generatePDF
{
    
    //start new document
    UIGraphicsBeginPDFContextToFile([NSTemporaryDirectory() stringByAppendingString:@"print.pdf"], CGRectZero, nil);
    
    //Start a new page.
    CGSize pageSize = CGSizeMake(612, 792);
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
    
    //set current context
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
    
    
    //add introduction section
    float nextHeight = [self addIntroSection];
    

    CGSize size = CGSizeMake(532, 712);
    CGRect rect;
    
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    paragrapStyle.alignment = NSTextAlignmentRight;
    paragrapStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    for (int i = 0; i < [[[QuestionList sharedInstance] questionList] count]; i++) {
        NSDictionary* question = [[[QuestionList sharedInstance] questionList] objectAtIndex:i];
        
        NSString *section = [NSString stringWithFormat:@"%@", [question objectForKey:[[KeyList sharedInstance] sectionTitleKey]]];
        
        paragrapStyle.alignment = NSTextAlignmentLeft;
        paragrapStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        rect = CGRectMake(40, nextHeight, size.width, 0);
        nextHeight = [self drawyText:section atPosition:rect withParagraghStyle:paragrapStyle withFontSize:12 withBold:YES] + 13;
        
        
        NSString *questionString = [NSString stringWithFormat:@"%@", [question objectForKey:[[KeyList sharedInstance] questionTemplateKey]]];
        
        paragrapStyle.alignment = NSTextAlignmentLeft;
        paragrapStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        rect = CGRectMake(40, nextHeight, size.width, 0);
        nextHeight = [self drawyText:questionString atPosition:rect withParagraghStyle:paragrapStyle withFontSize:10 withBold:NO] + 10;
        
        rect = CGRectMake(40, nextHeight, size.width , 0);
        nextHeight = [self printAnswerStringForQuestion:question atPosition:rect] + 10;
        
        NSString *commentString = [NSString stringWithFormat:@"Comment: %@", [[question objectForKey:[[KeyList sharedInstance] userAnswerToBeSavedTemplateKey]] objectForKey:[[KeyList sharedInstance] commentToBeSavedTemplateKey]]];
        
        paragrapStyle.alignment = NSTextAlignmentLeft;
        paragrapStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        rect = CGRectMake(40, nextHeight, size.width, 0);
        nextHeight = [self drawyText:commentString atPosition:rect withParagraghStyle:paragrapStyle withFontSize:10 withBold:NO] + 10;
        
        rect = CGRectMake(40, nextHeight, size.width, 0);
        
        nextHeight = [self printMediaForQuestion:question atPosition:rect] + 30;
        
    }
    UIGraphicsEndPDFContext();
    
}




-(float) printMediaForQuestion: (NSDictionary*) question atPosition: (CGRect) rect
{
    NSArray* images = [[question objectForKey:[[KeyList sharedInstance] userAnswerToBeSavedTemplateKey]] objectForKey:[[KeyList sharedInstance] imagesToBeSavedTemplateKey]];
    if ([images count] > 0) {
        return [self printImagesInArray:images atPosition:rect];
    }
    return rect.origin.y;
}


-(float) printImagesInArray: (NSArray*) imageList atPosition: (CGRect) rect
{
    float x = rect.origin.x;
    for (NSString* image in imageList) {
        if ((x + 96) > 572) {
            x = rect.origin.x;
            rect.origin.y = rect.origin.y +  10 + 72;
        }
        NSString* imagePath = [self getFileLocation:[NSString stringWithFormat:@"%@.jpg",image]];
        UIImage* questionImage = [UIImage imageWithContentsOfFile:imagePath];
        rect.origin.y = [self checkNewPageForPdf:rect objectHeight:72];
        [questionImage drawInRect:CGRectMake(x, rect.origin.y, 96, 72)];
        x = x + 96 + 10;

    }
    
    rect.origin.y = rect.origin.y + 72;
    return rect.origin.y ;
}


-(NSString*) getFileLocation: (NSString*) fileName
{
    NSString* userPath = [[QuestionList sharedInstance] userPath];
    NSString *folderPath;
    if (([[QuestionList sharedInstance] engineerView]) && (![[QuestionList sharedInstance] engineerNewMI])) {
        folderPath = [[QuestionList sharedInstance] completedFilePathToBeUploaded];
    }else{
        folderPath = [userPath stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]];
    }
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    return filePath;
}


-(float) printAnswerStringForQuestion: (NSDictionary*) question atPosition:(CGRect) rect
{
    if ([[question objectForKey:[[KeyList sharedInstance] answerTypeTemplateKey]] isEqualToString:[[KeyList sharedInstance] multipleChoiceQuestionTypeTemplateKey]]) {
        return [self getMultipleAnswerStringForQuestion:question atPosition:rect];
    }else if ([[question objectForKey:[[KeyList sharedInstance] answerTypeTemplateKey]] isEqualToString:[[KeyList sharedInstance] shortAnswerQuestionTypeTemplateKey]]) {
        return [self getShortAnswerStringForQuestion:question atPosition:rect];
    }else if ([[question objectForKey:[[KeyList sharedInstance] answerTypeTemplateKey]] isEqualToString:[[KeyList sharedInstance] tableQuestionTypeTemplateKey]]){
        return [self getTwoDimensionalTableViewForQuestion:question atPosition:rect];
    }
    return rect.origin.y;
}

-(float) getShortAnswerStringForQuestion: (NSDictionary*) question atPosition:(CGRect) rect
{
    NSString* selectedAnswer = [[question objectForKey:[[KeyList sharedInstance] userAnswerToBeSavedTemplateKey]] objectForKey:[[KeyList sharedInstance] shortAnswerQuestionTypeTemplateKey]];
    
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    paragrapStyle.alignment = NSTextAlignmentLeft;
    paragrapStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    return [self drawyText:selectedAnswer atPosition:rect withParagraghStyle:paragrapStyle withFontSize:10 withBold:NO];
}


-(float) getTwoDimensionalTableViewForQuestion: (NSDictionary*) question atPosition:(CGRect) rect
{
    UIScrollView* scollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 532, 500)];
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 532, 100)];
    
    logic = [[TableQuestionViewLogic alloc] initWithQuestion:question collectionViewWidth:532 sizeForPrint:YES scrollView:scollView headerView:headerView];
    [logic displayTable];
    headerView.frame = CGRectMake(0, 0, 532, [logic getHeaderHeight]);
    scollView.frame = CGRectMake(0, headerView.frame.size.height, 532, [logic getTotalHeight]);
    
    
    UIView* finalTable = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 532, [logic getHeaderHeight] + [logic getTotalHeight])];
    [finalTable addSubview:headerView];
    [finalTable addSubview:scollView];
    
    
    float height = finalTable.frame.size.height;
    
    UIGraphicsBeginImageContextWithOptions(finalTable.bounds.size, finalTable.opaque, 0.0);
    [finalTable.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    rect.origin.y = [self checkNewPageForPdf:rect objectHeight:height];

    [image drawInRect:CGRectMake(rect.origin.x, rect.origin.y, 532, height)];



    logic = nil;
    finalTable = nil;
    headerView = nil;
    scollView = nil;

    
    return height + rect.origin.y;
}


-(float) getMultipleAnswerStringForQuestion: (NSDictionary*) question atPosition:(CGRect) rect
{
    NSArray* userChoiceList = [question objectForKey:[[KeyList sharedInstance] answerListTemplateKey]];
    NSString* userChoice = @"";
    for (NSString* choice in userChoiceList) {
        userChoice = [[userChoice stringByAppendingString:choice] stringByAppendingString:@"\n"];
    }
    NSArray* selectedAnswer = [[question objectForKey:[[KeyList sharedInstance] userAnswerToBeSavedTemplateKey]] objectForKey:[[KeyList sharedInstance] tableAnswerToBeSavedTemplateKey]];
    for (NSString* answer in selectedAnswer) {
        
        userChoice = [userChoice stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@\n", answer] withString:[NSString stringWithFormat:@"%@ - Selected\n", answer]];
    }
    
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    paragrapStyle.alignment = NSTextAlignmentCenter;
    paragrapStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    return [self drawyText:userChoice atPosition:rect withParagraghStyle:paragrapStyle withFontSize:14 withBold:NO];
}

-(float) drawyText:(NSString*) string atPosition:(CGRect) rect withParagraghStyle:(NSParagraphStyle*) paragraphStyle withFontSize:(int) fontSize withBold:(BOOL) bold
{
    CGSize pageSize = CGSizeMake(612, 792);
    UIFont* font;
    if (bold) {
        font = [UIFont boldSystemFontOfSize:fontSize];
    }else{
        font = [UIFont systemFontOfSize:fontSize];
    }
    
    CGRect textRect = [string boundingRectWithSize:CGSizeMake(pageSize.width - 80, pageSize.height - 80)
                                           options:NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName: paragraphStyle.copy}
                                           context:nil];
    
    rect.size.height = textRect.size.height;
    rect.origin.y = [self checkNewPageForPdf:rect objectHeight:textRect.size.height];
    [string drawInRect:rect withAttributes:@{NSFontAttributeName:font, NSParagraphStyleAttributeName: paragraphStyle.copy}];
    return rect.size.height + rect.origin.y;
    
    
}

-(float) checkNewPageForPdf: (CGRect) rect objectHeight:(float) height
{
    if ((rect.origin.y + height) > 752)  {
        UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
        return 40;
    }
    return rect.origin.y;
}



-(float)addIntroSection
{
    
    NSString *title = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] titleTemplateKey]];
    NSString *discipline = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] disciplineTemplateKey]];
    NSString *instructionNumber = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] insructionNumberTemplateKey]];
    NSString *originalIssueDate = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] originalIssueDateTemplateKey]];
    NSString *applied = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] equipmentTemplateKey]];
    NSString *supersedes = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] supersedesTemplateKey]];
    NSString *references = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] referencesTemplateKey]];
    NSString *fileNumber = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] fileNumberTemplateKey]];
    NSString *preparedBy = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] preparedByTemplateKey]];
    NSString *preparedTitle = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] preparedByTitleTemplateKey]];
    NSString *acceptedBy = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] acceptedByTemplateKey]];
    NSString *acceptedTitle = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] acceptedByTitleTemplateKey]];
    NSString *eor = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] eorTemplateKey]];
    NSString *history = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] revisionHistoryTemplateKey]];
    NSString *revisionNumber = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] versionTemplateKey]];
    NSString *revisedBy = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] revisedByTemplateKey]];
    NSString *date = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] revisionDateTemplateKey]];
    NSString *user = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] userNameToBeSavedTemplateKey]];
    NSString *completedDate = [[[QuestionList sharedInstance] entireMITemplate] objectForKey:[[KeyList sharedInstance] completedDateKey]];
    
    NSLog(@"%@", completedDate);
    
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    paragrapStyle.alignment = NSTextAlignmentRight;
    paragrapStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    DrawRectUIView* view = [[DrawRectUIView alloc] initWithFrame:CGRectMake(0, 0, 532, 23)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view addSubview:titleLabel];
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(40, 35, 532, 23)];
    [@"Generation Maintenance Instruction" drawInRect:CGRectMake(40, 38, 522, 15) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:12], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    image = [UIImage imageNamed:@"pdfLogo"];
    [image drawInRect:CGRectMake(50, 39, 100, 18)];
    
    paragrapStyle.alignment = NSTextAlignmentLeft;
    [view setFrame:CGRectMake(0, 0, 310, 18)];
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(40, 57, 310, 18)];
    
    
    
    [@"Title:     " drawInRect:CGRectMake(50, 60, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [title drawInRect:CGRectMake(90, 59, 250, 16) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    [view setFrame:CGRectMake(0, 0, 222, 18)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view addSubview:titleLabel];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(348, 57, 224, 18)];
    
    [@"MI Discipline:     " drawInRect:CGRectMake(380, 60, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [discipline drawInRect:CGRectMake(450, 59, 250, 16) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    [view setFrame:CGRectMake(0, 0, 310, 18)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view addSubview:titleLabel];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(40, 73, 310, 18)];
    
    [@"Instruction Number:     " drawInRect:CGRectMake(50, 76, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [instructionNumber drawInRect:CGRectMake(160, 75, 250, 16) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    [view setFrame:CGRectMake(0, 0, 222, 18)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view addSubview:titleLabel];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(348, 73, 224, 18)];
    
    [@"Original Issue Date:     " drawInRect:CGRectMake(354, 76, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [originalIssueDate drawInRect:CGRectMake(450, 74, 250, 16) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    
    
    
    
    
    
    [view setFrame:CGRectMake(0, 0, 310, 18)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view addSubview:titleLabel];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(40, 89, 310, 18)];
    
    [@"Applied to Equipment:     " drawInRect:CGRectMake(50, 92, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [applied drawInRect:CGRectMake(170, 91, 250, 16) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    [view setFrame:CGRectMake(0, 0, 222, 18)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view addSubview:titleLabel];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(348, 89, 224, 18)];
    
    [@"Supersedes:     " drawInRect:CGRectMake(385, 92, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [supersedes drawInRect:CGRectMake(450, 91, 250, 16) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    
    
    
    
    
    [view setFrame:CGRectMake(0, 0, 310, 18)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view addSubview:titleLabel];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(40, 105, 310, 18)];
    
    [@"References:     " drawInRect:CGRectMake(50, 108, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [references drawInRect:CGRectMake(123, 107, 250, 16) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    [view setFrame:CGRectMake(0, 0, 222, 18)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view addSubview:titleLabel];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(348, 105, 224, 18)];
    
    [@"File #:     " drawInRect:CGRectMake(412, 108, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [fileNumber drawInRect:CGRectMake(450, 107, 250, 16) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    
    [view setFrame:CGRectMake(0, 0, 106, 40)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view addSubview:titleLabel];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(40, 122, 106, 40)];
    
    [@"Prepared By:     " drawInRect:CGRectMake(50, 126, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [preparedBy drawInRect:CGRectMake(50, 140, 90, 28) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    
    [view setFrame:CGRectMake(0, 0, 104, 40)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view addSubview:titleLabel];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(145, 122, 103, 40)];
    
    [@"Title:     " drawInRect:CGRectMake(152, 126, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [preparedTitle drawInRect:CGRectMake(155, 140, 90, 28) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    
    [view setFrame:CGRectMake(0, 0, 103, 40)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view addSubview:titleLabel];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(246, 122, 103, 40)];
    
    [@"Accepted By:     " drawInRect:CGRectMake(255, 126, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [acceptedBy drawInRect:CGRectMake(255, 140, 90, 28) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    
    
    
    
    
    [view setFrame:CGRectMake(0, 0, 113, 40)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view addSubview:titleLabel];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(348, 122, 113, 40)];
    
    [@"Title:     " drawInRect:CGRectMake(357, 126, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [acceptedTitle drawInRect:CGRectMake(357, 140, 90, 28) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    
    [view setFrame:CGRectMake(0, 0, 114, 40)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view addSubview:titleLabel];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(458, 122, 114, 40)];
    
    [@"EOR:     " drawInRect:CGRectMake(466, 126, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [eor drawInRect:CGRectMake(466, 140, 90, 28) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    
    
    CGRect textRect = [history boundingRectWithSize:CGSizeMake(412, 792)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10], NSParagraphStyleAttributeName: paragrapStyle.copy}
                                            context:nil];
    
    int size = MAX(textRect.size.height, 35);
    
    [view setFrame:CGRectMake(0, 0, 532, size)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view addSubview:titleLabel];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(40, 161, 532, size)];
    
    [@"Revision\nHistory:     " drawInRect:CGRectMake(50, 164, 100, size) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [history drawInRect:CGRectMake(110, 164, 412, size) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    
    
    [view setFrame:CGRectMake(0, 0, 106, 18)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view addSubview:titleLabel];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(40, 160 + size, 106, 18)];
    
    [@"Revision #     " drawInRect:CGRectMake(50, 163 + size, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [revisionNumber drawInRect:CGRectMake(100, 162+ size, 90, 15) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    
    [view setFrame:CGRectMake(0, 0, 260, 18)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view addSubview:titleLabel];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(144, 160 + size, 260, 18)];
    
    [@"Revised by:     " drawInRect:CGRectMake(154, 163 + size, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [revisedBy drawInRect:CGRectMake(220, 162 + size, 200, 15) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    
    [view setFrame:CGRectMake(0, 0, 170, 18)];
    [view setBackgroundColor:[UIColor whiteColor]];
    //[view addSubview:titleLabel];
    
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [image drawInRect:CGRectMake(402, 160 + size, 170, 18)];
    
    [@"Revised Date:     " drawInRect:CGRectMake(412, 163 + size, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [date drawInRect:CGRectMake(480, 162 + size, 90, 15) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:11], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    
    [@"Work Performed by:" drawInRect:CGRectMake(40, 186 + size, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [@"_______________________" drawInRect:CGRectMake(135, 190 + size, 150, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [user drawInRect:CGRectMake(138, 186 + size, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    [@"Date:" drawInRect:CGRectMake(260, 186 + size, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [@"_______________________" drawInRect:CGRectMake(300, 190 + size, 150, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [completedDate drawInRect:CGRectMake(309, 186 + size, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    [@"WO#:" drawInRect:CGRectMake(430, 186 + size, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [@"_______________________" drawInRect:CGRectMake(465, 190 + size, 150, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    [@"Work Leader Review:" drawInRect:CGRectMake(40, 210 + size, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [@"_______________________" drawInRect:CGRectMake(135, 215 + size, 150, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    if ([[QuestionList sharedInstance] engineerView]) {
        [[[QuestionList sharedInstance] username] drawInRect:CGRectMake(138, 210 + size, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMM d, yyyy";
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
        [dateFormatter setTimeZone:gmt];
        NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
        [timeStamp drawInRect:CGRectMake(309, 210 + size, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    }
    
    [@"Date:" drawInRect:CGRectMake(260, 210 + size, 100, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    [@"_______________________" drawInRect:CGRectMake(300, 215 + size, 150, 15) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:9], NSParagraphStyleAttributeName: paragrapStyle.copy}];
    
    
    return 215+size+35;
}
@end
