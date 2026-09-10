#
# Be sure to run `pod lib lint QuickSplicing.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'QuickSplicing'
  s.version          = '0.1.0'
  s.summary          = 'A short description of QuickSplicing.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ms/QuickSplicing'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ms' => '970028126@qq.com' }
  s.source           = { :git => 'https://github.com/ms/QuickSplicing.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'QuickSplicing/Classes/**/*'
  
  s.pod_target_xcconfig   = {
    'ENABLE_BITCODE'       => 'NO'
  }
  s.resources = 'QuickSplicing/Assets/*'

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
