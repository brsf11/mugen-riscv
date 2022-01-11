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
# @Author    :   xuchunlin
# @Contact   :   xcl_job@163.com
# @Date      :   2020-04-09 10:52:41
# @License   :   Mulan PSL v2
# @Desc      :   Query MEM configure test-lshw -c
# ############################################
source ${OET_PATH}/libs/locallibs/common_lib.sh
function run_test() {
    LOG_INFO "Start executing testcase!"
    if [[ "${NODE1_MACHINE}" =~ "kvm" ]]; then
        lshw -c memory | grep "bank" -A 5 | grep "size"
        CHECK_RESULT $?
        lshw -c memory | grep "bank" -A 5 | grep "description:"
        CHECK_RESULT $?
        lshw -c memory | grep "bank" -A 5 | grep "vendor"
        CHECK_RESULT $?
        lshw -c memory | grep -c "bank" | grep 1
        CHECK_RESULT $?
        lshw -c memory | grep bank -A 10 | grep -c "size" | grep 1
        CHECK_RESULT $?

    else
        lshw -c memory | grep "bank" -A 8 | grep "size"
        CHECK_RESULT $?
        lshw -c memory | grep "bank" -A 5 | grep "description:"
        CHECK_RESULT $?
        lshw -c memory
        CHECK_RESULT $?
        lshw -c memory | grep "bank" -A 5 | grep "vendor"
        CHECK_RESULT $?
        lshw -c memory | grep -c "bank" | grep 1
        CHECK_RESULT $?
        lshw -c memory | grep bank -A 10 | grep -c "size" | grep 1
        CHECK_RESULT $?
    fi
    LOG_INFO "End of testcase execution!"
}

main $@
