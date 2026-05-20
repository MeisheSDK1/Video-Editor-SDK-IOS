#!/bin/sh
ShellFile="../FTPPullShell/PullResources.sh"
NvAISdk="`pwd`/${PROJECT_DIRNAME}${PROJECT_NAME}/Resources/NvAISdk.framework"
extrasdk="../../../extrasdk/sdk/ios/"
extrasdkNvAISdk="../../../extrasdk/sdk/ios/NvAISdk.framework"

if [ -f $ShellFile ]; then
    #第一个参数为工程代码文件夹，第二个是资源版本）
    # The first parameter is the project code folder, the second parameter is the resource version)
    chmod +x ../FTPPullShell/PullResources.sh
    sh $ShellFile "SDKDemo" "3.15.1"
fi

if [ -e $extrasdkNvAISdk ]; then
    echo "已经拷贝过了"
else
    if [ -e $NvAISdk ]; then
    echo "拷贝NvAISdk.framework到extrasdk目录下"
    cp -rf $NvAISdk $extrasdk
    fi
fi

