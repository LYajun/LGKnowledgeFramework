#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "YJAttachmentItem.h"
#import "YJBaseCoreTextItem.h"
#import "YJCTLine.h"
#import "YJLinkItem.h"
#import "YJRichContentData.h"
#import "YJRichTextData.h"
#import "YJTextItem.h"
#import "YJTruncationItem.h"
#import "YJDrawView.h"

FOUNDATION_EXPORT double YJCoreTextVersionNumber;
FOUNDATION_EXPORT const unsigned char YJCoreTextVersionString[];

