//
//  AudioRecorder.m
//  ToolDemo
//
//  Created by 高大鹏 on 14-3-27.
//  Copyright (c) 2014年 BeaconStudio. All rights reserved.
//

#import "AudioRecorder.h"
#import <AudioToolbox/AudioToolbox.h>
#import "Tools.h"

@implementation AudioRecorder

static AudioRecorder *_sharedInst = nil;

+ (AudioRecorder *)defaultRecorder
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInst=[[AudioRecorder alloc] init];
    });
    return _sharedInst;
}

- (id) init
{
	if (self = [super init])
	{
        //设置音频会话场景
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        if(session == nil)
            NSLog(@"Error creating session: %@", [sessionError description]);
        else
            [session setActive:YES error:nil];
        
        //初始化默认参数
        _recording = _playing = _hasCAFFile = NO;
        _sampleRate  = 44100;
        _quality     = AVAudioQualityLow;
        _formatIndex = [self formatIndexToEnum:0];
	}
	return self;
}

- (void)dealloc
{
    [_player release];
    [_recorder release];
    [super dealloc];
}

- (NSInteger) formatIndexToEnum:(NSInteger) index
{
    switch (index) {
        case 0: return kAudioFormatLinearPCM; break;
        case 1: return kAudioFormatAC3; break;
        case 2: return kAudioFormat60958AC3; break;
        case 3: return kAudioFormatAppleIMA4; break;
        case 4: return kAudioFormatMPEG4AAC; break;
        case 5: return kAudioFormatMPEG4CELP; break;
        case 6: return kAudioFormatMPEG4HVXC; break;
        case 7: return kAudioFormatMPEG4TwinVQ; break;
        case 8: return kAudioFormatMACE3; break;
        case 9: return kAudioFormatMACE6; break;
        case 10: return kAudioFormatULaw; break;
        case 11: return kAudioFormatALaw; break;
        case 12: return kAudioFormatQDesign; break;
        case 13: return kAudioFormatQDesign2; break;
        case 14: return kAudioFormatQUALCOMM; break;
        case 15: return kAudioFormatMPEGLayer1; break;
        case 16: return kAudioFormatMPEGLayer2; break;
        case 17: return kAudioFormatMPEGLayer3; break;
        case 18: return kAudioFormatTimeCode; break;
        case 19: return kAudioFormatMIDIStream; break;
        case 20: return kAudioFormatParameterValueStream; break;
        case 21: return kAudioFormatAppleLossless; break;
        case 22: return kAudioFormatMPEG4AAC_HE; break;
        case 23: return kAudioFormatMPEG4AAC_LD; break;
        case 24: return kAudioFormatMPEG4AAC_ELD; break;
        case 25: return kAudioFormatMPEG4AAC_ELD_SBR; break;
        case 26: return kAudioFormatMPEG4AAC_ELD_V2; break;
        case 27: return kAudioFormatMPEG4AAC_HE_V2; break;
        case 28: return kAudioFormatMPEG4AAC_Spatial; break;
        case 29: return kAudioFormatAMR; break;
        case 30: return kAudioFormatAudible; break;
        case 31: return kAudioFormatiLBC; break;
        case 32: return kAudioFormatDVIIntelIMA; break;
        case 33: return kAudioFormatMicrosoftGSM; break;
        case 34: return kAudioFormatAES3; break;
        default:
            return -1;
            break;
    }
}

- (void)startRecord
{
    if (!_recording)
    {
        NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat: _sampleRate],AVSampleRateKey,[NSNumber numberWithInt:_formatIndex],AVFormatIDKey,[NSNumber numberWithInt: 2],                              AVNumberOfChannelsKey,[NSNumber numberWithInt: _quality],AVEncoderAudioQualityKey,nil];
        
        
        _recordedFile = [[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"]]retain];
        NSError* error;
        _recorder = [[AVAudioRecorder alloc] initWithURL:_recordedFile settings:settings error:&error];
        NSLog(@"%@", [error description]);
        if (error)
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"你的设备不支持当前设置"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles: nil];
            [alert show];
            [alert release];
            return;
        }
        _recording = YES;
        [_recorder prepareToRecord];
        _recorder.meteringEnabled = YES;
        [_recorder record];
    }
    else
    {
        _recording = NO;
        if (_recorder != nil )
        {
            _hasCAFFile = YES;
        }
        [_recorder stop];
        [_recorder release];
        _recorder = nil;
    }
}


- (void)playSoundsOrPause
{
    if (_recording) return;
  
    if (_playing)
    {
        _playing = NO;
        [_player pause];
    }
    else
    {
        if (_hasCAFFile)
        {
            if (_player == nil)
            {
                
                NSError *playerError;
                _player = [[AVAudioPlayer alloc] initWithContentsOfURL:_recordedFile error:&playerError];
                _player.meteringEnabled = YES;
                if (_player == nil)
                {
                    NSLog(@"ERror creating player: %@", [playerError description]);
                }
                _player.delegate = self;
            }
            _playing = YES;
            [_player play];
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"请先录一段声音"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
    }
}

- (void)encode
{
    if (_hasCAFFile && !_recording && !_playing)
    {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        _alert = [[UIAlertView alloc] init];
        [_alert setTitle:@"请稍等..."];
        
        UIActivityIndicatorView* activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        

        activity.frame = CGRectMake(140,80,CGRectGetWidth(_alert.frame),CGRectGetHeight(_alert.frame));
        
        [_alert addSubview:activity];
        [activity startAnimating];
        [activity release];
        
        [_alert show];
        [_alert release];
        _startDate = [[NSDate date] retain];
        [NSThread detachNewThreadSelector:@selector(toMp3) toTarget:self withObject:nil];
    }
}

- (void) toMp3
{
    NSString *cafFilePath =[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"];
    
    NSString *mp3FileName = @"Mp3File";
    mp3FileName = [mp3FileName stringByAppendingString:@".mp3"];
    NSString *mp3FilePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:mp3FileName];
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, _sampleRate);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
        [self performSelectorOnMainThread:@selector(convertMp3Finish)
                               withObject:nil
                            waitUntilDone:YES];
    }
}

- (void) convertMp3Finish
{
    [_alert dismissWithClickedButtonIndex:0 animated:YES];
    
    _alert = [[UIAlertView alloc] init];
    [_alert setTitle:@"完成"];
    [_alert setMessage:[NSString stringWithFormat:@"转换消耗%.2fs", [[NSDate date] timeIntervalSinceDate:_startDate]]];
    [_startDate release];
    [_alert addButtonWithTitle:@"OK"];
    [_alert setCancelButtonIndex: 0];
    [_alert show];
    [_alert release];
    
    _hasMp3File = YES;
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

#pragma mark - AVAudioPlayerDelegate
- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    _playing = NO;
}


@end
