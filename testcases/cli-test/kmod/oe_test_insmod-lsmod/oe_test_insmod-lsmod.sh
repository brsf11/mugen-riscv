#!/usr/bin/bash

# Copyright (c) 2021. Huawei Technologies Co.,Ltd.ALL rights reserved.
# This program is licensed under Mulan PSL v2.
# You can use it according to the terms and conditions of the Mulan PSL v2.
#          http://license.coscl.org.cn/MulanPSL2
# THIS PROGRAM IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
# EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
# MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
# See the Mulan PSL v2 for more details.

# #############################################
# @Author    :   liujuan
# @Contact   :   lchutian@163.com
# @Date      :   2020/10/29
# @License   :   Mulan PSL v2
# @Desc      :   verify the uasge of insmod and lsmod command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"
function config_params() {
    LOG_INFO "Start to config params of the case."
    depmod
    raw=($(depmod -n | grep -v '[/#]' | awk '{print$3}'))
    len=${#raw[@]}
    mod1='null'
    mod2='null'
    for ((i=1;i<len;i+=1))
    do  
        mod=${raw[i]}
        cmd="modprobe "${raw[i]}
        res=$(eval $cmd)
        if [ $? -eq 0 ]; then
            if [ $mod1 -eq 'null' ]; then
                mod1=$mod
            elif [ $mod2 -eq 'null' ]; then
                mod2=$mod
                break;
            else
                break;
            fi
            modprobe -r $mod
        fi
    done
    LOG_INFO "End to config params of the case."
}

function run_test() {
    LOG_INFO "Start to run test."
    insmod -h | grep -E "Usage:|insmod \[options\]"
    CHECK_RESULT $?
    insmod -V | grep "kmod version"
    CHECK_RESULT $?
    mod1Path=$(find /usr/lib/modules/ -name $mod1.ko)
    mod2Path=$(find /usr/lib/modules/ -name $mod2.ko)
    SLEEP_WAIT 5 "lsmod | grep raid0 && modprobe -r $mod1" 2    
    CHECK_RESULT $?
    SLEEP_WAIT 5 "lsmod | grep faulty && modprobe -r $mod2" 2
    CHECK_RESULT $?
    insmod -p $mod1Path
    CHECK_RESULT $?
    lsmod | grep $mod1
    CHECK_RESULT $?
    insmod -p $mod2Path
    CHECK_RESULT $?
    lsmod | grep $mod2
    CHECK_RESULT $?
    insmod $mod1Path
    CHECK_RESULT $? 1
    insmod $mod2Path
    CHECK_RESULT $? 1
    LOG_INFO "End of the test."
}

main "$@"
