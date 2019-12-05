//
//  YJRichContentData.h
//  CoreTextDemo
//
//  Created by 刘亚军 on 2019/11/19.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJAttachmentItem.h"
#import "YJLinkItem.h"
#import "YJTextItem.h"
#import "YJTruncationItem.h"
#import "YJCTLine.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YJDrawMode) {
    YJDrawModeLines,
    YJDrawModeFrame
};

typedef NS_ENUM(NSUInteger, YJDataType) {
    YJDataTypeImage,
    YJDataTypeView,
    YJDataTypeText,
    YJDataTypeLink
};

@interface YJRichContentData : NSObject
/** 图片数据 */
@property (nonatomic, strong) NSMutableArray<YJAttachmentItem *> *attachments;
/** 绘制的CTline数据 */
@property (nonatomic, strong) NSMutableArray<YJCTLine *> *linesToDraw;
@property (nonatomic, assign) CTFrameRef frameToDraw;
/** 绘制模式，使用CTFrame或者CTLine */
@property (nonatomic, assign) YJDrawMode drawMode;
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
@property (nonatomic, assign) CGFloat fontSize;
/** 阴影颜色 */
@property (nonatomic, strong) UIColor *shadowColor;
/** 阴影偏移位置 */
@property (nonatomic, assign) CGSize shadowOffset;
/** 阴影透明度 */
@property (nonatomic, assign) CGFloat shadowAlpha;
@property (nonatomic, assign) CTLineBreakMode lineBreakMode;
/** 行间距 */
@property (nonatomic, assign) CGFloat lineSpacing;
/** 段落间距 */
@property (nonatomic, assign) CGFloat paragraphSpacing;
/** 文字排版样式 */
@property (nonatomic, assign) CTTextAlignment textAlignment;



- (void)addString:(NSString *)string attributes:(NSDictionary *)attributes clickActionHandler:(nullable YJClickActionHandler)clickActionHandler;

- (void)addAttributedString:(NSAttributedString *)attr clickActionHandler:(nullable YJClickActionHandler)clickActionHandler;

- (void)addLink:(NSString *)link clickActionHandler:(YJClickActionHandler)clickActionHandler;

- (void)addImage:(UIImage *)image size:(CGSize)size clickActionHandler:(YJClickActionHandler)clickActionHandler;

- (void)addView:(UIView *)view size:(CGSize)size clickActionHandler:(YJClickActionHandler)clickActionHandler;

- (void)addView:(UIView *)view size:(CGSize)size align:(YJAttachmentAlignType)align clickActionHandler:(YJClickActionHandler)clickActionHandler;

/** 生成View绘制需要使用的数据 */
- (void)composeDataToDrawWithBounds:(CGRect)bounds;

/** 获取View点击位置的数据 */
- (YJBaseCoreTextItem *)itemAtPoint:(CGPoint)point;

/** 获取CTFrame对应的NSAttributedString数据 */
- (NSAttributedString *)attributeStringToDraw;
@end

NS_ASSUME_NONNULL_END
