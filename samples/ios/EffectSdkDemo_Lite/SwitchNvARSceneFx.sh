#!/bin/sh

PROJECTFILE=`pwd`/EffectSdkDemo.xcodeproj/project.pbxproj
EffectSdkDemoFILE=`pwd`
cd ..
PROJECTARSceneFx=`pwd`/NvARSceneFxModule
PROJECTNvARSceneMacro=$PROJECTARSceneFx/NvARSceneFxModule/NvUtils/NvARSceneMacro.h

echo "主工程目录=========$PROJECTFILE"
echo "人脸模型宏定义文件=========$PROJECTNvARSceneMacro"

if [ $1 == 0 ]
then
    sed -i "" "s/#define USE_EFFECT_SDK_NO/#define USE_EFFECT_SDK/g" $PROJECTNvARSceneMacro
    sed -i "" "s/#define USE_EFFECT_SDK/#define USE_EFFECT_SDK_NO/g" $PROJECTNvARSceneMacro
    if cat $PROJECTFILE | grep "NvEffectSdkCore.framework" > /dev/null
    then
        echo "NvStreamingSdkCore切换失败！"
    else
        echo "NvStreamingSdkCore切换成功！"
    fi
else
    sed -i "" "s/#define USE_EFFECT_SDK_NO/#define USE_EFFECT_SDK/g" $PROJECTNvARSceneMacro
    if cat $PROJECTFILE | grep "NvStreamingSdkCore.framework" > /dev/null
    then
        echo "NvEffectSdkCore切换失败！"
    else
        echo "NvEffectSdkCore切换成功！"
    fi
fi

cd $PROJECTARSceneFx

xcodebuild clean
#编译debug版本
xcodebuild -target NvARSceneFx build -configuration Debug
#编译release版本
#xcodebuild -target NvARSceneFx build

rm -rf $EffectSdkDemoFILE/EffectSdkDemo/Resources/NvARSceneFx.framework

PROJECTNvARSceneSDK=$PROJECTARSceneFx/build/Debug-iphoneos/NvARSceneFx.framework
cp -rf $PROJECTNvARSceneSDK $EffectSdkDemoFILE/EffectSdkDemo/Resources
