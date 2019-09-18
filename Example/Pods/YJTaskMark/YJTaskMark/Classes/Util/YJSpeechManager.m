//
//  YJSpeechManager.m
//  SpeechDemo
//
//  Created by 刘亚军 on 2018/10/25.
//  Copyright © 2018年 刘亚军. All rights reserved.
//

#import "YJSpeechManager.h"
#import <AVFoundation/AVFoundation.h>
#import "KYTestEngine.h"

#import <YJNetManager/YJNetMonitoring.h>

#import <LGAlertHUD/LGAlertHUD.h>
#import <YJExtensions/YJExtensions.h>
#import "YJSpeechTimer.h"



#define YJS_IsStrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref)isEqualToString:@""]))
#define YJS_IsArrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref) count] == 0))

static NSString *cMicAuthorization = @"micAuthorization";
static NSString *cSpeechAppkey = @"148757611600000f";
static NSString *cSpeechSecretkey = @"2d5356fe1d5f3f13eba43ca48c176647";

static CGFloat kSoundOffset = 10;



@interface YJSpeechManager ()

@property (nonatomic,assign) BOOL isInit;
@property (nonatomic,assign) YJSpeechMarkType markType;
@property (nonatomic,copy) NSString *refText;
@property(nonatomic,strong) YJSpeechTimer *timer;
@property (nonatomic,assign) CGFloat timeCount;
@property(nonatomic,strong) YJSpeechTimer *timeoutTimer;
@property (nonatomic,assign) CGFloat timeoutCount;
@property (nonatomic,assign) CGFloat sound;
@property (nonatomic,copy) void (^initBlock) (BOOL success);
@property (nonatomic,copy) void (^speechResultBlock) (YJSpeechResultModel *resultModel);
@property (nonatomic,copy) void (^soundIntensityBlock) (CGFloat sound,CGFloat silentTime);

/**
 当连续评测前，先强制关闭上次的，再开始下一次，但不输出上次评测结果
 */
/** 评测中 */
@property (nonatomic,assign) BOOL isMarking;
@property (nonatomic,assign) BOOL isEndMark;
@end

@implementation YJSpeechManager
+ (YJSpeechManager *)defaultManager{
    static YJSpeechManager * macro = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        macro = [[YJSpeechManager alloc]init];
    });
    return macro;
}
- (void)setMicrophoneAuthorization{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    void (^permissionGranted)(void) = ^{
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:cMicAuthorization];
        [[NSUserDefaults standardUserDefaults] synchronize];
    };
    void (^noPermission)(void) = ^{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:cMicAuthorization];
        [[NSUserDefaults standardUserDefaults] synchronize];
    };
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
        {
            //第一次提示用户授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
//                granted ? permissionGranted() : noPermission();
                permissionGranted();
            }];
            break;
        }
        case AVAuthorizationStatusAuthorized:
        {
            //通过授权
            permissionGranted();
            break;
        }
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
            //不能授权
            NSLog(@"不能完成授权，可能开启了访问限制");
            noPermission();
            break;
        default:
            break;
    }
}
- (BOOL)microphoneAuthorization{
    return [[NSUserDefaults standardUserDefaults] boolForKey:cMicAuthorization];
}

