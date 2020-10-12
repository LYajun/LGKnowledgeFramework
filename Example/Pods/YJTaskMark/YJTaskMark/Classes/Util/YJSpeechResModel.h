//
//  YJSpeechResModel.h
//  SpeechDemo
//
//  Created by 刘亚军 on 2018/10/25.
//  Copyright © 2018年 刘亚军. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YJSpeechResModel : NSObject
/** 时长 */
@property (nonatomic,assign) NSInteger duration;
/** 路径 */
@property (nonatomic,copy) NSString *path;
/** 创建时间 */
@property (nonatomic,copy) NSString *createTime;
/** 文件类型 */
@property (nonatomic,copy) NSString *fileType;
/** 音质类型 */
@property (nonatomic,copy) NSString *voiceType;
/** 文件大小 */
@property (nonatomic,copy) NSString *fileSize;
@end
