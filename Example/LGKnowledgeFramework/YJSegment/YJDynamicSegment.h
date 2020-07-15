//
//  YJDynamicSegment.h
//  LGSegment
//
//  Created by 刘亚军 on 2017/4/9.
//  Copyright © 2017年 LiGo. All rights reserved.
//

#import <UIKit/UIKit.h>




@class YJDynamicSegment;
@protocol YJDynamicSegmentDelegate <NSObject>
@optional
- (void)yj_dynamicSegment:(YJDynamicSegment *) dynamicSegment didSelectItemAtIndex:(NSInteger)index;
@end
@interface YJDynamicSegment : UIView

@property (nonatomic,strong) NSArray *titles;
@property (nonatomic,assign) float titleViewHeight;
@property (nonatomic,assign) float fontSize;
@property (nonatomic,strong) UIColor *selectColor;
@property (nonatomic,strong) UIColor *normalColor;
@property (nonatomic,assign) NSInteger pageItems;

@property (nonatomic,strong) UIColor *botLineColor;
@property (nonatomic,assign) BOOL showBotLine;

@property (nonatomic,assign) NSInteger currentIndex;
@property (nonatomic,assign) id<YJDynamicSegmentDelegate> delegate;

@property (nonatomic, assign) BOOL scrollHitTestDisable;
@end
