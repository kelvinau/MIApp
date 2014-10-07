//
//  DisplaySelectedMedia.m
//  MIApp
//
//  Created by Gursimran Singh on 12/31/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import "DisplaySelectedMedia.h"
#import "QuestionList.h"

@implementation DisplaySelectedMedia
{
    NSInteger currentSection;
    NSInteger currentItem;
}

@synthesize selectedMedia, soundList, videoList, imageList, headerTitle, image, moviePlayer, mediaBadge;

-(void) viewDidLoad{
    [super viewDidLoad];
    
    currentSection = [self selectedMedia].section;
    currentItem = [self selectedMedia].row;
    
    
    self.moviePlayer = [[MPMoviePlayerController alloc] init];

    
    //hide status bar for when playing video in full screen
    [self prefersStatusBarHidden];
    [self setNeedsStatusBarAppearanceUpdate];

    //add left and right gesture to navigate between media
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(mediaSwipedRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(mediaSwipedLeft:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    
    //delete button to delete media
    UIBarButtonItem* deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteMedia:)];
    
    self.navigationItem.rightBarButtonItem = deleteButton;
    
}


//UIViewController method to override when status bar needs to be hidden
- (BOOL)prefersStatusBarHidden
{
    return YES;
}


//method called when media is deleted
-(void)deleteMedia:(id)sender
{
    
    //get title of type of media
    NSString* section = [self getSectionTitle];
    if([section isEqualToString:@"Images"]){
        //get file path
        NSString* filePath = [self getFileLocation:[self.imageList objectAtIndex:currentItem]];
        
        //remove from list
        [imageList removeObjectAtIndex:currentItem];
        
        //delete file
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        [fileMgr removeItemAtPath:filePath error:NULL];
    }
    else if([section isEqualToString:@"Videos"]){
        //get file path
        NSString* filePath = [self getFileLocation:[self.videoList objectAtIndex:currentItem]];
        
        //remove from list
        [videoList removeObjectAtIndex:currentItem];
        
        //delete file
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        [fileMgr removeItemAtPath:filePath error:NULL];
    } else if([section isEqualToString:@"Voice"]){
        
        //get file path
        NSString* filePath = [self getFileLocation:[self.soundList objectAtIndex:currentItem]];
        
        //remove from list
        [soundList removeObjectAtIndex:currentItem];
        
        //remove file
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        [fileMgr removeItemAtPath:filePath error:NULL];
    }
    
    //update badge
    [self.mediaBadge setValue:[videoList count] + [imageList count] + [soundList count]];
    
    //display next media
    [self mediaDisplayAfterDelete];
}


//stop currently playing media
-(void)stopPlayingMedia
{
    [moviePlayer stop];
}


//display previous/next media after deleting a media item
- (void)mediaDisplayAfterDelete
{
    //if no more media then go back and display error
    if ([self getTotalMedia] == 0){
        [self stopPlayingMedia];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        
        //decrement current item and display
        currentItem--;
        
        //if at first object then display next item instead of previous
        if ([self mediaSwipedRight:NULL]){
            currentItem++;
            [self mediaSwipedLeft:NULL];
        }}
}


//display next item
- (BOOL)mediaSwipedRight:(UISwipeGestureRecognizer *)sender
{
    
    //stop currently playing media
    [self stopPlayingMedia];
    
    BOOL lastObject = NO;
    
    
    //if no more item in section then return
    if ([self getSectionTotalItems] == 0) {
        return YES;
    }
    
    //check if this item in section then display in next section
    if((currentItem+1) == [self getSectionTotalItems]){
        
        //check if last section
        if (currentSection+1 == [self getTotalSections]){
            lastObject = YES;
            [self displayMedia];
        }else{
            //increment first object of next section
            currentSection++;
            currentItem = 0;
        }
    }
    
    //increment item in current section
    else{
        currentItem++;
    }
    
    
    //if this is not the last object then display
    if (!lastObject) {
        [self displayMedia];
    }
    
    return lastObject;
}

//display previous item
- (BOOL)mediaSwipedLeft:(UISwipeGestureRecognizer *)sender
{
    
    //stop playing media
    [self stopPlayingMedia];
    
    BOOL firstObject = NO;
    
    
    //if this is first item
    if((currentItem) == 0){
        //if first section
        if (currentSection == 0){
            firstObject = YES;
            [self displayMedia];
        }else{
            //decrement section
            currentSection--;
            currentItem = [self getSectionTotalItems] - 1;
        }
    }else{
        
        //decrement item
        currentItem--;
    }
    
    if (!firstObject) {
        [self displayMedia];
    }
    return firstObject;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //set image fram
    self.image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, [self preferredContentSize].width, [self preferredContentSize].height - 80)];
    
    [self.view addSubview:image];
    
    //display selected media
    [self displayMedia];
}


