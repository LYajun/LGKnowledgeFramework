//
//  YJDrawView.h
//  CoreTextDemo
//
//  Created by 刘亚军 on 2019/11/19.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJRichTextData.h"
#import "YJBaseCoreTextItem.h"
#import "YJAttachmentItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface YJDrawView : UIView
/** 行数 */
@property (nonatomic, assign) NSInteger numberOfLines;
/** 截断的标识字符串，默认是"..." */
@property (nonatomic, strong) NSAttributedString *truncationToken;
/** 截断的标识字符串点击事件 */
@property (nonatomic, copy) YJClickActionHandler truncationActionHandler;
/** 文本内容 */
@property (nonatomic, strong) NSString *text;
/** 字体颜色 */
@property (nonatomic, strong) UIColor *textColor;
/** 字体 */
@property (nonatomic, strong) UIFont *font;
/** 阴影颜色 */
@property (nonatomic, strong) UIColor *shadowColor;
/** 阴影偏移位置 */
@property (nonatomic, assign) CGSize shadowOffset;
/** 阴影透明度 */
@property (nonatomic, assign) CGFloat shadowAlpha;
/** 行间距 */
@property (nonatomic, assign) CGFloat lineSpacing;
/** 段落间距 */
@property (nonatomic, assign) CGFloat paragraphSpacing;
/** 文字排版样式 */
@property (nonatomic, assign) CTTextAlignment textAlignment;

/** 添加自定义的字符串并且设置字符串属性 */
- (void)addString:(NSString *)string attributes:(NSDictionary *)attributes;
- (void)addString:(NSString *)string attributes:(NSDictionary *)attributes clickActionHandler:(nullable YJClickActionHandler)clickActionHandler;

- (void)addAttributedString:(NSAttributedString *)attr;
- (void)addAttributedString:(NSAttributedString *)attr clickActionHandler:(nullable YJClickActionHandler)clickActionHandler;

/** 添加链接 */
- (void)addLink:(NSString *)link clickActionHandler:(nullable YJClickActionHandler)clickActionHandler;

/** 添加图片 */
- (void)addImage:(UIImage *)image size:(CGSize)size clickActionHandler:(nullable YJClickActionHandler)clickActionHandler;

/** 添加UIView对象 */
- (void)addView:(UIView *)view size:(CGSize)size clickActionHandler:(nullable YJClickActionHandler)clickActionHandler;

/** 添加UIView对象 */
- (void)addView:(UIView *)view size:(CGSize)size align:(YJAttachmentAlignType)align clickActionHandler:(nullable YJClickActionHandler)clickActionHandler;
@end

NS_ASSUME_NONNULL_END
