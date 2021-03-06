//
//  YJRichContentData.m
//  CoreTextDemo
//
//  Created by 刘亚军 on 2019/11/19.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import "YJRichContentData.h"
#import <YJExtensions/YJExtensions.h>

NSString * const YJExtraDataAttributeName = @"YJExtraDataAttributeName";
NSString * const YJExtraDataAttributeTypeKey = @"YJExtraDataAttributeTypeKey";
NSString * const YJExtraDataAttributeDataKey = @"YJExtraDataAttributeDataKey";
NSString * const YJRunMetaData = @"runMetaData";

@interface YJRichContentData ()

@property (nonatomic, strong) NSMutableAttributedString *attributeString;
@property (nonatomic, assign) CTFrameRef ctFrame;

/* 文本数据 */
@property (nonatomic, strong) NSMutableArray<YJTextItem *> *texts;

/* 链接数据 */
@property (nonatomic, strong) NSMutableArray<YJLinkItem *> *links;

/* 截断标识字符串数据 */
@property (nonatomic, strong) NSMutableArray<YJTruncationItem *> *truncations;

@end


@implementation YJRichContentData

- (instancetype)init {
    self = [super init];
    if (self) {
        _textColor = [UIColor blackColor];
        _fontSize = 14;
        _lineBreakMode = kCTLineBreakByTruncatingTail;
    }
    return self;
}
- (void)dealloc {
    if (_drawMode == YJDrawModeLines) {
        for (YJCTLine *line in _linesToDraw) {
            if (line.ctLine != nil) {
                CFRelease(line.ctLine);
            }
        }
    } else {
        if (_ctFrame != nil) {
            CFRelease(_ctFrame);
        }
    }
}

#pragma mark - Public

- (void)addString:(NSString *)string attributes:(NSDictionary *)attributes clickActionHandler:(YJClickActionHandler)clickActionHandler{
    YJTextItem *textItem = [YJTextItem new];
    textItem.contentAttr = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    textItem.clickActionHandler = clickActionHandler;
  
    [self.texts addObject:textItem];
    [self.attributeString appendAttributedString:[self textAttributeStringWithTextItem:textItem]];
}

- (void)addAttributedString:(NSAttributedString *)attr clickActionHandler:(YJClickActionHandler)clickActionHandler{
    YJTextItem *textItem = [YJTextItem new];
    textItem.contentAttr = attr;
    textItem.clickActionHandler = clickActionHandler;
    [self.texts addObject:textItem];
    [self.attributeString appendAttributedString:[self textAttributeStringWithTextItem:textItem]];
}
- (void)addLink:(NSString *)link clickActionHandler:(YJClickActionHandler)clickActionHandler{
    YJLinkItem *linkItem = [YJLinkItem new];
    linkItem.link = link;
    linkItem.clickActionHandler = clickActionHandler;
    [self.links addObject:linkItem];
    [self.attributeString appendAttributedString:[self linkAttributeStringWithLinkItem:linkItem]];
}

- (void)addImage:(UIImage *)image size:(CGSize)size clickActionHandler:(YJClickActionHandler)clickActionHandler{
    YJAttachmentItem *imageItem = [YJAttachmentItem new];
    [self updateAttachment:imageItem withFont:[UIFont systemFontOfSize:self.fontSize]];
    imageItem.attachment = image;
    imageItem.type = YJAttachmentTypeImage;
    imageItem.size = size;
    imageItem.clickActionHandler = clickActionHandler;
    [self.attachments addObject:imageItem];
    NSAttributedString *imageAttributeString = [self attachmentAttributeStringWithAttachmentItem:imageItem size:size];
    [self.attributeString appendAttributedString:imageAttributeString];
}

- (void)addView:(UIView *)view size:(CGSize)size clickActionHandler:(YJClickActionHandler)clickActionHandler{
    [self addView:view size:size align:(YJAttachmentAlignTypeBottom) clickActionHandler:clickActionHandler];
}

