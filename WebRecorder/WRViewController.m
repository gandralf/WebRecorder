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
@synthesize webView = _webView;
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
    NSString *html = @"\
        <ul>\
        <li><a href=\"app://recordPressed\">Record</a></li>\
        <li><a href=\"app://stopPressed\">Stop</a></li>\
        <li><a href=\"app://playPressed\">Play</a></li>\
        </ul>";
    NSURL* baseURL = [[NSURL alloc] initWithString:@"http://google.com"];
    [self.webView loadHTMLString:html baseURL:baseURL];
}

- (void)viewDidUnload {
    [self setRecordButton:nil];
    [self setStopButton:nil];
    [self setPlayButton:nil];
    [self setWebView:nil];
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

- (IBAction)recordPressed {
    if (!self.audioRecorder.recording) {
        self.playButton.enabled = NO;
        self.recordButton.enabled = NO;
        self.stopButton.enabled = YES;
        
        [self.audioRecorder record];
    }
}

- (IBAction)stopPressed {
    self.playButton.enabled = YES;
    self.recordButton.enabled = YES;
    self.stopButton.enabled = NO;

    if (self.audioRecorder.recording) {
        [self.audioRecorder stop];
    } else if (self.audioPlayer) {
        [self.audioPlayer stop];
    }
}

- (IBAction)playPressed {
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *absoluteUrl = [[request URL] absoluteString];
    if ([absoluteUrl isEqualToString:@"app://recordPressed"]) {
        [self recordPressed];
        return NO;
    } else if ([absoluteUrl isEqualToString:@"app://stopPressed"]) {
        [self stopPressed];
        return NO;
    } else if ([absoluteUrl isEqualToString:@"app://playPressed"]) {
        [self playPressed];
        return NO;
    }

    
    return YES;
}

@end