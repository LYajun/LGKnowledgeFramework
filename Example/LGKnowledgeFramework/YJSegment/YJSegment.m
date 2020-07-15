//
//  YJ_Segment.m
//  LGSegment
//
//  Created by 刘亚军 on 2017/4/9.
//  Copyright © 2017年 LiGo. All rights reserved.
//

#import "YJSegment.h"
#import <Masonry/Masonry.h>


@interface YJSegment ()<UIScrollViewDelegate>
@property(nonatomic,strong)NSMutableArray *titleList;
@property(nonatomic,strong)NSMutableArray *buttonList;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIScrollView *titleScrollView;
@property(nonatomic,weak)CALayer *LGLayer;

@property (nonatomic, strong) UIView *bottomLine;
@end
@implementation YJSegment
#pragma mark - Instance lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (void)commonInit{
    _contentViewShadowEnabled = NO;
    _contentViewShadowColor = [UIColor blackColor];
    _contentViewShadowOffset = CGSizeMake(0, 3);
    _contentViewShadowOpacity = 0.8f;
    _contentViewShadowRadius = 2.0f;
}
- (void)setViewControllers:(NSArray *)viewControllers{
    _viewControllers = viewControllers;
    for (UIViewController *vc in viewControllers) {
        [self.titleList addObject:vc.title];
    }
    [self addItems];
    [self setContentScrollView];
}
- (NSInteger)pageItems{
    if (_pageItems > 0) {
        return _pageItems;
    }
    return 3;
}
- (float)titleViewHeight{
    if (_titleViewHeight > 0) {
        return _titleViewHeight;
    }else{
        return 44;
    }
}
- (UIColor *)selectColor{
    if (!_selectColor) {
        return [UIColor orangeColor];
    }else{
        return _selectColor;
    }
}
- (UIColor *)normalColor{
    if (!_normalColor) {
        return [UIColor lightGrayColor];
    }else{
        return _normalColor;;
    }
}

