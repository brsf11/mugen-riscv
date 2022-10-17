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
# @Author    :   doraemon2020
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-29
# @License   :   Mulan PSL v2
# @Desc      :   Query system version info test
# ############################################

source ${OET_PATH}/libs/locallibs/common_lib.sh

function run_test() {
    LOG_INFO "Start to run test."

    grep "NAME" /etc/os-release | grep "openEuler"
    CHECK_RESULT $? 0 0 "check os-release NAME openeuler fail"
    grep "NAME" /etc/os-release | grep "embedded" || \
    grep "NAME" /etc/os-release | grep "Embedded"
    CHECK_RESULT $? 0 0 "check os-release NAME embedded fail"
    grep -E "^ID" /etc/os-release | grep "openeuler"
    CHECK_RESULT $? 0 0 "check os-release ID fail"

    LOG_INFO "End to run test."
}

main "$@"