- (void)addView:(UIView *)view size:(CGSize)size align:(YJAttachmentAlignType)align clickActionHandler:(YJClickActionHandler)clickActionHandler{
    YJAttachmentItem *imageItem = [YJAttachmentItem new];
    [self updateAttachment:imageItem withFont:[UIFont systemFontOfSize:self.fontSize]];
    imageItem.align = align;
    imageItem.attachment = view;
    imageItem.type = YJAttachmentTypeView;
    imageItem.size = size;
    imageItem.clickActionHandler = clickActionHandler;
    [self.attachments addObject:imageItem];
    NSAttributedString *imageAttributeString = [self attachmentAttributeStringWithAttachmentItem:imageItem size:size];
    [self.attributeString appendAttributedString:imageAttributeString];
}

- (void)setText:(NSString *)text {
    _text = text;
    [self.attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:_text attributes:nil]];
    [self.attributeString yj_setFont:_fontSize];
    [self.attributeString yj_setColor:_textColor];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [self.attributeString yj_setColor:_textColor];
}

- (void)setFontSize:(CGFloat)fontSize{
    _fontSize = fontSize;
    [self.attributeString yj_setFont:_fontSize];
    [self updateAttachments];
}

- (void)setShadowColor:(UIColor *)shadowColor {
    _shadowColor = shadowColor;
}

- (void)setShadowOffset:(CGSize)shadowOffset {
    _shadowOffset = shadowOffset;
}

- (void)setShadowAlpha:(CGFloat)shadowAlpha {
    _shadowAlpha = shadowAlpha;
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    _lineSpacing = lineSpacing;
}

- (void)setParagraphSpacing:(CGFloat)paragraphSpacing {
    _paragraphSpacing = paragraphSpacing;
}

- (void)composeDataToDrawWithBounds:(CGRect)bounds {
    _ctFrame = [self composeCTFrameWithAttributeString:self.attributeStringToDraw frame:bounds];
    [self calculateContentPositionWithBounds:bounds];
    [self calculateTruncatedLinesWithBounds:bounds];
}

- (YJBaseCoreTextItem *)itemAtPoint:(CGPoint)point {
    for (YJBaseCoreTextItem *item in self.truncations) {
        if ([item containsPoint:point]) {
            return item;
        }
    }
    for (YJBaseCoreTextItem *item in self.links) {
        if ([item containsPoint:point]) {
            return item;
        }
    }
    for (YJBaseCoreTextItem *item in self.attachments) {
        if ([item containsPoint:point]) {
            return item;
        }
    }
    for (YJBaseCoreTextItem *item in self.texts) {
        if ([item containsPoint:point]) {
            return item;
        }
    }
    return nil;
}

- (NSAttributedString *)attributeStringToDraw {
    [self setStyleToAttributeString:self.attributeString];
    return self.attributeString;
}

- (CTFrameRef)frameToDraw {
    return self.ctFrame;
}

#pragma mark - Private
/* 设置排版样式 */
- (void)setStyleToAttributeString:(NSMutableAttributedString *)attributeString {
    CTParagraphStyleSetting settings[] =
    {
        {kCTParagraphStyleSpecifierAlignment, sizeof(self.textAlignment), &_textAlignment},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(self.lineSpacing), &_lineSpacing},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(self.lineSpacing), &_lineSpacing},
        {kCTParagraphStyleSpecifierParagraphSpacing, sizeof(self.paragraphSpacing), &_paragraphSpacing},
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(settings[0]));
    [attributeString addAttribute:(id)kCTParagraphStyleAttributeName
                            value:(__bridge id)paragraphStyle
                            range:NSMakeRange(0, [attributeString length])];
    CFRelease(paragraphStyle);
}

- (NSAttributedString *)linkAttributeStringWithLinkItem:(YJLinkItem *)linkItem {
    NSMutableAttributedString *linkAttributeString = [[NSMutableAttributedString alloc] initWithString:linkItem.link attributes:[self linkTextAttributes]];
    NSDictionary *extraData = @{YJExtraDataAttributeTypeKey: @(YJDataTypeLink),
                                YJExtraDataAttributeDataKey: linkItem,
                                };
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)linkAttributeString, CFRangeMake(0, linkItem.link.length), (CFStringRef)YJExtraDataAttributeName, (__bridge CFTypeRef)(extraData));
    return linkAttributeString;
}

