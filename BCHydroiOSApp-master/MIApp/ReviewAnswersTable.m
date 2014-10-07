//
//  ReviewAnswersTable.m
//  MIApp
//
//  Created by Gursimran Singh on 11/15/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//
//  This view displays all the questions with answers that the user has entered
//  Thumbnails of each media for every question is attached with it
//
//  If a foreman is reviewing a completed mi, they are not allowed to edit the answers
//  and can only read what the technician has entered
//
//  If a foreman or technician is filling a new MI they can click on any question
//  and are taken to the page to edit the selected question
//
//  If the person filling the form is not a foreman, the next button is titled "finish and submit"
//  and if it is a foremand it is "Add comments" and are taken to the comment screen instead of
//  back to the form selection view
//
//  When a technician submits, the current folder for this form is moved to the "completedMIs" folder for the foreman to review
//  If a foreman is filling a new form then they are not moved, instead the upload path is set to the current folder


//Constants for how big the thumbnails for each media is
//With these settings, we get 9 thumnails on each row
#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 1024.0f
#define CELL_CONTENT_MARGIN 10.0f
static int const MEDIA_WIDTH  = 90;
static int const MEDIA_HEIGHT = 80;
static int const NUMBER_MEDIA_ROW = ((CELL_CONTENT_WIDTH - (2*CELL_CONTENT_MARGIN) - 100)/(MEDIA_WIDTH+CELL_CONTENT_MARGIN));


#import "ReviewAnswersTable.h"
#import "QuestionList.h"
#import "DisplayMultipleChoiceQuestion.h"
#import "DisplayShortAnswerQuestion.h"
#import "DisplayTrueFalseQuestion.h"
#import <AVFoundation/AVFoundation.h>
#import "DisplayQuestionTypeWithTable.h"
#import "KeyList.h"
#import "GeneratePrintPDF.h"
#import "AddRemoveNotifications.h"
#import "TableQuestionViewLogic.h"
#import "NextQuestionHelp.h"

@implementation ReviewAnswersTable
{
    IBOutlet UITableView *ReviewAnswerTable;
    UIAlertView* loadingView;
    
    TableQuestionViewLogic* logic;
    
}

@synthesize doneButton;

//Set up view for first display
-(void) viewDidLoad{
    [super viewDidLoad];
    
    [self setTitle:@"Review Answers"];
    
    [[self navigationItem] setHidesBackButton:YES];
    
    //change button title if engineer is reviewing form
    if (([[QuestionList sharedInstance] engineerView]) && (![[QuestionList sharedInstance] engineerNewMI])) {
        [[self doneButton] setTitle:@"Add Comments"];
    }
    
    [self setCompletedDate];

    //print button
    UIBarButtonItem* printButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"print"] style:UIBarButtonItemStyleDone target:self action:@selector(printForm:)];
    
    //space between two buttons
    UIBarButtonItem* fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    fixedSpace.width = 50;
    
    self.navigationItem.rightBarButtonItems = @[self.navigationItem.rightBarButtonItem, fixedSpace, printButton];
    
}


//Set up view for every subsequient display
- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self reloadTable];
}


//set todays date as completed date of form
-(void) setCompletedDate
{
    //save todays date as completed date  only if logged in as technician
    
    if ((![[QuestionList sharedInstance] engineerView]) || (([[QuestionList sharedInstance] engineerView]) && [[QuestionList sharedInstance] engineerNewMI])){
        NSLog(@"in here");
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"MMM d, yyyy";
        NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"PST"];
        [dateFormatter setTimeZone:gmt];
        NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
        NSMutableDictionary *temp = [[QuestionList sharedInstance] entireMITemplate];
        [temp setObject:timeStamp forKey:[[KeyList sharedInstance] completedDateKey]];
        [[QuestionList sharedInstance] setEntireMITemplate:temp];
    }
}


//Reload data in the table
-(void) reloadTable
{
    [ReviewAnswerTable reloadData]; // to reload selected cell
}



//TABLE DATASOURCE METHODS

//return number of sections in table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //just have one section
    return 1;
}


//return title of section in table
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Your Answers";
}

