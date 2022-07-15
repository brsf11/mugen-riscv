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
# @Author    :   xuchunlin, wangpeng
# @Contact   :   xcl_job@163.com, wangpengb@uniontech.com
# @Date      :   2020-04-10
# @License   :   Mulan PSL v2
# @Desc      :   File system common command test-df
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."

    df | grep "Filesystem" | grep "Mounted on"
    CHECK_RESULT $? 0 0 "check df title fail"

    df -h | grep "Filesystem" | grep "Size" | grep "Mounted on"
    CHECK_RESULT $? 0 0 "check df -h title fail"

    df | grep 'G'
    CHECK_RESULT $? 1 0 "df default display error"

    df -h | grep -E 'G|M|K'
    CHECK_RESULT $? 0 0 "df -h didn't find G|M|K"

    df --help 2>&1 | grep "Usage"
    CHECK_RESULT $? 0 0 "check df helf fail"

    LOG_INFO "End to run test."
}

main $@
