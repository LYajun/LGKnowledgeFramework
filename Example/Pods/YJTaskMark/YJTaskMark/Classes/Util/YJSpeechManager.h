//
//  YJSpeechManager.h
//  SpeechDemo
//
//  Created by 刘亚军 on 2018/10/25.
//  Copyright © 2018年 刘亚军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "YJSpeechFileManager.h"
#import "YJSpeechResultModel.h"

typedef NS_ENUM(NSInteger,YJSpeechMarkType) {
    // 单词
    YJSpeechMarkTypeWord,
    // 句子
    YJSpeechMarkTypeSen,
    // 英文自由识别
    YJSpeechMarkTypeASR,
    // 段落
    YJSpeechMarkTypeParagraph
};



@interface YJSpeechManager : NSObject

/** 评测超时时间 默认15s*/
@property (nonatomic,assign) NSTimeInterval markTimeout;

+ (YJSpeechManager *)defaultManager;

/** 进行麦克风授权 */
- (void)setMicrophoneAuthorization;
/** 麦克风授权是否已授权 */
- (BOOL)microphoneAuthorization;

/** 初始化引擎 */
- (void)initEngine;
- (BOOL)isInitEngine;
/** 初始化结果 */
- (void)initResult:(void (^) (BOOL success))resultBlock;

/**
 开始评测

 @param refText 参考语音文本
 @param markType 评测类型
 */
- (void)startEngineAtRefText:(NSString *)refText
                    markType:(YJSpeechMarkType)markType;
/** 是否评测中 */
- (BOOL)isSpeechMarking;

/** 停止录音,tip为char1无提示框 */
- (void)stopEngine;
- (void)stopEngineWithTip:(NSString *)tip;
/** 取消录音 */
- (void)cancelEngine;

/** 录音回放 */
- (void)playback;

/** 删除引擎 */
- (void)deleteEngine;


/** 评测结果 */
- (void)speechEngineResult:(void (^) (YJSpeechResultModel *resultModel))resultBlock;
/** 音强 */
- (void)speechEngineSoundIntensity:(void (^) (CGFloat sound,CGFloat silentTime))soundIntensityBlock;
@end
