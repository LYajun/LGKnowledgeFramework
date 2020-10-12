//
//  YJSpeechSingModel.m
//  SingSoundDemo
//
//  Created by 刘亚军 on 2020/9/22.
//  Copyright © 2020 刘亚军. All rights reserved.
//

#import "YJSpeechSingModel.h"
#import <MJExtension/MJExtension.h>

@implementation YJSpeechSingAppModel

@end

@implementation YJSpeechSingSdkModel

@end

@implementation YJSpeechSingAudioModel

@end

@implementation YJSpeechSingRequestModel

@end

@implementation YJSpeechSingStressModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"charStr":@"char"};
}

@end

@implementation YJSpeechSingSyllableModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"charStr":@"char"};
}

@end


@implementation YJSpeechSingSnt_detailModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"charStr":@"char"};
}
@end


@implementation YJSpeechSingRhythmModel

@end

@implementation YJSpeechSingFluencyModel

@end


@implementation YJSpeechSingStaticsModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"charStr":@"char"};
}

@end

@implementation YJSpeechSingResultDetailModel
+ (NSDictionary *)mj_objectClassInArray{
    return @{@"snt_details":[YJSpeechSingSnt_detailModel class],
             @"stress":[YJSpeechSingStressModel class],
             @"syllable":[YJSpeechSingSyllableModel class],
              @"phone":[YJSpeechSingSyllableModel class]
    };
}
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"charStr":@"char"};
}
- (NSString *)phonemeScore{
    NSString *str = @"/";
       for (YJSpeechSingSyllableModel *model in _phone) {
            str = [str stringByAppendingFormat:@"%@:%.f /",model.charStr,model.score];
       }
       return str;
}

@end


@implementation YJSpeechSingResultWrd_detailsModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"charStr":@"char"};
}
@end

@implementation YJSpeechSingParamsModel

@end

@implementation YJSpeechSingConnectModel

@end

@implementation YJSpeechSingResultInfoModel

@end

@implementation YJSpeechSingResultModel
+ (NSDictionary *)mj_objectClassInArray{
    return @{@"details":[YJSpeechSingResultDetailModel class],
             @"statics":[YJSpeechSingStaticsModel class],
             @"wrd_details":[YJSpeechSingResultWrd_detailsModel class]
    };
}


- (NSString *)en_recognition{
    NSString *str = @"";
    for (YJSpeechSingResultWrd_detailsModel *model in _wrd_details) {
        if (str.length > 0) {
            str = [str stringByAppendingString:@" "];
        }
         str = [str stringByAppendingString:model.charStr];
    }
    return str;
}
- (NSString *)cn_recognition{
    NSString *str = @"";
    for (YJSpeechSingResultWrd_detailsModel *model in _wrd_details) {
         str = [str stringByAppendingString:model.charStr];
    }
    return str;
}
- (NSString *)senWordScore{
    NSString *str = @"";
    for (YJSpeechSingResultDetailModel *model in _details) {
         str = [str  stringByAppendingString:[NSString stringWithFormat:@"%@:%.f /",model.charStr,model.score]];
    }
    return str;
}
@end

@implementation YJSpeechSingModel

@end
