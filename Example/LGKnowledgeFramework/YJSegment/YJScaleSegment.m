//
//  YJScaleSegment.m
//  LGSegment
//
//  Created by 刘亚军 on 2017/4/10.
//  Copyright © 2017年 LiGo. All rights reserved.
//

#import "YJScaleSegment.h"

@interface YJScaleSegment ()<UIScrollViewDelegate>
@property(nonatomic,strong)NSMutableArray *titleList;
@property(nonatomic,strong)NSMutableArray *buttonList;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIScrollView *titleScrollView;
@end
@implementation YJScaleSegment
- (void)setViewControllers:(NSArray *)viewControllers{
    _viewControllers = viewControllers;
    for (UIViewController *vc in viewControllers) {
        [self.titleList addObject:vc.title];
    }
    [self addItems];
    [self setContentScrollView];
}
- (float)titleViewHeight{
    if (_titleViewHeight > 0) {
        return _titleViewHeight;
    }else{
        return 44;
    }
}
- (NSInteger)pageItems{
    if (_pageItems > 0) {
        return _pageItems;
    }
    return 3;
}
- (CGFloat)titlescale{
    if (_titlescale > 0) {
        return _titlescale;
    }
    return 1.3;
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
- (void)addItems{
    UIScrollView *sv = [[UIScrollView alloc]initWithFrame:CGRectZero];
    [self addSubview:sv];
    [sv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_offset(44);
    }];
    sv.bounces = NO;
    //    sv.scrollEnabled = NO;
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
            [UIView animateWithDuration:0.3 animations:^{
                buttonItem.transform = CGAffineTransformMakeScale(self.titlescale, self.titlescale);
            }];
        }
        
    }
    self.titleScrollView = sv;
}
-(void)buttonClick:(UIButton *)sender {
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    self.contentScrollView.contentOffset = CGPointMake(screenW*sender.tag, 0);
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
            [UIView animateWithDuration:0.3 animations:^{
                btn.transform = CGAffineTransformMakeScale(self.titlescale, self.titlescale);
            }];
            [btn setTitleColor:self.selectColor forState:UIControlStateNormal];
        }else{
            [UIView animateWithDuration:0.3 animations:^{
                btn.transform = CGAffineTransformIdentity;
            }];
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
    for (UIButton *btn in self.buttonList) {
        if (bannerX == btn.frame.origin.x) {
            [self didSelectButton:btn];
            break;
        }
    }
    CGFloat titleOffset = bannerX - btnW;
    [self.titleScrollView scrollRectToVisible:CGRectMake(titleOffset, 0, screenW, self.titleViewHeight) animated:YES];
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
