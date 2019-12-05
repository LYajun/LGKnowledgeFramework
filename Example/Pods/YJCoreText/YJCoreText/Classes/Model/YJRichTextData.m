//
//  YJRichTextData.m
//  CoreTextDemo
//
//  Created by 刘亚军 on 2019/11/19.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import "YJRichTextData.h"

@implementation YJRichTextData
- (NSMutableArray *)images {
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (void)dealloc {
    if (_ctFrame != nil) {
        CFRelease(_ctFrame);
    }
}
@end
