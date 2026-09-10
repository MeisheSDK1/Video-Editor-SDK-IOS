#!/bin/sh

#  PullShell.sh
#
#
#  Created by Meicam on 2021/10/20.
#  Copyright © 2021 cdv. All rights reserved.
ShellFile="../FTPPullShell/PullResources.sh"
if [ -f $ShellFile ]; then
    #第一个参数为工程代码文件夹，第二个是资源版本）
    sh $ShellFile "NvEffectModule" "3.16.1"
fi
rm -rf "./NvEffectModule/__MACOSX"
