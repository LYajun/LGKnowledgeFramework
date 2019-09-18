//
//  YJSpeechResultModel.m
//  SpeechDemo
//
//  Created by 刘亚军 on 2018/10/25.
//  Copyright © 2018年 刘亚军. All rights reserved.
//

#import "YJSpeechResultModel.h"
#import <objc/message.h>

@implementation YJSpeechResultModel
+ (instancetype)speechResultWithDictionary:(NSDictionary *)aDictionary{
    id objc = [[self alloc] init];
    unsigned int count;
    // 获取类中的所有成员属性
    Ivar *ivarList = class_copyIvarList(self, &count);
    for (int i = 0; i < count; i++) {
        // 根据角标，从数组取出对应的成员属性
        Ivar ivar = ivarList[i];
        // 获取成员属性名
        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
        // 处理成员属性名->字典中的key
        // 从第一个角标开始截取
        NSString *key = [name substringFromIndex:1];
        // 根据成员属性名去字典中查找对应的value
        id value = aDictionary[key];
        if (value) { // 有值，才需要给模型的属性赋值
            // 利用KVC给模型中的属性赋值
            [objc setValue:value forKey:key];
        }
    }
    return objc;
}
- (NSDictionary *)yj_JSONObject{
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList(YJSpeechResultModel.class, &count);
    NSMutableDictionary *jsonModel = [NSMutableDictionary dictionary];
    for (int i = 0; i < count; i++) {
        const char *propertyName = property_getName(propertyList[i]);
        NSString *key = [NSString stringWithUTF8String:propertyName];
        id value = [self valueForKeyPath:key];
        if (!value || value == [NSNull null]) continue;
        [jsonModel setValue:value forKey:key];
    }
    return jsonModel;
}
- (NSDictionary *)wordScoreInfo{
    if (self.wordScore && self.wordScore.length > 0 && [self.wordScore containsString:@"/"]) {
        NSString *wordScore = [self.wordScore stringByReplacingOccurrencesOfString:@"/" withString:@""];
        NSDictionary *wordInfo = [self parseParameterUrl:wordScore];
        return wordInfo;
    }else{
        return nil;
    }
}
- (NSDictionary *)parseParameterUrl:(NSString *)parameterUrl{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSArray *parameterArr = [parameterUrl componentsSeparatedByString:@" "];
    for (NSString *parameter in parameterArr) {
        NSArray *parameterBoby = [parameter componentsSeparatedByString:@":"];
        if (parameterBoby.count == 2) {
            NSString *key = [parameterBoby[0] lowercaseString];
            id value = parameterBoby[1];
            if ([[dic allKeys] containsObject:key]) {
                id oldValue = [dic objectForKey:key];
                if ([value floatValue] > [oldValue floatValue]) {
                    [dic setObject:value forKey:key];
                }
            }else{
                [dic setObject:value forKey:key];
            }
        } else {
            NSLog(@"单词得分 - 句子 Invalid Parameter String");
        }
    }
    return dic;
}
- (NSString *)speechID{
    if (!_speechID) {
        return @"000";
    }
    return _speechID;
}
@end
