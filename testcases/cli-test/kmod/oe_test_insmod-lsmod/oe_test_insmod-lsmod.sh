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

function run_test() {
    LOG_INFO "Start to run test."
    insmod -h | grep -E "Usage:|insmod \[options\]"
    CHECK_RESULT $?
    insmod -V | grep "kmod version"
    CHECK_RESULT $?
    raid0Path=$(find /usr/lib/modules/ -name raid0.ko)
    faultyPath=$(find /usr/lib/modules/ -name faulty.ko)
    SLEEP_WAIT 5 "lsmod | grep raid0 && modprobe -r raid0" 2    
    CHECK_RESULT $?
    SLEEP_WAIT 5 "lsmod | grep faulty && modprobe -r faulty" 2
    CHECK_RESULT $?
    insmod -p $raid0Path
    CHECK_RESULT $?
    lsmod | grep raid0
    CHECK_RESULT $?
    insmod -p $faultyPath
    CHECK_RESULT $?
    lsmod | grep faulty
    CHECK_RESULT $?
    insmod $raid0Path
    CHECK_RESULT $? 1
    insmod $faultyPath
    CHECK_RESULT $? 1
    LOG_INFO "End of the test."
}

main "$@"
