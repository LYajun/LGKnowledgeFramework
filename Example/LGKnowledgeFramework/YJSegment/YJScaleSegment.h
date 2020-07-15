//
//  YJScaleSegment.h
//  LGSegment
//
//  Created by 刘亚军 on 2017/4/10.
//  Copyright © 2017年 LiGo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YJScaleSegment : UIView
@property (nonatomic,strong) NSArray *viewControllers;
@property (nonatomic,assign) float titleViewHeight;
@property (nonatomic,strong) UIColor *selectColor;
@property (nonatomic,strong) UIColor *normalColor;
@property (nonatomic,assign) CGFloat titlescale;
@property (nonatomic,assign) NSInteger pageItems;
@end
