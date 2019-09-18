//
//  YJSpeechFileManager.m
//  SpeechDemo
//
//  Created by 刘亚军 on 2018/10/25.
//  Copyright © 2018年 刘亚军. All rights reserved.
//

#import "YJSpeechFileManager.h"
#import <AVFoundation/AVFoundation.h>
@interface YJSpeechFileManager ()

@end
@implementation YJSpeechFileManager
+ (YJSpeechFileManager *)defaultManager{
    static YJSpeechFileManager * macro = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        macro = [[YJSpeechFileManager alloc]init];
    });
    return macro;
}
- (NSString *)speechRecordDir{
    NSString *recordDir = [NSString stringWithFormat:@"%@/Documents/record",NSHomeDirectory()];
    if (![[NSFileManager defaultManager] fileExistsAtPath:recordDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:recordDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return recordDir;
}
- (NSArray<YJSpeechResModel *> *)speechRecordURLAssets{
    NSArray *paths = self.speechRecordFilePaths;
    if (paths && paths.count > 0) {
        NSMutableArray *arr = [NSMutableArray array];
        for (NSString *path in paths) {
            [arr addObject:[self parseVoiceFileAtPath:path]];
        }
        return arr;
    }
    return nil;
}
- (NSArray *)speechRecordFilePaths{
    NSError *error;
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.speechRecordDir error:&error];
    if (error) {
        NSLog(@"%@",[NSString stringWithFormat:@"获取录音文件失败: %@",error.localizedDescription]);
        return nil;
    }
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *name in fileList) {
        NSString *fullpath = [self.speechRecordDir stringByAppendingPathComponent:name];
        [arr addObject:fullpath];
    }
    return arr;
}
- (NSArray *)speechRecordFileNames{
    NSError *error;
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.speechRecordDir error:&error];
    if (error) {
        NSLog(@"%@",[NSString stringWithFormat:@"获取录音文件失败: %@",error.localizedDescription]);
        return nil;
    }
    NSMutableArray *arr = [NSMutableArray array];
    for (NSString *name in fileList) {
        [arr addObject:[name componentsSeparatedByString:@"."].firstObject];
    }
    return arr;
}
- (YJSpeechResModel *)parseVoiceFileAtPath:(NSString *) filePath{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDictionary *dictAtt = [fm attributesOfItemAtPath:filePath error:nil];
    //取得音频数据
    NSURL *fileURL=[NSURL fileURLWithPath:filePath];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:fileURL options:nil];
    YJSpeechResModel *assetModel = [[YJSpeechResModel alloc] init];
    CMTime audioDuration = asset.duration;
    assetModel.duration = (NSInteger)CMTimeGetSeconds(audioDuration);
    assetModel.path = filePath;
    NSString *fileSize;//文件大小
    NSString *voiceStyle;//音质类型
    NSString *fileStyle;//文件类型
    NSString *creatDate;//创建日期
    float tempFlo = [[dictAtt objectForKey:@"NSFileSize"] floatValue]/(1024*1024);
    fileSize = [NSString stringWithFormat:@"%.2fMB",[[dictAtt objectForKey:@"NSFileSize"] floatValue]/(1024*1024)];
    NSString *tempStrr  = [NSString stringWithFormat:@"%@", [dictAtt objectForKey:@"NSFileCreationDate"]] ;
    creatDate = [tempStrr substringToIndex:19];
    //    assetModel.createTime = creatDate;
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    dateformatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateformatter dateFromString:creatDate];
    NSDate *refDate = [date dateByAddingTimeInterval:8 * 60 * 60];
    assetModel.createTime = [dateformatter stringFromDate:refDate];
    
    NSString *fileName = [filePath componentsSeparatedByString:@"/"].lastObject;
    fileStyle = [fileName componentsSeparatedByString:@"."].lastObject;
    if(tempFlo <= 2){
        voiceStyle = @"普通";
    }else if(tempFlo > 2 && tempFlo <= 5){
        voiceStyle = @"良好";
    }else if(tempFlo > 5 && tempFlo < 10){
        voiceStyle = @"标准";
    }else if(tempFlo > 10){
        voiceStyle = @"高清";
    }
    assetModel.fileSize = fileSize;
    assetModel.fileType = fileStyle;
    assetModel.voiceType = voiceStyle;
    return assetModel;
}
- (void)removeRecordFileAtPath:(NSString *)path complete:(void (^)(BOOL))complete{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    if (error) {
        NSLog(@"%@",[NSString stringWithFormat:@"删除录音文件失败: %@",error.localizedDescription]);
        if (complete) {
            complete(NO);
        }
    }else{
        if (complete) {
            complete(YES);
        }
    }
}
- (void)removeAllRecordFile{
    [[NSFileManager defaultManager] removeItemAtPath:self.speechRecordDir error:nil];
}
@end
