#
# Be sure to run `pod lib lint NvAlbum.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NvAlbum'
  s.version          = '0.2.0'
  s.summary          = 'A short description of NvAlbum.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/chuyang009@163.com/NvAlbum'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'chuyang009@163.com' => 'liudongxu@meishesdk.com' }
  s.source           = { :git => 'https://github.com/chuyang009@163.com/NvAlbum.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.source_files = 'NvAlbum/Classes/**/*'
  s.resources = 'NvAlbum/Assets/*'
  
  s.public_header_files = 'Pod/Classes/Controller/NvAlbumViewController.h',
       'Pod/Classes/Model/NvAlbumItem.h',
       'Pod/Classes/Controller/NvAlbumSizeViewController.h',
       'Pod/Classes/NvAlbum.h'
       
  s.private_header_files = ['NvAlbum/Classes/Utils/*.h',
  'NvAlbum/Classes/Category/*.h',
  'NvAlbum/Classes/FetchAlbum/*.h',
  'NvAlbum/Classes/View/*.h',
  'NvAlbum/Classes/Controller/NvAlbumBaseViewController.h',
  'NvAlbum/Classes/Controller/NvAlbumSizeViewController.h',
  'NvAlbum/Classes/Controller/NvAlbumProgressViewController.h']

  s.pod_target_xcconfig   = {
    'ENABLE_BITCODE'       => 'NO'
  }
#  s.xcconfig = {
#      'HEADER_SEARCH_PATHS' => [
#      '$(inherited)'
#      ]
#  }
  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  
  s.dependency 'MBProgressHUD', '~> 1.1.0'
  s.dependency 'Masonry', '~> 1.1.0'
  s.dependency 'NvBaseCommon'
  
end
