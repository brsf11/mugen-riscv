#!/usr/bin/bash

# Copyright (c) 2022. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   Classicriver_jia
# @Contact   :   classicriver_jia@foxmail.com
# @Date      :   2020.5.8
# @License   :   Mulan PSL v2
# @Desc      :   Module operation
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh
function config_params() {
    LOG_INFO "Start to config params of the case."
    depmod
    raw=($(depmod -n | grep -v '[/#]'))
    len=${#raw[@]}
    for ((i=2;i<len;i+=3))
    do  
        mod=${raw[i]}
        cmd="modprobe "${raw[i]}
        res=$(eval $cmd)
        if [ $? -eq 0 ]; then break; fi
    done
    LOG_INFO "End to config params of the case."
}

function run_test() {
    LOG_INFO "Start executing testcase."
    modprobe -r $mod
    CHECK_RESULT $?
    modprobe $mod
    CHECK_RESULT $?
    lsmod | grep $mod
    CHECK_RESULT $?
    modprobe -r $mod
    lsmod | grep $mod
    CHECK_RESULT $? 1
    LOG_INFO "End of testcase execution."
}

function post_test() {
    LOG_INFO "start environment cleanup."
    modprobe $mod
    LOG_INFO "Finish environment cleanup."
}

main $@
