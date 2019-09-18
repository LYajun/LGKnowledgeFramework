//
//  YJSpeechResultModel.h
//  SpeechDemo
//
//  Created by 刘亚军 on 2018/10/25.
//  Copyright © 2018年 刘亚军. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YJSpeechResultModel : NSObject
/** 编号 */
@property (nonatomic,copy) NSString *speechID;
/** 总分 */
@property (nonatomic,assign) float totalScore;
/** 发音得分 */
@property (nonatomic,assign) float pronunciationScore;

/** 音素得分 - 单词 */
@property (nonatomic,copy) NSString *phonemeScore;

/** 完整度得分 - 句子/段落 */
@property (nonatomic,assign) float integrityScore;
/** 流利度得分 - 句子/段落 */
@property (nonatomic,assign) float fluencyScore;
/** 韵律度得分 - 句子 */
@property (nonatomic,assign) float rhythmScore;

/** 单词得分 - 句子 */
@property (nonatomic,copy) NSString *wordScore;
/** 单词得分 - 句子 */
@property (nonatomic,strong) NSArray *words;
- (NSDictionary *)wordScoreInfo;

/** 句子得分 - 段落 */
@property (nonatomic,strong) NSArray *sentences;

/** 识别结果 - 英文自由识别 */
@property (nonatomic,copy) NSString *recognition;
/** 识别出来的置信度, 0~100 - 英文自由识别 */
@property (nonatomic,assign) NSInteger confidence;

/** 是否出错 */
@property (nonatomic,assign) BOOL isError;
/** 错误信息 */
@property (nonatomic,copy) NSString *errorMsg;

+ (instancetype)speechResultWithDictionary:(NSDictionary *)aDictionary;

- (NSDictionary *)yj_JSONObject;
@end
