//
//  YJAttachmentItem.h
//  CoreTextDemo
//
//  Created by 刘亚军 on 2019/11/19.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import "YJBaseCoreTextItem.h"

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, YJAttachmentType) {
    YJAttachmentTypeImage,
    YJAttachmentTypeView,
};
typedef NS_ENUM(NSUInteger, YJAttachmentAlignType) {
    // 底部对齐
    YJAttachmentAlignTypeBottom,
    // 居中
    YJAttachmentAlignTypeCenter,
    // 顶部对齐
    YJAttachmentAlignTypeTop,
};
@interface YJAttachmentItem : YJBaseCoreTextItem
@property (nonatomic, assign) YJAttachmentType type;
@property (nonatomic, strong) id attachment;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) YJAttachmentAlignType align;
/** 文本内容的ascent，用于计算attachment内容的ascent */
@property (nonatomic, assign) CGFloat ascent;
/** 文本内容的descent，用于计算attachment内容的descent */
@property (nonatomic, assign) CGFloat descent;
/** attachment内容的大小 */
@property (nonatomic, assign) CGSize size;

- (UIImage *)image;
- (UIView *)view;
@end

NS_ASSUME_NONNULL_END
