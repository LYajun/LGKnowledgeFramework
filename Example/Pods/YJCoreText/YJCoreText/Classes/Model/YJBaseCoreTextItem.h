//
//  YJBaseCoreTextItem.h
//  CoreTextDemo
//
//  Created by 刘亚军 on 2019/11/19.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef void(^YJClickActionHandler)(id obj);
@interface YJBaseCoreTextItem : NSObject
@property (nonatomic, strong) NSMutableArray<NSValue *> *clickableFrames;
@property (nonatomic, copy) YJClickActionHandler clickActionHandler;

- (void)addFrame:(CGRect)frame;
- (BOOL)containsPoint:(CGPoint)point;
@end

NS_ASSUME_NONNULL_END
