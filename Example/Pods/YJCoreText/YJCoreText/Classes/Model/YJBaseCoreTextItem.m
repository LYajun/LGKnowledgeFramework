//
//  YJBaseCoreTextItem.m
//  CoreTextDemo
//
//  Created by 刘亚军 on 2019/11/19.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import "YJBaseCoreTextItem.h"

@implementation YJBaseCoreTextItem
- (NSMutableArray<NSValue *> *)clickableFrames {
    if (!_clickableFrames) {
        _clickableFrames = [NSMutableArray arrayWithCapacity:2];
    }
    return _clickableFrames;
}

- (void)addFrame:(CGRect)frame {
    [self.clickableFrames addObject:[NSValue valueWithCGRect:frame]];
}

- (BOOL)containsPoint:(CGPoint)point {
    for (NSValue *frameValue in self.clickableFrames) {
        if (CGRectContainsPoint(frameValue.CGRectValue, point)) {
            return YES;
        }
    }
    return false;
}
@end
