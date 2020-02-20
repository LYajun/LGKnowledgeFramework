//
//  LGKnowledgeManager.h
//  LGKnowledgeFramework
//
//  Created by 刘亚军 on 2018/10/29.
//  Copyright © 2018年 刘亚军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** 测试使用 */
typedef NS_ENUM(NSUInteger, LGKnowledgeTestLevel) {
    LGKnowledgeTestLevelDefault,
    LGKnowledgeTestLevelPrimary,
    LGKnowledgeTestLevelMiddle,
    LGKnowledgeTestLevelHigh,
};

@interface LGKnowledgeManager : NSObject

/** 测试使用，指定训练等级(初中高,默认自动通过知识点ID判断) */
@property (nonatomic, assign) LGKnowledgeTestLevel testLevel;

/** 知识点服务器地址 */
@property (nonatomic,copy) NSString *apiUrl;
/** 资源服务器基础地址,可以不传 */
@property (nonatomic,copy) NSString *baseUrl;
/** 知识点编码 */
@property (nonatomic,copy) NSString *klgCode;

/** VIP模式 默认为YES，不对入口做限制*/
@property (nonatomic,assign) BOOL isVipMode;
/** 是否只开放知识点卡片 */
@property (nonatomic,assign) BOOL onlyKlgCark;

/** 进入知识点学习课件错误回调 */
@property (nonatomic,copy) void (^klgErrorBlock) (NSError *error);

+ (LGKnowledgeManager *)defaultManager;

/** 直接进入知识点课件 */
- (void)presentKnowledgeControllerBy:(UIViewController *)controller;

/** 调用知识点弹窗 */
/** 弹窗1:通过klgCode进行查询 提供“加入再学习”按钮，电子素材用到 */
- (void)presentKnowledgeAlertViewByController:(UIViewController *)controller addStudyBlock:(void (^) (void))addStudyBlock;

/** 弹窗2:通过知识点标准JSON数据进行查询 */
- (void)presentKnowledgeAlertViewByController:(UIViewController *)controller cardInfo:(NSDictionary *)cardInfo;
/** 弹窗3:通过知识点标准JSON数组进行查询 */
- (void)presentKnowledgeAlertViewByController:(UIViewController *)controller cardInfoArr:(NSArray *)cardInfoArr;

/** 弹窗4:通过课件编辑JSON数组进行查询 */
- (void)presentKnowledgeAlertViewByController:(UIViewController *)controller klgJsonArr:(NSArray *)klgJsonArr;
@end
