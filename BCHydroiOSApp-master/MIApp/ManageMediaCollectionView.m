//
//  ManageMediaCollectionView.m
//  MIApp
//
//  Created by Gursimran Singh on 12/31/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import "ManageMediaCollectionView.h"
#import "ManageMediaCell.h"
#import "ManageMediaHeaderCollectionView.h"
#import "QuestionList.h"
#import <AVFoundation/AVFoundation.h>
#import "DisplaySelectedMedia.h"
@implementation ManageMediaCollectionView
{
    NSArray* videoFiles;
    NSArray* imageFiles;
    NSArray* soundFiles;
    NSMutableArray* selectedMedia;
}

@synthesize currentQuestion, mediaBadge;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setTitle:@"Manage Media"];
    
    [self reloadAllMedia];
        // to reload selected cell
}


//reloads all media
-(void) reloadAllMedia
{
    
    //get all media files
    [self getVideoFiles];
    [self getImageFiles];
    [self getSoundFiles];
    
    //set badge value
    [self.mediaBadge setValue:[imageFiles count] + [soundFiles count] + [videoFiles count]];

    [[[self navigationItem] leftBarButtonItem] setEnabled:YES];
    
    
    //reload collection view
    [[self collectionView] reloadData];
}


-(void) viewDidLoad{
    [super viewDidLoad];
    [self setTitle:@"Manage Media"];
    
    //set left button as edit button
    UIBarButtonItem* editButton = self.editButtonItem;
    [editButton setTarget:self];
    [editButton setAction:@selector(editMedia:)];
    [self.navigationItem setLeftBarButtonItem:editButton];
    
    //no media selected no delete
    selectedMedia = [[NSMutableArray alloc] init];
}


//setup for editing when user presses edit
-(IBAction)editMedia:(id)sender
{
    
    //In edit mode user should be able to select multiple items in collection view
    //when user is not editing, selecting one item open up that selected item
    
    //turn off editing when user taps 'done'
    if ([[self collectionView] allowsMultipleSelection]) {
        [[[self navigationItem] leftBarButtonItem] setTitle:@"Edit"];
        [[[self navigationItem] leftBarButtonItem] setStyle:UIBarButtonItemStylePlain];
        [[self collectionView] setAllowsMultipleSelection:NO];
        [[self navigationItem] setRightBarButtonItem:NULL];
        for (NSIndexPath* path in [[self collectionView] indexPathsForSelectedItems]) {
            [self.collectionView deselectItemAtIndexPath:path animated:NO];
        }
    }
    
    //turn on editing when user taps 'edit'
    else{
        [[[self navigationItem] leftBarButtonItem] setTitle:@"Done"];
        [[[self navigationItem] leftBarButtonItem] setStyle:UIBarButtonItemStyleDone];
        [[self collectionView] setAllowsMultipleSelection:YES];
        UIBarButtonItem* deleteItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAction:)];
        deleteItem.enabled= NO;
        [[self navigationItem] setRightBarButtonItem:deleteItem];
        
    }
    
    //ipdate title when user has selected multiple
    [self updateTitleWhenMultipleSelected];
}


//when user selects an item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //is user in edit mode then add media to selected
    if ([[self collectionView] allowsMultipleSelection]) {
        [selectedMedia addObject:indexPath];
        if ([selectedMedia count] > 0) {
            [[[self navigationItem] rightBarButtonItem] setEnabled:YES];
        }
        [self updateTitleWhenMultipleSelected];
    }
    //else open that media
    else{
        [self performSegueWithIdentifier:@"DisplayMedia" sender:self];
    }
}

//when user de selects an item
//can only happen when user editing
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //remove media from list of selected media
    NSArray* temp = [[NSArray alloc] initWithArray:selectedMedia];
    for (int i =0; i < [temp count]; i++) {
        NSIndexPath* path = [temp objectAtIndex:i];
        if ((path.row == indexPath.row) && (path.section == indexPath.section)) {
            [selectedMedia removeObjectAtIndex:i];
            break;
        }
    }
    
    //update title
    [self updateTitleWhenMultipleSelected];
    
    //diable delete when no medai selected
    if ([selectedMedia count] == 0) {
        [[[self navigationItem] rightBarButtonItem] setEnabled:NO];
    }

}


