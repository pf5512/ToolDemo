//
//  AudioRecorder.h
//  ToolDemo
//
//  Created by 高大鹏 on 14-3-27.
//  Copyright (c) 2014年 BeaconStudio. All rights reserved.
//

/*
注:本类专门用于声音的录制、播放和转码，使用时请导入"lame.h","AudioToolbox.framework","AVFoundation.framework"
 */
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "lame.h"

@interface AudioRecorder : NSObject<AVAudioPlayerDelegate>
{
    BOOL _recording;
    BOOL _playing;
    BOOL _hasCAFFile;
    BOOL _playingMp3;
    BOOL _hasMp3File;
    
    NSURL *_recordedFile;
    AVAudioRecorder *_recorder;
    AVAudioPlayer *_player;
    AVAudioPlayer *_mp3Player;
    CGFloat _sampleRate;
    AVAudioQuality _quality;
    NSInteger _formatIndex;
    UIAlertView *_alert;
    NSDate *_startDate;
    
    UILabel *_cafFileSize;
    UILabel *_mp3FileSize;
    UILabel *_duration;
    
    UIProgressView *_progress;
    UIProgressView *_mp3Progress;
}

+ (AudioRecorder *)defaultRecorder;
- (void)startRecord;
- (void)playSoundsOrPause;
- (void)encode;

@end
