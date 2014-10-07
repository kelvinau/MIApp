//
//  RecordSound.m
//  MIApp
//
//  Created by Gursimran Singh on 1/6/2014.
//  Copyright (c) 2014 BCHydro. All rights reserved.
//

#import "RecordSound.h"

@implementation RecordSound
{
    AVAudioRecorder *recorder;
    NSTimer* timeTimer;
    NSInteger timeSinceStart;
    int milli;
    int sec;
    int min;
}
@synthesize audioFilePath, audioRecorder, mediaBadge, popOver, recordButton, timerLabel, fileNameLabel;

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    
    //set title
    self.title = @"Record";
    
    //display filename
    [fileNameLabel setText:[[[[audioFilePath pathComponents] lastObject] componentsSeparatedByString:@"."] firstObject]];
    
    
    //create file location url
    NSURL *outputFileURL = [NSURL fileURLWithPath:audioFilePath];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    
    [session setActive:YES error:nil];
    
    
    //set time
    milli=0;
    min = 0;
    sec = 0;
    

}


//called when recording button pressed
- (IBAction)startRecordSoundButton:(UIButton*)sender {
    
    //if currently recording
    if ([sender isSelected]) {
        
        //pause recording
        [timeTimer invalidate];
        [recorder pause];
        
        //change button image
        [sender setImage:[UIImage imageNamed:@"record"] forState:UIControlStateNormal];
        [sender setSelected:NO];
    } else {
        
        //start recording or resume recording
        timeTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
        [recorder record];
        
        //change button image
        [sender setImage:[UIImage imageNamed:@"stopRecord"] forState:UIControlStateSelected];
        [sender setSelected:YES];
    }
    
    
}


//method timer calls to increment time
//called every 10 ms
- (void)timerTick:(NSTimer *)timer {
    
    self.timerLabel.text = [self addAndGetTime];

}

//called when user pressed 'done'
- (IBAction)stopRecordSoundButton:(id)sender {
    
    //cancel timer and stop recording
    [timeTimer invalidate];
    timeTimer = nil;
    [recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    
    //increment badge count by 1
    [self.mediaBadge setValue:self.mediaBadge.value + 1];
    //[self.audioRecorder stop];
    
    //dismiss popover
    [popOver dismissPopoverAnimated:YES];
    
    
    //if user did not record anything then call popover controller did dismiss to delete the file and decrement the bagde by -1
    if ([[self addAndGetTime] isEqualToString:@"00:00:01"]) {
        [self.popOver.delegate popoverControllerDidDismissPopover:self.popOver];
    }
}

//get new time
-(NSString*) addAndGetTime
{
    
    //add milliseconds
    milli++;
    
    //if milliseconds = 100 then increment secs, if secs = 60 increment min
    if (milli == 100) {
        milli = 0;
        sec++;
        if (sec == 60) {
            sec = 0;
            min++;
        }
    }
    
    //create a string with time and return
    return [NSString stringWithFormat:@"%02d:%02d:%02d", min, sec, milli];
}

@end