//update title to display how many media items selected
-(void) updateTitleWhenMultipleSelected
{
    
    if ([self.collectionView allowsMultipleSelection]) {
    NSInteger totalItemsSelected = [[self.collectionView indexPathsForSelectedItems] count];
    if(totalItemsSelected == 0){
        [self setTitle:@"Manage Media"];
    }
    else if (totalItemsSelected == 1){
        self.title = [NSString stringWithFormat:@"%ld item selected", (long)totalItemsSelected];
    }else{
        self.title = [NSString stringWithFormat:@"%ld items selected", (long)totalItemsSelected];
    }
    }else{
        [self setTitle:@"Manage Media"];
    }
}


//delete button pressed
-(void) deleteAction: (id) sender
{

    //for every media selected, delete that item
    for(NSIndexPath* path in [self.collectionView indexPathsForSelectedItems]){
        NSString* headerTitle = [self getTitleOfHeader:path.section];
        NSString* filePath;
        
        //check what type of media that is
        if ([headerTitle isEqualToString:@"Images"]) {
            filePath = [self getFileLocation:[imageFiles objectAtIndex:path.row]];
        }else if([headerTitle isEqualToString:@"Videos"]){
            filePath = [self getFileLocation:[videoFiles objectAtIndex:path.row]];
        }else if([headerTitle isEqualToString:@"Voice"]){
            filePath = [self getFileLocation:[soundFiles objectAtIndex:path.row]];
        }
        
        //delete file
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        [fileMgr removeItemAtPath:filePath error:NULL];
    }
    
    //update collection view
    [self editMedia:self];
    [self reloadAllMedia];
    
}


//get list of video files
-(void) getVideoFiles
{
    videoFiles = [self getfile:@".mov"];
}


//get list of audio files
-(void) getSoundFiles
{
    soundFiles = [self getfile:@".m4a"];
}

//get list of images
-(void) getImageFiles
{
    imageFiles = [self getfile:@".jpg"];
}


//get list of files of type
-(NSArray*) getfile:(NSString*) ofType
{
    
    //get folder path of MI
    NSString *userPath = [[QuestionList sharedInstance] userPath];
    NSString *folderPath = [[userPath stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
   
    //get list of all files of type
    NSArray* listOfFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", ofType];
    
    
    //from sublist get files for only this question
    NSArray* listOfFilesForCurrentType = [listOfFiles filteredArrayUsingPredicate:predicate];
    NSPredicate *predicateForCurrentQuestion = [NSPredicate predicateWithFormat:@"SELF contains[c] %@", [NSString stringWithFormat:@"Qid%@", currentQuestion.stringValue]];
    return [listOfFilesForCurrentType filteredArrayUsingPredicate:predicateForCurrentQuestion];
}

//depending on how what media exists, get number of sections
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // Return the number of sections.
    NSInteger numSections = 0;
    if ([imageFiles count] > 0){
        numSections++;
    }
    if ([videoFiles count] > 0){
        numSections++;
    }
    if([soundFiles count] > 0){
        numSections++;
    }
    
    //if no media then display media error
    if (numSections == 0) {
        [self displayNoMediaMessage];
    }
    return numSections;
}


//display no media error
-(void) displayNoMediaMessage
{
    [[[self navigationItem] leftBarButtonItem] setEnabled:NO];
    UITextView* message = [[UITextView alloc] initWithFrame:CGRectMake(0, ([self preferredContentSize].height / 4) - 20, [self preferredContentSize].width, ([self preferredContentSize].height / 2) + 20)];
    message.text = @"No Media Selected";
    message.font = [UIFont boldSystemFontOfSize:20];
    message.textAlignment = NSTextAlignmentCenter;
    message.textColor = [UIColor grayColor];
    message.editable = NO;
    [[self view] addSubview:message];
    self.mediaBadge.value = 0;
}

//returns the number of items for each type of media
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString* titleOfHeader = [[NSString alloc] init];
    
    //get title for header
    titleOfHeader = [self getTitleOfHeader:section];
    NSInteger numRows = 0;
    
    //num of rows in media
    if ([titleOfHeader isEqualToString:@"Images"]){
        numRows = [imageFiles count];
    } else if ([titleOfHeader isEqualToString:@"Videos"]){
        numRows = [videoFiles count];
    } else if ([titleOfHeader isEqualToString:@"Voice"]){
        numRows = [soundFiles count];
    }
    return numRows;
}


