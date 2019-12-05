//
//  YJRichTextData.h
//  CoreTextDemo
//
//  Created by 刘亚军 on 2019/11/19.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
NS_ASSUME_NONNULL_BEGIN

@interface YJRichTextData : NSObject
@property (nonatomic, assign) CTFrameRef ctFrame;
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSAttributedString *attributeString;
@end

NS_ASSUME_NONNULL_END
