//
//  LGKnowledgeManager.h
//  LGKnowledgeFramework
//
//  Created by 刘亚军 on 2018/10/29.
//  Copyright © 2018年 刘亚军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LGKnowledgeManager : NSObject

/** 知识点服务器地址 */
@property (nonatomic,copy) NSString *apiUrl;
/** 知识点编码 */
@property (nonatomic,copy) NSString *klgCode;
/** VIP模式 默认为YES，不对入口做限制*/
@property (nonatomic,assign) BOOL isVipMode;
/** 是否只开放知识点卡片 */
@property (nonatomic,assign) BOOL onlyKlgCark;

/** 进入知识点学习课件错误回调 */
@property (nonatomic,copy) void (^klgErrorBlock) (NSError *error);

+ (LGKnowledgeManager *)defaultManager;


- (void)presentKnowledgeControllerBy:(UIViewController *)controller;
- (void)presentKnowledgeAlertViewByController:(UIViewController *)controller addStudyBlock:(void (^) (void))addStudyBlock;

- (void)presentKnowledgeAlertViewByController:(UIViewController *)controller cardInfo:(NSDictionary *)cardInfo;
@end
