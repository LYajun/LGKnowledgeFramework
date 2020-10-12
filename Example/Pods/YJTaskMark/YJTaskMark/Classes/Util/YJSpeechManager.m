//
//  YJSpeechManager.m
//  SpeechDemo
//
//  Created by 刘亚军 on 2018/10/25.
//  Copyright © 2018年 刘亚军. All rights reserved.
//

#import "YJSpeechManager.h"

#import <YJNetManager/YJNetMonitoring.h>

#import <LGAlertHUD/LGAlertHUD.h>
#import <YJExtensions/YJExtensions.h>
#import <AVFoundation/AVFoundation.h>
#import <SingSound/SSOralEvaluatingManager.h>
#import "YJSpeechTimer.h"
#import <MJExtension/MJExtension.h>
#import "YJSpeechFileManager.h"
#import "YJSpeechSingModel.h"

#define YJS_IsStrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref)isEqualToString:@""]))
#define YJS_IsArrEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]) ||([(_ref) count] == 0))
#define IsObjEmpty(_ref)    (((_ref) == nil) || ([(_ref) isEqual:[NSNull null]]))
#define kApiParams(_ref)    (IsObjEmpty(_ref) ? @"" : _ref)
static NSString *cMicAuthorization = @"micAuthorization";
static NSString *cSpeechAppkey = @"t714";
static NSString *cSpeechSecretkey = @"bPSj0QFufvC6OB9yRthr81aLH3pedmED";
static NSString *cSpeechUserID = @"lancooios001";

static CGFloat kFrontTimet = 5;
static CGFloat kBackTime = 20;

static CGFloat kSoundOffset = 8;

@interface YJSpeechManager ()<SSOralEvaluatingManagerDelegate>
@property(nonatomic,strong) YJSpeechTimer *timer;
@property (nonatomic,assign) CGFloat timeCount;
@property (nonatomic,assign) BOOL isInit;
@property (nonatomic,assign) YJSpeechMarkType markType;
@property (nonatomic,copy) NSString *refText;
@property (nonatomic,assign) CGFloat soundVolume;
@property (nonatomic,copy) void (^initBlock) (BOOL success);
@property (nonatomic,copy) void (^speechResultBlock) (YJSpeechResultModel *resultModel);
@property (nonatomic,copy) void (^soundIntensityBlock) (CGFloat sound,CGFloat silentTime);
@property (nonatomic,copy) void (^speechStartBlock) (void);
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
    [self getWarrntIdAuth];
    //注册评测
    SSOralEvaluatingManagerConfig *managerConfig = [[SSOralEvaluatingManagerConfig alloc]init];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"error"];
    managerConfig.logPath = path;

    managerConfig.appKey = cSpeechAppkey;
    managerConfig.secretKey = cSpeechSecretkey;
    managerConfig.frontTime = kFrontTimet;
    managerConfig.backTime = kBackTime;
    managerConfig.isOutputLog = YES;
    managerConfig.allowDynamicService = YES;

    //请确保SSOralEvaluatingManager的当前代理是自己
    [SSOralEvaluatingManager shareManager].delegate = self;
    
    [SSOralEvaluatingManager registerEvaluatingManagerConfig:managerConfig];
    [[SSOralEvaluatingManager shareManager] registerEvaluatingType:OralEvaluatingTypeLine];
    
}
/**
    正式：http://api.cloud.ssapi.cn:8080/auth/authorize
    测试：http://trial.cloud.ssapi.cn:8080/auth/authorize
 */
