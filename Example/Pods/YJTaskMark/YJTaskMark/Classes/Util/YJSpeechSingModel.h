//
//  YJSpeechSingModel.h
//  SingSoundDemo
//
//  Created by 刘亚军 on 2020/9/22.
//  Copyright © 2020 刘亚军. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface YJSpeechSingAppModel : NSObject
@property (nonatomic,copy) NSString *sig;
@property (nonatomic,copy) NSString *deviceId;
@property (nonatomic,copy) NSString *timestamp;
@property (nonatomic,copy) NSString *connect_id;
@property (nonatomic,copy) NSString *userId;
@property (nonatomic,copy) NSString *applicationId;
@end

@interface YJSpeechSingSdkModel : NSObject
@property (nonatomic,copy) NSString *os;
@property (nonatomic,copy) NSString *product;
@property (nonatomic,copy) NSString *arch;
@property (nonatomic,copy) NSString *os_version;
@property (nonatomic,assign) NSInteger source;
@property (nonatomic,assign) NSInteger protocol;
@property (nonatomic,assign) NSInteger version;
@property (nonatomic,assign) NSInteger type;
@end

@interface YJSpeechSingAudioModel : NSObject
@property (nonatomic,copy) NSString *audioType;
@property (nonatomic,assign) NSInteger sampleRate;
@property (nonatomic,assign) NSInteger channel;
@property (nonatomic,assign) NSInteger sampleBytes;
@end

@interface YJSpeechSingRequestModel : NSObject
@property (nonatomic,assign) NSInteger syldet;
@property (nonatomic,assign) NSInteger symbol;
@property (nonatomic,assign) float precision;
@property (nonatomic,assign) NSInteger rateScale;
@property (nonatomic,assign) NSInteger rank;
@property (nonatomic,assign) NSInteger attachAudioUrl;
@property (nonatomic,copy) NSString *request_id;
@property (nonatomic,copy) NSString *refText;
@property (nonatomic,copy) NSString *coreType;
@end

/** 重音发音 */
@interface YJSpeechSingStressModel : NSObject
/** 音素 */
@property (nonatomic,copy) NSString *charStr;
@property (nonatomic,assign) NSInteger ref;
@property (nonatomic,assign) float score;
@end

/** 音节检错 */
@interface YJSpeechSingSyllableModel : NSObject
/** 音节发音 */
@property (nonatomic,copy) NSString *charStr;
@property (nonatomic,assign) NSInteger start;
@property (nonatomic,assign) NSInteger end;
@property (nonatomic,assign) float score;
@end

@interface YJSpeechSingSnt_detailModel : NSObject
/** 句子中的每个单词 */
@property (nonatomic,copy) NSString *charStr;
@property (nonatomic,assign) NSInteger dur;
/** 停顿标记 */
@property (nonatomic,assign) NSInteger is_pause;
@property (nonatomic,assign) float score;
@property (nonatomic,assign) NSInteger start;
@property (nonatomic,assign) NSInteger end;
@end

@interface YJSpeechSingRhythmModel : NSObject
@property (nonatomic,assign) float overall;
@property (nonatomic,assign) NSInteger stress;
@property (nonatomic,assign) NSInteger tone;
@property (nonatomic,assign) NSInteger sense;
@end


@interface YJSpeechSingFluencyModel : NSObject
@property (nonatomic,assign) float overall;
@property (nonatomic,assign) NSInteger pause;
@property (nonatomic,assign) NSInteger speed;
@end

@interface YJSpeechSingStaticsModel : NSObject
@property (nonatomic,assign) float score;
@property (nonatomic,assign) NSInteger count;
@property (nonatomic,copy) NSString *charStr;
@end

@interface YJSpeechSingResultDetailModel : NSObject
@property (nonatomic,assign) float score;

/** 段落 */
@property (nonatomic,strong) NSArray<YJSpeechSingSnt_detailModel *> *snt_details;
@property (nonatomic,strong) YJSpeechSingFluencyModel *fluency;
@property (nonatomic,copy) NSString *text;


/** 单词 */
@property (nonatomic,strong) NSArray<YJSpeechSingStressModel *> *stress;
@property (nonatomic,strong) NSArray<YJSpeechSingSyllableModel *> *syllable;
@property (nonatomic,strong) NSArray<YJSpeechSingSyllableModel *> *phone;
/** 规整后的单词文本 */
@property (nonatomic,copy) NSString *charStr;
/** 单词发音时间，单位ms */
@property (nonatomic,assign) NSInteger dur;
/** 单词在音频中的起始时间,单位ms */
@property (nonatomic,assign) NSInteger start;
/** 单词在音频中的结束时间，单位ms */
@property (nonatomic,assign) NSInteger end;

