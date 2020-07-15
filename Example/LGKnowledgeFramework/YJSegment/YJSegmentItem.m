//
//  YJSegmentItem.m
//  LGSegment
//
//  Created by 刘亚军 on 2017/4/9.
//  Copyright © 2017年 LiGo. All rights reserved.
//

#import "YJSegmentItem.h"
#import <Masonry/Masonry.h>
#import <YJBaseModule/YJBMarqueeLabel.h>

@interface YJSegmentItem ()
@property (nonatomic,strong) YJBMarqueeLabel *titileL;
@property (nonatomic,strong) UIView *line;
@property (nonatomic,strong) UIColor *norColor;
@property (nonatomic,strong) UIColor *selectColor;
@property (nonatomic,copy) void (^block) (void);
@end
@implementation YJSegmentItem
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *) title selectColor:(UIColor *) selectColor norColor:(UIColor *) norColor{
    if (self = [super initWithFrame:frame]) {
        _fontSize = 15;
        self.norColor = norColor;
        self.selectColor = selectColor;
        self.titileL.text = title;
        self.titileL.textColor = norColor;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonClick)];
        [self addGestureRecognizer:tap];
        [self addSubview:self.titileL];
        [self.titileL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.centerX.equalTo(self);
            make.left.equalTo(self).mas_offset(6);
            make.bottom.equalTo(self.mas_bottom).offset(2);
        }];
        self.line = [UIView new];
        [self addSubview:self.line];
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.equalTo(self);
            make.height.mas_offset(2);
        }];
//         self.line.layer.cornerRadius = 1;
//         self.line.layer.masksToBounds = YES;
        self.line.hidden = YES;
        self.line.backgroundColor = selectColor;
    }
    return self;
}
- (void)buttonClick{
    if (self.block) {
        self.block();
    }
}
- (void)clickEventBlock:(void (^)(void))block{
    _block = block;
}
- (void)setFontSize:(float)fontSize{
    _fontSize = fontSize;
    self.titileL.font = [UIFont systemFontOfSize:fontSize];
}
- (void)setIsSelect:(BOOL)isSelect{
    _isSelect = isSelect;
    if (isSelect) {
         self.titileL.font = [UIFont boldSystemFontOfSize:self.fontSize];
        self.titileL.textColor = self.selectColor;
        [self.titileL restartLabel];
        self.titileL.labelize = NO;
    }else{
        self.titileL.font = [UIFont systemFontOfSize:self.fontSize];
        self.titileL.textColor = self.norColor;
        self.titileL.labelize = YES;
    }
    self.line.hidden = !_isSelect;
}
- (YJBMarqueeLabel *)titileL{
    if (!_titileL) {
        _titileL = [[YJBMarqueeLabel alloc] initWithFrame:CGRectZero rate:10 andFadeLength:5];
        _titileL.animationDelay = 0.5;
        _titileL.font = [UIFont systemFontOfSize:15];
        _titileL.textColor = [UIColor whiteColor];
        _titileL.textAlignment = NSTextAlignmentCenter;
        _titileL.trailingBuffer = 24;
        _titileL.marqueeType = YJBContinuous;
        _titileL.labelize = YES;
        _titileL.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _titileL;
}
@end