-(void)getWarrntIdAuth{
    if (self.isInit) {
        return;
    }
    NSString *timestamp = [NSString stringWithFormat:@"%.f",[[NSDate date] timeIntervalSince1970]];
    NSString *user_client_ip = @"192.168.129.37";
    NSString *signStr = [NSString stringWithFormat:@"app_secret=%@&appid=%@&timestamp=%@&user_client_ip=%@&user_id=%@",cSpeechSecretkey,cSpeechAppkey,timestamp,user_client_ip,cSpeechUserID];;
    NSString *signature = [NSString yj_md5EncryptStr:signStr];
    NSURL * url = [NSURL URLWithString:@"http://trial.cloud.ssapi.cn:8080/auth/authorize"];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 10;
    [request setHTTPMethod:@"POST"];
    NSString * argument = [NSString stringWithFormat:@"appid=%@&timestamp=%@&user_id=%@&user_client_ip=%@&request_sign=%@&warrant_available=%li",cSpeechAppkey,timestamp,cSpeechUserID,user_client_ip,signature,(long)12*3600];
    request.HTTPBody = [argument dataUsingEncoding:NSUTF8StringEncoding];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDataTask * task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary * responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSLog(@"%@",responseObject);
                NSDictionary * dict = (NSDictionary *)responseObject;
                if ([dict[@"code"] integerValue]==0) {
                    if (dict[@"data"] && dict[@"data"][@"warrant_id"]) {
                        NSString * warrantId = [NSString stringWithFormat:@"%@",dict[@"data"][@"warrant_id"]];
                        NSString * expire_at = [NSString stringWithFormat:@"%@",dict[@"data"][@"expire_at"]];
                        [[SSOralEvaluatingManager shareManager] setAuthInfoWithWarrantId:warrantId AuthTimeout:expire_at];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.isInit = YES;
                            if (weakSelf.initBlock) {
                                weakSelf.initBlock(YES);
                            }
                        });
                    }
                }
            }else{
                NSString *result =[[ NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@",result);
            }
        }else{
            NSLog(@"AuthInfoWithWarrantId 失败");
        }
    }];
    [task resume];
}
- (BOOL)isInitEngine{
    return self.isInit;
}