- (NSAttributedString *)textAttributeStringWithTextItem:(YJTextItem *)textItem {
    NSMutableAttributedString *textAttributeString = [[NSMutableAttributedString alloc] initWithAttributedString:textItem.contentAttr];
    NSDictionary *extraData = @{YJExtraDataAttributeTypeKey: @(YJDataTypeLink),
                                YJExtraDataAttributeDataKey: textItem,
                                };
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)textAttributeString, CFRangeMake(0, textItem.contentAttr.length), (CFStringRef)YJExtraDataAttributeName, (__bridge CFTypeRef)(extraData));
    return textAttributeString;
}

- (void)updateAttachment:(YJAttachmentItem *)attachment withFont:(UIFont *)font {
    attachment.ascent = CTFontGetAscent((CTFontRef)font);
    attachment.descent = CTFontGetDescent((CTFontRef)font);
}

- (void)updateAttachments {
    for (YJAttachmentItem *attachment in self.attachments) {
        [self updateAttachment:attachment withFont:[UIFont systemFontOfSize:self.fontSize]];
    }
}
- (NSAttributedString *)attachmentAttributeStringWithAttachmentItem:(YJAttachmentItem *)attachmentItem size:(CGSize)size {
    // 创建CTRunDelegateCallbacks
    CTRunDelegateCallbacks callback;
    memset(&callback, 0, sizeof(CTRunDelegateCallbacks));
    callback.getAscent = getAscent;
    callback.getDescent = getDescent;
    callback.getWidth = getWidth;
    
    // 创建CTRunDelegateRef
    //    NSDictionary *metaData = @{YTRunMetaData: attachmentItem};
    CTRunDelegateRef runDelegate = CTRunDelegateCreate(&callback, (__bridge void * _Nullable)(attachmentItem));
    
    // 设置占位使用的图片属性字符串
    // 参考：https://en.wikipedia.org/wiki/Specials_(Unicode_block)  U+FFFC ￼ OBJECT REPLACEMENT CHARACTER, placeholder in the text for another unspecified object, for example in a compound document.
    unichar objectReplacementChar = 0xFFFC;
    NSMutableAttributedString *imagePlaceHolderAttributeString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithCharacters:&objectReplacementChar length:1] attributes:[self defaultTextAttributes]];
    
    // 设置RunDelegate代理
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)imagePlaceHolderAttributeString, CFRangeMake(0, 1), kCTRunDelegateAttributeName, runDelegate);
    
    // 设置附加数据，设置点击效果
    NSDictionary *extraData = @{YJExtraDataAttributeTypeKey: attachmentItem.type == YJAttachmentTypeImage ? @(YJDataTypeImage) : @(YJDataTypeView),
                                YJExtraDataAttributeDataKey: attachmentItem,
                                };
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)imagePlaceHolderAttributeString, CFRangeMake(0, 1), (CFStringRef)YJExtraDataAttributeName, (__bridge CFTypeRef)(extraData));
    
    CFRelease(runDelegate);
    return imagePlaceHolderAttributeString;
}

