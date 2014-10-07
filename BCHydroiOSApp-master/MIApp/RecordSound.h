//
//  RecordSound.h
//  MIApp
//
//  Created by Gursimran Singh on 1/6/2014.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>
#import "MKNumberBadgeView.h"

@interface RecordSound : UIViewController <AVAudioRecorderDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) NSString* audioFilePath;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (retain) IBOutlet MKNumberBadgeView* mediaBadge;
@property (strong, nonatomic) UIPopoverController* popOver;
@property (strong, nonatomic) IBOutlet UILabel *timerLabel;
@property (strong, nonatomic) IBOutlet UILabel* fileNameLabel;
@property (strong, nonatomic) IBOutlet UIButton* recordButton;

- (IBAction)startRecordSoundButton:(id)sender;
- (IBAction)stopRecordSoundButton:(id)sender;

@end
