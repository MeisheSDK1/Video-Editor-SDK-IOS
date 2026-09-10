#!/bin/sh

PROJECTFILE=`pwd`/EffectSdkDemo.xcodeproj/project.pbxproj
if [ $1 == 0 ]
then
    if cat $PROJECTFILE | grep "NvEffectSdkCore.framework" > /dev/null
    then
        sed -i "" "s/NvEffectSdkCore.framework/NvStreamingSdkCore.framework/g" $PROJECTFILE
    else
        echo "sdk切换成功！"
    fi

else
    if cat $PROJECTFILE | grep "NvStreamingSdkCore.framework" > /dev/null
    then
        sed -i "" "s/NvStreamingSdkCore.framework/NvEffectSdkCore.framework/g" $PROJECTFILE
    else
        echo "sdk切换成功！"
    fi

fi


