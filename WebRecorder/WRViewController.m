//
//  WRViewController.m
//  WebRecorder
//
//  Created by Alexandre Lages on 9/18/12.
//  Copyright (c) 2012 Hibu. All rights reserved.
//

#import "WRViewController.h"

@interface WRViewController ()
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (readonly, nonatomic) NSURL* soundFileURL;
@end

@implementation WRViewController
@synthesize playButton = _playButton;
@synthesize stopButton = _stopButton;
@synthesize recordButton = _recordButton;
@synthesize audioRecorder = _audioRecorder;
@synthesize soundFileURL = _soundFileURL;
@synthesize audioPlayer = _audioPlayer;

-(NSURL*)soundFileURL {
    if (!_soundFileURL) {
        NSArray *dirPaths;
        NSString *docsDir;
        
        dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docsDir = [dirPaths objectAtIndex:0];
        NSString *soundFilePath = [docsDir stringByAppendingPathComponent:@"sound.caf"];
        
        _soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    }
    
    return _soundFileURL;
}

-(AVAudioRecorder*)audioRecorder {
    if (!_audioRecorder) {
        NSDictionary *recordSettings = [NSDictionary
                                        dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt:AVAudioQualityMin],
                                        AVEncoderAudioQualityKey,
                                        [NSNumber numberWithInt:16],
                                        AVEncoderBitRateKey,
                                        [NSNumber numberWithInt: 2],
                                        AVNumberOfChannelsKey,
                                        [NSNumber numberWithFloat:44100.0],
                                        AVSampleRateKey,
                                        nil];

        NSError *error = nil;
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:self.soundFileURL
                                                     settings:recordSettings
                                                        error:&error];
        if (error) {
            NSLog(@"error: %@", [error localizedDescription]);
        } else {
            [self.audioRecorder prepareToRecord];
        }
    }
    
    return _audioRecorder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.playButton.enabled = NO;
    self.stopButton.enabled = NO;
}

- (void)viewDidUnload {
    [self setRecordButton:nil];
    [self setStopButton:nil];
    [self setPlayButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)recordPressed:(UIButton *)sender {
    if (!self.audioRecorder.recording) {
        self.playButton.enabled = NO;
        self.recordButton.enabled = NO;
        self.stopButton.enabled = YES;
        
        [self.audioRecorder record];
    }
}

- (IBAction)stopPressed:(UIButton *)sender {
    self.playButton.enabled = YES;
    self.recordButton.enabled = YES;
    self.stopButton.enabled = NO;

    if (self.audioRecorder.recording) {
        [self.audioRecorder stop];
    } else if (self.audioPlayer) {
        [self.audioPlayer stop];
    }
}

- (IBAction)playPressed:(UIButton *)sender {
    if (!self.audioRecorder.recording) {
        self.stopButton.enabled = YES;
        self.recordButton.enabled = NO;
        
        NSError *error;
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioRecorder.url error:&error];
        
        self.audioPlayer.delegate = self;
        
        if (error) {
            NSLog(@"Error: %@", [error localizedDescription]);
        } else {
            [self.audioPlayer play];
        }
    }
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    self.recordButton.enabled = YES;
    self.stopButton.enabled = NO;
}

-(void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                error:(NSError *)error {
    NSLog(@"Decode Error occurred");
}

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                          successfully:(BOOL)flag{
}

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                  error:(NSError *)error{
    NSLog(@"Encode Error occurred");
}

@end