//
//  DisplayQuestionHelp.m
//  MIApp
//
//  Created by Gursimran Singh on 2014-03-07.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "DisplayQuestionHelp.h"
#import "KeyList.h"

@implementation DisplayQuestionHelp
{
    UIScrollView* scrollView;
}

@synthesize helpInfo;

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    //check if help exists
    //if not display error
    if ([[helpInfo objectForKey:[[KeyList sharedInstance] helpTextTemplateKey]] isEqualToString:@""] && ([[helpInfo objectForKey:[[KeyList sharedInstance] helpImagesTemplateKey]] count] == 0) ) {
        [self displayNoHelpError];
        return;
    }
    
    //display help
    [self displayHelp];
}


//display error when no help available
-(void) displayNoHelpError
{
    //set error message
    UITextView* message = [[UITextView alloc] initWithFrame:CGRectMake(0, ([self preferredContentSize].height / 4) - 20, [self preferredContentSize].width, ([self preferredContentSize].height / 2) + 20)];
    message.text = @"No help provided for this question";
    message.font = [UIFont boldSystemFontOfSize:20];
    message.textAlignment = NSTextAlignmentCenter;
    message.textColor = [UIColor grayColor];
    message.editable = NO;
    
    //display error message
    [[self view] addSubview:message];
}

//display help
-(void) displayHelp
{
    //set the scroll bar width to popover width
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.preferredContentSize.width, self.preferredContentSize.height)];
    [self.view addSubview:scrollView];
    
    //frame to use is the frame to use for the next ui object
    //since first object is help text, get height of text and set the frame
    CGRect frameToUse = CGRectMake(20, 20, self.preferredContentSize.width - 40, [self getSizeForString:[helpInfo objectForKey:[[KeyList sharedInstance] helpTextTemplateKey]]].height);
    
    //set the help message
    UILabel* message = [[UILabel alloc] initWithFrame:frameToUse];
    message.text = [helpInfo objectForKey:[[KeyList sharedInstance] helpTextTemplateKey]];
    message.numberOfLines = 0;
    message.lineBreakMode = NSLineBreakByCharWrapping;
    [message sizeToFit];
    
    //add help message
    [scrollView addSubview:message];
    
    
    //increment frame to use by height of text for next ui object
    frameToUse.origin.y = frameToUse.origin.y + message.frame.size.height + 20;
    
    
    //get list of images
    NSArray* images = [helpInfo objectForKey:[[KeyList sharedInstance] helpImagesTemplateKey]];
    
    
    //add every image
    for (int i=0; i < [images count]; i++) {
        
        //get text attached to that image
        NSDictionary* imageInfo = [images objectAtIndex:i];
        NSString* text = [imageInfo objectForKey:[[KeyList sharedInstance] helpImageTextTemplateKey]];
        
        //if text exists add text
        if ([text length] > 0) {
            UILabel* imageText = [[UILabel alloc] initWithFrame:CGRectMake(frameToUse.origin.x, frameToUse.origin.y, frameToUse.size.width, [self getSizeForString:text].height + 10)];
            imageText.text = [imageInfo objectForKey:[[KeyList sharedInstance] helpImageTextTemplateKey]];
            [scrollView addSubview:imageText];
        
            frameToUse.origin.y = frameToUse.origin.y + imageText.frame.size.height + 20;
        }
        
        //get image data
        NSString* imageData = [imageInfo objectForKey:[[KeyList sharedInstance] helpImagesImageTemplateKey]];
        if ([imageData length] > 0) {
            //convert image data to base 64
            imageData = [@"data:image/jpg;base64," stringByAppendingString:imageData];
            NSData *image = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageData]];
            UIImage* imageDecoded = [UIImage imageWithData:image];
            
            //set new height and width of image
            float aspectRatio = imageDecoded.size.height / imageDecoded.size.width;
            float height = frameToUse.size.width * aspectRatio;
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(frameToUse.origin.x, frameToUse.origin.y, frameToUse.size.width, height)];
            imageView.image = imageDecoded;
            imageView.contentMode = UIViewContentModeScaleToFill;
            
            [scrollView addSubview:imageView];
            frameToUse.origin.y = frameToUse.origin.y + imageView.frame.size.height + 20;
        }
        
    }
    
    //set scroll bars in scroll view
    CGSize sizeScrollView = CGSizeMake(self.preferredContentSize.width, frameToUse.origin.y);
    [scrollView setContentSize:sizeScrollView];
}


//returns size of string passed in
-(CGSize) getSizeForString: (NSString*) string
{
    CGSize size = CGSizeMake(self.preferredContentSize.width - 40,INFINITY);
    
    CGRect textRect = [string
                       boundingRectWithSize:size
                       options:NSStringDrawingUsesLineFragmentOrigin
                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12.0f]}
                       context:nil];
    
    return textRect.size;
}

@end
