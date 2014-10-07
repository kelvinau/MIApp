//
//  MediaAttachmentButton.m
//  MIApp
//
//  Created by Gursimran Singh on 2014-02-25.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "MediaAttachmentButton.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "RecordSound.h"
#import "QuestionList.h"
#import "ManageMediaCollectionView.m"

@implementation MediaAttachmentButton
//{
//    UIButton* cameraButton;
//    UIViewController* parentView;
//}
//
//@synthesize mediaBadge, number, popOver;
//
//-(id) initWithId: (NSNumber*) num forView: (UIViewController*) view
//{
//    self = [super init];
//    
//    if(self){
//        self.mediaBadge = [[MKNumberBadgeView alloc] init];
//        self.number = num;
//        parentView = view;
//        return self;
//    }
//    return nil;
//    
//}
//
//-(UIButton*) setUpButtonAtOrigin:(CGPoint)origin
//{
//    UIImage* cameraButtonImage = [UIImage imageNamed:@"CameraButton.png"];
//    double cameraButtonWidth = cameraButtonImage.size.width;
//    double cameraButtonHeight = cameraButtonImage.size.height;
//    double cameraButtonXaxis = origin.x - cameraButtonWidth - 20;
//    double cameraButtonYaxis = origin.y + 50;
//    cameraButton = [[UIButton alloc] initWithFrame:CGRectMake(cameraButtonXaxis, cameraButtonYaxis, cameraButtonWidth, cameraButtonHeight)];
//    [cameraButton setImage:cameraButtonImage forState:UIControlStateNormal];
//    //[cameraButton setSelected:YES];
//    [cameraButton addTarget:self action:@selector(cameraButtonPressed:) forControlEvents:UIControlEventTouchDown];
//    [self setUpMediaBadge];
//    
//    return cameraButton;
//}
//
//
//-(void) setUpMediaBadge
//{
//    self.mediaBadge.frame = CGRectMake(cameraButton.frame.size.width - 25, -20, 44, 40);
//    
//    self.mediaBadge.userInteractionEnabled = NO;
//    self.mediaBadge.exclusiveTouch = NO;
//    [cameraButton addSubview:mediaBadge];
//    mediaBadge.hideWhenZero = YES;
//}
//
//- (void) cameraButtonPressed:(id)sender{
//    NSString *actionSheetTitle = @"Attach Media"; // Title
//    NSString *destroyTitle = @"Cancel"; // Button titles
//    NSString *button1 = @"Take Photo or Video";
//    NSString *button2 = @"Choose Existing Photo or Video";
//    NSString *button3 = @"Voice Note";
//    NSString *button4 = @"Manage Media";
//    NSString *cancelTitle = @"Clicked elsewhere";
//    UIActionSheet *actionSheet = [[UIActionSheet alloc]
//                                  initWithTitle:actionSheetTitle
//                                  delegate:self
//                                  cancelButtonTitle:cancelTitle
//                                  destructiveButtonTitle:button1
//                                  otherButtonTitles:button2, button3, button4, destroyTitle, nil];
//    actionSheet.destructiveButtonIndex = 4;
//    
//    //[actionSheet dismissWithClickedButtonIndex:5 animated:YES];
//    
//    UIButton *button = (UIButton*)sender;
//    
//    [actionSheet showFromRect:button.frame inView: button.superview animated: YES];
//}
//
//
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex  { //Get the name of the current pressed button
//    
//    
//    
//    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
//    if  ([buttonTitle isEqualToString:@"Cancel"]) {
//    }
//    if ([buttonTitle isEqualToString:@"Take Photo or Video"]) {
//        [self takePhoto];
//    }
//    if ([buttonTitle isEqualToString:@"Choose Existing Photo or Video"]) {
//        [self selectPhoto];
//    }
//    if ([buttonTitle isEqualToString:@"Voice Note"]) {
//        [self recordAudio:actionSheet];
//    }
//    if ([buttonTitle isEqualToString:@"Manage Media"]) {
//        [self manageMedia:actionSheet];
//    }
//    if ([buttonTitle isEqualToString:@"Clicked elsewhere"]) {
//    }
//}
//
//
//-(IBAction)takePhoto
//{
//    //[self saveAnswers];
//    
//    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//    
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
//    {
//        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
//    }
//    
//    imagePickerController.mediaTypes = @[(NSString *) kUTTypeImage,
//                                         (NSString *) kUTTypeMovie];
//    
//    // image picker needs a delegate,
//    [imagePickerController setDelegate:self];
//    
//    
//    // Place image picker on the screen
//    [parentView presentViewController:imagePickerController animated:YES completion:nil];
//}
//
//
//-(IBAction)selectPhoto
//{
//    
//    //[self saveAnswers];
//    
//    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//    
//    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
//    {
//        [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//    }
//    
//    imagePickerController.mediaTypes = @[(NSString *) kUTTypeImage,
//                                         (NSString *) kUTTypeMovie];
//    
//    imagePickerController.preferredContentSize = CGSizeMake(1024, 768);
//    
//    // image picker needs a delegate,
//    [imagePickerController setDelegate:self];
//    
//    
//    // Place image picker on the screen
//    [parentView presentViewController:imagePickerController animated:YES completion:nil];
//    
//    //    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
//    //
//    //    [popover presentPopoverFromRect:CGRectMake(1024, 768, 1, 1) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    //    [popover setPopoverContentSize:CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height) animated:NO];
//    //    //[popover presentPopoverFromRect:self.theScrollView.bounds inView:self.theScrollView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    //    self.popOver = popover;
//}
//
//
//-(void) recordAudio: (UIActionSheet*) actionSheet
//{
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    RecordSound* recordSound = [mainStoryboard instantiateViewControllerWithIdentifier:@"recordSound"];
//    NSString *userDirectory = [[QuestionList sharedInstance] userPath];
//    NSString *folderPath = [[userDirectory stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
//    NSString* fileName = [[self getFileNameForMedia] stringByAppendingString:@".m4a"];
//    NSString* fullPath = [folderPath stringByAppendingString:fileName];
//    recordSound.audioFilePath = fullPath;
//    recordSound.mediaBadge = self.mediaBadge;
//    recordSound.preferredContentSize = CGSizeMake(300, 350);
//    [self displayPopOver:recordSound :actionSheet];
//}
//
//-(NSString*)getFileNameForMedia
//{
//    NSString *userDirectory = [[QuestionList sharedInstance] userPath];
//    NSString *folderPath = [[userDirectory stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
//    NSString *fileName = [NSString stringWithFormat:@"Qid%@", self.number.stringValue];
//    
//    NSArray* listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", [NSString stringWithFormat: @"Qid%@",self.number.stringValue]];
//    NSArray* filteredFormArray = [listOfFiles filteredArrayUsingPredicate:predicate];
//    if ([filteredFormArray count] == 1){
//        fileName = [NSString stringWithFormat:@"Qid%@(02)", self.number.stringValue];
//    }
//    else if ([filteredFormArray count] > 1){
//        filteredFormArray = [filteredFormArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
//        
//        NSString *newName = [filteredFormArray lastObject];
//        NSCharacterSet *delimiters = [NSCharacterSet characterSetWithCharactersInString:@"()"];
//        NSNumber *splitString = [[NSNumber alloc] initWithInt:[[[newName componentsSeparatedByCharactersInSet:delimiters] objectAtIndex:1] intValue]];
//        int nextNumber = [splitString intValue] + 1;
//        fileName = [NSString stringWithFormat:@"Qid%@(%02d)", self.number.stringValue, nextNumber];
//    }
//    return fileName;
//}
//
//-(void) displayPopOver:(UIViewController*) view :(UIActionSheet*) actionSheet
//{
//    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:view];
//    
//    CGRect button = cameraButton.frame;
//    
//    CGRect popRect = actionSheet.frame;
//    popRect.size.height = 350.0f;
//    popRect.size.width = 300.0f;
//    popRect.origin.x = button.origin.x;
//    CGRect test = CGRectMake(button.origin.x, parentView.view.frame.size.height - popRect.size.height - button.origin.y + button.size.height/2 + 350/2, 300, 350);
//    //popRect.origin.y = self.view.frame.size.height - button.origin.y + (button.size.height/2);
//    //popRect.origin.x = self.view.frame.size.width - popRect.origin.x;
//    //popRect.origin.y = self.view.frame.size.height - popRect.origin.y;
//    
//    [popover presentPopoverFromRect:test inView:parentView.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    
//    //    NSLog(@"%f %f %f %f", popover.v origin.x, popRect.origin.y, popRect.size.width, popRect.size.height);
//    
//    //[popover setPopoverContentSize:CGSizeMake(300, 500) animated:NO];
//    
//    popOver = popover;
//    
//    if ([view isKindOfClass:[RecordSound class]]) {
//        RecordSound* temp = (RecordSound*) view;
//        temp.popOver = popOver;
//    }
//    
//}
//
//
////delegate methode will be called after picking photo either from camera or library
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//{
//    [parentView dismissViewControllerAnimated:YES completion:nil];
//    
//    NSString *mediaType = info[UIImagePickerControllerMediaType];
//    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
//    {
//        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
//        [self saveImage:image];
//        
//    }
//    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
//    {
//        // Media is a video
//        NSURL *url = info[UIImagePickerControllerMediaURL];
//        [self saveMovie:url];
//    }
//    
//    [self updateMediaBadge];
//    
//    //[myImageView setImage:image];    // "myImageView" name of any UImageView.
//}
//
//-(void)saveMovie:(NSURL*) url
//{
//    NSData *videoData = [NSData dataWithContentsOfURL:url];
//    
//    NSString *userDirectory = [[QuestionList sharedInstance] userPath];
//    NSString *folderPath = [[userDirectory stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
//    
//    NSString* fileName = [[self getFileNameForMedia] stringByAppendingString:@".mov"];
//    NSString* fullPath = [folderPath stringByAppendingString:fileName];
//    
//    [videoData writeToFile:fullPath atomically:YES];
//    
//}
//-(void)saveImage:(UIImage*) image{
//    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
//    
//    NSString *userDirectory = [[QuestionList sharedInstance] userPath];
//    NSString *folderPath = [[userDirectory stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
//    
//    NSString* fileName = [[self getFileNameForMedia] stringByAppendingString:@".jpg"];
//    NSString* fullPath = [folderPath stringByAppendingString:fileName];
//    
//    [imageData writeToFile:fullPath atomically:YES];
//}
//
//-(void) updateMediaBadge
//{
//    
//    //[self.mediaBadge setValue:[[self getSoundFiles] count] + [[self getVideoFiles] count] + [[self getImageFiles] count]];
//    
//}
//
//-(NSArray*) getVideoFiles
//{
//    NSArray* videoFiles = [self getfile:@".mov"];
//    return videoFiles;
//}
//
//-(NSArray*) getSoundFiles
//{
//    NSArray* soundFiles = [self getfile:@".m4a"];
//    return soundFiles;
//}
//
//-(NSArray*) getImageFiles
//{
//    NSArray* imageFiles = [self getfile:@".jpg"];
//    return imageFiles;
//}
//
//
//-(NSArray*) getfile:(NSString*) ofType
//{
//    NSString *userDirectory = [[QuestionList sharedInstance] userPath];
//    NSString *folderPath = [[userDirectory stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
//    //NSString *fileName = [NSString stringWithFormat:@"Qid%@", self.id.stringValue];
//    NSArray* listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", ofType];
//    
//    NSArray* listOfFilesForCurrentType = [listOfFiles filteredArrayUsingPredicate:predicate];
//    NSPredicate *predicateForCurrentQuestion = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", [NSString stringWithFormat:@"Qid%@", self.number.stringValue]];
//    return [listOfFilesForCurrentType filteredArrayUsingPredicate:predicateForCurrentQuestion];
//}
//
//
//-(void) manageMedia:(UIActionSheet*) actionSheet
//{
//    
//    //        UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
//    //        [aFlowLayout setItemSize:CGSizeMake(300, 320)];
//    //        [aFlowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
//    //        ManageMediaCollectionView* mediaManageTable = [[ManageMediaCollectionView alloc]initWithCollectionViewLayout:aFlowLayout];
//    //        mediaManageTable.currentQuestion = self.id;
//    //        [mediaManageTable.collectionView registerClass:[ManageMediaHeaderCollectionView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ManageMediaCell"];
//    //        [mediaManageTable.collectionView registerClass:[ManageMediaCell class] forCellWithReuseIdentifier:@"ManageMediaCell"];
//    
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    ManageMediaCollectionView* mediaManageTable =   [mainStoryboard instantiateViewControllerWithIdentifier:@"MediaCollection"];
//    mediaManageTable.currentQuestion = self.number;
//    mediaManageTable.mediaBadge = self.mediaBadge;
//    mediaManageTable.preferredContentSize = CGSizeMake(300, 350);
//    UINavigationController* popNav = [[UINavigationController alloc] initWithRootViewController:mediaManageTable];
//    
//    [self displayPopOver:popNav :actionSheet];
//    
//}
//
@end