//Get the number of rows in each section
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Get the count of number of questions in form.
    NSArray* questions = [[QuestionList sharedInstance] questionList];
    return [questions count];
}

//Return height for every cell
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // this method is called for each cell and returns height
    
    NSString* text = [self getString:(int)indexPath.row];
    
    //get size of text
    //Calculate the expected height of question
    CGSize maximumLabelSize = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2) - 100, FLT_MAX);
    
    CGSize expectedLabelSize = [text sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    
    //CGSize size = [text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:FONT_SIZE]}];
    CGFloat height = MAX(expectedLabelSize.height, 44.0f);
    
   
    //get table height
    if ([[[[[QuestionList sharedInstance] questionList] objectAtIndex:indexPath.row] objectForKey:[[KeyList sharedInstance] answerTypeTemplateKey]] isEqualToString:[[KeyList sharedInstance] tableQuestionTypeTemplateKey]]) {
        logic = [[TableQuestionViewLogic alloc] initWithQuestion:[[[QuestionList sharedInstance] questionList] objectAtIndex:indexPath.row] collectionViewWidth:984 sizeForPrint:NO scrollView:nil headerView:nil];
        height = height + [logic getTotalHeight] + [logic getHeaderHeight];
        logic = nil;
    }
    
    //get height of images
    int numberRows = ceil((double)[self getMediaCount:indexPath.row]/NUMBER_MEDIA_ROW);
    int heightOfMedia = numberRows*(MEDIA_HEIGHT+CELL_CONTENT_MARGIN);
    
    
    return height + (CELL_CONTENT_MARGIN * 2) + heightOfMedia;
}


//Get the cell at every index
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"singleAnswer";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *label = nil;
    
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    //Set up label that displays the text for that question
        label = [[UILabel alloc] initWithFrame:CGRectZero];
        [label setLineBreakMode:NSLineBreakByWordWrapping];
        [label setNumberOfLines:0];
        [label setFont:[UIFont systemFontOfSize:12.0]];
        [label setTag:1];
        
        [[label layer] setBorderWidth:0.0f];
        
        [[cell contentView] addSubview:label];

    
    //Calculate the size of label by getting teh height of string that will go in there
    NSString* text = [self getString:(int)indexPath.row];
    
    //CGSize size = [text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:FONT_SIZE]}];
    if (!label)
        label = (UILabel*)[cell viewWithTag:1];

    [label setText:text];
    
    CGSize maximumLabelSize = CGSizeMake(CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2) - 100, FLT_MAX);
    
    CGSize expectedLabelSize = [text sizeWithFont:[UIFont systemFontOfSize:12.0] constrainedToSize:maximumLabelSize lineBreakMode:NSLineBreakByWordWrapping];
    
    [label setFrame:CGRectMake(CELL_CONTENT_MARGIN, CELL_CONTENT_MARGIN, CELL_CONTENT_WIDTH - (CELL_CONTENT_MARGIN * 2) - 100, MAX(expectedLabelSize.height, 44.0f))];
    
    CGFloat otherHeight = 0;
    
    //get table
    if ([[[[[QuestionList sharedInstance] questionList] objectAtIndex:indexPath.row] objectForKey:[[KeyList sharedInstance] answerTypeTemplateKey]] isEqualToString:[[KeyList sharedInstance] tableQuestionTypeTemplateKey]]) {
       
        //inititalize views
        UIScrollView* scollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 984, 500)];
        UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 984, 100)];
        
        //get table logic
        logic = [[TableQuestionViewLogic alloc] initWithQuestion:[[[QuestionList sharedInstance] questionList] objectAtIndex:indexPath.row] collectionViewWidth:984 sizeForPrint:NO scrollView:scollView headerView:headerView];
        
        //display table
        [logic displayTable];
        
        //set frame to display entire table without scroll
        headerView.frame = CGRectMake(0, 0, 984, [logic getHeaderHeight]);
        scollView.frame = CGRectMake(0, headerView.frame.size.height, 984, [logic getTotalHeight]);

        float height = [logic getHeaderHeight] + [logic getTotalHeight];
        otherHeight = height;
        //create a view to add table
        UIView* finalTable = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 984, height)];
        [finalTable addSubview:headerView];
        [finalTable addSubview:scollView];
    
        
        //convert view to image
        UIGraphicsBeginImageContextWithOptions(finalTable.bounds.size, finalTable.opaque, 0);
        [finalTable.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        logic = nil;
        finalTable = nil;
        headerView = nil;
        scollView = nil;
        
        //add image to cell
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CELL_CONTENT_MARGIN, label.frame.size.height+CELL_CONTENT_MARGIN, 984, height)];
        imageView.image = image;
        [[cell contentView] addSubview:imageView];
        
    }

    
    //Get all thumbnails
    NSArray* listOfViews = [self getMediaViewsForQuestion:indexPath.row withRowHeight:(expectedLabelSize.height + otherHeight)];
    
    //Add every thumbnail to cell
    for (UIImageView* imageView in listOfViews) {
        [cell addSubview:imageView];
    }
    
    return cell;
}

