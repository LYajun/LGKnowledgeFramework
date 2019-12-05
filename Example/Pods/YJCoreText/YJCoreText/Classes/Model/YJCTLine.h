//
//  YJCTLine.h
//  CoreTextDemo
//
//  Created by 刘亚军 on 2019/11/19.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
NS_ASSUME_NONNULL_BEGIN

@interface YJCTLine : NSObject
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) CTLineRef ctLine;
@end

NS_ASSUME_NONNULL_END