- (void)initEngine{
    
    
    
    self.isInit = NO;
    //配置初始化引擎参数
    KYStartEngineConfig *startEngineConfig = [[KYStartEngineConfig alloc] init];
    startEngineConfig.appKey = cSpeechAppkey;
    startEngineConfig.secretKey = cSpeechSecretkey;
    startEngineConfig.vadEnable = YES;
    __weak typeof(self) weakSelf = self;
    //初始化引擎
    [[KYTestEngine sharedInstance] initEngine:KY_CloudEngine startEngineConfig:startEngineConfig finishBlock:^(BOOL isSuccess) {
        NSLog(@"语音服务初始化结果：%i",isSuccess);
        weakSelf.isInit = isSuccess;
        if (weakSelf.initBlock) {
            weakSelf.initBlock(isSuccess);
        }
    }];
}
- (BOOL)isInitEngine{
    return self.isInit;
}
- (NSTimeInterval)markTimeout{
    if (_markTimeout == 0) {
        return 15.0;
    }
    return _markTimeout;
}
- (void)startEngineAtRefText:(NSString *)refText markType:(YJSpeechMarkType)markType{
   
    self.markType = markType;
    self.refText = refText;
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"micAuthorization"]) {
        [self showResult:@"麦克风权限未打开"];
        return;
    }
    if ((markType != YJSpeechMarkTypeASR) &&
        (!refText || [refText isEqualToString:@""])) {
        [self showResult:@"语音评测参数有误"];
        return;
    }
    if (!self.isInit) {
        [self showResult:@"语音评测服务未开启"];
        return;
    }
    if ([YJNetMonitoring shareMonitoring].netStatus == 0) {
        [self showResult:@"网络未连接"];
        return;
    }
    if ([YJNetMonitoring shareMonitoring].networkCanUseState != 1) {
        [self showResult:@"网络异常"];
        return;
    }
     [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    //配置评测参数
    KYTestConfig *config = [[KYTestConfig alloc] init];
    if (markType == YJSpeechMarkTypeWord) {
        config.coreType = KYTestType_Word;
    }else if (markType == YJSpeechMarkTypeSen){
        config.coreType = KYTestType_Sentence;
    }else if (markType == YJSpeechMarkTypeParagraph){
        config.coreType = KYTestType_Paragraph;
        config.paragraph_need_word_score = YES;
    }else{
        config.coreType = KYTestType_ASR;
    }
    config.refText = refText;
    config.phonemeOption = KYPhonemeOption_KK;
    config.soundIntensityEnable = YES;
    config.audioType = @"wav";
    config.sampleRate = 16000;
    config.sampleBytes = 2;
    __weak typeof(self) weakSelf = self;
    self.isMarking = YES;
    self.isEndMark = NO;
    [[KYTestEngine sharedInstance] startEngineWithTestConfig:config result:^(NSString *testResult) {
        [weakSelf showResult:testResult];
    }];
     [self startTimer];
}
- (BOOL)isSpeechMarking{
    return self.isMarking;
}
- (void)showResult:(NSString *) result{
   
     __weak typeof(self) weakSelf = self;
    if ([result containsString:@"sound_intensity"]) {
        NSData *rdata = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:rdata options:NSJSONReadingMutableLeaves  error:nil];
        self.sound = [[resultDic objectForKey:@"sound_intensity"] floatValue];
        if (self.sound > kSoundOffset) {
            self.timeCount = 0;
        }
    }else{
        [self removeTimeoutTimer];
        if (!self.isEndMark) {
            NSLog(@"评测异常结束");
//            [self startEngineAtRefText:self.refText markType:self.markType];
//            return;
        }
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        NSLog(@"评测结果:%@",result);
        dispatch_async(dispatch_get_main_queue(), ^{
            [LGAlert hide];
            YJSpeechResultModel *model = [[YJSpeechResultModel alloc] init];
            if ([result containsString:@"tokenId"]) {
                NSData *rdata = [result dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:rdata options:NSJSONReadingMutableLeaves  error:nil];
                model.speechID = [resultDic objectForKey:@"tokenId"];
                if ([result rangeOfString:@"errId"].length > 0) {
                    model.isError = YES;
                    model.errorMsg = [resultDic objectForKey:@"error"];
                    model.totalScore = 0;
                    NSString *fullpath = [[YJSpeechFileManager defaultManager].speechRecordDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",[resultDic objectForKey:@"tokenId"]]];
                    [[YJSpeechFileManager defaultManager] removeRecordFileAtPath:fullpath complete:nil];
                }else{
                    NSDictionary *jsonresult = [resultDic objectForKey:@"result"];
                    model.isError = NO;
                    model.errorMsg = @"";
                    if (self.markType == YJSpeechMarkTypeASR) {
                        model.recognition = [jsonresult objectForKey:@"recognition"];
                        model.confidence = [[jsonresult objectForKey:@"confidence"] integerValue];
                    }else{
                        NSString *str = @"";
                        NSArray *arr0 = [NSArray arrayWithObjects:@"words", nil];
                        NSArray *jsonwords = [jsonresult objectsForKeys:arr0 notFoundMarker:@"notFound"];
                        
                        if (self.markType == YJSpeechMarkTypeWord) {
                            NSArray *arr = [NSArray arrayWithObjects:@"phonemes",nil];
                            NSDictionary *word = jsonwords[0][0];
                            NSArray *ph = [word objectsForKeys:arr notFoundMarker:@"notFound"];
                            if(![ph containsObject:@"notFound"])
                            {
                                str = @"/";
                                for(int i=0; i<((NSArray *)ph[0]).count; i++)
                                {
                                    str = [str  stringByAppendingString:[NSString stringWithFormat:@"%@:%@ /", [ph[0][i] objectForKey:@"phoneme"], [ph[0][i] objectForKey:@"pronunciation"]]];
                                }
                            }
                            model.phonemeScore = str;
                        }else if (self.markType == YJSpeechMarkTypeSen){
                            model.integrityScore = [[jsonresult objectForKey:@"integrity"] floatValue];
                            model.fluencyScore = [[jsonresult objectForKey:@"fluency"] floatValue];
                            model.rhythmScore = [[jsonresult objectForKey:@"rhythm"] floatValue];
                            for(int i=0; i<((NSArray *)jsonwords[0]).count; i++)
                            {
                                str = [str  stringByAppendingString:[NSString stringWithFormat:@"%@:%@ /", [[jsonwords[0][i] objectForKey:@"word"] stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]], [[jsonwords[0][i] objectForKey:@"scores"] objectForKey:@"overall"]]];
                            }
                            model.words = [jsonresult objectForKey:@"words"];
                            model.wordScore = str;
                        }else{
                            model.integrityScore = [[jsonresult objectForKey:@"integrity"] floatValue];
                            model.fluencyScore = [[jsonresult objectForKey:@"fluency"] floatValue];
                            model.rhythmScore = [[jsonresult objectForKey:@"rhythm"] floatValue];
                            NSArray *sentences = [jsonresult objectForKey:@"sentences"];
                            model.sentences = sentences;
                        }
                        model.totalScore = [[jsonresult objectForKey:@"overall"] floatValue];
                        model.pronunciationScore = [[jsonresult objectForKey:@"pronunciation"] floatValue];
                    }
                }
            }else{
                model.isError = YES;
                model.errorMsg = result;
                model.totalScore = 0;
            }
            weakSelf.isMarking = NO;
            weakSelf.isEndMark = NO;
            if (weakSelf.speechResultBlock) {
                weakSelf.speechResultBlock(model);
            }
        });
    }
}

