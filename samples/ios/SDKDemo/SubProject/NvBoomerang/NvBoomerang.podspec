#
# Be sure to run `pod lib lint NvBoomerang.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NvBoomerang'
  s.version          = '0.1.0'
  s.summary          = 'A short description of NvBoomerang.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/chuyang009@163.com/NvBoomerang'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'chuyang009@163.com' => 'liudongxu@meishesdk.com' }
  s.source           = { :git => 'https://github.com/chuyang009@163.com/NvBoomerang.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'NvBoomerang/Classes/**/*'
  
  s.resources = 'NvBoomerang/Assets/*'

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.pod_target_xcconfig   = {
    'ENABLE_BITCODE'       => 'NO'
  }

  #s.vendored_frameworks  = 'NvStreamingSdkCore.framework'
  s.libraries = "c++", "z", "NvBoomerangLib"
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => [
       "$(SRCROOT)/../../../../../../lib/ios",#为pod中demo配置路径
       "$(SRCROOT)/../../../../../../../lib/ios",#为pod lib 配置路径
       "$(SRCROOT)/../../../../lib/ios"],#为sdkdemo配置路径
       
      'HEADER_SEARCH_PATHS' => [#同上
      "$(SRCROOT)/../../../../../../lib/ios/NvStreamingSdkCore.framework/Headers",
      "$(SRCROOT)/../../../../../../../lib/ios/NvStreamingSdkCore.framework/Headers",
      "$(SRCROOT)/../../../../lib/ios/NvStreamingSdkCore.framework/Headers",
      '$(SRCROOT)/../../../../../../extrasdk/sdk/ios/NvBoomerangLib/include',
      '$(SRCROOT)/../../../../../../../extrasdk/sdk/ios/NvBoomerangLib/include',
      '$(SRCROOT)/../../../../extrasdk/sdk/ios/NvBoomerangLib/include'
      ],
      
      'LIBRARY_SEARCH_PATHS' => [
      '$(SRCROOT)/../../../../../../extrasdk/sdk/ios',
      '$(SRCROOT)/../../../../extrasdk/sdk/ios',
      '$(SRCROOT)/../../../../../../../extrasdk/sdk/ios'
      ]
  }

  
#   s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'NvBaseCommon'
  s.dependency 'NvSDKCommon'
  s.dependency 'Masonry', '1.1.0'
  s.dependency 'AFNetworking'
end
