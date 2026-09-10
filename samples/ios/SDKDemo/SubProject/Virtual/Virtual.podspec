#
#  Be sure to run `pod spec lint Virtual.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "Virtual"
  s.version      = "0.1.0"
  s.summary      = "A short description of Virtual."

  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description  = <<-DESC
  TODO: Add long description of the pod here.
                   DESC

  s.homepage         = 'https://github.com/chuyang009@163.com/Virtual'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'chuyang009@163.com' => 'liu_dongxu@cdv.com' }
  s.source           = { :git => 'https://github.com/chuyang009@163.com/Virtual.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.source_files = 'Virtual/Classes/**/*'
  s.pod_target_xcconfig   = {
    'ENABLE_BITCODE'       => 'NO'
  }
  s.resources = 'Virtual/Assets/*'

  #s.vendored_frameworks  = 'NvStreamingSdkCore.framework'
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => [
       "$(SRCROOT)/../../../../../../lib/ios",#为pod中demo配置路径
       "$(SRCROOT)/../../../../../../../lib/ios",#为pod lib 配置路径
       "$(SRCROOT)/../../../../lib/ios"],#为sdkdemo配置路径
       
      'HEADER_SEARCH_PATHS' => [#同上
      "$(SRCROOT)/../../../../../../lib/ios/NvStreamingSdkCore.framework/Headers",
      "$(SRCROOT)/../../../../../../../lib/ios/NvStreamingSdkCore.framework/Headers",
      "$(SRCROOT)/../../../../lib/ios/NvStreamingSdkCore.framework/Headers"
      ]
  }
  
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Masonry', '~> 1.1.0'
  s.dependency 'NvBaseCommon'
  s.dependency 'NvSDKCommon'
  s.dependency 'NvAlbum'
  s.dependency 'YYWebImage', '~> 1.0.5'

end