- (void)stopEngine{
    [self stopEngineWithTip:nil];
}
- (void)stopEngineWithTip:(NSString *)tip{
     [self removeTimer];
    if (self.isMarking) {
        self.isEndMark = YES;
        [[KYTestEngine sharedInstance] stopEngine];
        [self startTimeoutTimer];
        if (!YJS_IsStrEmpty(tip)) {
            if (![tip isEqualToString:[NSString yj_Char1]]) {
                [LGAlert showIndeterminateWithStatus:tip];
            }
        }else{
            [LGAlert showIndeterminateWithStatus:@"语音评测中..."];
        }
    }
}
- (void)cancelEngine{
     [self removeTimer];
    [LGAlert hide];
    [[KYTestEngine sharedInstance] cancelEngine];
    self.isMarking = NO;
    self.isEndMark = NO;
}
- (void)deleteEngine{
     [self removeTimer];
    [[KYTestEngine sharedInstance] deleteEngine];
}
- (void)initResult:(void (^)(BOOL))resultBlock{
    _initBlock = resultBlock;
}
- (void)speechEngineResult:(void (^)(YJSpeechResultModel *))resultBlock{
    _speechResultBlock = resultBlock;
}
- (void)speechEngineSoundIntensity:(void (^)(CGFloat, CGFloat))soundIntensityBlock{
    _soundIntensityBlock = soundIntensityBlock;
}
- (void)playback{
    [[KYTestEngine sharedInstance] playback];
}
- (void)startTimer{
    [self.timer fire];
    self.timeCount = -1;
    self.sound = 0;
}
- (void)removeTimer{
    [self.timer invalidate];
    self.timer = nil;
}
- (void)timerAction{
    __weak typeof(self) weakSelf = self;
    if (self.soundIntensityBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (weakSelf.timeCount >= 0 && weakSelf.sound <= kSoundOffset) {
                weakSelf.timeCount += 0.2;
            }
            if (weakSelf.timeCount > 0 && weakSelf.sound > kSoundOffset) {
                weakSelf.timeCount = 0;
            }
            weakSelf.soundIntensityBlock(weakSelf.sound, weakSelf.timeCount);
           
        });
    }
}
- (void)startTimeoutTimer{
    [self.timeoutTimer fire];
    self.timeoutCount = 0;
}
- (void)removeTimeoutTimer{
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}
- (void)timeoutTimerAction{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.timeoutCount += 1;
        if (weakSelf.timeoutCount >= weakSelf.markTimeout) {
            [weakSelf cancelEngine];
            [weakSelf showResult:@"评测超时"];
        }
    });
}
- (YJSpeechTimer *)timer{
    if (!_timer) {
        _timer = [YJSpeechTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerAction) userInfo:nil repeats:YES dispatchQueue:dispatch_queue_create("YJSpeechTimerQueue", DISPATCH_QUEUE_CONCURRENT)];
    }
    return _timer;
}
- (YJSpeechTimer *)timeoutTimer{
    if (!_timeoutTimer) {
         _timeoutTimer = [YJSpeechTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeoutTimerAction) userInfo:nil repeats:YES dispatchQueue:dispatch_queue_create("YJSpeechTimeroutQueue", DISPATCH_QUEUE_CONCURRENT)];
    }
    return _timeoutTimer;
}
@end