- (CTFrameRef)composeCTFrameWithAttributeString:(NSAttributedString *)attributeString frame:(CGRect)frame {
    // 绘制区域
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, (CGRect){{0, 0}, frame.size});
    
    // 使用NSMutableAttributedString创建CTFrame
    CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeString);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(0, attributeString.length), path, NULL);
    
    CFRelease(ctFramesetter);
    CFRelease(path);
    
    return ctFrame;
}
- (void)calculateContentPositionWithBounds:(CGRect)bounds {
    
    int imageIndex = 0;
    
    // CTFrameGetLines获取但CTFrame内容的行数
    NSArray *lines = (NSArray *)CTFrameGetLines(self.ctFrame);
    // CTFrameGetLineOrigins获取每一行的起始点，保存在lineOrigins数组中
    CGPoint lineOrigins[lines.count];
    CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, 0), lineOrigins);
    for (int i = 0; i < lines.count; i++) {
        CTLineRef line = (__bridge CTLineRef)lines[i];
        
        NSArray *runs = (NSArray *)CTLineGetGlyphRuns(line);
        for (int j = 0; j < runs.count; j++) {
            CTRunRef run = (__bridge CTRunRef)(runs[j]);
            NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes(run);
            if (!attributes) {
                continue;
            }
            
            // 获取附加的数据->设置链接、图片等元素的点击效果的位置
            NSDictionary *extraData = (NSDictionary *)[attributes valueForKey:YJExtraDataAttributeName];
            if (extraData) {
                NSInteger type = [[extraData valueForKey:YJExtraDataAttributeTypeKey] integerValue];
                YJBaseCoreTextItem *data = (YJBaseCoreTextItem *)[extraData valueForKey:YJExtraDataAttributeDataKey];
                NSLog(@"run = (%@-%@) type = %@ data = %@", @(i), @(j), @(type), data);
                
                // 获取CTRun的信息
                CGFloat ascent;
                CGFloat desent;
                // 可以直接从metaData获取到图片的宽度和高度信息
                CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &desent, NULL);
                CGFloat height = ascent + desent;
                
                // CTLineGetOffsetForStringIndex获取CTRun的起始位置
                CGFloat xOffset = lineOrigins[i].x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
                CGFloat yOffset = bounds.size.height - lineOrigins[i].y - ascent;
                
                if ([data isKindOfClass:YJBaseCoreTextItem.class]) {
                    // 由于CoreText和UIKit坐标系不同所以要做个对应转换
                    // CGRect ctClickableFrame = CGRectMake(xOffset, yOffset, width, height);
                    // 将CoreText坐标转换为UIKit坐标
                    CGRect uiKitClickableFrame = CGRectMake(xOffset, yOffset, width, height);
                    [data addFrame:uiKitClickableFrame];
                }
            }
            
            // 从属性中获取到创建属性字符串使用CFAttributedStringSetAttribute设置的delegate值
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[attributes valueForKey:(id)kCTRunDelegateAttributeName];
            if (!delegate) {
                continue;
            }
            // CTRunDelegateGetRefCon方法从delegate中获取使用CTRunDelegateCreate初始时候设置的元数据
            NSDictionary *metaData = (NSDictionary *)CTRunDelegateGetRefCon(delegate);
            if (!metaData) {
                continue;
            }
            
            // 找到代理则开始计算图片位置信息
            CGFloat ascent;
            CGFloat desent;
            // 可以直接从metaData获取到图片的宽度和高度信息
            CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &desent, NULL);
            CGFloat height = ascent + desent;
            
            // CTLineGetOffsetForStringIndex获取CTRun的起始位置
            CGFloat xOffset = lineOrigins[i].x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            CGFloat yOffset = lineOrigins[i].y;
            
            // 更新ImageItem对象的位置
            if (imageIndex < self.attachments.count) {
                YJAttachmentItem *imageItem = self.attachments[imageIndex];
                // 使用CG绘图的位置不用矫正，使用UI绘图的坐标Y轴会上下颠倒，所以需要做调整
                if (imageItem.type == YJAttachmentTypeView) {
                    yOffset = bounds.size.height - lineOrigins[i].y - ascent;
                } else if (imageItem.type == YJAttachmentTypeImage) {
                    yOffset = yOffset - desent;
                }
                imageItem.frame = CGRectMake(xOffset, yOffset, width, height);
                imageIndex ++;
            }
        }
    }
}