- (void)startEngineAtRefText:(NSString *)refText markType:(YJSpeechMarkType)markType{
   if (self.speechStartBlock) {
       self.speechStartBlock();
   }
    self.markType = markType;
    self.refText = refText;
    self.isMarking = YES;
    self.isEndMark = NO;
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"micAuthorization"]) {
        [self showResult:@"麦克风权限未打开"];
        return;
    }
    if ((markType != YJSpeechMarkTypeASR) && (markType != YJSpeechMarkTypeChineseASR)  &&
        (!refText || [refText isEqualToString:@""])) {
        [self showResult:@"语音评测参数有误"];
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
    
    //初始化参数
        SSOralEvaluatingConfig *config = [[SSOralEvaluatingConfig alloc]init];
        // 设置用户id
        config.userId = cSpeechUserID;
    if (self.markType == YJSpeechMarkTypeLocalEnASR || self.markType == YJSpeechMarkTypeLocalCnASR) {
        config.coreType = self.markType == YJSpeechMarkTypeLocalEnASR ? @"en.longsent.rec" : @"cn.longsent.rec";
        NSString *extName = [refText pathExtension];
        config.audioType = extName.lowercaseString;
         [LGAlert showIndeterminateWithStatus:@"语音识别中..."];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[SSOralEvaluatingManager shareManager] startEvaluateOralWithWavPath:refText config:config];
        });
    }else{
        switch (markType) {
            case YJSpeechMarkTypeWord:
                config.oralType = OralTypeWord;
                break;
            case YJSpeechMarkTypeSen:
                config.oralType = OralTypeSentence;
                break;
            case YJSpeechMarkTypeParagraph:
                config.oralType = OralTypeParagraph;
                break;
            case YJSpeechMarkTypeASR:
//                config.oralType = OralTypeEnRec;
                config.coreType = @"en.longsent.rec";
                break;
            case YJSpeechMarkTypeChineseASR:
//                config.oralType = OralTypeCnRec;
                config.coreType = @"cn.longsent.rec";
                break;
            default:
                break;
        }
        // 设置音频格式,默认wav
        config.audioType = @"wav";
        // 设置音频格式-采样率,默认16000
        config.sampleRate = 16000;
        // 设置音频格式-声道,默认1，单声道
        config.channel = 1;
        // 设置音频格式-采样字节数,默认2
        config.sampleBytes = 2;
        // 设置评测文本内容
        config.oralContent = refText;
        // 设置分值,默认100
        config.rank = 100;
        // 是否开启边读边评，实时返回数据
        config.openFeed = NO;
        // 设置评分精度
        config.precision = 0.5;
        // 评分松紧度，范围0.8~1.5，数值越小，打分越严厉
        config.rateScale = 1.0;
        // 录音回调时间间隔 int类型 单位毫秒
        config.recordTimeinterval = 50;
        //开始评测
        [[SSOralEvaluatingManager shareManager] startEvaluateOralWithConfig:config];
        if (self.markType != YJSpeechMarkTypeASR && self.markType != YJSpeechMarkTypeChineseASR) {
            [self startTimer];
        }
    }
}
- (BOOL)isSpeechMarking{
    return self.isMarking;
}
- (void)showResult:(NSString *) result{
     [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
   YJSpeechResultModel *model = [[YJSpeechResultModel alloc] init];
    model.isError = YES;
    model.errorMsg = result;
    model.totalScore = 0;
    self.isMarking = NO;
    self.isEndMark = NO;
    if (self.speechResultBlock) {
        self.speechResultBlock(model);
    }
    
}

- (void)stopEngine{
    [self stopEngineWithTip:nil];
}
- (void)stopEngineWithTip:(NSString *)tip{
     [self removeTimer];
    if (self.isMarking) {
        self.isEndMark = YES;
        [[SSOralEvaluatingManager shareManager] stopEvaluate];
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
    [[SSOralEvaluatingManager shareManager] cancelEvaluate];
    self.isMarking = NO;
    self.isEndMark = NO;
}
- (void)deleteEngine{
     [self removeTimer];
    [[SSOralEvaluatingManager shareManager] engineDealloc];
}
- (void)initResult:(void (^)(BOOL))resultBlock{
    _initBlock = resultBlock;
}
- (void)speechEngineStartBLock:(void (^)(void))startBlock{
    _speechStartBlock = startBlock;
}
- (void)speechEngineResult:(void (^)(YJSpeechResultModel *))resultBlock{
    _speechResultBlock = resultBlock;
}
- (void)speechEngineSoundIntensity:(void (^)(CGFloat, CGFloat))soundIntensityBlock{
    _soundIntensityBlock = soundIntensityBlock;
}

#pragma mark - SSOralEvaluatingManagerDelegate
// 评测开始
-(void)oralEvaluatingDidStart{
}
// 评测停止
-(void)oralEvaluatingDidStop{
    dispatch_async(dispatch_get_main_queue(), ^{
        [LGAlert hide];
    });
}

-(void)oralEvaluatingDidEndWithResult:(NSDictionary*)result RequestId:(NSString*)request_id{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
       __weak typeof(self) weakSelf = self;
       dispatch_async(dispatch_get_main_queue(), ^{
          
           YJSpeechSingModel *singModel = [YJSpeechSingModel mj_objectWithKeyValues:result];
           
           YJSpeechResultModel *model = [[YJSpeechResultModel alloc] init];
           model.isError = NO;
           model.errorMsg = @"";
           model.speechID = request_id;
          
           if (weakSelf.markType == YJSpeechMarkTypeLocalEnASR || weakSelf.markType == YJSpeechMarkTypeLocalCnASR) {
               model.audioPath = self.refText;
           }
           
           if (weakSelf.markType == YJSpeechMarkTypeASR || weakSelf.markType == YJSpeechMarkTypeChineseASR || weakSelf.markType == YJSpeechMarkTypeLocalEnASR || weakSelf.markType == YJSpeechMarkTypeLocalCnASR) {
               if (weakSelf.markType == YJSpeechMarkTypeASR || weakSelf.markType == YJSpeechMarkTypeLocalEnASR) {
                   model.recognition = singModel.result.en_recognition;
               }else{
                   model.recognition = singModel.result.cn_recognition;
               }
           }else{
               if (self.markType == YJSpeechMarkTypeWord) {
                   model.phonemeScore = singModel.result.details.firstObject.phonemeScore;
               }else if (self.markType == YJSpeechMarkTypeSen){
                   model.integrityScore = singModel.result.integrity;
                   if ([singModel.result.fluency isKindOfClass:NSDictionary.class]) {
                       model.fluencyScore = [[singModel.result.fluency objectForKey:@"overall"] floatValue];
                   }else{
                       model.fluencyScore = [singModel.result.fluency floatValue];
                   }
                   model.rhythmScore = singModel.result.rhythm.overall;
                   
                   NSMutableArray *words = [NSMutableArray array];
                   for (YJSpeechSingResultDetailModel *detailModel in singModel.result.details) {
                       NSMutableDictionary *bigDic = [NSMutableDictionary dictionary];
                       [bigDic setObject:kApiParams(detailModel.charStr) forKey:@"word"];
                       [bigDic setObject:@{@"overall":@(detailModel.score)} forKey:@"scores"];
                   }
                   model.words = words;
                   model.wordScore = singModel.result.senWordScore;
               }else{
                   model.integrityScore = singModel.result.integrity;
                   if ([singModel.result.fluency isKindOfClass:NSDictionary.class]) {
                       model.fluencyScore = [[singModel.result.fluency objectForKey:@"overall"] floatValue];
                   }else{
                       model.fluencyScore = [singModel.result.fluency floatValue];
                   }
                   model.rhythmScore = singModel.result.rhythm.overall;
                   
                   NSMutableArray *sentences = [NSMutableArray array];
                   for (YJSpeechSingResultDetailModel *detailModel in singModel.result.details) {
                       NSMutableDictionary *bigDic = [NSMutableDictionary dictionary];
                       [bigDic setObject:@(detailModel.score) forKey:@"overall"];
                        [bigDic setObject: kApiParams(detailModel.text) forKey:@"sentence"];
                       
                       NSMutableArray *words = [NSMutableArray array];
                       for (YJSpeechSingSnt_detailModel *sDetailModel in detailModel.snt_details) {
                           NSMutableDictionary *smallDic = [NSMutableDictionary dictionary];
                           [smallDic setObject:@(sDetailModel.score) forKey:@"overall"];
                           [smallDic setObject: kApiParams(sDetailModel.charStr) forKey:@"word"];
                           [words addObject:smallDic];
                       }
                       [bigDic setObject: words forKey:@"details"];
                       [sentences addObject:bigDic];
                   }
                   model.sentences = sentences;
               }
               model.totalScore = singModel.result.overall;
               model.pronunciationScore = singModel.result.pron;
           }
           [LGAlert hide];
           weakSelf.isMarking = NO;
           weakSelf.isEndMark = NO;
           if (weakSelf.speechResultBlock) {
               weakSelf.speechResultBlock(model);
           }
       });
    NSLog(@"评测成功回调2:result:%@",result);
}

-(void)oralEvaluatingDidEndError: (NSError *)error RequestId:(NSString *)request_id{
    NSString *fullpath = [[YJSpeechFileManager defaultManager].speechRecordDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",request_id]];
    [[YJSpeechFileManager defaultManager] removeRecordFileAtPath:fullpath complete:nil];
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [LGAlert hide];
        if (error.userInfo && [[error.userInfo objectForKey:@"error"] containsString:@"audio type is not supported"]) {
            [weakSelf showResult:@"该音频格式不支持"];
        } else if (error.userInfo && [[error.userInfo objectForKey:@"error"] containsString:@"no warrant provided"]){
            weakSelf.isInit = NO;
            [weakSelf getWarrntIdAuth];
            [weakSelf showResult:@"操作失败"];
        }else{
            [weakSelf showResult:@"操作失败"];
        }
    });
    NSLog(@"评测失败回调2:error:%@",error);
}


-(void)oralEvaluatingDidUpdateVolume: (int)volume{
    self.soundVolume = volume;
    if (self.soundVolume > kSoundOffset) {
        self.timeCount = 0;
    }
}
// 前置超时
- (void)oralEvaluatingDidVADFrontTimeOut {
     //建议取消
    [self cancelEngine];
     __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
            [LGAlert hide];
            [weakSelf showResult:@"录音超时"];
          
       });
   
}
// 后置超时
- (void)oralEvaluatingDidVADBackTimeOut {
    [self stopEngine];
}
// 录音即将超时（只支持在线模式，单词20s，句子40s)函数
-(void)oralEvaluatingDidRecorderWillTimeOut{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [LGAlert hide];
        [weakSelf showResult:@"录音超时"];
    });
}

#pragma mark - 音量定时处理

- (void)startTimer{
    [self.timer fire];
    self.timeCount = -1;
    self.soundVolume = 0;
}
- (void)removeTimer{
    [self.timer invalidate];
    self.timer = nil;
}
- (void)timerAction{
    __weak typeof(self) weakSelf = self;
    if (self.soundIntensityBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (weakSelf.timeCount >= 0 && weakSelf.soundVolume <= kSoundOffset) {
                weakSelf.timeCount += 0.2;
            }
            if (weakSelf.timeCount > 0 && weakSelf.soundVolume > kSoundOffset) {
                weakSelf.timeCount = 0;
            }
            weakSelf.soundIntensityBlock(weakSelf.soundVolume, weakSelf.timeCount);
        });
    }
}
- (YJSpeechTimer *)timer{
    if (!_timer) {
        _timer = [YJSpeechTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(timerAction) userInfo:nil repeats:YES dispatchQueue:dispatch_queue_create("YJSpeechTimerQueue", DISPATCH_QUEUE_CONCURRENT)];
    }
    return _timer;
}
@end
