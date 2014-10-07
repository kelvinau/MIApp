//
//  MediaAttachment.m
//  MIApp
//
//  Created by Gursimran Singh on 2014-02-25.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "MediaAttachment.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "QuestionList.h"
#import "ManageMediaCollectionView.h"
#import "RecordSound.h"

@implementation MediaAttachment
{
    UIBarButtonItem* mediaBarButton;
    UIButton* mediaButton;
    id parentView;
    NSString* recordAudioMediaFilePath;
}

@synthesize mediaBadge, number, popOver;


//initialize a media badge
-(id) initWithId: (NSNumber*) num forView: (DisplayQuestionType*) view
{
    self = [super init];
    
    if(self){
        
        //save paramenters
        self.mediaBadge = [[MKNumberBadgeView alloc] init];
        self.number = num;
        parentView = view;
        return self;
    }
    return nil;
    
}

//returns the media button with everything setup
-(UIBarButtonItem*) setUpButtonAtOrigin:(CGPoint)origin
{
    //get image
    UIImage* cameraButtonImage = [UIImage imageNamed:@"CameraButton.png"];
    
    //set size
    double cameraButtonWidth = cameraButtonImage.size.width;
    double cameraButtonHeight = cameraButtonImage.size.height;
    
    //initialize button and set properties
    mediaButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, cameraButtonWidth, cameraButtonHeight)];
    [mediaButton setImage:cameraButtonImage forState:UIControlStateNormal];
    [mediaButton addTarget:self action:@selector(cameraButtonPressed:) forControlEvents:UIControlEventTouchDown];
    
    //create bar button from button
    mediaBarButton = [[UIBarButtonItem alloc] initWithCustomView:mediaButton];

    //setup badge for this button
    [self setUpMediaBadge];
    
    mediaBarButton.tag = 100;
    
    //return bar button
    return mediaBarButton;
}


//sets up the badge for this button
-(void) setUpMediaBadge
{
    self.mediaBadge.frame = CGRectMake(mediaButton.frame.size.width - 25, -20, 44, 40);
    [self.mediaBadge setValue:0];
    self.mediaBadge.userInteractionEnabled = NO;
    self.mediaBadge.exclusiveTouch = NO;
    [mediaButton addSubview:mediaBadge];
    self.mediaBadge.hideWhenZero = YES;
}

//called when user presses media button
- (void) cameraButtonPressed:(id)sender{
    
    //buttons to be displayed in action sheet
    NSString *actionSheetTitle = @"Attach Media"; // Title
    NSString *destroyTitle = @"Cancel"; // Button titles
    NSString *button1 = @"Take Photo or Video";
    NSString *button2 = @"Choose Existing Photo or Video";
    NSString *button3 = @"Voice Note";
    NSString *button4 = @"Manage Media";
    NSString *cancelTitle = @"Clicked elsewhere";
    
    //display action sheet
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:button1
                                  otherButtonTitles:button2, button3, button4, destroyTitle, nil];
    actionSheet.destructiveButtonIndex = 4;
    
    //disable toolbar so that user cant open another action sheet
    ((DisplayQuestionType*)parentView).navigationController.toolbar.userInteractionEnabled = NO;
    
    [actionSheet showFromBarButtonItem:mediaBarButton animated:YES];
}

//delegate called when user selects button on action sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex  { //Get the name of the current pressed button

    //perform some action depending on what button was pressed
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if  ([buttonTitle isEqualToString:@"Cancel"]) {
    }
    if ([buttonTitle isEqualToString:@"Take Photo or Video"]) {
        [self takePhoto];
    }
    if ([buttonTitle isEqualToString:@"Choose Existing Photo or Video"]) {
        [self selectPhoto];
    }
    if ([buttonTitle isEqualToString:@"Voice Note"]) {
        [self recordAudio:actionSheet];
    }
    if ([buttonTitle isEqualToString:@"Manage Media"]) {
        [self manageMedia:actionSheet];
    }
    if ([buttonTitle isEqualToString:@"Clicked elsewhere"]) {
    }
}

//action sheet dismissed delegate
-(void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //toolbar interaction is disabled to make sure user doesnt open another action sheet
    //enabled once action sheet is dismissed
    ((DisplayQuestionType*)parentView).navigationController.toolbar.userInteractionEnabled = YES;

}

-(void) actionSheetCancel:(UIActionSheet *)actionSheet
{
}

//called when user wants to record new movie or take new photo
-(IBAction)takePhoto
{
    
    //since another is view is displayed, need to save user answers first
    [(DisplayQuestionType*)parentView saveAnswers];
    
    
    //initialize a new imagepicker
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    //only camera source allowed
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    
    
    //both images and videos allowed
    imagePickerController.mediaTypes = @[(NSString *) kUTTypeImage,
                                         (NSString *) kUTTypeMovie];
    
    // image picker needs a delegate,
    [imagePickerController setDelegate:self];
    
    
    // Place image picker on the screen
    [parentView presentViewController:imagePickerController animated:YES completion:nil];
}

