#!/bin/sh

#  PullShell.sh
#  EffectSdkDemo
#
#  Created by meicam on 2021/9/27.
#  Copyright © 2021 美摄. All rights reserved.
ShellFile="../FTPPullShell/PullResources.sh"
if [ -f $ShellFile ]; then
    #第一个参数为工程代码文件夹，第二个是资源版本）
    chmod +x ../FTPPullShell/PullResources.sh
    sh $ShellFile "EffectSdkDemo" "3.8.1"
fi
echo "结束下载ftp"
