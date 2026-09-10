#
# Be sure to run `pod lib lint NvMimo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NvMimo'
  s.version          = '0.2.0'
  s.summary          = 'A short description of NvMimo.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/chuyang009@163.com/NvMimo'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'chuyang009@163.com' => 'liudongxu@meishesdk.com' }
  s.source           = { :git => 'https://github.com/chuyang009@163.com/NvMimo.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  
  s.source_files = 'NvMimo/Classes/**/*'
  s.resources = 'NvMimo/Assets/*'
#  s.public_header_files = 'NvMimo/Classes/Clip/Controller/NvMimoListViewController.h','Pod/Classes/**/*.h'
  s.private_header_files = ['NvMimo/Classes/Configuration/*.h',
  'NvMimo/Classes/FileConvert/*.h',
  'NvMimo/Classes/Library/Album/**/*.h',
  'NvMimo/Classes/ThemeManager/*.h',
  'NvMimo/Classes/Utils/*.h',
  'NvMimo/Classes/Clip/Model/*.h',
  'NvMimo/Classes/Clip/View/*.h',
  'NvMimo/Classes/Clip/Controller/NvMimoCompileViewController.h',
  'NvMimo/Classes/Clip/Controller/NvMimoEditTailoringViewController.h',
  'NvMimo/Classes/Clip/Controller/NvPreviewViewController.h',
  'NvMimo/Classes/Clip/AlbumSelect/*.h'
    ]
#  s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.pod_target_xcconfig   = {
    'ENABLE_BITCODE'       => 'NO'
  }
  s.vendored_frameworks  = 'NvStreamingSdkCore.framework'
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => [
       '$(SRCROOT)/../../../../../../lib/ios/',#为pod中demo配置路径
       '$(SRCROOT)/../../../../../../../lib/ios/',#为pod lib 配置路径
       '$(SRCROOT)/../../../../lib/ios/'],#为sdkdemo配置路径
      'HEADER_SEARCH_PATHS' => [#同上
      '$(SRCROOT)/../../../../../../lib/ios/NvStreamingSdkCore.framework/Headers',
      '$(SRCROOT)/../../../../../../../lib/ios/NvStreamingSdkCore.framework/Headers',
      '$(SRCROOT)/../../../../lib/ios/NvStreamingSdkCore.framework/Headers'
      ]
  }
    
  s.dependency 'AFNetworking'
  s.dependency 'SSZipArchive', '~> 2.2.2'
  s.dependency 'YYWebImage', '~> 1.0.5'
  s.dependency 'MBProgressHUD', '~> 1.1.0'
  s.dependency 'YYModel', '~> 1.0.4'
  s.dependency 'Masonry', '~> 1.1.0'
  s.dependency 'Reachability', '~> 3.2.0'
  s.dependency 'NvBaseCommon'
  s.dependency 'NvSDKCommon'
  s.dependency 'NvAlbum'
  
end
