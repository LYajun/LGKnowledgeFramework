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

#import "YJSpeechFileManager.h"
#import "YJSpeechManager.h"
#import "YJSpeechMark.h"
#import "YJSpeechResModel.h"
#import "YJSpeechResultModel.h"
#import "YJSpeechTimer.h"
#import "KYPlayer.h"
#import "KYRecorder.h"
#import "KYWavHeader.h"
#import "KYStartEngineConfig.h"
#import "KYTestConfig.h"
#import "KYTestEngine.h"
#import "skegn.h"

FOUNDATION_EXPORT double YJTaskMarkVersionNumber;
FOUNDATION_EXPORT const unsigned char YJTaskMarkVersionString[];

