//
//  YJDrawView.m
//  CoreTextDemo
//
//  Created by 刘亚军 on 2019/11/19.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import "YJDrawView.h"
#import "YJAttachmentItem.h"
#import "YJRichContentData.h"

#define COVER_TAG  100023
@interface YJDrawView ()
@property (nonatomic, strong) YJRichContentData *data;
@property (nonatomic, strong) YJBaseCoreTextItem *clickedItem;
@end
@implementation YJDrawView

@dynamic truncationToken, truncationActionHandler, text, textColor, font, shadowColor, shadowOffset, shadowAlpha, lineSpacing, paragraphSpacing, textAlignment;

- (void)addString:(NSString *)string attributes:(NSDictionary *)attributes{
    [self.data addString:string attributes:attributes clickActionHandler:nil];
}

- (void)addString:(NSString *)string attributes:(NSDictionary *)attributes clickActionHandler:(YJClickActionHandler)clickActionHandler{
    [self.data addString:string attributes:attributes clickActionHandler:clickActionHandler];
}

- (void)addAttributedString:(NSAttributedString *)attr{
    [self.data addAttributedString:attr clickActionHandler:nil];
}
- (void)addAttributedString:(NSAttributedString *)attr clickActionHandler:(YJClickActionHandler)clickActionHandler{
    [self.data addAttributedString:attr clickActionHandler:clickActionHandler];
}
- (void)addLink:(NSString *)link clickActionHandler:(YJClickActionHandler)clickActionHandler{
    [self.data addLink:link clickActionHandler:clickActionHandler];
}

- (void)addImage:(UIImage *)image size:(CGSize)size clickActionHandler:(YJClickActionHandler)clickActionHandler{
    [self.data addImage:image size:size clickActionHandler:clickActionHandler];
}

- (void)addView:(UIView *)view size:(CGSize)size clickActionHandler:(YJClickActionHandler)clickActionHandler{
    [self.data addView:view size:size clickActionHandler:clickActionHandler];
}

- (void)addView:(UIView *)view size:(CGSize)size align:(YJAttachmentAlignType)align clickActionHandler:(YJClickActionHandler)clickActionHandler{
    [self.data addView:view size:size align:align clickActionHandler:clickActionHandler];
}

- (void)setNumberOfLines:(NSInteger)numberOfLines {
    self.data.numberOfLines = numberOfLines;
    [self setNeedsDisplay];
}


#pragma mark - Override

- (CGSize)sizeThatFits:(CGSize)size {
    NSAttributedString *drawString = self.data.attributeStringToDraw;
    if (drawString == nil) {
        return CGSizeZero;
    }
    CFAttributedStringRef attributedStringRef = (__bridge CFAttributedStringRef)drawString;
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attributedStringRef);
    CFRange range = CFRangeMake(0, 0);
    if (_numberOfLines > 0 && framesetter) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, size.width, size.height));
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFArrayRef lines = CTFrameGetLines(frame);
        
        if (nil != lines && CFArrayGetCount(lines) > 0) {
            NSInteger lastVisibleLineIndex = MIN(_numberOfLines, CFArrayGetCount(lines)) - 1;
            CTLineRef lastVisibleLine = CFArrayGetValueAtIndex(lines, lastVisibleLineIndex);
            
            CFRange rangeToLayout = CTLineGetStringRange(lastVisibleLine);
            range = CFRangeMake(0, rangeToLayout.location + rangeToLayout.length);
        }
        CFRelease(frame);
        CFRelease(path);
    }
    
    CFRange fitCFRange = CFRangeMake(0, 0);
    CGSize newSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, range, NULL, size, &fitCFRange);
    if (framesetter) {
        CFRelease(framesetter);
    }
    
    return newSize;
}

- (CGSize)intrinsicContentSize {
    return [self sizeThatFits:CGSizeMake(self.bounds.size.width, 10000)];
}

// truncationToken, truncationActionHandler, text, textColor, font, shadowColor, shadowOffset, shadowAlpha, lineSpacing, paragraphSpacing, textAlignment 这些属性走转发流程
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.data;
}

#pragma mark - Draw
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1, -1);
    
    // 处理数据
    [self.data composeDataToDrawWithBounds:self.bounds];
    
    // 绘制阴影
    [self drawShadowInContext:context];
    
    // 绘制文字
    [self drawTextInContext:context];
    
    // 绘制图片
    [self drawAttachmentsInContext:context];
}

/* 绘制文字 */
- (void)drawTextInContext:(CGContextRef)context {
    if (self.data.drawMode == YJDrawModeFrame) {
        CTFrameDraw(self.data.frameToDraw, context);
    } else if (self.data.drawMode == YJDrawModeLines) {
        for (YJCTLine *line in self.data.linesToDraw) {
            // 设置Line绘制的位置
            CGContextSetTextPosition(context, line.position.x, line.position.y);
            CTLineDraw(line.ctLine, context);
        }
    }
}

/* 绘制图片 */
- (void)drawAttachmentsInContext:(CGContextRef)context {
    // 在CGContextRef上下文上绘制图片
    for (int i = 0; i < self.data.attachments.count; i++) {
        YJAttachmentItem *attachmentItem = self.data.attachments[i];
        if (attachmentItem.type == YJAttachmentTypeImage) {
            if (attachmentItem.image) {
                CGContextDrawImage(context, attachmentItem.frame, attachmentItem.image.CGImage);
            }
        } else if (attachmentItem.type == YJAttachmentTypeView) {
            if (attachmentItem.view) {
                attachmentItem.view.frame = attachmentItem.frame;
                [self addSubview:attachmentItem.view];
            }
        }
    }
}

/* 绘制阴影 */
- (void)drawShadowInContext:(CGContextRef)context {
    if (self.data.shadowColor == nil
        || CGSizeEqualToSize(self.data.shadowOffset, CGSizeZero)) {
        return;
    }
    CGContextSetShadowWithColor(context, self.data.shadowOffset, self.data.shadowAlpha, self.data.shadowColor.CGColor);
}

#pragma mark - Gesture
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = event.allTouches.anyObject;
    if (touch.view == self) {
        CGPoint point = [touch locationInView:touch.view];
        YJBaseCoreTextItem *clickedItem = [self.data itemAtPoint:point];
        self.clickedItem = clickedItem;
        NSLog(@"clickedItem = %@", clickedItem);
        if (clickedItem && clickedItem.clickActionHandler) {
            [self addClickableCoverWithItem:clickedItem];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    !self.clickedItem.clickActionHandler ?: self.clickedItem.clickActionHandler(_clickedItem);
    self.clickedItem = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self removeClickableCoverView];
    });
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.clickedItem = nil;
    [self touchesEnded:touches withEvent:event];
}


#pragma mark - Helper

- (void)addClickableCoverWithItem:(YJBaseCoreTextItem *)item {
    for (NSValue *frameValue in item.clickableFrames) {
        CGRect clickedPartFrame = frameValue.CGRectValue;
        UIView *coverView = [[UIView alloc] initWithFrame:clickedPartFrame];
        coverView.tag = COVER_TAG;
        coverView.backgroundColor = [UIColor colorWithRed:0.3 green:1 blue:1 alpha:0.3];
        coverView.layer.cornerRadius = 3;
        [self addSubview:coverView];
    }
}

- (void)removeClickableCoverView {
    for (UIView *subView in self.subviews) {
        if (subView.tag == COVER_TAG) {
            [subView removeFromSuperview];
        }
    }
}


#pragma mark - Lazy load

- (YJRichContentData *)data {
    if (!_data) {
        _data = [YJRichContentData new];
    }
    return _data;
}

@end
