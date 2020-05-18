#
# Be sure to run `pod lib lint LGKnowledgeFramework.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LGKnowledgeFramework'
  s.version          = '2.0.5'
  s.summary          = '智能化知识点学习课件'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/LYajun/LGKnowledgeFramework'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'LYajun' => 'liuyajun1999@icloud.com' }
  s.source           = { :git => 'https://github.com/LYajun/LGKnowledgeFramework.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.static_framework  = true

  #系统依赖库
  #s.frameworks = 'xx', 'xx'
  #s.libraries = 'xx', 'xx', 'xx'
  
  #需要包含的源文件
  s.source_files = 'LGKnowledgeFramework/Classes/LGKnowledgeFramework.framework/Headers/*.{h}'

  #你的SDK路径
  s.vendored_frameworks = 'LGKnowledgeFramework/Classes/LGKnowledgeFramework.framework'

  s.resources = 'LGKnowledgeFramework/Classes/LGKnowledgeFramework.bundle'

  s.dependency 'YJTaskMark'
  s.dependency 'YJExtensions'
  s.dependency 'YJBaseModule'
  s.dependency 'LGAlertHUD'
  s.dependency 'YJNetManager'
  s.dependency 'YJPresentAnimation'
  s.dependency 'YJUtils'
  s.dependency 'MJExtension'
  s.dependency 'Masonry'
  s.dependency 'YJImageBrowser'
  s.dependency 'YJCoreText'
end
