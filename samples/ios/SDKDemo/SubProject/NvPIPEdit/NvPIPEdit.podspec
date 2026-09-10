#
# Be sure to run `pod lib lint NvPIPEdit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NvPIPEdit'
  s.version          = '0.1.0'
  s.summary          = 'A short description of NvPIPEdit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/chuyang009@163.com/NvPIPEdit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'chuyang009@163.com' => 'liu_dongxu@cdv.com' }
  s.source           = { :git => 'https://github.com/chuyang009@163.com/NvPIPEdit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'NvPIPEdit/Classes/**/*'
  s.pod_target_xcconfig   = {
    'ENABLE_BITCODE'       => 'NO'
  }
  # s.resource_bundles = {
  #   'NvPIPEdit' => ['NvPIPEdit/Assets/*.png']
  # }
  s.vendored_frameworks  = 'NvStreamingSdkCore.framework'
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => [
       '${SRCROOT}/../../../../lib/ios',
       '${PODS_ROOT}/../../../../lib/ios',
       '$(SRCROOT)/../../../../../../../lib/ios',
       '$(SRCROOT)/../../../../../../lib/ios/'],
      'HEADER_SEARCH_PATHS' => [
      '$(SRCROOT)/../../../../lib/ios/NvStreamingSdkCore.framework/Headers',
      '$(SRCROOT)/../../../../../../lib/ios/NvStreamingSdkCore.framework/Headers',
      '$(SRCROOT)/../../../../../../../lib/ios/NvStreamingSdkCore.framework/Headers'
      ]
  }
  
  s.xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => ['${PODS_ROOT}/../../../../lib/ios',
       '$(SRCROOT)/../../../../../../../lib/ios'],
      'HEADER_SEARCH_PATHS' => [
      '$(SRCROOT)/../../../../lib/ios/NvStreamingSdkCore.framework/Headers',
      '$(SRCROOT)/../../../../../../../lib/ios/NvStreamingSdkCore.framework/Headers'
      ]
  }
  
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
#   s.dependency 'SDWebImage', '~> 5.9.5'
  s.dependency 'NvBaseCommon'
  s.dependency 'NvAlbum'
  s.dependency 'MBProgressHUD', '~> 1.1.0'
#   s.dependency 'YYModel', '~> 1.0.4'
  s.dependency 'Masonry', '~> 1.1.0'
end
