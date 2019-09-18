# LGKnowledgeFramework

[![CI Status](https://img.shields.io/travis/lyj/LGKnowledgeFramework.svg?style=flat)](https://travis-ci.org/lyj/LGKnowledgeFramework)
[![Version](https://img.shields.io/cocoapods/v/LGKnowledgeFramework.svg?style=flat)](https://cocoapods.org/pods/LGKnowledgeFramework)
[![License](https://img.shields.io/cocoapods/l/LGKnowledgeFramework.svg?style=flat)](https://cocoapods.org/pods/LGKnowledgeFramework)
[![Platform](https://img.shields.io/cocoapods/p/LGKnowledgeFramework.svg?style=flat)](https://cocoapods.org/pods/LGKnowledgeFramework)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

LGKnowledgeFramework is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LGKnowledgeFramework'
```

## Usage


```ruby

配置：第一步
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 网络监控
    [[YJNetMonitoring shareMonitoring] startNetMonitoring];
    // 初始化语音评测
    [[YJSpeechManager defaultManager] initEngine];
    return YES;
}

配置：第二步

// 在登录成功时，需检测网络是否可以连接外网
[[YJNetMonitoring shareMonitoring] checkNetCanUseWithComplete:nil];

调用1：直接进入知识点课件首页
/** 服务器地址 */
[LGKnowledgeManager defaultManager].apiUrl =@"http://192.168.129.129:10107/";
/** 是否只开放知识点卡片 */
//    [LGKnowledgeManager defaultManager].onlyKlgCark = YES;
/** 知识点编码 */
[LGKnowledgeManager defaultManager].klgCode = [dic objectForKey:@"NewCode"];
[LGKnowledgeManager defaultManager].klgErrorBlock = ^(NSError *error) {
        NSLog(@"%@",error.localizedDescription);
};

调用2：知识点查询弹窗
/** 服务器地址 */
[LGKnowledgeManager defaultManager].apiUrl =@"http://192.168.129.129:10107/";
/** 知识点编码 */
[LGKnowledgeManager defaultManager].klgCode = [dic objectForKey:@"NewCode"];

[[LGKnowledgeManager defaultManager] presentKnowledgeAlertViewByController:self addStudyBlock:nil];

```


## Author

lyj, liuyajun1999@icloud.com

## License

LGKnowledgeFramework is available under the MIT license. See the LICENSE file for more info.
