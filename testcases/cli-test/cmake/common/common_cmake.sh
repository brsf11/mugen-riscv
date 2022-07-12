#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# ############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/12
# @License   :   Mulan PSL v2
# @Version   :   1.0
# @Desc      :   public class integration
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function deploy_env() {
    DNF_INSTALL "cmake gcc-c++ ninja-build make"
    mkdir build && cd build
}

function clear_env() {
    currentDir=$(
        cd "$(dirname $0)" || exit 1
        pwd
    )
    currentName=$(echo $currentDir | awk -F '/' '{print $NF}')
    test "$currentName"x = "build"x && cd .. && {
        roc=$(ls | grep -vE "\.sh|\.c|\.cpp|\.txt")
        rm -rf $roc
    }
    DNF_REMOVE
}
