//
//  YJAttachmentItem.m
//  CoreTextDemo
//
//  Created by 刘亚军 on 2019/11/19.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import "YJAttachmentItem.h"

@implementation YJAttachmentItem
- (UIImage *)image {
    if ([_attachment isKindOfClass:[UIImage class]]) {
        return _attachment;
    }
    return nil;
}

- (UIView *)view {
    if ([_attachment isKindOfClass:[UIView class]]) {
        return _attachment;
    }
    return nil;
}
@end
