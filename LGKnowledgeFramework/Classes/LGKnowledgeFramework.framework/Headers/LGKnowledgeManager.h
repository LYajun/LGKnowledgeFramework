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
/** 新建笔记回调 */
@property (nonatomic,copy) void (^klgNewNoteBlock) (NSString *klgCode,NSString *klgName,NSString *US_phonetic,NSString *US_voice,NSString *UN_phonetic,NSString *UN_voice,NSAttributedString *ExplainAttr);
/** 知识点收藏回调,isCollect:YES-收藏，NO-取消收藏 */
@property (nonatomic,copy) void (^klgCollectBlock) (BOOL isCollect,NSString *klgCode);

/** 是否可以新建笔记 */
@property (nonatomic,assign) BOOL multimediaOpenNewNoteEnable;
/** 不需外部赋值  */
@property (nonatomic,assign) BOOL openNewNoteEnable;
+ (LGKnowledgeManager *)defaultManager;

/** 查询知识点名*/
@property (nonatomic,copy) NSString *queryKlgName;
@property (nonatomic,copy) NSString *userID;
@property (nonatomic,copy) NSString *queryApi;

- (void)presentQueryKnowledgeControllerBy:(UIViewController *)controller;

- (void)presentKnowledgeControllerBy:(UIViewController *)controller;
- (void)presentKnowledgeAlertViewByController:(UIViewController *)controller addStudyBlock:(void (^) (void))addStudyBlock;
- (void)presentKnowledgeAlertViewByController:(UIViewController *)controller cardInfo:(NSDictionary *)cardInfo;
- (void)presentKnowledgeAlertViewByController:(UIViewController *)controller cardInfoArr:(NSArray *)cardInfoArr;

- (void)presentKnowledgeAlertViewByController:(UIViewController *)controller klgJsonArr:(NSArray *)klgJsonArr;
@end