- (void)calculateTruncatedLinesWithBounds:(CGRect)bounds {
    
    // 清除旧的数据
    [self.truncations removeAllObjects];
    
    // 获取最终需要绘制的文本行数
    CFIndex numberOfLinesToDraw = [self numberOfLinesToDrawWithCTFrame:self.ctFrame];
    if (numberOfLinesToDraw <= 0) {
        self.drawMode = YJDrawModeFrame;
    } else {
        self.drawMode = YJDrawModeLines;
        NSArray *lines = (NSArray *)CTFrameGetLines(self.ctFrame);
        
        CGPoint lineOrigins[numberOfLinesToDraw];
        CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, numberOfLinesToDraw), lineOrigins);
        
        for (int lineIndex = 0; lineIndex < numberOfLinesToDraw; lineIndex ++) {
            
            CTLineRef line = (__bridge CTLineRef)(lines[lineIndex]);
            CFRange range = CTLineGetStringRange(line);
            // 判断最后一行是否需要显示【截断标识字符串(...)】
            if ( lineIndex == numberOfLinesToDraw - 1
                && range.location + range.length < [self attributeStringToDraw].length) {
                
                // 创建【截断标识字符串(...)】
                NSAttributedString *tokenString = nil;
                if (_truncationToken) {
                    tokenString = _truncationToken;
                } else {
                    NSUInteger truncationAttributePosition = range.location + range.length - 1;
                    
                    NSDictionary *attributes = [[self attributeStringToDraw] attributesAtIndex:truncationAttributePosition
                                                                                effectiveRange:NULL];
                    // 只要用到字体大小和颜色的属性，这里如果使用kCTParagraphStyleAttributeName属性在使用boundingRectWithSize方法计算大小的步骤会崩溃
                    NSDictionary *tokenAttributes =@{NSForegroundColorAttributeName: attributes[NSForegroundColorAttributeName]? attributes[NSForegroundColorAttributeName]: [UIColor blackColor],
                                                     NSFontAttributeName: attributes[NSFontAttributeName]? attributes[NSFontAttributeName]: [UIFont systemFontOfSize:14],
                                                     };
                    tokenString = [[NSAttributedString alloc] initWithString:@"\u2026" attributes:tokenAttributes];
                }
                
                // 计算【截断标识字符串(...)】的长度
                CGSize tokenSize = [tokenString boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:NULL].size;
                CGFloat tokenWidth = tokenSize.width;
                CTLineRef truncationTokenLine = CTLineCreateWithAttributedString((CFAttributedStringRef)tokenString);
                
                // 根据【截断标识字符串(...)】的长度，计算【需要截断字符串】的最后一个字符的位置，把该位置之后的字符从【需要截断字符串】中移除，留出【截断标识字符串(...)】的位置
                CFIndex truncationEndIndex = CTLineGetStringIndexForPosition(line, CGPointMake(bounds.size.width - tokenWidth, 0));
                CGFloat length = range.location + range.length - truncationEndIndex;
                
                // 把【截断标识字符串(...)】添加到【需要截断字符串】后面
                NSMutableAttributedString *truncationString = [[[self attributeStringToDraw] attributedSubstringFromRange:NSMakeRange(range.location, range.length)] mutableCopy];
                if (length < truncationString.length) {
                    [truncationString deleteCharactersInRange:NSMakeRange(truncationString.length - length, length)];
                    [truncationString appendAttributedString:tokenString];
                }
                
                // 使用`CTLineCreateTruncatedLine`方法创建含有【截断标识字符串(...)】的`CTLine`对象
                CTLineRef truncationLine = CTLineCreateWithAttributedString((CFAttributedStringRef)truncationString);
                CTLineTruncationType truncationType = kCTLineTruncationEnd;
                CTLineRef lastLine = CTLineCreateTruncatedLine(truncationLine, bounds.size.width, truncationType, truncationTokenLine);
                
                // 添加truncation的位置信息
                NSArray *runs = (NSArray *)CTLineGetGlyphRuns(line);
                if (runs.count > 0 && self.truncationActionHandler) {
                    CTRunRef run = (__bridge CTRunRef)runs.lastObject;
                    
                    CGFloat ascent;
                    CGFloat desent;
                    // 可以直接从metaData获取到图片的宽度和高度信息
                    CGFloat width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &desent, NULL);
                    CGFloat height = ascent + desent;
                    
                    YJTruncationItem* truncationItem = [YJTruncationItem new];
                    CGRect truncationFrame = CGRectMake(width - tokenWidth,
                                                        bounds.size.height - lineOrigins[lineIndex].y - height,
                                                        tokenSize.width,
                                                        tokenSize.height);
                    [truncationItem addFrame:truncationFrame];
                    truncationItem.clickActionHandler = self.truncationActionHandler;
                    [self.truncations addObject:truncationItem];
                }
                
                
                YJCTLine *ytLine = [YJCTLine new];
                ytLine.ctLine = lastLine;
                ytLine.position = CGPointMake(lineOrigins[lineIndex].x, lineOrigins[lineIndex].y);
                [self.linesToDraw addObject:ytLine];
                
                CFRelease(truncationTokenLine);
                CFRelease(truncationLine);
                
            } else {
                YJCTLine *ytLine = [YJCTLine new];
                ytLine.ctLine = line;
                ytLine.position = CGPointMake(lineOrigins[lineIndex].x, lineOrigins[lineIndex].y);
                [self.linesToDraw addObject:ytLine];
            }
        }
    }
}
- (CFIndex)numberOfLinesToDrawWithCTFrame:(CTFrameRef)ctFrame {
    if (_numberOfLines <= 0) {
        return _numberOfLines;
    }
    return MIN(CFArrayGetCount(CTFrameGetLines(ctFrame)), _numberOfLines);
}
#pragma mark - CTRunDelegateCallbacks 回调方法
static CGFloat getAscent(void *ref) {
    YJAttachmentItem *attachmentItem = (__bridge YJAttachmentItem *)ref;
    if (attachmentItem.align == YJAttachmentAlignTypeTop) {
        return attachmentItem.ascent;
    } else if (attachmentItem.align == YJAttachmentAlignTypeBottom) {
        return attachmentItem.size.height - attachmentItem.descent;
    } else if (attachmentItem.align == YJAttachmentAlignTypeCenter) {
        return attachmentItem.ascent - ((attachmentItem.descent + attachmentItem.ascent) - attachmentItem.size.height) / 2;
    }
    return attachmentItem.size.height;
}

