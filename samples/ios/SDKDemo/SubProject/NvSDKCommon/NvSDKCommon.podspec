#
# Be sure to run `pod lib lint NvSDKCommon.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NvSDKCommon'
  s.version          = '0.1.0'
  s.summary          = 'A short description of NvSDKCommon.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/chuyang009@163.com/NvSDKCommon'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'chuyang009@163.com' => 'liu_dongxu@cdv.com' }
  s.source           = { :git => 'https://github.com/chuyang009@163.com/NvSDKCommon.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.pod_target_xcconfig   = {
    'ENABLE_BITCODE'       => 'NO'
  }
  s.source_files = 'NvSDKCommon/Classes/**/*'
  s.resources = 'NvSDKCommon/Assets/*'

#  s.public_header_files = 'NvSDKCommon/Classes/Compile/NvCompileViewController.h',
#      'NvSDKCommon/Classes/Common/NvWeakTimer.h',
#      'NvSDKCommon/Classes/Base/*.h',
#      'NvSDKCommon/Classes/View/*.h'
#  s.private_header_files = [
#  'NvSDKCommon/Classes/Utils/*.h'
#  
#  ]
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
  s.dependency 'NvBaseCommon'
  s.dependency 'Masonry', '~> 1.1.0'
  s.dependency 'AFNetworking'
  s.dependency 'NvBaseCommon'
  s.dependency 'SSZipArchive'
end