//display media at section and position
-(void) displayMedia
{
    //change title depending on what media is being displayed
    [self changeTitle];
    
    NSString* section = [self getSectionTitle];
    
    //if image then display image
    if([section isEqualToString:@"Images"]){
        NSString* filePath = [self getFileLocation:[self.imageList objectAtIndex:currentItem]];
        image.image = [[UIImage alloc] initWithData:[[NSData alloc] initWithContentsOfFile:filePath]];
        [self.moviePlayer.view removeFromSuperview];
    }
    
    //if video
    else if([section isEqualToString:@"Videos"]){
        [self.moviePlayer.view removeFromSuperview];
        
        //get file path
        NSString* filePath = [self getFileLocation:[self.videoList objectAtIndex:currentItem]];
        
        NSURL* videoUrl = [NSURL fileURLWithPath:filePath];
        
        
        //initialize movie player with video
        [self.moviePlayer setContentURL:videoUrl];
        
        //set media player properties
        moviePlayer.controlStyle = MPMovieControlStyleDefault;
        [moviePlayer.view setFrame:CGRectMake(0, 40, [self preferredContentSize].width, [self preferredContentSize].height - 80)];
        moviePlayer.shouldAutoplay = NO;
        moviePlayer.allowsAirPlay = NO;
        [self.view addSubview:moviePlayer.view];
        [moviePlayer setFullscreen:NO animated:YES];
    }
    //if audio
    else if([section isEqualToString:@"Voice"]){
        [self.moviePlayer.view removeFromSuperview];
        
        //get file location
        NSString *soundFile = [self getFileLocation:[self.soundList objectAtIndex:currentItem]];
        
        //uses same player as movie player
        NSURL* videoUrl = [NSURL fileURLWithPath:soundFile];
        
        //add image instead of black screen when playing audio
        [image setImage:[UIImage imageNamed:@"voiceImageFull"]];
        
        //set player properties
        [self.moviePlayer setContentURL:videoUrl];
        moviePlayer.controlStyle = MPMovieControlStyleDefault;
        [moviePlayer.view setFrame:CGRectMake(0, [self preferredContentSize].height - 80, [self preferredContentSize].width, [self preferredContentSize].height - 310)];
        moviePlayer.shouldAutoplay = NO;
        moviePlayer.allowsAirPlay = NO;
        [self.view addSubview:moviePlayer.view];
        [moviePlayer setFullscreen:NO animated:YES];
    }
    
    
}


//set title of view
-(void) changeTitle
{
    NSInteger totalItems = [self getTotalMedia];
    NSString* headerTitleOfCurrentItem = [self getSectionTitle];
    NSInteger currentItemWithRespectToAll = 0;
    if ([headerTitleOfCurrentItem isEqualToString:@"Images"]) {
        currentItemWithRespectToAll = currentItem + 1;
    }
    else if ([headerTitleOfCurrentItem isEqualToString:@"Videos"]){
        currentItemWithRespectToAll = currentItem + 1 + [imageList count];
    }
    else if ([headerTitleOfCurrentItem isEqualToString:@"Voice"]){
        currentItemWithRespectToAll = currentItem + 1 + [imageList count] + [videoList count];
    }
    self.title = [NSString stringWithFormat:@"%ld of %ld", (long)currentItemWithRespectToAll, (long)totalItems];
}


//returns total count of media
-(NSInteger)getTotalMedia
{
    return [imageList count] + [videoList count] + [soundList count];
}


//returns total of current section
-(NSInteger) getSectionTotalItems
{
    NSInteger sectionTotal = 0;
    NSString* section = [self getSectionTitle];
    if([section isEqualToString:@"Images"]){
        sectionTotal = sectionTotal + [imageList count];
    }
    else if([section isEqualToString:@"Videos"]){
        sectionTotal = sectionTotal + [videoList count];
    }
    else if([section isEqualToString:@"Voice"]){
        sectionTotal = sectionTotal + [soundList count];
    }
    return sectionTotal;
}


//returns total sections
-(NSInteger)getTotalSections
{
    NSInteger count = 0;
    if ([imageList count] > 0) {
        count++;
    }
    if([videoList count]>0){
        count++;
    }
    if([soundList count] > 0){
        count++;
    }
    return count;
}


//returns the title
-(NSString*) getSectionTitle{
    NSString *sectionName;
    switch (currentSection)
    {
        case 0:
            if([imageList count] > 0){
                sectionName = @"Images";
            }
            else if ([videoList count] > 0){
                sectionName = @"Videos";
            }
            else{
                sectionName = @"Voice";
            }
            break;
        case 1:
            if (([videoList count] > 0) && ([imageList count])){
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


//returns the location (full path) of file
-(NSString*) getFileLocation: (NSString*) fileName
{
    NSString* userPath = [[QuestionList sharedInstance] userPath];
    NSString *folderPath;
    if (([[QuestionList sharedInstance] engineerView]) && (![[QuestionList sharedInstance] engineerNewMI])) {
        folderPath = [[QuestionList sharedInstance] completedFilePathToBeUploaded];
    }else{
        folderPath = [[userPath stringByAppendingPathComponent:[[QuestionList sharedInstance] fileNameToBeSavedAs]] stringByAppendingString:@"/"];
    }
    
    NSString *filePath = [folderPath stringByAppendingString:fileName];
    return filePath;
}

//stop media player when view changed
- (void)viewWillDisappear:(BOOL)animated {
    [moviePlayer stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