//called when user has an image/video selected
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [parentView dismissViewControllerAnimated:YES completion:nil];
    
    
    //get type of media if image or video
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    //save image
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self saveImage:image];
        
    }
    
    //save video
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Media is a video
        NSURL *url = info[UIImagePickerControllerMediaURL];
        [self saveMovie:url];
    }
    
    
    //update badge count
    [self updateMediaBadge];
    
}

-(void)test:(UIImage*) blah
{
    NSLog(@"test");
}

//called when user wants to select a movie or select an image from gallery
-(IBAction)selectPhoto
{
    
    //since another is view is displayed, need to save user answers first
    [(DisplayQuestionType*)parentView saveAnswers];
    
    //initialize a new imagepicker
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    //only gallery source allowed
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    
    //both video and images allowed
    imagePickerController.mediaTypes = @[(NSString *) kUTTypeImage,
                                         (NSString *) kUTTypeMovie];
    
    //set image gallery selection view size
    imagePickerController.preferredContentSize = CGSizeMake(1024, 768);
    
    // image picker needs a delegate,
    [imagePickerController setDelegate:self];
    
    
    // Place image picker on the screen
    [parentView presentViewController:imagePickerController animated:YES completion:nil];
    
}

//called when need to save video (either newly recorded or selected from gallery)
-(void)saveMovie:(NSURL*) url
{
    
    //get moview data
    NSData *videoData = [NSData dataWithContentsOfURL:url];
    
    //get save file path
    NSString *userDirectory = [[QuestionList sharedInstance] userPath];
    NSString *folderPath;
    if (([[QuestionList sharedInstance] engineerView]) && (![[QuestionList sharedInstance] engineerNewMI])) {
        folderPath = [[QuestionList sharedInstance] completedFilePathToBeUploaded];
    }else{
        folderPath = [[userDirectory stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
    }

    NSString* fileName = [[self getFileNameForMedia] stringByAppendingString:@".mov"];
    NSString* fullPath = [folderPath stringByAppendingString:fileName];

    
    //write data to file
    [videoData writeToFile:fullPath atomically:YES];
    
}

//called when need to save image (either newly taken or selected from gallery)
-(void)saveImage:(UIImage*) image{
    
    NSLog(@"image");
    //get image data
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
    
    
    //get file path
    NSString *userDirectory = [[QuestionList sharedInstance] userPath];
    NSString *folderPath;
    if (([[QuestionList sharedInstance] engineerView]) && (![[QuestionList sharedInstance] engineerNewMI])) {
        folderPath = [[QuestionList sharedInstance] completedFilePathToBeUploaded];
    }else{
        folderPath = [[userDirectory stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
    }
    NSString* fileName = [[self getFileNameForMedia] stringByAppendingString:@".jpg"];
    NSString* fullPath = [folderPath stringByAppendingString:fileName];
    
    //write image data to file
    [imageData writeToFile:fullPath atomically:YES];
}


//returns the name of file for next media to be saved
-(NSString*)getFileNameForMedia
{
    //get folder path
    NSString *userDirectory = [[QuestionList sharedInstance] userPath];
    NSString *folderPath;
    if (([[QuestionList sharedInstance] engineerView]) && (![[QuestionList sharedInstance] engineerNewMI])) {
        folderPath = [[QuestionList sharedInstance] completedFilePathToBeUploaded];
    }else{
        folderPath = [[userDirectory stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
    }
    
    //start filename by question number
    NSString *fileName = [NSString stringWithFormat:@"Qid%@", self.number.stringValue];
    
    
    //get list of all files for this question without extension
    NSArray* listOfFilesWithExtension = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    NSMutableArray *listOfFiles = [[NSMutableArray alloc] init];
    for (NSString* file in listOfFilesWithExtension) {
        //Remove the file extension
        [listOfFiles addObject:[file stringByDeletingPathExtension]];
    }
    
    
    //check if file by filename already exists
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF ==[c] %@", [NSString stringWithFormat: @"Qid%@",self.number.stringValue]];
    NSArray* filteredFormArray = [listOfFiles filteredArrayUsingPredicate:predicate];
    int nextNumber = 2;
    
    //keep incrementing file number and check if file with this name exists
    while ([filteredFormArray count] > 0) {
        fileName = [NSString stringWithFormat:@"Qid%@(%d)", self.number.stringValue, nextNumber];
        nextNumber++;
        predicate = [NSPredicate predicateWithFormat:@"SELF ==[c] %@", fileName];
        filteredFormArray = [listOfFiles filteredArrayUsingPredicate:predicate];
    }

    return fileName;
}


//updates media badge number
-(void) updateMediaBadge
{
    [self.mediaBadge setValue:[[self getSoundFiles] count] + [[self getVideoFiles] count] + [[self getImageFiles] count]];
}


//get list of video files
-(NSArray*) getVideoFiles
{
    NSArray* videoFiles = [self getfile:@".mov"];
    return videoFiles;
}


//get list of audio files
-(NSArray*) getSoundFiles
{
    NSArray* soundFiles = [self getfile:@".m4a"];
    return soundFiles;
}


//get list of image files
-(NSArray*) getImageFiles
{
    NSArray* imageFiles = [self getfile:@".jpg"];
    return imageFiles;
}


//get list of files of type
-(NSArray*) getfile:(NSString*) ofType
{
    
    //get MI folder path
    NSString *userDirectory = [[QuestionList sharedInstance] userPath];
    NSString *folderPath;
    if (([[QuestionList sharedInstance] engineerView]) && (![[QuestionList sharedInstance] engineerNewMI])) {
        folderPath = [[QuestionList sharedInstance] completedFilePathToBeUploaded];
    }else{
        folderPath = [[userDirectory stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
    }

    //get list of files of type
    NSArray* listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", ofType];
    
    
    //get list of files of type of only this question
    NSArray* listOfFilesForCurrentType = [listOfFiles filteredArrayUsingPredicate:predicate];
    NSPredicate *predicateForCurrentQuestion = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", [NSString stringWithFormat:@"Qid%@", self.number.stringValue]];
    return [listOfFilesForCurrentType filteredArrayUsingPredicate:predicateForCurrentQuestion];
}


//display manage media
-(void) manageMedia: (UIActionSheet*) actionSheet
{
    //instantiate a new manage media view from story board
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    //set properties
    ManageMediaCollectionView* mediaManageTable =   [mainStoryboard instantiateViewControllerWithIdentifier:@"MediaCollection"];
    mediaManageTable.currentQuestion = self.number;
    mediaManageTable.mediaBadge = self.mediaBadge;
    mediaManageTable.preferredContentSize = CGSizeMake(300, 350);
    
    //create a navigation controller
    UINavigationController* popNav = [[UINavigationController alloc] initWithRootViewController:mediaManageTable];
    
    //display popover
    [self displayPopOver:popNav :actionSheet];
    
}


-(void) displayPopOver:(UIViewController*) view :(UIActionSheet*) actionSheet
{
    
    //create new popover
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:view];
    
    UIButton* button = (UIButton*) [[parentView theScrollView] viewWithTag:100];
    CGRect buttonRect = button.frame;
    
    CGRect popRect = actionSheet.frame;
    popRect.size.height = 350.0f;
    popRect.size.width = 300.0f;
    popRect.origin.x = buttonRect.origin.x;
    
    [popover presentPopoverFromBarButtonItem:mediaBarButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    //save reference to popover
    popOver = popover;
    popover.passthroughViews = nil;
    
    //set properties if record sound popover
    if ([view isKindOfClass:[RecordSound class]]) {
        RecordSound* temp = (RecordSound*) view;
        [popOver setDelegate:self];
        temp.popOver = popOver;
    }
    
}

//popover delegate
//called when user closes recording sound popover
//need to decrement badge and delete file that was created for the session
-(void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [[NSFileManager defaultManager] removeItemAtPath:recordAudioMediaFilePath error:nil];
    [self updateMediaBadge];
}


//called when user wants to record audio
-(void) recordAudio : (UIActionSheet*) actionSheet
{
    //get recording view controller from storyboard
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RecordSound* recordSound = [mainStoryboard instantiateViewControllerWithIdentifier:@"recordSound"];
    
    //get new filename for recording
    NSString *userDirectory = [[QuestionList sharedInstance] userPath];
    NSString *folderPath;
    if (([[QuestionList sharedInstance] engineerView]) && (![[QuestionList sharedInstance] engineerNewMI])) {
        folderPath = [[QuestionList sharedInstance] completedFilePathToBeUploaded];
    }else{
        folderPath = [[userDirectory stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
    }
    NSString* fileName = [[self getFileNameForMedia] stringByAppendingString:@".m4a"];
    NSString* fullPath = [folderPath stringByAppendingString:fileName];
    
    //set properties of view
    recordAudioMediaFilePath = fullPath;
    recordSound.audioFilePath = recordAudioMediaFilePath;
    recordSound.mediaBadge = self.mediaBadge;
    recordSound.preferredContentSize = CGSizeMake(200, 250);
    
    //display popover
    [self displayPopOver:recordSound :actionSheet];
}



@end