/** 音素得分 - 单词 */
- (NSString *)phonemeScore;
@end

@interface YJSpeechSingParamsModel : NSObject
@property (nonatomic,strong) YJSpeechSingAppModel *app;
@property (nonatomic,strong) YJSpeechSingSdkModel *sdk;
@property (nonatomic,strong) YJSpeechSingAudioModel *audio;
@property (nonatomic,strong) YJSpeechSingRequestModel *request;
@end


@interface YJSpeechSingConnectModel : NSObject
@property (nonatomic,strong) YJSpeechSingParamsModel *param;
@property (nonatomic,copy) NSString *cmd;
@end

@interface YJSpeechSingResultInfoModel : NSObject
/** 信噪比，值越高越清晰，范围(0～40dB)
此参数影响评分时，会设置相应的tipId值 */
@property (nonatomic,assign) float snr;
@property (nonatomic,assign) NSInteger tipId;
@property (nonatomic,assign) NSInteger clip;
@property (nonatomic,assign) NSInteger volume;
@end

@interface YJSpeechSingResultWrd_detailsModel : NSObject
@property (nonatomic,assign) float score;
/** 单词所属句子序号 */
@property (nonatomic,assign) NSInteger snt_index;
@property (nonatomic,assign) NSInteger vad_index;
/** 单词信息 */
@property (nonatomic,copy) NSString *charStr;
@end


@interface YJSpeechSingResultModel : NSObject
/** 评测整个过程的总耗时，单位ms */
@property (nonatomic,assign) NSInteger systime;
/** 流利度评分（完整度为0时，流利度得分为0） */
@property (nonatomic,assign) id fluency;
/** 音频时长，单位ms */
@property (nonatomic,assign) NSInteger wavetime;
/** 引擎的版本，包含发布时间 */
@property (nonatomic,copy) NSString *version;
/** 完整度评分 */
@property (nonatomic,assign) float integrity;
/** 发音得分 */
@property (nonatomic,assign) float pron;
@property (nonatomic,assign) NSInteger forceout;
/** 评分分制 */
@property (nonatomic,assign) NSInteger rank;
/** 总分 */
@property (nonatomic,assign) float overall;
/** 分精度 */
@property (nonatomic,assign) float precision;
@property (nonatomic,assign) float accuracy;
/** 云端调用Start接口本身耗时，单位ms */
@property (nonatomic,assign) NSInteger pretime;
/** 云端从feed音频结束到获取结果的耗时，单位ms */
@property (nonatomic,assign) NSInteger delaytime;
@property (nonatomic,copy) NSString *res;
@property (nonatomic,strong) YJSpeechSingResultInfoModel *info;
@property (nonatomic,strong) NSArray<YJSpeechSingResultDetailModel *> *details;


/** 句子 */
@property (nonatomic,strong) YJSpeechSingRhythmModel *rhythm;
@property (nonatomic,strong) NSArray<YJSpeechSingStaticsModel *> *statics;


/** 识别 */
@property (nonatomic,strong) NSArray<YJSpeechSingResultWrd_detailsModel *> *wrd_details;
@property (nonatomic,assign) float code_startime;
@property (nonatomic,assign) float nettime;
@property (nonatomic,assign) float decodetime;

/** 识别内容 */
- (NSString *)en_recognition;
- (NSString *)cn_recognition;
/** 句子单子得分 */
- (NSString *)senWordScore;
@end


@interface YJSpeechSingModel : NSObject
@property (nonatomic,copy) NSString *dtLastResponse;
@property (nonatomic,strong) YJSpeechSingConnectModel *connect;
@property (nonatomic,strong) YJSpeechSingParamsModel *params;
@property (nonatomic,strong) YJSpeechSingResultModel *result;
@property (nonatomic,assign) NSInteger eof;
@property (nonatomic,copy) NSString *request_id;
@property (nonatomic,copy) NSString *recordId;
@property (nonatomic,copy) NSString *applicationId;
@property (nonatomic,copy) NSString *refText;
@property (nonatomic,copy) NSString *audioUrl;
@property (nonatomic,strong) NSDictionary *cloud_platform;
@end

NS_ASSUME_NONNULL_END
