//
//  DisplaySelectedMedia.h
//  MIApp
//
//  Created by Gursimran Singh on 12/31/2013.
//  Copyright (c) 2013 BCHydro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MKNumberBadgeView.h"
@interface DisplaySelectedMedia : UIViewController <UINavigationControllerDelegate>
{
    
}

@property (retain) IBOutlet MKNumberBadgeView* mediaBadge;
@property (nonatomic, strong) NSString* headerTitle;
@property (nonatomic, strong) NSMutableArray* soundList;
@property (nonatomic, strong) NSMutableArray* videoList;
@property (nonatomic, strong) NSMutableArray* imageList;
@property (nonatomic, strong) NSIndexPath* selectedMedia;
@property (nonatomic, strong) UIImageView* image;
@property (nonatomic, strong) MPMoviePlayerController* moviePlayer;

@end