static CGFloat getDescent(void *ref) {
    YJAttachmentItem *attachmentItem = (__bridge YJAttachmentItem *)ref;
    if (attachmentItem.align == YJAttachmentAlignTypeTop) {
        return attachmentItem.size.height - attachmentItem.ascent;
    } else if (attachmentItem.align == YJAttachmentAlignTypeBottom) {
        return attachmentItem.descent;
    } else if (attachmentItem.align == YJAttachmentAlignTypeCenter) {
        return attachmentItem.size.height - attachmentItem.ascent + ((attachmentItem.descent + attachmentItem.ascent) - attachmentItem.size.height) / 2;
    }
    return 0;
}

static CGFloat getWidth(void *ref) {
    YJAttachmentItem *attachmentItem = (__bridge YJAttachmentItem *)ref;
    return attachmentItem.size.width;
}

#pragma mark - Config
- (NSDictionary *)defaultTextAttributes {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18],
                                 NSForegroundColorAttributeName: [UIColor cyanColor]
                                 };
    return attributes;
}

- (NSDictionary *)boldHighlightedTextAttributes {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:24],
                                 NSForegroundColorAttributeName: [UIColor redColor],
                                 };
    return attributes;
}

- (NSDictionary *)linkTextAttributes {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18],
                                 NSForegroundColorAttributeName: [UIColor blueColor],
                                 NSUnderlineStyleAttributeName: @1,
                                 NSUnderlineColorAttributeName: [UIColor blueColor],
                                 };
    return attributes;
}


#pragma mark - lazy load


- (NSMutableArray *)attachments {
    if (!_attachments) {
        _attachments = [NSMutableArray array];
    }
    return _attachments;
}

- (NSMutableArray<YJTextItem *> *)texts{
    if (!_texts) {
        _texts = [NSMutableArray array];
    }
    return _texts;
}

- (NSMutableArray *)links {
    if (!_links) {
        _links = [NSMutableArray array];
    }
    return _links;
}

- (NSMutableArray<YJTruncationItem *> *)truncations {
    if (!_truncations) {
        _truncations = [NSMutableArray array];
    }
    return _truncations;
}

- (NSMutableArray<YJCTLine *> *)linesToDraw {
    if (!_linesToDraw) {
        _linesToDraw = [NSMutableArray array];
    }
    return _linesToDraw;
}

- (NSMutableAttributedString *)attributeString {
    if (!_attributeString) {
        _attributeString = [NSMutableAttributedString new];
    }
    return _attributeString;
}
@end
