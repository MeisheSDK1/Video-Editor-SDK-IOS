#
#  Be sure to run `pod spec lint NvEffectModule.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "NvEffectModule"
  spec.version      = "0.0.1"
  spec.summary      = "the editor module"
  spec.description  = "the media asset editor"
  spec.homepage     = "https://github.com"
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "meishe" => "meicamapp@meishesdk.com" }
  spec.source       = { :git => "https://github.com/meicam/NvEffectModule.git", :tag => "#{spec.version}" }

  spec.prepare_command = "sh #{__dir__}/PullShell.sh"
  
  spec.platform              = :ios
  spec.static_framework      = false
  spec.ios.deployment_target = '11.0'
  spec.ios.requires_arc      = true
  spec.ios.xcconfig = {
    'FRAMEWORK_SEARCH_PATHS' => [#为子工程配置framework路径
    '$(SRCROOT)/../../../../lib/ios'
    ]
  }

  spec.ios.pod_target_xcconfig   = {
    'SWIFT_VERSION'                    => '5.0',
    'ENABLE_BITCODE'                   => 'NO',
    'DEFINES_MODULE'                   => 'YES',
    'BUILD_LIBRARIES_FOR_DISTRIBUTION' => 'YES'
  }
  
  spec.default_subspec = 'UseEffectSdkCore'
  
  spec.subspec 'UseEffectSdkCore' do |useEffectSdkCore|
    useEffectSdkCore.resources = 'NvEffectModule/Resources/*'
    useEffectSdkCore.source_files = [
    'NvEffectModule/SourceFiles/Communal/**/*.*',
    'NvEffectModule/SourceFiles/NvEffectModule/**/*.*',
    ]
    
    useEffectSdkCore.public_header_files = [
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLiveHomePage/NvLiveHomeListPageController.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLiveHomePage/NvLiveModel.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLiveHomePage/NvLiveUserModel.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLivePush/NvLiveViewController.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLivePush/View/NvLiveCountDownAnimationView.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLivePush/View/NvLiveGarbageView.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLivePush/View/NvLivePushConfigView.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLivePush/View/NvLivePushOperatingView.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLivePush/View/NvLiveUserView.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLivePush/Model/NvLiveFunctionModel.h',
    'NvEffectModule/SourceFiles/Communal/NvLivePopView.h',
    'NvEffectModule/SourceFiles/Communal/Utils/NvLiveAppEnv.h',
    'NvEffectModule/SourceFiles/Communal/BeautyView/View/NvLiveARSceneFilterView.h',
    'NvEffectModule/SourceFiles/Communal/BeautyView/View/NvLiveARSeceneCaptureFilterCell.h',
    'NvEffectModule/SourceFiles/Communal/Category/UIColor+NvLiveColor.h',
    'NvEffectModule/SourceFiles/Communal/Makeup/NvMakeupView/NvLiveARSceneMakeupView.h',
    'NvEffectModule/SourceFiles/Communal/Makeup/NvMakeupView/NvLiveMenuTabView.h',
    'NvEffectModule/SourceFiles/Communal/BeautyView/View/NvLiveBeautyView.h',
    'NvEffectModule/SourceFiles/NvEffectModule/NvLiveEffectModule.h',
    'NvEffectModule/SourceFiles/NvEffectModule/ViewModel/NvLiveBeautyViewModel.h',
    'NvEffectModule/SourceFiles/NvEffectModule/ViewModel/NvLiveFilterViewModel.h',
    'NvEffectModule/SourceFiles/NvEffectModule/ViewModel/NvLivePropViewModel.h',
    'NvEffectModule/SourceFiles/NvEffectModule/ViewModel/NvLiveMakeupViewModel.h',
    ]
  end
  
  spec.subspec 'UseNvStreamingSdkCore' do |useNvStreamingSdkCore|
    useNvStreamingSdkCore.resources = 'NvEffectModule/Resources/*'
    useNvStreamingSdkCore.source_files = [
    'NvEffectModule/SourceFiles/Communal/**/*.*',
    'NvEffectModule/SourceFiles/NvStreamingModule/**/*.*',
    ]
    
    useNvStreamingSdkCore.public_header_files = [
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLiveHomePage/NvLiveHomeListPageController.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLiveHomePage/NvLiveModel.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLiveHomePage/NvLiveUserModel.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLivePush/NvLiveViewController.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLivePush/View/NvLiveCountDownAnimationView.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLivePush/View/NvLiveGarbageView.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLivePush/View/NvLivePushConfigView.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLivePush/View/NvLivePushOperatingView.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLivePush/View/NvLiveUserView.h',
    'NvEffectModule/SourceFiles/Communal/NvLive/NvLivePush/Model/NvLiveFunctionModel.h',
    'NvEffectModule/SourceFiles/Communal/NvLivePopView.h',
    'NvEffectModule/SourceFiles/Communal/Utils/NvLiveAppEnv.h',
    'NvEffectModule/SourceFiles/Communal/BeautyView/View/NvLiveARSceneFilterView.h',
    'NvEffectModule/SourceFiles/Communal/BeautyView/View/NvLiveARSeceneCaptureFilterCell.h',
    'NvEffectModule/SourceFiles/Communal/Category/UIColor+NvLiveColor.h',
    'NvEffectModule/SourceFiles/Communal/Makeup/NvMakeupView/NvLiveARSceneMakeupView.h',
    'NvEffectModule/SourceFiles/Communal/Makeup/NvMakeupView/NvLiveMenuTabView.h',
    'NvEffectModule/SourceFiles/Communal/BeautyView/View/NvLiveBeautyView.h',
    'NvEffectModule/SourceFiles/NvStreamingModule/NvLiveStreamingModule.h',
    'NvEffectModule/SourceFiles/NvStreamingModule/ViewModel/NvLiveBeautyViewModel.h',
    'NvEffectModule/SourceFiles/NvStreamingModule/ViewModel/NvLiveFilterViewModel.h',
    'NvEffectModule/SourceFiles/NvStreamingModule/ViewModel/NvLivePropViewModel.h',
    'NvEffectModule/SourceFiles/NvStreamingModule/ViewModel/NvLiveMakeupViewModel.h',
    'NvEffectModule/SourceFiles/NvStreamingModule/ViewModel/NvLiveCaptureModularVM.h',
    'NvEffectModule/SourceFiles/NvStreamingModule/ViewModel/NvLiveCaptureModularVMFilter.h',
    'NvEffectModule/SourceFiles/NvStreamingModule/ViewModel/NvLiveCaptureModularVMProp.h',
    'NvEffectModule/SourceFiles/NvStreamingModule/ViewModel/NvLiveCaptureModularVMMakeup.h',
    ]
  end
  
  spec.ios.dependency 'Masonry'
  spec.ios.dependency 'YYModel'

end
