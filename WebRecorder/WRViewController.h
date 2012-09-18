//
//  WRViewController.h
//  WebRecorder
//
//  Created by Alexandre Lages on 9/18/12.
//  Copyright (c) 2012 Hibu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface WRViewController : UIViewController<AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
- (IBAction)recordPressed;
- (IBAction)stopPressed;
- (IBAction)playPressed;

-(void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                          successfully:(BOOL)flag;

-(void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                  error:(NSError *)error;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
@end
