//
//  YJSpeechFileManager.h
//  SpeechDemo
//
//  Created by 刘亚军 on 2018/10/25.
//  Copyright © 2018年 刘亚军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJSpeechResModel.h"

@interface YJSpeechFileManager : NSObject

+ (YJSpeechFileManager *)defaultManager;

/** 语音评测源文件的本地存放文件夹 */
- (NSString *)speechRecordDir;

/** 语音评测源文件信息模型数组 */
- (NSArray<YJSpeechResModel *> *)speechRecordURLAssets;

/** 语音评测源文件存放路径 */
- (NSArray *)speechRecordFilePaths;

/** 语音评测源文件存放名称 */
- (NSArray *)speechRecordFileNames;

/** 根据录音文件路径删除录音文件 */
- (void)removeRecordFileAtPath:(NSString *) path
                      complete:(void (^) (BOOL success))complete;

/** 移除全部录音文件 */
- (void)removeAllRecordFile;
@end