//Return array of views containing thumnail image
-(NSArray*) getMediaViewsForQuestion:(int) questionID withRowHeight:(CGFloat) height
{
    NSMutableArray* views = [[NSMutableArray alloc] initWithArray:[self getImageViewsForQuestion:questionID withRowHeight:height]];
    [views addObjectsFromArray:[self getVideoThumbnailsForQuestion:questionID withRowHeight: height]];
    [views addObjectsFromArray:[self getVoiceViewsForQuestion:questionID withRowHeight: height]];
    return views;
}


//returns an array of views with thumbnails for all images for that question
//Height here is the height of text displayed in the cell
//images are placed at a minimum of that height
-(NSArray*) getImageViewsForQuestion:(int)questionID withRowHeight:(CGFloat) height
{
    NSArray* images = [self getImagesForQuestion:questionID];
    NSString *userDirectory = [[QuestionList sharedInstance] userPath];
    NSString *folderPath;
    
    //Depending if the form is being reviewed or a new form filled, the path to media is set
    if (([[QuestionList sharedInstance] engineerView]) && (![[QuestionList sharedInstance] engineerNewMI])) {
        folderPath = [[QuestionList sharedInstance] completedFilePathToBeUploaded];
    }else{
        folderPath = [[userDirectory stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
    }
    NSMutableArray* viewOfImages = [[NSMutableArray alloc] init];
    
    int imageCount = [images count];
    
    for (int i = 0; i < imageCount; i++) {
        
        //get path to file
        NSString* image = [images objectAtIndex:i];
        NSString* fullPath = [folderPath stringByAppendingPathComponent:image];
        
        //calculate the width of image
        //1st image has no padding and all other images have extra white space
        //to add space between them.
        //Calculate the row at which this image is to be added.
        int width;
        int row = (i)/NUMBER_MEDIA_ROW;
        if ((i%NUMBER_MEDIA_ROW) == 0) {
            width = MEDIA_WIDTH;
        }else{
            width = MEDIA_WIDTH+CELL_CONTENT_MARGIN;
        }
        
        //calculate the placement with respect to the cell where this image is placed
        //Like row 1,2,3 and so on and image 1,2,3.. of that row
        CGRect frame = CGRectMake(CELL_CONTENT_MARGIN + ((i%NUMBER_MEDIA_ROW)*width), (CELL_CONTENT_MARGIN + height) + (row*(MEDIA_HEIGHT + CELL_CONTENT_MARGIN)), MEDIA_WIDTH, MEDIA_HEIGHT);
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = [UIImage imageWithContentsOfFile:fullPath];
        [viewOfImages addObject:imageView];
    }
    return viewOfImages;
}

//Similar method of getting thumbnails of audio
//They are just static images in the app bundle
-(NSArray*) getVoiceViewsForQuestion:(int)questionID withRowHeight:(CGFloat) height
{
    NSArray* voice = [self getVoiceForQuestion:questionID];
    
    NSMutableArray* viewOfVoice = [[NSMutableArray alloc] init];
    int videoCount = [[self getVideosForQuestion:questionID] count];
    int imageCount = [[self getImagesForQuestion:questionID] count];
    int voiceCount = [voice count];
    
    for (int i = 0; i < voiceCount; i++) {
        
        int width;
        int row = (i+ imageCount + videoCount)/NUMBER_MEDIA_ROW;
        
        if (((i+imageCount+ videoCount)%NUMBER_MEDIA_ROW) == 0) {
            width = MEDIA_WIDTH;
        }else{
            width = MEDIA_WIDTH+CELL_CONTENT_MARGIN;
        }
        CGRect frame = CGRectMake(CELL_CONTENT_MARGIN + (((i+ imageCount+videoCount)%NUMBER_MEDIA_ROW)*width), (CELL_CONTENT_MARGIN + height) + (row*(MEDIA_HEIGHT + CELL_CONTENT_MARGIN)), MEDIA_WIDTH , MEDIA_HEIGHT);
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = [UIImage imageNamed:@"voiceImage"];
        [viewOfVoice addObject:imageView];
    }
    
    return viewOfVoice;
}

//Similar method for getting video thumbnails
-(NSArray*) getVideoThumbnailsForQuestion:(int) questionID withRowHeight:(CGFloat) height
{
    NSArray* videos = [self getVideosForQuestion:questionID];
    NSString *userDirectory = [[QuestionList sharedInstance] userPath];
    NSString *folderPath;
    
    if (([[QuestionList sharedInstance] engineerView]) && (![[QuestionList sharedInstance] engineerNewMI])) {
        folderPath = [[QuestionList sharedInstance] completedFilePathToBeUploaded];
    }else{
        folderPath = [[userDirectory stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
    }
    NSMutableArray* viewOfVideos = [[NSMutableArray alloc] init];
    int videoCount = [videos count];
    int imageCount = [[self getImagesForQuestion:questionID] count];
    
    for (int i = 0; i < videoCount; i++) {
        
        NSString* image = [videos objectAtIndex:i];
        NSString* fullPath = [folderPath stringByAppendingPathComponent:image];
        
        int width;
        int row = (i+ imageCount)/NUMBER_MEDIA_ROW;
        if (((i+imageCount)%NUMBER_MEDIA_ROW) == 0) {
            width = MEDIA_WIDTH;
        }else{
            width = MEDIA_WIDTH+CELL_CONTENT_MARGIN;
        }
        CGRect frame = CGRectMake(CELL_CONTENT_MARGIN + (((i+ imageCount)%NUMBER_MEDIA_ROW)*width), (CELL_CONTENT_MARGIN + height) + (row*(MEDIA_HEIGHT + CELL_CONTENT_MARGIN)), MEDIA_WIDTH , MEDIA_HEIGHT);
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.image = [self getVideoThumbnail:fullPath];
        [viewOfVideos addObject:imageView];
    }
    
    return viewOfVideos;
}

//Retuns the thumbnail of the file passed between second 0 and 1
-(UIImage*) getVideoThumbnail: (NSString*) of{
    AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:of] options:nil];
    AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
    generate1.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(0, 1);
    CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
    return one;
}

//Called everytime users selects a row.
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    //Find what type of Question is slected and display page
    [QuestionList sharedInstance].nextQuestionID = [[NSNumber alloc] initWithInt:indexPath.row];
   
    //get next segue
    
    NSString* segueName = [NextQuestionHelp getNextSegueName];
    
    if (segueName != NULL) {
        [self performSegueWithIdentifier:segueName sender:self];
    }
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

    if (![segue.identifier isEqualToString:@"engineerAddComment"] ) {
        DisplayQuestionType* editQuestion = [segue destinationViewController];
        [editQuestion setEditQuestion:YES];
    }
 
}


//Returns a list of images attached to this question
-(NSArray*) getImagesForQuestion:(int)questionID
{
    NSArray* questions = [[QuestionList sharedInstance] questionList];
    NSDictionary* oneQuestion = [questions objectAtIndex:questionID];
    NSArray* images = [[oneQuestion objectForKey:[[KeyList sharedInstance] userAnswerToBeSavedTemplateKey]] objectForKey:[[KeyList sharedInstance] imagesToBeSavedTemplateKey]];
    NSMutableArray* imagesWithExtension = [[NSMutableArray alloc] init];
    for (NSString* each in images) {
        NSString* withExtension = [NSString stringWithFormat:@"%@.jpg", each];
        [imagesWithExtension addObject:withExtension];
    }
    return imagesWithExtension;
}


//Returns a list of videos attached to this question
-(NSArray*) getVideosForQuestion:(int)questionID
{
    NSArray* questions = [[QuestionList sharedInstance] questionList];
    NSDictionary* oneQuestion = [questions objectAtIndex:questionID];
    NSArray* videos = [[oneQuestion objectForKey:[[KeyList sharedInstance] userAnswerToBeSavedTemplateKey]] objectForKey:[[KeyList sharedInstance] videosToBeSavedTemplateKey]];
    NSMutableArray* videosWithExtension = [[NSMutableArray alloc] init];
    for (NSString* each in videos) {
        NSString* withExtension = [NSString stringWithFormat:@"%@.mov", each];
        [videosWithExtension addObject:withExtension];
    }
    return videosWithExtension;
}

//Returns a list of sounds attached to this question
-(NSArray*) getVoiceForQuestion:(int)questionID
{
    NSArray* questions = [[QuestionList sharedInstance] questionList];
    NSDictionary* oneQuestion = [questions objectAtIndex:questionID];
    NSArray* voice = [[oneQuestion objectForKey:[[KeyList sharedInstance] userAnswerToBeSavedTemplateKey]] objectForKey:[[KeyList sharedInstance] voiceToBeSavedTemplateKey]];
    NSMutableArray* voiceWithExtension = [[NSMutableArray alloc] init];
    for (NSString* each in voice) {
        NSString* withExtension = [NSString stringWithFormat:@"%@.m4a", each];
        [voiceWithExtension addObject:withExtension];
    }
    return voiceWithExtension;
}

//returns the total count of media in this question
-(int)getMediaCount:(int) questionID
{
    int total = (int)[[self getImagesForQuestion:questionID] count] + (int)[[self getVideosForQuestion:questionID] count] + (int)[[self getVoiceForQuestion:questionID] count];
    return total;
}


//returns the question and the user's answer as a long text that is displayed in the table
//used to get height of text and also to display the contents of the question
-(NSString*)getString:(int) questionID{
    NSArray* questions = [[QuestionList sharedInstance] questionList];
    NSDictionary* oneQuestion = [questions objectAtIndex:questionID];
    NSString* questionString = [oneQuestion objectForKey:[[KeyList sharedInstance] questionTemplateKey]];
    NSMutableString *userAnswer = [[NSMutableString alloc]init];
    NSString* commentEntered = [[oneQuestion objectForKey:[[KeyList sharedInstance] userAnswerToBeSavedTemplateKey]] objectForKey:[[KeyList sharedInstance] commentToBeSavedTemplateKey]];
    if ([[oneQuestion objectForKey:[[KeyList sharedInstance] answerTypeTemplateKey]] isEqualToString:[[KeyList sharedInstance] shortAnswerQuestionTypeTemplateKey]]){
        userAnswer = [[oneQuestion objectForKey:[[KeyList sharedInstance] userAnswerToBeSavedTemplateKey]] objectForKey:[[KeyList sharedInstance] shortAnswerQuestionTypeTemplateKey]];
    }else if ([[oneQuestion objectForKey:[[KeyList sharedInstance] answerTypeTemplateKey]] isEqualToString:[[KeyList sharedInstance] tableQuestionTypeTemplateKey]]){
    
    }else{
        NSArray* selectedAnswerInListForm = [[oneQuestion objectForKey:[[KeyList sharedInstance] userAnswerToBeSavedTemplateKey]] objectForKey:[[KeyList sharedInstance] tableAnswerToBeSavedTemplateKey]];
        for (NSString* eachAnswer in selectedAnswerInListForm){
            [userAnswer appendFormat:@"\n%@", eachAnswer];
        }
    }
    
    NSString* finalString = questionString;
    
    if ([[oneQuestion objectForKey:[[KeyList sharedInstance] answerTypeTemplateKey]] isEqualToString:[[KeyList sharedInstance] tableQuestionTypeTemplateKey]]){
        if ([commentEntered length] != 0){
            finalString = [finalString stringByAppendingString:@"\n\nComment\n"];
            finalString = [finalString stringByAppendingString:commentEntered];
        }
        finalString = [finalString stringByAppendingString:@"\n\nAnswers\n"];
        finalString = [finalString stringByAppendingString:userAnswer];
    }else{
    finalString = [finalString stringByAppendingString:@"\n\nAnswers\n"];
    finalString = [finalString stringByAppendingString:userAnswer];
    if ([commentEntered length] != 0){
        finalString = [finalString stringByAppendingString:@"\n\nComment\n"];
        finalString = [finalString stringByAppendingString:commentEntered];
    }
    }
    
    return finalString;
}


//Perform action on user pressing done button
- (IBAction)DoneButtonPressed:(id)sender {
    //if foreman is user then take to comment page else take the technician back to form select page after moving all files to completed folder
    
    [AddRemoveNotifications removeNotificationsForForm:[[QuestionList sharedInstance] fileNameToBeSavedAs] byUser:[[QuestionList sharedInstance] username]];
    
    if ([[QuestionList sharedInstance] engineerView]) {
        if ([[QuestionList sharedInstance] engineerNewMI]){
            [QuestionList sharedInstance].completedFilePathToBeUploaded = [[[QuestionList sharedInstance] userPath] stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]];
            [[QuestionList sharedInstance] setEngineerNewMI:NO];
        }
        [self performSegueWithIdentifier:@"engineerAddComment" sender:self];
    }
    else{
        [self moveCurrentMIToCompleted];
        [self.navigationController popToViewController:[[self.navigationController viewControllers] objectAtIndex:1] animated:YES];
    }
}


