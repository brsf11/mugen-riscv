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
# @Desc      :   verify the uasge of rmmod command
# ############################################

source "$OET_PATH/libs/locallibs/common_lib.sh"

function run_test() {
    LOG_INFO "Start to run test."
    rmmod --help | grep -E "Usage:|rmmod \[options\]"
    CHECK_RESULT $?
    rmmod --version | grep "kmod version"
    CHECK_RESULT $?
    modprobe -a dm_log dm_mirror
    CHECK_RESULT $?
    rmmod -f -v dm_mirror
    CHECK_RESULT $?
    lsmod | grep dm_mirror
    CHECK_RESULT $? 1
    lsmod | grep dm_log
    CHECK_RESULT $?
    rmmod -v dm_log
    CHECK_RESULT $? 1
    rmmod -s dm_log
    CHECK_RESULT $? 1
    rmmod -v dm_region_hash
    CHECK_RESULT $?
    rmmod -v -s dm_log
    CHECK_RESULT $?
    LOG_INFO "End of the test."
}

main $@
