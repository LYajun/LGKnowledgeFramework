//
//  LGKCardView.h
//  LGKnowledgeFramework
//
//  Created by 刘亚军 on 2019/8/15.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LGKCardView : UIView

/** 单词，词组，句法,专有名词自动播放 */
@property (nonatomic,assign) BOOL isAutoPlay;
/** 宽度 */
@property (nonatomic,assign) CGFloat cardViewWidth;

@property (nonatomic,copy) void (^clickPlayBlock) (void);
/** 知识点卡片数据 */
- (void)configCardModel:(id)cardModel;
- (void)configCardInfo:(NSDictionary *)cardInfo klgConfigInfo:(NSDictionary *)klgConfigInfo;
- (void)invalidatePlayer;
@end

NS_ASSUME_NONNULL_END
