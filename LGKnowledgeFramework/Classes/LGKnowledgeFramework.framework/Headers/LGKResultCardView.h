//
//  LGKResultCardView.h
//  LGKnowledgeFramework
//
//  Created by 刘亚军 on 2019/8/25.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class LGKCardModel;
@interface LGKResultCardView : UIView
/** 知识点卡片数据 */
@property (nonatomic,strong) LGKCardModel *cardModel;
@property (nonatomic,assign) CGFloat cardViewWidth;
@property (nonatomic,copy) void (^playBlock) (void);
- (void)invalidatePlayer;
@end

NS_ASSUME_NONNULL_END