//Copies all files for this form to completed folder
-(void) moveCurrentMIToCompleted
{
    NSString* userPath = [[QuestionList sharedInstance] userPath];
    NSString *dataPath = [userPath stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]];
    NSArray* listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:nil];
    NSString* newFolder = [self createDestinationFolder];
    for (NSString* file in listOfFiles) {
        NSString* filePath = [[dataPath stringByAppendingString:@"/"] stringByAppendingString:file];
       [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:[[newFolder stringByAppendingString:@"/"] stringByAppendingString:file] error:nil];
    }
        
}


//Create a dsitinct folder name for this form in the completed folder path
-(NSString*) createDestinationFolder
{
    //Current time is appended to folder name to avoid duplicates
    NSString* userFolder = [self createUserFolder];

    NSDate *now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH-mm-ss"];
    NSString *time = [outputFormatter stringFromDate:now];
    NSString* newFolderName = [[[QuestionList sharedInstance] fileNameToBeSavedAs] stringByAppendingString:[NSString stringWithFormat:@" %@", time]];
    NSString* completePath = [userFolder stringByAppendingPathComponent:newFolderName];
    [[NSFileManager defaultManager] createDirectoryAtPath:completePath withIntermediateDirectories:NO attributes:nil error:nil];
    return completePath;
}

//create a folder for this user in the completed folder
-(NSString*) createUserFolder
{
    NSString* folderPath = [[[QuestionList sharedInstance] completedPath] stringByAppendingPathComponent:[[QuestionList sharedInstance] username]];
    [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:nil];
    return folderPath;
}



//called when user clicks on print
-(void) printForm: (UIBarButtonItem*) sender
{

    //get pdf data to print
    NSData* dataToPrint = [[[GeneratePrintPDF alloc] init] getPrintData];
    
    //new print controller
    UIPrintInteractionController *printController = [UIPrintInteractionController sharedPrintController];
    
    //set properties
    printController.delegate = self;
        
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = [[[QuestionList sharedInstance] fileNameToBeSavedAs] lastPathComponent];
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    
    printController.printInfo = printInfo;
    printController.showsPageRange = YES;
    
    printController.printingItem = dataToPrint;
    
    
    //print error message if failed
    void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if (!completed && error) {
            NSLog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);
        }
    };
    
    
    //display print controller
    [printController presentFromBarButtonItem:sender animated:YES completionHandler:completionHandler];
    
}

@end
