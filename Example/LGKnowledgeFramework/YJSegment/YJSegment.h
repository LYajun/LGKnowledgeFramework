//
//  YJ_Segment.h
//  LGSegment
//
//  Created by 刘亚军 on 2017/4/9.
//  Copyright © 2017年 LiGo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YJSegment : UIView
@property (nonatomic,strong) NSArray *viewControllers;
@property (nonatomic,assign) IBInspectable float titleViewHeight;
@property (nonatomic,strong) IBInspectable UIColor *selectColor;
@property (nonatomic,strong) IBInspectable UIColor *normalColor;
@property (nonatomic,assign) NSInteger pageItems;
@property (assign, nonatomic) IBInspectable BOOL hideBottomLine;
@property (assign, nonatomic) IBInspectable BOOL contentViewShadowEnabled;
@property (strong, nonatomic) IBInspectable UIColor *contentViewShadowColor;
@property (assign, nonatomic) IBInspectable CGSize contentViewShadowOffset;
@property (assign, nonatomic) IBInspectable CGFloat contentViewShadowOpacity;
@property (assign, nonatomic) IBInspectable CGFloat contentViewShadowRadius;

@end