- (void)updateTitleViewShadow
{
    if (self.contentViewShadowEnabled) {
        CALayer *layer = self.bottomLine.layer;
//        UIBezierPath *path = [UIBezierPath bezierPathWithRect:layer.bounds];
//        layer.shadowPath = path.CGPath;
        layer.shadowColor = self.contentViewShadowColor.CGColor;
        layer.shadowOffset = self.contentViewShadowOffset;
        layer.shadowOpacity = self.contentViewShadowOpacity;
        layer.shadowRadius = self.contentViewShadowRadius;
    }
}
- (UIView *)bottomLine{
    if (!_bottomLine) {
        _bottomLine = [UIView new];
        _bottomLine.backgroundColor = [UIColor lightGrayColor];
    }
    return _bottomLine;
}
- (void)addItems{
    UIScrollView *sv = [[UIScrollView alloc]initWithFrame:CGRectZero];
    sv.backgroundColor = [UIColor whiteColor];
    [self addSubview:sv];
    [sv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_offset(44);
    }];
    sv.bounces = NO;
    sv.scrollEnabled = NO;
    sv.showsHorizontalScrollIndicator = NO;
    UIView *contentV = [UIView new];
    [sv addSubview:contentV];
    [contentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(sv);
        make.height.equalTo(sv);
    }];
     CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
     CGFloat btnW = screenW/self.pageItems;
     int count = (int)self.titleList.count;
     for (int i = 0; i < count; i++) {
        
         UIButton *buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
         buttonItem.tag = i;
         [buttonItem setTitle:self.titleList[i] forState:UIControlStateNormal];
         [buttonItem setTitleColor:self.normalColor forState:UIControlStateNormal];
         [buttonItem addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
         [contentV addSubview:buttonItem];
        [self.buttonList addObject:buttonItem];
         
         if (i == 0) {
             [buttonItem mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.left.top.bottom.height.equalTo(contentV);
                 make.width.mas_equalTo(btnW);
             }];
         }else{
             UIButton *lastBtn = self.buttonList[i-1];
             [buttonItem mas_makeConstraints:^(MASConstraintMaker *make) {
                 make.top.bottom.height.equalTo(contentV);
                 make.left.equalTo(lastBtn.mas_right);
                 make.width.mas_equalTo(btnW);
             }];
             if (i == self.titleList.count - 1) {
                 [contentV mas_makeConstraints:^(MASConstraintMaker *make) {
                     make.right.equalTo(buttonItem.mas_right);
                 }];
             }
         }
         
         if (i == 0) {
             [buttonItem setTitleColor:self.selectColor forState:UIControlStateNormal];
             [self creatBanner:0];
         }
        
     }
    [contentV addSubview:self.bottomLine];
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(contentV);
        make.height.mas_equalTo(1);
    }];
    self.titleScrollView = sv;
    [self updateTitleViewShadow];
}
-(void)buttonClick:(UIButton *)sender {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    self.contentScrollView.contentOffset = CGPointMake(screenW*sender.tag, 0);
}
-(void)creatBanner:(CGFloat)firstX{
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat btnW = screenW/self.pageItems;
    //初始化
    CALayer *LGLayer = [[CALayer alloc]init];
    LGLayer.backgroundColor = self.selectColor.CGColor;
    LGLayer.frame = CGRectMake(firstX, self.titleViewHeight - 2, btnW, 2);
    // 设定它的frame
    LGLayer.cornerRadius = 2;// 圆角处理
    [self.layer addSublayer:LGLayer]; // 增加到UIView的layer上面
    self.LGLayer = LGLayer;
    
}
- (void)setContentScrollView{
    UIScrollView *sv = [[UIScrollView alloc]initWithFrame:CGRectZero];
    [self addSubview:sv];
    [sv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self);
        make.top.equalTo(self).offset(44);
    }];
    sv.bounces = NO;
    sv.pagingEnabled = YES;
    sv.showsHorizontalScrollIndicator = NO;
    sv.delegate = self;
    UIView *contentV = [UIView new];
    [sv addSubview:contentV];
    [contentV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(sv);
        make.height.equalTo(sv);
    }];
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    for (int i=0; i < self.viewControllers.count; i++) {
        UIViewController * vc = self.viewControllers[i];
        [contentV addSubview:vc.view];
        if (i == 0) {
            [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.bottom.height.equalTo(contentV);
                make.width.mas_equalTo(screenW);
            }];
        }else{
            UIViewController *lastVc = self.viewControllers[i-1];
            [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.height.equalTo(contentV);
                make.left.equalTo(lastVc.view.mas_right);
                make.width.mas_equalTo(screenW);
            }];
            if (i == self.viewControllers.count - 1) {
                [contentV mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.right.equalTo(vc.view.mas_right);
                }];
            }
        }
    }
    self.contentScrollView = sv;
}
//点击按钮后改变字体颜色
-(void)didSelectButton:(UIButton*)Button {
    for (UIButton *btn in self.buttonList) {
        if (btn.tag == Button.tag) {
            [btn setTitleColor:self.selectColor forState:UIControlStateNormal];
        }else{
            [btn setTitleColor:self.normalColor forState:UIControlStateNormal];
        }
    }
}
#pragma mark - UIScrollViewDelegate
// 只要滚动UIScrollView就会调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGFloat offsetX = scrollView.contentOffset.x;
    
    [self moveToOffsetX:offsetX];
    
}
-(void)moveToOffsetX:(CGFloat)offsetX {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
     CGFloat btnW = screenW/self.pageItems;
    CGFloat bannerX = 0;
    CGFloat addX = offsetX/screenW*btnW;
    bannerX += addX;
    [self bannerMoveTo:bannerX];
    for (UIButton *btn in self.buttonList) {
        if (bannerX == btn.frame.origin.x) {
            [self didSelectButton:btn];
            break;
        }
    }
    
    
    CGFloat titleOffset = bannerX - btnW;
    [self.titleScrollView scrollRectToVisible:CGRectMake(titleOffset, 0, screenW, self.titleViewHeight) animated:YES];
}
-(void)bannerMoveTo:(CGFloat)bannerX{
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat btnW = screenW/self.pageItems;
    bannerX += btnW/2;
    //基本动画，移动到点击的按钮下面
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"position.x"];
    pathAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(bannerX, 100)];
    //组合动画
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = [NSArray arrayWithObjects:pathAnimation, nil];
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animationGroup.duration = 0.3;
    //设置代理
    //    animationGroup.delegate = self;
    //1.3设置动画执行完毕后不删除动画
    animationGroup.removedOnCompletion=NO;
    //1.4设置保存动画的最新状态
    animationGroup.fillMode=kCAFillModeForwards;
    //监听动画
    [animationGroup setValue:@"animationStep1" forKey:@"animationName"];
    //动画加入到changedLayer上
    [_LGLayer addAnimation:animationGroup forKey:nil];
}
#pragma mark - 懒加载
- (NSMutableArray *)buttonList
{
    if (!_buttonList)
    {
        _buttonList = [NSMutableArray array];
    }
    return _buttonList;
}

- (NSMutableArray *)titleList
{
    if (!_titleList)
    {
        _titleList = [NSMutableArray array];
    }
    return _titleList;
}
@end