//return cell for location
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ManageMediaCell";
    
    ManageMediaCell *cvc = (ManageMediaCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    //get image to display in cell
    cvc.imageView.image = [self getImage:indexPath];

    
    //set selected image
    //this image is displayed when user selects a media item to delete
    UIImageView* selectedCheckMarkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"CheckMark"]];
    cvc.selectedBackgroundView = selectedCheckMarkView;

    return cvc;
}


//returns image for cell at
-(UIImage*) getImage: (NSIndexPath*) at
{
    
    //get type of media
    NSString* section = [self getTitleOfHeader:at.section];
    UIImage* image;
    
    //if media is image then set image
    if([section isEqualToString:@"Images"]){
        NSString* filePath = [self getFileLocation:[imageFiles objectAtIndex:at.row]];
        image = [[UIImage alloc] initWithData:[[NSData alloc] initWithContentsOfFile:filePath]];
    }
    //if media if video then get thumbnail of video
    else if ([section isEqualToString:@"Videos"]){
        NSString* location = [self getFileLocation:[videoFiles objectAtIndex:at.row]];
        image = [self getVideoThumbnail:location];
    }
    //if media is audio then set image of mic
    else if ([section isEqualToString:@"Voice"]){
        image = [UIImage imageNamed:@"voiceImage"];
    }
    return image;
}


//return thumbnail of video file
-(UIImage*) getVideoThumbnail: (NSString*) of{
    AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:of] options:nil];
    AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
    generate1.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    
    //at time 1 second
    CMTime time = CMTimeMake(0, 1);
    CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
    UIImage *one = [[UIImage alloc] initWithCGImage:oneRef];
    return one;
}

//get full path of file
-(NSString*) getFileLocation: (NSString*) fileName
{
    NSString *userPath = [[QuestionList sharedInstance] userPath];
    NSString *folderPath = [[userPath stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
    NSString *filePath = [folderPath stringByAppendingString:fileName];
    
    return filePath;
    
}


//get header view
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    ManageMediaHeaderCollectionView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
    
    
    headerView.headerTitle.text = [self getTitleOfHeader:indexPath.section];
    
    reusableview = headerView;
    
    return reusableview;
}


//returns title of section
-(NSString*) getTitleOfHeader: (NSInteger) at
{
    NSString *sectionName;
    
    switch (at)
    {
        case 0:
            if([imageFiles count] > 0){
                sectionName = @"Images";
            }
            else if ([videoFiles count] > 0){
                sectionName = @"Videos";
            }
            else{
                sectionName = @"Voice";
            }
            break;
        case 1:
            if (([videoFiles count] > 0) && (([imageFiles count] > 0))){
                sectionName = @"Videos";
            }
            else{
                sectionName = @"Voice";
            }
            break;
        case 2:
            sectionName = @"Voice";
            break;
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}


//set up variables in view to be presented
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get reference to the destination view controller
    DisplaySelectedMedia *vc = [segue destinationViewController];
    
    // Pass any objects to the view controller here, like...
    [vc setPreferredContentSize:[self preferredContentSize]];
    [vc setSoundList:[[NSMutableArray alloc] initWithArray:soundFiles]];
    [vc setImageList:[[NSMutableArray alloc] initWithArray:imageFiles]];
    [vc setVideoList:[[NSMutableArray alloc] initWithArray:videoFiles]];
    NSIndexPath* selectedIndex = (NSIndexPath*)[[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
    [vc setSelectedMedia:selectedIndex];
    [vc setMediaBadge:self.mediaBadge];
    [vc setHeaderTitle:[self getTitleOfHeader:selectedIndex.section]];
    
}

@end
